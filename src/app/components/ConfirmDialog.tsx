import { useFocusTrap } from "../hooks/useFocusTrap";
import { G, glassBase } from "../theme";

export function ConfirmDialog({
  title,
  body,
  confirmLabel,
  cancelLabel,
  extraLabel,
  danger = true,
  onConfirm,
  onCancel,
  onExtra,
}: {
  title: string;
  body: string;
  confirmLabel: string;
  cancelLabel: string;
  extraLabel?: string;
  danger?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
  onExtra?: () => void;
}) {
  const trapRef = useFocusTrap<HTMLDivElement>(true, onCancel);
  return (
    <div
      role="presentation"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onCancel();
      }}
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 80,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: 20,
        background: "rgba(0,0,0,0.62)",
        backdropFilter: "blur(5px)",
      }}
    >
      <div
        ref={trapRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby="confirm-title"
        className="modal-in"
        style={{
          ...glassBase(28),
          width: "100%",
          maxWidth: 400,
          borderRadius: 22,
          overflow: "hidden",
          border: danger ? "1px solid rgba(255,115,115,0.38)" : "1px solid rgba(255,255,255,0.22)",
          boxShadow: "0 28px 80px rgba(0,0,0,0.70)",
        }}
      >
        <div style={{ padding: "22px 22px 20px" }}>
          <h2
            id="confirm-title"
            style={{
              margin: "0 0 10px",
              fontSize: "1rem",
              fontWeight: 700,
              color: danger ? "rgba(255,215,215,0.98)" : G.textPrimary,
            }}
          >
            {title}
          </h2>
          <p
            style={{
              margin: "0 0 20px",
              fontSize: "0.82rem",
              lineHeight: 1.55,
              color: G.textSecondary,
            }}
          >
            {body}
          </p>
          <div style={{ display: "flex", gap: 8, justifyContent: "flex-end", flexWrap: "wrap" }}>
            <button
              type="button"
              onClick={onCancel}
              style={{
                padding: "10px 14px",
                borderRadius: 11,
                border: `1px solid ${G.border}`,
                background: "rgba(255,255,255,0.05)",
                color: G.textSecondary,
                cursor: "pointer",
                fontFamily: "inherit",
                fontSize: "0.8rem",
                fontWeight: 600,
              }}
            >
              {cancelLabel}
            </button>
            {extraLabel && onExtra && (
              <button
                type="button"
                onClick={onExtra}
                style={{
                  padding: "10px 14px",
                  borderRadius: 11,
                  border: `1px solid ${G.border}`,
                  background: "rgba(255,255,255,0.08)",
                  color: G.textPrimary,
                  cursor: "pointer",
                  fontFamily: "inherit",
                  fontSize: "0.8rem",
                  fontWeight: 600,
                }}
              >
                {extraLabel}
              </button>
            )}
            <button
              type="button"
              onClick={onConfirm}
              style={{
                padding: "10px 14px",
                borderRadius: 11,
                border: danger
                  ? "1px solid rgba(255,105,105,0.55)"
                  : "1px solid rgba(255,255,255,0.35)",
                background: danger ? "rgba(225,55,65,0.42)" : "rgba(255,255,255,0.16)",
                color: "white",
                cursor: "pointer",
                fontFamily: "inherit",
                fontSize: "0.8rem",
                fontWeight: 700,
              }}
            >
              {confirmLabel}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
