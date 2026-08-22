import React, { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { RefreshCw, Trash2 } from "lucide-react";
import { onAuthStateChanged } from "firebase/auth";
import { doc, writeBatch } from "firebase/firestore";
import { useTranslation } from "../i18n";
import { auth, db, hasFirebaseConfig } from "../firebase";
import { useFirestoreQuery } from "../hooks/useFirestoreQuery";
import { listenNativeBackButton } from "../native";
import {
  cancelReminderNotification,
  ensureReminderChannel,
  playReminderSound,
  scheduleReminderNotification,
} from "../notifications";
import { ConfirmDialog } from "./components/ConfirmDialog";
import { ReminderModal, SortSheet } from "./components/NoteOverlays";
import {
  BottomNav,
  EmptyState,
  FabBtn,
  GridView,
  KeepSearchBar,
  LoadingState,
  NotesLoadError,
  NoteSyncError,
} from "./components/NotesView";
import { SettingsScreen } from "./components/SettingsScreen";
import { useTheme } from "./hooks/useTheme";
import {
  DEFAULT_THEME,
  NOTES_COLLECTION,
  NOTES_PAGE_SIZE,
  type AuthUser,
  type FirestoreNote,
  type Note,
  type Screen,
  type SortOrder,
  type Tab,
} from "./model";
import {
  deleteCurrentAccount,
  getUserProfile,
  logoutAccount as authLogout,
  setUserTheme,
} from "./services/accountService";
import {
  buildWelcomeNotes,
  isWelcomeNoteId,
  loadGuestNotes,
  markGuestNotesDirty,
  migrateGuestNotesToFirestore,
  saveGuestNotes,
} from "./services/guestNotes";
import {
  buildNotesQuery,
  createNoteDocumentId,
  deleteNoteFromFirestore,
  noteFromFirestore,
  patchNoteInFirestore,
  writeNoteToFirestore,
} from "./services/notesRepository";
import { G, THEMES, buildCSS, glassBase, type ThemeId } from "./theme";
import { newNoteId, stripHtml } from "./utils";

const EditorModal = React.lazy(() =>
  import("./components/EditorDialogs").then((module) => ({ default: module.EditorModal }))
);

function useWidth() {
  const [w, setW] = useState(typeof window !== "undefined" ? window.innerWidth : 1280);
  useEffect(() => {
    const h = () => setW(window.innerWidth);
    window.addEventListener("resize", h);
    return () => window.removeEventListener("resize", h);
  }, []);
  return w;
}

/* ════════════════════════════════════════════════════════════════════
   ROOT
   ════════════════════════════════════════════════════════════════════ */
export default function App() {
  const { t, language } = useTranslation();
  // Keep readiness and the account in one state update. Updating them
  // separately can briefly render the guest collection while Firebase is
  // restoring a signed-in session.
  const [authState, setAuthState] = useState<{ ready: boolean; user: AuthUser | null }>({
    ready: !hasFirebaseConfig || !auth,
    user: null,
  });
  const { ready: authReady, user: currentUser } = authState;
  const [themeId, setThemeId] = useTheme(currentUser, DEFAULT_THEME);
  const [screen, setScreen] = useState<Screen>("dashboard");
  const [tab, setTab] = useState<Tab>("all");
  const [editing, setEditing] = useState<Note | null>(null);
  const [creating, setCreating] = useState(false);
  const [search, setSearch] = useState("");
  const [reminderNoteId, setReminderNoteId] = useState<number | null>(null);
  const [sort, setSort] = useState<SortOrder>("default");
  const [showSort, setShowSort] = useState(false);
  const [now, setNow] = useState(Date.now());
  const [localNotes, setLocalNotes] = useState<Note[]>(() => loadGuestNotes() ?? []);
  // Intro cards for a brand-new guest (facts about GlassWave). Ephemeral: they
  // are shown instead of the empty state and vanish once a real note exists.
  const welcomeNotes = useMemo(() => buildWelcomeNotes(t), [t]);
  const [notesQueryVersion, setNotesQueryVersion] = useState(0);
  const [notesLimit, setNotesLimit] = useState(NOTES_PAGE_SIZE);
  const [noteSyncError, setNoteSyncError] = useState<string | null>(null);
  const [confirm, setConfirm] = useState<
    { type: "delete-note"; note: Note } | { type: "empty-trash" } | null
  >(null);
  const searchInputRef = useRef<HTMLInputElement>(null);
  const editorRequestCloseRef = useRef<(() => void) | null>(null);

  const width = useWidth();
  const isMobile = width < 768;
  const isTablet = width >= 768 && width < 1280;
  const theme = THEMES.find((th) => th.id === themeId)!;

  // Parallax for background orbs WITHOUT React state: a state update per
  // scroll frame used to re-render the whole note grid. Mutate transforms
  // directly instead and let the browser composite.
  const orbsRef = useRef<HTMLDivElement | null>(null);
  const handleNotesScroll = useCallback((e: React.UIEvent<HTMLDivElement>) => {
    const host = orbsRef.current;
    if (!host) return;
    const y = (e.target as HTMLDivElement).scrollTop;
    for (let i = 0; i < host.children.length; i++) {
      (host.children[i] as HTMLElement).style.transform =
        `translateY(${(y * (0.07 + i * 0.05)).toFixed(1)}px)`;
    }
  }, []);

  // Ticker every 60s for relative times
  useEffect(() => {
    const id = setInterval(() => setNow(Date.now()), 60000);
    return () => clearInterval(id);
  }, []);

  // Persist guest notes
  useEffect(() => {
    // Do not persist seed data while Firebase is still restoring a session.
    if (authReady && !currentUser) saveGuestNotes(localNotes);
  }, [authReady, localNotes, currentUser]);

  // Auth state is resolved before guest UI is exposed, preventing a flash of
  // demo notes and stale profile requests from crossing user sessions.
  useEffect(() => {
    if (!hasFirebaseConfig || !auth) return;
    let active = true;
    const authWatchdog = window.setTimeout(() => {
      if (!active) return;
      console.warn("Firebase Auth initialization timed out; continuing in guest mode.");
      setAuthState((previous) => ({ ...previous, ready: true }));
    }, 10_000);
    const unsub = onAuthStateChanged(auth, async (user) => {
      if (!active) return;
      window.clearTimeout(authWatchdog);
      if (!user) {
        setAuthState({ ready: true, user: null });
        setThemeId(DEFAULT_THEME);
        setNotesLimit(NOTES_PAGE_SIZE);
        return;
      }
      const uid = user.uid;
      const next = { uid, email: user.email ?? "", name: user.displayName ?? "" };
      // Auth can emit again when its token refreshes. Retain the user object
      // for the same account so the memoized Firestore query is not torn down
      // and recreated on every token refresh.
      setAuthState((previous) => ({
        ready: true,
        user:
          previous.user?.uid === uid &&
          previous.user.email === next.email &&
          previous.user.name === next.name
            ? previous.user
            : next,
      }));
      setNotesLimit(NOTES_PAGE_SIZE);
      void migrateGuestNotesToFirestore(uid);
      try {
        const profile = await getUserProfile(uid);
        if (active && auth?.currentUser?.uid === uid) {
          setThemeId(profile?.themeId ?? DEFAULT_THEME);
        }
      } catch (error) {
        if (active && auth?.currentUser?.uid === uid) setThemeId(DEFAULT_THEME);
        console.warn("Could not load user profile.", error);
      }
    });
    return () => {
      active = false;
      window.clearTimeout(authWatchdog);
      unsub();
    };
  }, [setThemeId]);

  const notesQuery = useMemo(() => {
    // The retry token intentionally creates a fresh Firestore Query instance.
    void notesQueryVersion;
    return currentUser ? buildNotesQuery(currentUser.uid, notesLimit) : null;
  }, [currentUser, notesQueryVersion, notesLimit]);

  const {
    data: firestoreData,
    loading: notesLoading,
    error: notesError,
  } = useFirestoreQuery<FirestoreNote>(notesQuery);

  const allNotes: Note[] = useMemo(() => {
    // A guest with no notes of their own sees the intro cards instead of an
    // empty dashboard. As soon as a real note exists, only real notes show.
    if (!currentUser) return localNotes.length === 0 ? welcomeNotes : localNotes;
    if (!firestoreData) return [];
    const list = Array.isArray(firestoreData) ? firestoreData : [];
    // The Firestore request deliberately has no `orderBy` (see
    // buildNotesQuery), so preserve the previous newest-updated-first UX here.
    return list
      .map((n) => noteFromFirestore(n as FirestoreNote & { firestoreId: string }))
      .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime() || b.id - a.id);
  }, [currentUser, firestoreData, localNotes, welcomeNotes]);

  // When the current page is "full", there may be more notes to load.
  const hasMoreNotes = Boolean(
    currentUser && Array.isArray(firestoreData) && firestoreData.length >= notesLimit
  );

  // Keeps callbacks referentially stable (so memoized cards don't re-render)
  // while always reading the freshest notes list.
  const allNotesRef = useRef(allNotes);
  allNotesRef.current = allNotes;

  const filtered = useMemo(() => {
    const src = allNotes
      .filter((n) => {
        if (tab === "all") return !n.archived && !n.trashed;
        if (tab === "archive") return n.archived && !n.trashed;
        return n.trashed;
      })
      .filter((n) => {
        if (!search) return true;
        const s = search.toLowerCase();
        return n.title.toLowerCase().includes(s) || stripHtml(n.body).toLowerCase().includes(s);
      });
    const sorted = [...src];
    if (sort === "created")
      sorted.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime() || b.id - a.id);
    else if (sort === "updated")
      sorted.sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime());
    return sorted;
  }, [allNotes, tab, search, sort]);

  const { pinned, unpinned } = useMemo(
    () => ({
      pinned: filtered.filter((n) => n.pinned),
      unpinned: filtered.filter((n) => !n.pinned),
    }),
    [filtered]
  );
  const cols = isMobile ? 1 : isTablet ? 2 : 3;
  const editorOpen = creating || editing !== null;

  const updateTheme = useCallback(
    (id: ThemeId) => {
      setThemeId(id);
      if (currentUser) {
        setUserTheme(currentUser.uid, id).catch((e) =>
          console.warn("Could not save theme pref.", e)
        );
      }
    },
    [currentUser, setThemeId]
  );

  /* ─────────────────── Reminder notifications (best-effort) ────────────
     When the tab/app is open we poll notes every 30s and fire a browser
     Notification (or in-app toast fallback) for any reminder whose time has
     arrived but that we haven't shown yet. We also ask for Notification
     permission once a reminder is first scheduled. */
  const firedRef = useRef<Set<string>>(new Set());
  useEffect(() => {
    if (!("Notification" in window)) return;
    if (Notification.permission === "default") {
      // Don't annoy on first open — ask lazily when user sets a reminder.
    }
  }, []);
  // Register the Android notification channel (with the notification sound) once at
  // startup. No-op on web; harmless to run again when the language changes.
  useEffect(() => {
    void ensureReminderChannel(t.reminder);
  }, [t.reminder]);
  useEffect(() => {
    const tick = () => {
      const nowMs = Date.now();
      allNotes.forEach((n) => {
        if (!n.reminder) return;
        const key = `${n.firestoreId || `local-${n.id}`}-${n.reminder.toISOString()}`;
        if (firedRef.current.has(key)) return;
        const diff = n.reminder.getTime() - nowMs;
        if (diff <= 0 && diff > -60 * 60 * 1000 /* within last hour */) {
          firedRef.current.add(key);
          const title = n.title || t.untitled;
          const body = stripHtml(n.body).slice(0, 140);
          // Browsers can't attach a custom sound to a Notification, so play the
          // GlassWave notification sound in-app as well whenever a reminder comes due.
          playReminderSound();
          if ("Notification" in window && Notification.permission === "granted") {
            try {
              new Notification(title, { body, icon: "/favicon.png" });
            } catch {}
          }
          console.log("[Reminder]", title, body);
        }
      });
    };
    const id = setInterval(tick, 30_000);
    tick();
    return () => clearInterval(id);
  }, [allNotes, t]);

  // Draft text lives inside EditorModal — typing there must NOT re-render App.
  const openEdit = useCallback((n: Note) => {
    setEditing(n);
    setCreating(false);
  }, []);
  const openNew = useCallback(() => {
    setEditing(null);
    setCreating(true);
  }, []);
  const closeEd = useCallback(() => {
    setEditing(null);
    setCreating(false);
  }, []);

  /**
   * Firestore immediately applies writes to its persistent local cache, but the
   * returned promise settles only after the backend acknowledges it. Waiting
   * for that acknowledgement leaves the editor open indefinitely offline even
   * though the note is safely queued for sync. Queue the write instead; its
   * local snapshot updates the list right away and a rejected write is shown.
   */
  const enqueueNoteWrite = useCallback(
    (write: Promise<unknown>) => {
      setNoteSyncError(null);
      void write.catch((error) => {
        console.error("Could not synchronize note.", error);
        setNoteSyncError(t.noteSyncError);
      });
    },
    [t]
  );

  /**
   * Persist a note (create or update) WITHOUT closing the editor. Returns the
   * persisted Note so callers can track a newly-created note. Both `save` and
   * `autosave` funnel through here, keeping writes idempotent.
   */
  const persistNote = useCallback(
    (title: string, body: string): Note | null => {
      if (!title.trim() && !body.trim()) return null;
      setNoteSyncError(null);
      const noteTitle = title.trim() ? title : t.untitled;
      if (!currentUser) {
        // Editing a welcome/demo card (reserved negative id) behaves like
        // creating a note: the demo content is a starting point, not a real
        // note, and the intro cards vanish once a real note exists.
        const editingWelcome = editing !== null && isWelcomeNoteId(editing.id);
        // Only a real change makes guest notes migration-worthy.
        if (!editing || editingWelcome || editing.title !== noteTitle || editing.body !== body) {
          markGuestNotesDirty();
        }
        const nowDate = new Date();
        if (editing && !editingWelcome) {
          const updated: Note = { ...editing, title: noteTitle, body, updatedAt: nowDate };
          setLocalNotes((prev) => prev.map((n) => (n.id === editing.id ? updated : n)));
          return updated;
        }
        const created: Note = {
          id: newNoteId(),
          title: noteTitle,
          body,
          updatedAt: nowDate,
          createdAt: nowDate,
          // Keep the accent of the demo card this note was started from.
          accentIdx: editing ? editing.accentIdx : Math.floor(Math.random() * theme.accents.length),
          pinned: false,
          archived: false,
          trashed: false,
          reminder: null,
        };
        setLocalNotes((prev) => [created, ...prev]);
        return created;
      }
      const nowDate = new Date();
      const payload: Note = {
        // Allocate once, before the asynchronous write. Editor state retains this
        // id, so every debounced autosave targets the same Firestore document.
        firestoreId: editing?.firestoreId ?? createNoteDocumentId(),
        id: editing?.id ?? newNoteId(),
        title: noteTitle,
        body: body,
        updatedAt: nowDate,
        createdAt: editing?.createdAt ?? nowDate,
        accentIdx: editing?.accentIdx ?? Math.floor(Math.random() * theme.accents.length),
        pinned: editing?.pinned ?? false,
        archived: editing?.archived ?? false,
        trashed: editing?.trashed ?? false,
        reminder: editing?.reminder ?? null,
      };
      enqueueNoteWrite(writeNoteToFirestore(payload, currentUser.uid));
      return payload;
    },
    [currentUser, editing, t, theme.accents.length, enqueueNoteWrite]
  );

  const save = useCallback(
    (title: string, body: string) => {
      persistNote(title, body);
      closeEd();
    },
    [persistNote, closeEd]
  );

  /**
   * Autosave a draft without closing the editor. For an existing note this
   * updates it in place. For a brand-new note, the first autosave creates it
   * and switches the editor into "edit" mode so subsequent autosaves update the
   * same note instead of creating duplicates.
   */
  const autosave = useCallback(
    (title: string, body: string) => {
      if (!title.trim() && !body.trim()) return;
      const persisted = persistNote(title, body);
      if (persisted) {
        // Advance the editor's persisted baseline after every autosave. This both
        // retains a new document id and avoids a false unsaved-changes warning.
        setEditing(persisted);
        setCreating(false);
      }
    },
    [persistNote]
  );

  const mutNote = useCallback(
    (id: number, patch: Partial<Note>) => {
      if (!currentUser) {
        markGuestNotesDirty();
        setNoteSyncError(null);
        setLocalNotes((prev) =>
          prev.map((n) => (n.id === id ? { ...n, ...patch, updatedAt: new Date() } : n))
        );
        return;
      }
      const note = allNotesRef.current.find((n) => n.id === id);
      if (!note) return;
      enqueueNoteWrite(patchNoteInFirestore(note, patch, currentUser.uid));
    },
    [currentUser, enqueueNoteWrite]
  );

  const handlePinNote = useCallback((n: Note) => mutNote(n.id, { pinned: !n.pinned }), [mutNote]);
  const handleArchiveNote = useCallback(
    (n: Note) => mutNote(n.id, { archived: !n.archived }),
    [mutNote]
  );
  const handleReminderNote = useCallback((n: Note) => setReminderNoteId(n.id), []);
  const openSettings = useCallback(() => setScreen("settings"), []);
  const openSortSheet = useCallback(() => setShowSort(true), []);

  const restoreNote = useCallback(
    (note: Note) => {
      mutNote(note.id, { trashed: false });
    },
    [mutNote]
  );

  const moveToTrash = useCallback(
    (note: Note) => {
      mutNote(note.id, { trashed: true, archived: false });
    },
    [mutNote]
  );

  const deleteNoteForever = useCallback(
    (note: Note) => {
      if (!currentUser) {
        markGuestNotesDirty();
        setNoteSyncError(null);
        setLocalNotes((prev) => prev.filter((n) => n.id !== note.id));
        return;
      }
      if (!note.firestoreId) return;
      enqueueNoteWrite(deleteNoteFromFirestore(note));
    },
    [currentUser, enqueueNoteWrite]
  );

  const emptyTrash = useCallback(() => {
    const trashed = allNotesRef.current.filter((n) => n.trashed);
    if (!trashed.length) return;
    if (!currentUser) {
      markGuestNotesDirty();
      setNoteSyncError(null);
      setLocalNotes((prev) => prev.filter((n) => !n.trashed));
      return;
    }
    if (!db) return;
    enqueueNoteWrite(
      (async () => {
        for (let start = 0; start < trashed.length; start += 450) {
          const batch = writeBatch(db!);
          trashed.slice(start, start + 450).forEach((n) => {
            if (n.firestoreId) batch.delete(doc(db!, NOTES_COLLECTION, n.firestoreId));
          });
          await batch.commit();
        }
      })()
    );
  }, [currentUser, enqueueNoteWrite]);

  useEffect(() => {
    const h = (e: KeyboardEvent) => {
      if (!(e.metaKey || e.ctrlKey)) return;
      const k = e.key.toLowerCase();
      if (k === "n") {
        if (editorOpen || screen !== "dashboard") return;
        e.preventDefault();
        openNew();
      }
      if (k === "f") {
        if (editorOpen || screen !== "dashboard") return;
        e.preventDefault();
        searchInputRef.current?.focus();
        searchInputRef.current?.select();
      }
    };
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, [editorOpen, screen, openNew]);

  useEffect(() => {
    return listenNativeBackButton(() => {
      if (confirm) {
        setConfirm(null);
        return true;
      }
      if (editorOpen) {
        if (editorRequestCloseRef.current) editorRequestCloseRef.current();
        else closeEd();
        return true;
      }
      if (showSort) {
        setShowSort(false);
        return true;
      }
      if (reminderNoteId !== null) {
        setReminderNoteId(null);
        return true;
      }
      if (screen === "settings") {
        setScreen("dashboard");
        return true;
      }
      return false;
    });
  }, [editorOpen, showSort, reminderNoteId, screen, closeEd, confirm]);

  const handleLogout = () => {
    authLogout().catch(() => {});
    setAuthState({ ready: true, user: null });
  };

  const handleDeleteAccount = async (password: string): Promise<string | null> => {
    const err = await deleteCurrentAccount(password, t);
    if (!err) {
      setAuthState({ ready: true, user: null });
      setThemeId(DEFAULT_THEME);
      setScreen("dashboard");
      setEditing(null);
      setCreating(false);
    }
    return err;
  };

  if (!authReady) {
    return (
      <main className="app-loading" role="status" aria-live="polite">
        {t.loading}
      </main>
    );
  }

  return (
    <div
      style={{
        fontFamily: "'Manrope','Inter',sans-serif",
        background: theme.bg,
        minHeight: "100vh",
        position: "relative",
        overflow: "hidden",
        fontSize: "1rem",
      }}
    >
      <style>{buildCSS()}</style>

      <div
        ref={orbsRef}
        style={{ position: "absolute", inset: 0, pointerEvents: "none", overflow: "hidden" }}
      >
        {theme.orbs.map((o, i) => (
          <div
            key={i}
            style={{
              position: "absolute",
              top: o.top,
              left: o.left,
              width: o.size,
              height: o.size,
              borderRadius: "50%",
              background: `radial-gradient(circle,${o.color} 0%,transparent 68%)`,
              filter: "blur(2px)",
              willChange: "transform",
            }}
          />
        ))}
      </div>

      <div
        style={{
          position: "relative",
          zIndex: 10,
          maxWidth: isMobile ? "100%" : isTablet ? 920 : 1220,
          margin: "0 auto",
          height: "100vh",
        }}
      >
        {screen === "settings" ? (
          <div
            style={{
              position: "absolute",
              inset: 0,
              overflowY: "auto",
              padding: isMobile ? "0 16px" : isTablet ? "0 28px" : "0 44px",
            }}
          >
            <SettingsScreen
              themeId={themeId}
              setThemeId={updateTheme}
              onBack={() => setScreen("dashboard")}
              currentUser={currentUser}
              onLogout={handleLogout}
              onDeleteAccount={handleDeleteAccount}
              language={language}
            />
          </div>
        ) : (
          <>
            <div
              style={{
                position: "absolute",
                top: 0,
                left: 0,
                right: 0,
                zIndex: 30,
                padding: isMobile ? "0 16px" : isTablet ? "0 28px" : "0 44px",
                maxWidth: isMobile ? "100%" : isTablet ? 920 : 1220,
                margin: "0 auto",
                width: "100%",
              }}
            >
              <KeepSearchBar
                search={search}
                setSearch={setSearch}
                inputRef={searchInputRef}
                sortActive={sort !== "default"}
                onSort={openSortSheet}
                onSettings={openSettings}
              />
            </div>
            <div
              className="scroll-host"
              style={{
                position: "absolute",
                inset: 0,
                overflowY: "auto",
                paddingTop: `calc(92px + var(--safe-area-inset-top, env(safe-area-inset-top, 0px)))`,
                paddingBottom: `calc(150px + var(--safe-area-inset-bottom, env(safe-area-inset-bottom, 0px)))`,
                paddingLeft: isMobile ? 24 : isTablet ? 36 : 52,
                paddingRight: isMobile ? 24 : isTablet ? 36 : 52,
              }}
              onScroll={handleNotesScroll}
            >
              {currentUser && notesError && firestoreData === null ? (
                <NotesLoadError onRetry={() => setNotesQueryVersion((v) => v + 1)} t={t} />
              ) : currentUser && notesLoading && firestoreData === null ? (
                <LoadingState t={t} />
              ) : filtered.length === 0 ? (
                <EmptyState tab={tab} search={search} t={t} onCreate={openNew} />
              ) : (
                <>
                  {tab === "trash" && (
                    <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 12 }}>
                      <button
                        type="button"
                        onClick={() => setConfirm({ type: "empty-trash" })}
                        style={{
                          ...glassBase(12),
                          display: "inline-flex",
                          alignItems: "center",
                          gap: 7,
                          padding: "8px 12px",
                          borderRadius: 11,
                          cursor: "pointer",
                          fontFamily: "inherit",
                          color: "rgba(255,170,170,0.95)",
                          fontSize: "0.76rem",
                          fontWeight: 600,
                          border: "1px solid rgba(255,120,120,0.32)",
                          background: "rgba(145,20,35,0.18)",
                        }}
                      >
                        <Trash2 size={13} />
                        {t.emptyTrash}
                      </button>
                    </div>
                  )}
                  <GridView
                    pinned={pinned}
                    unpinned={unpinned}
                    cols={cols}
                    theme={theme}
                    isMobile={isMobile}
                    isTablet={isTablet}
                    tab={tab}
                    onOpen={openEdit}
                    onPin={handlePinNote}
                    onArchive={handleArchiveNote}
                    onRestore={restoreNote}
                    onTrash={moveToTrash}
                    onDeleteForever={(n) => setConfirm({ type: "delete-note", note: n })}
                    onReminder={handleReminderNote}
                    now={now}
                    language={language}
                    t={t}
                  />
                  {hasMoreNotes && (
                    <div
                      style={{
                        display: "flex",
                        justifyContent: "center",
                        marginTop: 20,
                        paddingBottom: 8,
                      }}
                    >
                      <button
                        type="button"
                        onClick={() => setNotesLimit((l) => l + NOTES_PAGE_SIZE)}
                        style={{
                          ...glassBase(12),
                          display: "inline-flex",
                          alignItems: "center",
                          gap: 7,
                          padding: "9px 16px",
                          borderRadius: 11,
                          cursor: "pointer",
                          fontFamily: "inherit",
                          color: G.textPrimary,
                          fontSize: "0.78rem",
                          fontWeight: 600,
                        }}
                      >
                        <RefreshCw size={14} />
                        {t.loadMore}
                      </button>
                    </div>
                  )}
                </>
              )}
            </div>
            <BottomNav tab={tab} setTab={setTab} isMobile={isMobile} t={t} />
          </>
        )}
      </div>

      {screen === "dashboard" && <FabBtn onClick={openNew} isMobile={isMobile} t={t} />}

      {showSort && (
        <SortSheet
          current={sort}
          onSelect={(o) => {
            setSort(o);
            setShowSort(false);
          }}
          onClose={() => setShowSort(false)}
          t={t}
        />
      )}

      {reminderNoteId !== null &&
        (() => {
          const n = allNotes.find((x) => x.id === reminderNoteId);
          if (!n) return null;
          return (
            <ReminderModal
              note={n}
              onSave={(d) => {
                mutNote(n.id, { reminder: d });
                const key = `${n.firestoreId || `local-${n.id}`}`;
                if (d) {
                  scheduleReminderNotification(
                    key,
                    n.title || t.untitled,
                    stripHtml(n.body).slice(0, 140),
                    d
                  );
                } else {
                  cancelReminderNotification(key);
                }
                setReminderNoteId(null);
              }}
              onClose={() => setReminderNoteId(null)}
              language={language}
              t={t}
            />
          );
        })()}

      {editorOpen && (
        <React.Suspense
          fallback={
            <div className="app-loading" role="status">
              {t.loading}
            </div>
          }
        >
          <EditorModal
            creating={creating}
            initialTitle={editing?.title ?? ""}
            initialBody={editing?.body ?? ""}
            onClose={closeEd}
            onSave={save}
            onAutosave={autosave}
            requestCloseRef={editorRequestCloseRef}
            isMobile={isMobile}
            isTablet={isTablet}
            language={language}
            t={t}
          />
        </React.Suspense>
      )}

      {confirm && (
        <ConfirmDialog
          title={
            confirm.type === "empty-trash" ? t.emptyTrashConfirmTitle : t.confirmDeleteNoteTitle
          }
          body={confirm.type === "empty-trash" ? t.emptyTrashConfirmBody : t.confirmDeleteNoteBody}
          confirmLabel={confirm.type === "empty-trash" ? t.emptyTrash : t.deleteForeverAction}
          cancelLabel={t.cancel}
          onCancel={() => setConfirm(null)}
          onConfirm={() => {
            if (confirm.type === "empty-trash") emptyTrash();
            else deleteNoteForever(confirm.note);
            setConfirm(null);
          }}
        />
      )}

      {noteSyncError && (
        <NoteSyncError
          message={noteSyncError}
          closeLabel={t.close}
          onDismiss={() => setNoteSyncError(null)}
        />
      )}
    </div>
  );
}
