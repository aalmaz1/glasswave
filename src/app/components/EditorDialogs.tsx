import { useCallback, useEffect, useRef, useState } from "react";
import type { MutableRefObject, ReactNode } from "react";
import { Check, Clock, Hash, X } from "lucide-react";
import type { Language, Translation } from "../../i18n";
import { RichTextEditor } from "./RichTextEditor";
import { ConfirmDialog } from "./ConfirmDialog";
import { useFocusTrap } from "../hooks/useFocusTrap";
import { countWords, stripHtml } from "../utils";
import { G, glassBase } from "../theme";

/* ════════════════════════════════════════════════════════════════════
   EDITOR MODAL
   ════════════════════════════════════════════════════════════════════ */
export function EditorModal({
  creating,
  initialTitle,
  initialBody,
  onClose,
  onSave,
  onAutosave,
  requestCloseRef,
  isMobile,
  isTablet,
  language,
  t,
}: {
  creating: boolean;
  initialTitle: string;
  initialBody: string;
  onClose: () => void;
  onSave: (title: string, body: string) => void;
  onAutosave: (title: string, body: string) => void;
  requestCloseRef: MutableRefObject<(() => void) | null>;
  isMobile: boolean;
  isTablet: boolean;
  language: Language;
  t: Translation;
}) {
  // Draft state is local to the editor: every keystroke used to re-render the
  // whole app (note grid, nav, orbs) because the draft lived in App.
  const [title, setTitle] = useState(initialTitle);
  const [body, setBody] = useState(initialBody);
  const [leaveOpen, setLeaveOpen] = useState(false);
  // Focus trap (no onEscape — the editor already handles Escape via its own
  // keydown listener, which also covers the "unsaved changes" prompt).
  const trapRef = useFocusTrap<HTMLDivElement>(true);
  const saveRef = useRef(onSave);
  saveRef.current = onSave;
  const dirty = title !== initialTitle || body !== initialBody;
  const dirtyRef = useRef(dirty);
  dirtyRef.current = dirty;
  const leaveOpenRef = useRef(leaveOpen);
  leaveOpenRef.current = leaveOpen;

  const autosaveRef = useRef(onAutosave);
  autosaveRef.current = onAutosave;

  // Debounced autosave: persist the draft shortly after the user pauses typing,
  // without closing the editor. The timer is cancelled on every keystroke and
  // on unmount, so we never save stale text or fire after a manual save.
  useEffect(() => {
    if (!dirty) return;
    const id = setTimeout(() => autosaveRef.current(title, body), 1500);
    return () => clearTimeout(id);
  }, [title, body, dirty]);

  const requestClose = useCallback(() => {
    if (leaveOpenRef.current) {
      setLeaveOpen(false);
      return;
    }
    if (dirtyRef.current) {
      setLeaveOpen(true);
      return;
    }
    onClose();
  }, [onClose]);

  useEffect(() => {
    requestCloseRef.current = requestClose;
    return () => {
      requestCloseRef.current = null;
    };
  }, [requestClose, requestCloseRef]);

  useEffect(() => {
    const h = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "s") {
        e.preventDefault();
        saveRef.current(title, body);
      }
      if (e.key === "Escape") requestClose();
    };
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, [requestClose, title, body]);

  const wc = countWords(stripHtml(body));
  const today = new Date().toLocaleDateString(language, t.dateFormatLong as any);
  const mW = isMobile ? "100%" : isTablet ? "82%" : "62%";
  const mH = isMobile ? "92dvh" : "88vh";
  const br = isMobile ? 20 : G.radius + 4;

  return (
    <div
      className="modal-overlay"
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 50,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: G.overlay,
        backdropFilter: isMobile ? "none" : "blur(2px)",
        padding: isMobile ? 12 : 24,
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) requestClose();
      }}
    >
      <div
        ref={trapRef}
        role="dialog"
        aria-modal="true"
        aria-label={creating ? t.newNote : t.edit}
        className="modal-in modal-mobile-safe"
        style={{
          ...glassBase(32),
          width: mW,
          maxWidth: isMobile ? "100%" : isTablet ? 760 : 720,
          height: mH,
          borderRadius: br,
          border: "1px solid rgba(255,255,255,0.28)",
          boxShadow: "0 32px 80px rgba(0,0,0,0.65),inset 0 1px 0 rgba(255,255,255,0.22)",
          display: "flex",
          flexDirection: "column",
          overflow: "hidden",
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
              "linear-gradient(160deg,rgba(255,255,255,0.40) 0%,rgba(255,255,255,0.06) 45%,rgba(255,255,255,0.01) 100%)",
            WebkitMask: "linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0)",
            WebkitMaskComposite: "xor",
            maskComposite: "exclude",
          }}
        />
        <div
          style={{
            position: "relative",
            zIndex: 20,
            display: "flex",
            flexDirection: "column",
            height: "100%",
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              gap: 8,
              padding: "14px 20px",
              borderBottom: "1px solid rgba(255,255,255,0.08)",
              minWidth: 0,
            }}
          >
            <GlassChip onClick={requestClose}>
              <X size={14} color={G.textSecondary} />
              <span style={{ fontSize: "0.78rem", color: G.textSecondary, fontWeight: 500 }}>
                {t.close}
              </span>
            </GlassChip>
            {!isMobile && creating && (
              <span
                style={{
                  fontSize: "0.66rem",
                  fontWeight: 500,
                  color: G.textMuted,
                  letterSpacing: "0.08em",
                  textTransform: "uppercase",
                  overflow: "hidden",
                  textOverflow: "ellipsis",
                  whiteSpace: "nowrap",
                }}
              >
                {t.newNote}
              </span>
            )}
            <GlassChip onClick={() => onSave(title, body)} highlight>
              <Check size={14} color={G.textPrimary} />
              <span style={{ fontSize: "0.78rem", color: G.textPrimary, fontWeight: 600 }}>
                {t.save}
              </span>
            </GlassChip>
          </div>

          <div style={{ padding: "20px 24px 0" }}>
            <input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder={t.noteTitlePlaceholder}
              autoFocus
              data-autofocus
              aria-label={t.noteTitlePlaceholder}
              style={{
                width: "100%",
                background: "transparent",
                border: "none",
                outline: "none",
                fontFamily: "inherit",
                fontWeight: 300,
                fontSize: isMobile ? "1.5rem" : "1.75rem",
                letterSpacing: "-0.025em",
                color: G.textPrimary,
              }}
            />
          </div>

          <div
            style={{
              padding: "6px 24px 12px",
              display: "flex",
              alignItems: "center",
              gap: 8,
              color: G.textMuted,
              fontSize: "0.68rem",
              borderBottom: "1px solid rgba(255,255,255,0.06)",
            }}
          >
            <Clock size={10} />
            <span>{today}</span>
            <span style={{ opacity: 0.5 }}>·</span>
            <Hash size={10} />
            <span>{t.wordsCount(wc)}</span>
          </div>

          <div
            className="scroll-host"
            style={{ flex: 1, overflowY: "auto", padding: "12px 24px 24px" }}
          >
            <RichTextEditor
              content={body}
              onChange={setBody}
              placeholder={t.noteContentPlaceholder}
            />
          </div>
        </div>
      </div>
      {leaveOpen && (
        <ConfirmDialog
          title={t.unsavedChangesTitle}
          body={t.unsavedChangesBody}
          confirmLabel={t.unsavedSave}
          cancelLabel={t.cancel}
          extraLabel={t.unsavedDiscard}
          danger={false}
          onCancel={() => setLeaveOpen(false)}
          onConfirm={() => onSave(title, body)}
          onExtra={() => onClose()}
        />
      )}
    </div>
  );
}

function GlassChip({
  children,
  onClick,
  highlight,
}: {
  children: ReactNode;
  onClick: () => void;
  highlight?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      style={{
        ...glassBase(16),
        display: "flex",
        alignItems: "center",
        gap: 6,
        padding: "7px 14px",
        borderRadius: 12,
        border: `1px solid ${highlight ? "rgba(255,255,255,0.35)" : G.border}`,
        background: highlight ? G.bgHov : G.bg,
        cursor: "pointer",
        fontFamily: "inherit",
        transition: "all 0.2s",
        flexShrink: 0,
        whiteSpace: "nowrap",
      }}
    >
      {children}
    </button>
  );
}
