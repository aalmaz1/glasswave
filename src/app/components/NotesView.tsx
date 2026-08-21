import React from "react";
import type { ReactNode } from "react";
import {
  Archive,
  Bell,
  BellRing,
  Clock,
  FileText,
  Pin,
  PinOff,
  Plus,
  RefreshCw,
  RotateCcw,
  Settings,
  SlidersHorizontal,
  Trash2,
  X,
} from "lucide-react";
import { useTranslation, type Language, type Translation } from "../../i18n";
import { fmtDate, stripHtml } from "../utils";
import { G, glassBase, type Theme } from "../theme";
import { isWelcomeNoteId } from "../services/guestNotes";
import type { Note, Tab } from "../model";

/* ════════════════════════════════════════════════════════════════════
   SEARCH BAR
   ════════════════════════════════════════════════════════════════════ */
export const KeepSearchBar = React.memo(function KeepSearchBar({
  search,
  setSearch,
  inputRef,
  sortActive,
  onSort,
  onSettings,
}: {
  search: string;
  setSearch: (v: string) => void;
  inputRef: React.Ref<HTMLInputElement>;
  sortActive: boolean;
  onSort: () => void;
  onSettings: () => void;
}) {
  const { t } = useTranslation();
  return (
    <div
      style={{
        paddingTop: "calc(20px + var(--safe-area-inset-top, env(safe-area-inset-top, 0px)))",
        paddingBottom: 24,
        background: "linear-gradient(to bottom, rgba(0,0,0,0.38) 60%, transparent 100%)",
      }}
    >
      <div
        className="search-bar"
        style={{
          ...glassBase(20),
          borderRadius: 50,
          display: "flex",
          alignItems: "center",
          gap: 4,
          padding: "0 12px 0 16px",
          height: 52,
          transition: "border-color 0.2s,box-shadow 0.2s",
        }}
      >
        <input
          ref={inputRef}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder={t.searchPlaceholder}
          aria-label={t.search}
          style={{
            flex: 1,
            background: "transparent",
            border: "none",
            outline: "none",
            fontSize: "0.95rem",
            color: G.textPrimary,
            fontFamily: "inherit",
            letterSpacing: "0.01em",
          }}
        />
        {search && (
          <button
            onClick={() => setSearch("")}
            aria-label={t.close}
            style={{
              background: "none",
              border: "none",
              cursor: "pointer",
              lineHeight: 0,
              padding: 6,
            }}
          >
            <X size={16} color={G.textMuted} />
          </button>
        )}
        <button
          className="icon-btn"
          onClick={onSort}
          aria-label={t.sort}
          title={t.sort}
          style={{
            position: "relative",
            background: sortActive ? "rgba(255,200,60,0.12)" : "transparent",
            borderRadius: 50,
            outline: sortActive ? "1px solid rgba(255,200,60,0.30)" : "none",
          }}
        >
          <SlidersHorizontal
            size={17}
            color={sortActive ? "rgba(255,210,70,0.90)" : G.textSecondary}
          />
          {sortActive && (
            <span
              style={{
                position: "absolute",
                top: 4,
                right: 4,
                width: 6,
                height: 6,
                borderRadius: "50%",
                background: "rgba(255,200,60,0.90)",
              }}
            />
          )}
        </button>
        <button
          className="icon-btn"
          onClick={onSettings}
          aria-label={t.settings}
          title={t.settings}
        >
          <Settings size={18} color={G.textSecondary} />
        </button>
      </div>
    </div>
  );
});

/* ════════════════════════════════════════════════════════════════════
   GRID
   ════════════════════════════════════════════════════════════════════ */
type ViewProps = {
  pinned: Note[];
  unpinned: Note[];
  cols: number;
  theme: Theme;
  isMobile: boolean;
  isTablet: boolean;
  tab: Tab;
  onOpen: (n: Note) => void;
  onPin: (n: Note) => void;
  onArchive: (n: Note) => void;
  onRestore: (n: Note) => void;
  onTrash: (n: Note) => void;
  onDeleteForever: (n: Note) => void;
  onReminder: (n: Note) => void;
  now: number;
  language: Language;
  t: Translation;
};

