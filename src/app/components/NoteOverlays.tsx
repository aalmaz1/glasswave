import {
  CalendarClock,
  CalendarDays,
  Check,
  RefreshCw,
  Shuffle,
  SlidersHorizontal,
  X,
} from "lucide-react";
import type { Language, Translation } from "../../i18n";
import { useFocusTrap } from "../hooks/useFocusTrap";
import { G, glassBase } from "../theme";
import type { Note, SortOrder } from "../model";
import { useState } from "react";

/* ════════════════════════════════════════════════════════════════════
   SORT SHEET
   ════════════════════════════════════════════════════════════════════ */
export function SortSheet({
  current,
  onSelect,
  onClose,
  t,
}: {
  current: SortOrder;
  onSelect: (o: SortOrder) => void;
  onClose: () => void;
  t: Translation;
}) {
  const opts: { id: SortOrder; label: string; sub: string; Icon: typeof Shuffle }[] = [
    { id: "default", label: t.sortDefault, sub: t.sortDefaultSub, Icon: Shuffle },
    { id: "created", label: t.sortByCreated, sub: t.sortCreatedSub, Icon: CalendarDays },
    { id: "updated", label: t.sortByUpdated, sub: t.sortUpdatedSub, Icon: RefreshCw },
  ];
  const trapRef = useFocusTrap<HTMLDivElement>(true, onClose);
  return (
    <div
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 60,
        display: "flex",
        flexDirection: "column",
        justifyContent: "flex-end",
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: "rgba(0,0,0,0.52)",
          backdropFilter: "blur(3px)",
        }}
        onClick={onClose}
      />
      <div
        ref={trapRef}
        role="dialog"
        aria-modal="true"
        aria-label={t.sortBy}
        className="sheet-in"
        style={{
          position: "relative",
          zIndex: 1,
          background: "rgba(18,18,24,0.96)",
          backdropFilter: "blur(40px)",
          WebkitBackdropFilter: "blur(40px)",
          borderTop: "1px solid rgba(255,255,255,0.14)",
          borderRadius: "24px 24px 0 0",
          boxShadow: "0 -16px 60px rgba(0,0,0,0.60), inset 0 1px 0 rgba(255,255,255,0.12)",
          padding: "0 0 env(safe-area-inset-bottom,16px)",
        }}
      >
        <div style={{ display: "flex", justifyContent: "center", padding: "12px 0 4px" }}>
          <div
            style={{ width: 36, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.18)" }}
          />
        </div>
        <div
          style={{
            padding: "8px 24px 16px",
            display: "flex",
            alignItems: "center",
            gap: 10,
            borderBottom: "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <SlidersHorizontal size={16} color={G.textMuted} />
          <span
            style={{
              fontWeight: 700,
              fontSize: "0.96rem",
              color: G.textPrimary,
              letterSpacing: "-0.01em",
            }}
          >
            {t.sortBy}
          </span>
        </div>
        <div style={{ padding: "8px 12px 20px", display: "flex", flexDirection: "column", gap: 4 }}>
          {opts.map(({ id, label, sub, Icon }) => {
            const active = current === id;
            return (
              <button
                key={id}
                onClick={() => onSelect(id)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 14,
                  padding: "14px 16px",
                  borderRadius: 16,
                  border: "none",
                  cursor: "pointer",
                  fontFamily: "inherit",
                  background: active ? "rgba(255,255,255,0.07)" : "transparent",
                  transition: "background 0.16s",
                  textAlign: "left",
                }}
                onMouseEnter={(e) =>
                  ((e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.06)")
                }
                onMouseLeave={(e) =>
                  ((e.currentTarget as HTMLElement).style.background = active
                    ? "rgba(255,255,255,0.07)"
                    : "transparent")
                }
              >
                <div
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: 12,
                    flexShrink: 0,
                    background: active ? "rgba(255,255,255,0.10)" : "rgba(255,255,255,0.05)",
                    border: `1px solid ${active ? "rgba(255,255,255,0.20)" : G.border}`,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    transition: "all 0.16s",
                  }}
                >
                  <Icon
                    size={18}
                    color={active ? G.textPrimary : G.textSecondary}
                    strokeWidth={1.7}
                  />
                </div>
                <div style={{ flex: 1 }}>
                  <p
                    style={{
                      margin: 0,
                      fontWeight: active ? 700 : 500,
                      fontSize: "0.92rem",
                      color: active ? G.textPrimary : G.textSecondary,
                    }}
                  >
                    {label}
                  </p>
                  <p style={{ margin: "2px 0 0", fontSize: "0.74rem", color: G.textMuted }}>
                    {sub}
                  </p>
                </div>
                {active && (
                  <div
                    style={{
                      width: 22,
                      height: 22,
                      borderRadius: "50%",
                      flexShrink: 0,
                      background: "rgba(255,255,255,0.90)",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                    }}
                  >
                    <Check size={12} color="#111" strokeWidth={2.5} />
                  </div>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════════════
   REMINDER MODAL
   ════════════════════════════════════════════════════════════════════ */
export function ReminderModal({
  note,
  onSave,
  onClose,
  language,
  t,
}: {
  note: Note;
  onSave: (d: Date | null) => void;
  onClose: () => void;
  language: Language;
  t: Translation;
}) {
  const now = new Date();
  const pad = (n: number) => String(n).padStart(2, "0");
  const toVal = (d: Date) =>
    `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
  const [val, setVal] = useState(note.reminder ? toVal(note.reminder) : "");
  const [saving, setSaving] = useState(false);
  const trapRef = useFocusTrap<HTMLDivElement>(true, onClose);

  const todayAt = (h: number, m = 0) => {
    const d = new Date(now);
    d.setHours(h, m, 0, 0);
    if (d <= now) d.setDate(d.getDate() + 1);
    return d;
  };
  const tomorrowAt = (h: number) => {
    const d = new Date(now);
    d.setDate(d.getDate() + 1);
    d.setHours(h, 0, 0, 0);
    return d;
  };
  const nextMonday = () => {
    const d = new Date(now);
    const diff = (8 - d.getDay()) % 7 || 7;
    d.setDate(d.getDate() + diff);
    d.setHours(8, 0, 0, 0);
    return d;
  };

  const quickPicks = [
    { label: t.reminderToday, sub: "20:00", val: todayAt(20) },
    { label: t.reminderTomorrow, sub: "08:00", val: tomorrowAt(8) },
    { label: t.reminderNextWeek, sub: "Mon 08:00", val: nextMonday() },
  ];

  const fmt = (d: Date) => d.toLocaleString(language, t.dateFormatReminder as any);

  /**
   * Saving a reminder must never depend on the notification stack.
   *
   * This used to `await ensureNotificationPermission()` before calling
   * `onSave`. On a native shell where the permission bridge call never calls
   * back (plugin missing, activity recreated, OEM permission dialog swallowed)
   * that promise hangs forever, so the modal stayed open with a disabled
   * button and the whole app looked frozen. The reminder is persisted first
   * and the permission prompt + OS scheduling happen afterwards in `onSave`
   * (see App.tsx), where they can fail harmlessly.
   */
  const saveReminder = () => {
    if (!val || saving) return;
    const at = new Date(val);
    if (Number.isNaN(at.getTime())) return;
    setSaving(true);
    onSave(at);
  };

  return (
    <div
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 60,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "rgba(0,0,0,0.55)",
        backdropFilter: "blur(4px)",
        padding: 24,
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        ref={trapRef}
        role="dialog"
        aria-modal="true"
        aria-label={t.reminder}
        className="modal-in"
        style={{
          ...glassBase(32),
          width: "100%",
          maxWidth: 360,
          border: "1px solid rgba(255,255,255,0.26)",
          boxShadow: "0 32px 80px rgba(0,0,0,0.65),inset 0 1px 0 rgba(255,255,255,0.22)",
          borderRadius: 24,
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
            zIndex: 1,
            padding: 1,
            background:
              "linear-gradient(160deg,rgba(255,255,255,0.38) 0%,rgba(255,255,255,0.05) 50%,transparent 100%)",
            WebkitMask: "linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0)",
            WebkitMaskComposite: "xor",
            maskComposite: "exclude",
          }}
        />
        <div style={{ position: "relative", zIndex: 2, padding: "22px 22px 20px" }}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              marginBottom: 20,
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <CalendarClock size={18} color="rgba(255,200,60,0.90)" />
              <span style={{ fontWeight: 700, fontSize: "1rem", color: G.textPrimary }}>
                {t.reminder}
              </span>
            </div>
            <button
              onClick={onClose}
              aria-label={t.close}
              style={{
                background: "none",
                border: "none",
                cursor: "pointer",
                lineHeight: 0,
                padding: 4,
              }}
            >
              <X size={16} color={G.textMuted} />
            </button>
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 18 }}>
            {quickPicks.map((qp) => (
              <button
                key={qp.label}
                onClick={() => setVal(toVal(qp.val))}
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "11px 14px",
                  borderRadius: 14,
                  border: `1px solid ${G.border}`,
                  background: val === toVal(qp.val) ? "rgba(255,200,60,0.12)" : G.bg,
                  cursor: "pointer",
                  fontFamily: "inherit",
                  transition: "all 0.18s",
                  outline: val === toVal(qp.val) ? "1px solid rgba(255,200,60,0.35)" : "none",
                }}
                onMouseEnter={(e) =>
                  ((e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.08)")
                }
                onMouseLeave={(e) =>
                  ((e.currentTarget as HTMLElement).style.background =
                    val === toVal(qp.val) ? "rgba(255,200,60,0.12)" : G.bg)
                }
              >
                <span style={{ fontWeight: 600, fontSize: "0.86rem", color: G.textPrimary }}>
                  {qp.label}
                </span>
                <span style={{ fontSize: "0.76rem", color: G.textSecondary }}>{fmt(qp.val)}</span>
              </button>
            ))}
          </div>

          <div style={{ marginBottom: 18 }}>
            <p
              style={{
                margin: "0 0 8px",
                fontSize: "0.68rem",
                fontWeight: 600,
                color: G.textMuted,
                textTransform: "uppercase",
                letterSpacing: "0.08em",
              }}
            >
              {t.reminderCustom}
            </p>
            <input
              type="datetime-local"
              value={val}
              min={toVal(new Date(now.getTime() + 60000))}
              onChange={(e) => setVal(e.target.value)}
              style={{
                width: "100%",
                background: "rgba(255,255,255,0.05)",
                border: `1px solid ${G.border}`,
                borderRadius: 12,
                padding: "10px 14px",
                outline: "none",
                fontFamily: "inherit",
                fontSize: "0.86rem",
                color: G.textPrimary,
                colorScheme: "dark",
              }}
            />
          </div>

          <div style={{ display: "flex", gap: 8 }}>
            {note.reminder && (
              <button
                onClick={() => onSave(null)}
                aria-label={t.reminderDelete}
                style={{
                  flex: 1,
                  padding: "11px 0",
                  borderRadius: 14,
                  border: "1px solid rgba(255,100,100,0.28)",
                  background: "rgba(255,80,80,0.08)",
                  cursor: "pointer",
                  fontFamily: "inherit",
                  fontSize: "0.84rem",
                  fontWeight: 600,
                  color: "rgba(255,120,120,0.90)",
                  transition: "all 0.18s",
                }}
              >
                {t.reminderDelete}
              </button>
            )}
            <button
              onClick={saveReminder}
              disabled={!val || saving}
              aria-label={t.reminderSave}
              style={{
                flex: 2,
                padding: "11px 0",
                borderRadius: 14,
                border: "1px solid rgba(255,200,60,0.35)",
                background: val && !saving ? "rgba(255,200,60,0.14)" : "rgba(255,255,255,0.04)",
                cursor: val && !saving ? "pointer" : "not-allowed",
                fontFamily: "inherit",
                fontSize: "0.84rem",
                fontWeight: 700,
                color: val ? "rgba(255,210,80,0.95)" : G.textMuted,
                transition: "all 0.18s",
              }}
            >
              {t.reminderSave}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
