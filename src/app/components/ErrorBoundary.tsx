import React, { Component, type ReactNode } from "react";
import { useTranslation, type Translation } from "../../i18n";

interface ErrorBoundaryProps {
  t: Translation;
  children: ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
}

/**
 * Catches render errors anywhere below it and shows a localized recovery
 * screen instead of a blank page. Notes themselves live in Firestore or
 * localStorage, so a UI crash never destroys user data.
 */
class ErrorBoundaryInner extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false };

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true };
  }

  componentDidCatch(error: unknown, info: React.ErrorInfo) {
    console.error("[ErrorBoundary] Unhandled UI error:", error, info.componentStack);
  }

  render() {
    if (!this.state.hasError) return this.props.children;

    const { t } = this.props;
    return (
      <div
        role="alert"
        style={{
          position: "fixed", inset: 0, display: "flex", flexDirection: "column",
          alignItems: "center", justifyContent: "center", gap: 16, padding: 24,
          background: "#0b0b1a", color: "rgba(255,255,255,0.92)",
          fontFamily: "'Manrope','Inter',sans-serif", textAlign: "center",
        }}
      >
        <h1 style={{ margin: 0, fontSize: "1.3rem", fontWeight: 700 }}>{t.errorTitle}</h1>
        <p style={{ margin: 0, maxWidth: 420, fontSize: "0.88rem", lineHeight: 1.6, color: "rgba(255,255,255,0.60)" }}>
          {t.errorMessage}
        </p>
        <button
          type="button"
          onClick={() => window.location.reload()}
          style={{
            marginTop: 8, padding: "11px 22px", borderRadius: 14, border: "1px solid rgba(255,255,255,0.20)",
            background: "rgba(255,255,255,0.12)", color: "rgba(255,255,255,0.92)", cursor: "pointer",
            fontFamily: "inherit", fontSize: "0.86rem", fontWeight: 700,
          }}
        >
          {t.errorReload}
        </button>
      </div>
    );
  }
}

/** Function wrapper so the boundary can read translations from context. */
export function AppErrorBoundary({ children }: { children: ReactNode }) {
  const { t } = useTranslation();
  return <ErrorBoundaryInner t={t}>{children}</ErrorBoundaryInner>;
}