export const GridView = React.memo(function GridView(p: ViewProps) {
  const g = (items: Note[]) => (
    <div
      style={{
        display: "grid",
        gridTemplateColumns: `repeat(${p.cols},1fr)`,
        gap: p.isMobile ? 14 : 18,
      }}
    >
      {items.map((n) => (
        <NoteCard key={n.id} note={n} {...p} />
      ))}
    </div>
  );
  return (
    <div style={{ paddingTop: 4 }}>
      {p.pinned.length > 0 && (
        <>
          <p className="section-label">{p.t.pinnedSection}</p>
          {g(p.pinned)}
          <p className="section-label" style={{ marginTop: 24 }}>
            {p.t.othersSection}
          </p>
        </>
      )}
      {g(p.unpinned)}
    </div>
  );
});

// Memoized: card state updates (draft typing, timers, etc.) must not re-render
// every card — notes are referentially stable between Firestore snapshots.
const NoteCard = React.memo(function NoteCard({
  note,
  theme,
  isMobile,
  isTablet,
  tab,
  onOpen,
  onPin,
  onArchive,
  onRestore,
  onTrash,
  onDeleteForever,
  onReminder,
  now,
  language,
  t,
}: ViewProps & { note: Note }) {
  const accent = theme.accents[note.accentIdx % theme.accents.length];
  const minH = isMobile ? 130 : isTablet ? 140 : 160;
  const pad = isMobile ? "14px 16px 12px" : "18px 20px 14px";
  const hasReminder = !!note.reminder;
  // Welcome/demo cards are read-only samples: tap to open, but no pin/archive
  // actions — they aren't real notes yet.
  const isDemo = isWelcomeNoteId(note.id);

  return (
    <article
      className="card"
      role="button"
      tabIndex={0}
      aria-labelledby={`card-title-${note.id}`}
      onClick={() => onOpen(note)}
      onKeyDown={(e) => {
        // Only the card itself acts as a button — Enter/Space pressed on inner
        // controls (pin, reminder, delete, archive) must not open the note.
        if (e.target !== e.currentTarget) return;
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          onOpen(note);
        }
      }}
    >
      <div className="card-glass" style={{ minHeight: minH }}>
        <div className="glass-ring" />
        <div className="glass-sheen" />
        <div
          className="card-accent"
          style={{ background: `linear-gradient(145deg,${accent} 0%,rgba(255,255,255,0.01) 70%)` }}
        />
        <div
          style={{
            position: "relative",
            zIndex: 20,
            padding: pad,
            minHeight: minH,
            display: "flex",
            flexDirection: "column",
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "flex-start",
              justifyContent: "space-between",
              gap: 8,
              marginBottom: 8,
            }}
          >
            <h3
              id={`card-title-${note.id}`}
              style={{
                margin: 0,
                fontWeight: 700,
                fontSize: isMobile ? "0.90rem" : isTablet ? "0.96rem" : "1.06rem",
                lineHeight: 1.3,
                color: G.textPrimary,
                letterSpacing: "-0.02em",
                flex: 1,
              }}
            >
              {note.title || t.untitled}
            </h3>
            {isDemo ? (
              note.pinned ? (
                <span
                  style={{ padding: 4, flexShrink: 0, lineHeight: 0 }}
                  aria-hidden="true"
                  title={t.pin}
                >
                  <Pin size={14} color="rgba(255,255,255,0.70)" strokeWidth={1.8} />
                </span>
              ) : null
            ) : (
              <button
                className={`card-pin${note.pinned ? " pinned" : ""}`}
                onClick={(e) => {
                  e.stopPropagation();
                  onPin(note);
                }}
                title={note.pinned ? t.unpin : t.pin}
                aria-label={note.pinned ? t.unpinNote : t.pinNote}
                style={{
                  background: "none",
                  border: "none",
                  cursor: "pointer",
                  padding: 4,
                  flexShrink: 0,
                  lineHeight: 0,
                }}
              >
                {note.pinned ? (
                  <PinOff size={14} color="rgba(255,255,255,0.70)" strokeWidth={1.8} />
                ) : (
                  <Pin size={14} color={G.textSecondary} strokeWidth={1.8} />
                )}
              </button>
            )}
          </div>

          <p
            style={{
              margin: "0 0 auto",
              fontSize: isMobile ? "0.76rem" : isTablet ? "0.80rem" : "0.84rem",
              color: G.textSecondary,
              lineHeight: 1.65,
              fontWeight: 400,
              whiteSpace: "pre-line",
              display: "-webkit-box",
              WebkitLineClamp: 3,
              WebkitBoxOrient: "vertical",
              overflow: "hidden",
              paddingBottom: 12,
            }}
          >
            {stripHtml(note.body)}
          </p>

          {hasReminder && note.reminder && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                onReminder(note);
              }}
              aria-label={t.reminder}
              style={{
                alignSelf: "flex-start",
                display: "flex",
                alignItems: "center",
                gap: 5,
                background: "rgba(255,200,60,0.12)",
                border: "1px solid rgba(255,200,60,0.28)",
                borderRadius: 8,
                padding: "3px 8px 3px 6px",
                marginBottom: 8,
                cursor: "pointer",
                color: "rgba(255,210,80,0.90)",
                fontSize: "0.68rem",
                fontWeight: 600,
                fontFamily: "inherit",
                transition: "background 0.18s",
              }}
              onMouseEnter={(e) =>
                ((e.currentTarget as HTMLElement).style.background = "rgba(255,200,60,0.20)")
              }
              onMouseLeave={(e) =>
                ((e.currentTarget as HTMLElement).style.background = "rgba(255,200,60,0.12)")
              }
            >
              <BellRing size={10} strokeWidth={2} />
              {note.reminder.toLocaleString(language, t.dateFormatShort as any)}
            </button>
          )}

          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              marginTop: "auto",
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 4,
                color: G.textMuted,
                fontSize: "0.68rem",
              }}
            >
              <Clock size={9} strokeWidth={1.8} />
              <span>{fmtDate(note.updatedAt, t.localeTag, t, now)}</span>
            </div>
            {!isDemo && (
              <div
                className={`card-actions${isMobile ? " actions-always" : ""}`}
                style={{ display: "flex", gap: 4 }}
                onClick={(e) => e.stopPropagation()}
              >
                {tab === "trash" ? (
                  <>
                    <MiniAction onClick={() => onRestore(note)} title={t.restore}>
                      <RotateCcw size={11} color={G.textSecondary} strokeWidth={1.8} />
                    </MiniAction>
                    <MiniAction onClick={() => onDeleteForever(note)} title={t.deleteForeverAction}>
                      <Trash2 size={11} color="rgba(255,140,140,0.90)" strokeWidth={1.8} />
                    </MiniAction>
                  </>
                ) : (
                  <>
                    <MiniAction onClick={() => onReminder(note)} title={t.reminder}>
                      <Bell
                        size={11}
                        color={hasReminder ? "rgba(255,200,60,0.80)" : G.textSecondary}
                        strokeWidth={1.8}
                      />
                    </MiniAction>
                    <MiniAction
                      onClick={() => onArchive(note)}
                      title={note.archived ? t.unarchive : t.archive}
                    >
                      <Archive size={11} color={G.textSecondary} strokeWidth={1.8} />
                    </MiniAction>
                    <MiniAction onClick={() => onTrash(note)} title={t.delete}>
                      <Trash2 size={11} color={G.textSecondary} strokeWidth={1.8} />
                    </MiniAction>
                  </>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </article>
  );
});

function MiniAction({
  children,
  onClick,
  title,
}: {
  children: ReactNode;
  onClick: () => void;
  title: string;
}) {
  return (
    <button
      onClick={onClick}
      title={title}
      aria-label={title}
      style={{
        ...glassBase(10),
        width: 26,
        height: 26,
        borderRadius: 8,
        border: "none",
        cursor: "pointer",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      {children}
    </button>
  );
}

/* ════════════════════════════════════════════════════════════════════
   FIRESTORE FEEDBACK
   ════════════════════════════════════════════════════════════════════ */
export function NoteSyncError({
  message,
  closeLabel,
  onDismiss,
}: {
  message: string;
  closeLabel: string;
  onDismiss: () => void;
}) {
  return (
    <div
      role="alert"
      aria-live="assertive"
      style={{
        position: "fixed",
        zIndex: 70,
        top: "calc(86px + env(safe-area-inset-top, 0px))",
        left: "50%",
        transform: "translateX(-50%)",
        width: "min(460px, calc(100% - 32px))",
        ...glassBase(20),
        display: "flex",
        alignItems: "center",
        gap: 10,
        padding: "11px 12px 11px 14px",
        border: "1px solid rgba(255,130,130,0.42)",
        background: "rgba(100,22,30,0.78)",
      }}
    >
      <X size={16} color="rgba(255,205,205,0.95)" aria-hidden="true" />
      <span
        style={{ flex: 1, color: "rgba(255,235,235,0.98)", fontSize: "0.77rem", lineHeight: 1.45 }}
      >
        {message}
      </span>
      <button
        type="button"
        onClick={onDismiss}
        aria-label={closeLabel}
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          width: 28,
          height: 28,
          border: "none",
          borderRadius: 8,
          cursor: "pointer",
          color: G.textPrimary,
          background: "rgba(255,255,255,0.10)",
        }}
      >
        <X size={14} />
      </button>
    </div>
  );
}

export function NotesLoadError({ onRetry, t }: { onRetry: () => void; t: Translation }) {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        height: 260,
        gap: 14,
        textAlign: "center",
      }}
    >
      <div
        style={{
          ...glassBase(16),
          width: 52,
          height: 52,
          borderRadius: 14,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <FileText size={22} color="rgba(255,170,170,0.78)" />
      </div>
      <p
        style={{
          maxWidth: 360,
          color: G.textSecondary,
          fontSize: "0.84rem",
          lineHeight: 1.5,
          margin: 0,
        }}
      >
        {t.notesLoadError}
      </p>
      <button
        type="button"
        onClick={onRetry}
        style={{
          ...glassBase(14),
          display: "inline-flex",
          alignItems: "center",
          gap: 7,
          padding: "9px 14px",
          borderRadius: 11,
          cursor: "pointer",
          fontFamily: "inherit",
          color: G.textPrimary,
          fontSize: "0.78rem",
          fontWeight: 600,
        }}
      >
        <RefreshCw size={14} />
        {t.retry}
      </button>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   EMPTY / LOADING
   ════════════════════════════════════════════════════════════════════ */
export function EmptyState({
  tab,
  search,
  t,
  onCreate,
}: {
  tab: Tab;
  search: string;
  t: Translation;
  onCreate: () => void;
}) {
  const msg = search
    ? t.noSearchResults
    : tab === "all"
      ? t.noNotes
      : tab === "archive"
        ? t.noNotesArchive
        : t.noNotesTrash;
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        height: 260,
        gap: 14,
        textAlign: "center",
      }}
    >
      <div
        style={{
          ...glassBase(16),
          width: 52,
          height: 52,
          borderRadius: 14,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <FileText size={22} color={G.textMuted} />
      </div>
      <p style={{ color: G.textMuted, fontSize: "0.84rem", letterSpacing: "0.02em", margin: 0 }}>
        {msg}
      </p>
      {!search && tab === "all" && (
        <>
          <p
            style={{
              color: G.textMuted,
              fontSize: "0.76rem",
              margin: 0,
              maxWidth: 280,
              lineHeight: 1.5,
            }}
          >
            {t.noNotesSubtitle}
          </p>
          <button
            type="button"
            onClick={onCreate}
            style={{
              ...glassBase(14),
              display: "inline-flex",
              alignItems: "center",
              gap: 7,
              padding: "9px 14px",
              borderRadius: 11,
              cursor: "pointer",
              fontFamily: "inherit",
              color: G.textPrimary,
              fontSize: "0.78rem",
              fontWeight: 600,
            }}
          >
            <Plus size={14} />
            {t.createNote}
          </button>
        </>
      )}
    </div>
  );
}

export function LoadingState({ t }: { t: Translation }) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "center", height: 240 }}>
      <div style={{ ...glassBase(16), padding: "22px 26px", textAlign: "center" }}>
        <div
          style={{ marginBottom: 14, fontSize: "0.95rem", fontWeight: 700, color: G.textPrimary }}
        >
          {t.loadingNotes}
        </div>
        <div
          style={{
            height: 4,
            width: 180,
            background: "rgba(255,255,255,0.10)",
            borderRadius: 999,
            overflow: "hidden",
          }}
        >
          <div
            style={{
              width: 80,
              height: 4,
              background: "rgba(255,200,60,0.90)",
              animation: "loadingBar 1.2s ease-in-out infinite",
            }}
          />
        </div>
      </div>
      <style>{`@keyframes loadingBar{0%{transform:translateX(-100%);}50%{transform:translateX(0%);}100%{transform:translateX(100%);}}`}</style>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   BOTTOM NAV
   ════════════════════════════════════════════════════════════════════ */
export const BottomNav = React.memo(function BottomNav({
  tab,
  setTab,
  isMobile,
  t,
}: {
  tab: Tab;
  setTab: (t: Tab) => void;
  isMobile: boolean;
  t: Translation;
}) {
  const items: [Tab, typeof FileText, string][] = [
    ["all", FileText, t.tabNotes],
    ["archive", Archive, t.tabArchive],
    ["trash", Trash2, t.tabTrash],
  ];
  return (
    <div
      style={{
        position: "fixed",
        bottom: isMobile ? "calc(12px + env(safe-area-inset-bottom, 0px))" : 24,
        left: "50%",
        transform: "translateX(-50%)",
        width: isMobile ? "calc(100% - 32px)" : "56%",
        minWidth: 260,
        maxWidth: 420,
        zIndex: 40,
      }}
    >
      <div
        style={{
          ...glassBase(28),
          borderRadius: 30,
          padding: "10px 8px",
          display: "flex",
          alignItems: "center",
          justifyContent: "space-around",
          position: "relative",
        }}
      >
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: "inherit",
            pointerEvents: "none",
            zIndex: 10,
            padding: 1,
            background:
              "linear-gradient(160deg,rgba(255,255,255,0.28) 0%,rgba(255,255,255,0.04) 60%)",
            WebkitMask: "linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0)",
            WebkitMaskComposite: "xor",
            maskComposite: "exclude",
          }}
        />
        {items.map(([id, Icon, label]) => {
          const active = tab === id;
          return (
            <button
              key={id}
              onClick={() => setTab(id)}
              aria-label={label}
              style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: 3,
                padding: "4px 16px 6px",
                borderRadius: 20,
                border: "none",
                cursor: "pointer",
                background: "transparent",
                fontFamily: "inherit",
                color: active ? G.textPrimary : G.textMuted,
                position: "relative",
                transition: "color 0.2s",
              }}
            >
              <Icon size={20} strokeWidth={active ? 2.2 : 1.5} />
              <span
                style={{
                  fontSize: "0.62rem",
                  fontWeight: active ? 700 : 500,
                  letterSpacing: "0.02em",
                  lineHeight: 1,
                }}
              >
                {label}
              </span>
              {active && (
                <div
                  style={{
                    position: "absolute",
                    bottom: 0,
                    left: "50%",
                    transform: "translateX(-50%)",
                    width: 18,
                    height: 2,
                    borderRadius: 2,
                    background: "rgba(255,255,255,0.70)",
                  }}
                />
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
});

/* ════════════════════════════════════════════════════════════════════
   FAB
   ════════════════════════════════════════════════════════════════════ */
export const FabBtn = React.memo(function FabBtn({
  onClick,
  isMobile,
  t,
}: {
  onClick: () => void;
  isMobile: boolean;
  t: Translation;
}) {
  const sz = isMobile ? 52 : 56;
  return (
    <button
      onClick={onClick}
      aria-label={t.createNewNote}
      className="fab-btn"
      style={{
        position: "fixed",
        bottom: isMobile ? "calc(92px + env(safe-area-inset-bottom, 0px))" : 32,
        right: isMobile ? 20 : 32,
        width: sz,
        height: sz,
        border: "none",
        cursor: "pointer",
        padding: 0,
        background: "transparent",
        zIndex: 40,
      }}
    >
      <span
        className="card-glass"
        style={{
          position: "absolute",
          inset: 0,
          borderRadius: 18,
          background: "rgba(255,255,255,0.10)",
        }}
      >
        <span className="glass-ring" />
        <span className="glass-sheen" />
      </span>
      <span
        style={{
          position: "relative",
          zIndex: 20,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          width: "100%",
          height: "100%",
        }}
      >
        <Plus size={isMobile ? 22 : 24} color={G.textPrimary} strokeWidth={2} />
      </span>
    </button>
  );
});
