import { useState } from "react";
import type { CSSProperties } from "react";
import {
  Check,
  ChevronLeft,
  Eye,
  EyeOff,
  Languages as LanguagesIcon,
  LogOut,
  Palette,
  Shield,
  Trash2,
  User,
  X,
  type LucideIcon,
} from "lucide-react";
import { themeNameByLang, useTranslation, type Language, type Translation } from "../../i18n";
import { hasFirebaseConfig } from "../../firebase";
import { useFocusTrap } from "../hooks/useFocusTrap";
import { G, THEMES, glassBase, type ThemeId } from "../theme";
import type { AuthUser } from "../model";
import {
  loginAccount as authLogin,
  registerAccount as authRegister,
  resetAccountPassword as authResetPassword,
} from "../services/accountService";

/* ════════════════════════════════════════════════════════════════════
   SETTINGS
   ════════════════════════════════════════════════════════════════════ */
export function SettingsScreen({
  themeId,
  setThemeId,
  onBack,
  currentUser,
  onLogout,
  onDeleteAccount,
  language,
}: {
  themeId: ThemeId;
  setThemeId: (id: ThemeId) => void;
  onBack: () => void;
  currentUser: AuthUser | null;
  onLogout: () => void;
  onDeleteAccount: (password: string) => Promise<string | null>;
  language: Language;
}) {
  const { t, setLanguage } = useTranslation();
  const [deleteOpen, setDeleteOpen] = useState(false);

  const block: CSSProperties = {
    width: "100%",
    maxWidth: 666,
    boxSizing: "border-box",
    marginBottom: 36,
    overflow: "hidden",
    marginLeft: "auto",
    marginRight: "auto",
  };

  const handleLanguageChange = (next: Language) => {
    setLanguage(next);
    window.localStorage.setItem("preferred-lang", next);
    document.documentElement.lang = next;
  };

  return (
    <div
      className="settings-page-root"
      style={{ width: "100%", maxWidth: "100%", boxSizing: "border-box", paddingBottom: 64 }}
    >
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 14,
          paddingTop: "calc(28px + var(--safe-area-inset-top, env(safe-area-inset-top, 0px)))",
          paddingBottom: 28,
        }}
      >
        <button
          onClick={onBack}
          aria-label={t.close}
          style={{
            ...glassBase(16),
            width: 38,
            height: 38,
            borderRadius: 12,
            border: "none",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            flexShrink: 0,
          }}
        >
          <ChevronLeft size={18} color={G.textSecondary} />
        </button>
        <h1
          style={{
            fontWeight: 700,
            fontSize: "1.3rem",
            color: G.textPrimary,
            margin: 0,
            letterSpacing: "-0.02em",
          }}
        >
          {t.settings}
        </h1>
      </div>

      <div style={block} className="settings-section-container">
        <SLabel Icon={User} label={t.account} />
        {currentUser ? <AccountCard user={currentUser} onLogout={onLogout} t={t} /> : <AuthPanel />}
      </div>

      <div style={block} className="settings-section-container">
        <SLabel Icon={Palette} label={t.theme} />
        <div
          className="settings-theme-grid"
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: 10,
            width: "100%",
            boxSizing: "border-box",
          }}
        >
          {THEMES.map((th) => {
            const active = th.id === themeId;
            const name = themeNameByLang(th.id, t);
            return (
              <button
                key={th.id}
                onClick={() => setThemeId(th.id)}
                aria-label={name}
                aria-pressed={active}
                title={name}
                style={{
                  ...glassBase(20),
                  padding: 0,
                  border: active ? "1px solid rgba(255,255,255,0.50)" : `1px solid ${G.border}`,
                  boxShadow: active
                    ? "0 16px 48px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.28)"
                    : G.shadow,
                  cursor: "pointer",
                  borderRadius: 18,
                  overflow: "hidden",
                  transition: "all 0.25s",
                  boxSizing: "border-box",
                  flex: "0 0 auto",
                  maxWidth: "100%",
                }}
              >
                <div
                  style={{
                    height: 56,
                    background: th.bg,
                    position: "relative",
                    overflow: "hidden",
                  }}
                >
                  {th.orbs.slice(0, 2).map((o, i) => (
                    <div
                      key={i}
                      style={{
                        position: "absolute",
                        top: i === 0 ? "-30%" : "20%",
                        left: i === 0 ? "-10%" : "52%",
                        width: o.size * 0.3,
                        height: o.size * 0.3,
                        borderRadius: "50%",
                        background: `radial-gradient(circle,${o.color} 0%,transparent 70%)`,
                      }}
                    />
                  ))}
                  {active && (
                    <div
                      style={{
                        position: "absolute",
                        top: 8,
                        right: 8,
                        width: 20,
                        height: 20,
                        borderRadius: "50%",
                        background: "rgba(255,255,255,0.90)",
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                      }}
                    >
                      <Check size={12} color="#111" strokeWidth={2.5} />
                    </div>
                  )}
                </div>
                <div
                  style={{
                    padding: "8px 6px 10px",
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: 4,
                  }}
                >
                  <span style={{ fontSize: "1.2rem", lineHeight: 1 }}>{th.emoji}</span>
                  <span
                    style={{
                      fontSize: "0.62rem",
                      fontWeight: 600,
                      lineHeight: 1.2,
                      textAlign: "center",
                      color: active ? G.textPrimary : G.textSecondary,
                      maxWidth: "100%",
                      overflow: "hidden",
                      textOverflow: "ellipsis",
                      whiteSpace: "nowrap",
                    }}
                  >
                    {name}
                  </span>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      <div style={block} className="settings-section-container">
        <SLabel Icon={LanguagesIcon} label={t.language} />
        <select
          aria-label={t.selectLanguage}
          value={language}
          onChange={(e) => handleLanguageChange(e.target.value as Language)}
          style={{
            width: "100%",
            boxSizing: "border-box",
            padding: "12px 14px",
            borderRadius: 12,
            border: `1px solid ${G.border}`,
            background: "rgba(255,255,255,0.06)",
            color: G.textPrimary,
            fontFamily: "inherit",
            fontSize: "0.86rem",
            outline: "none",
            colorScheme: "dark",
          }}
        >
          <option value="ru" style={{ background: "#17171d" }}>
            Русский
          </option>
          <option value="en" style={{ background: "#17171d" }}>
            English
          </option>
          <option value="ko" style={{ background: "#17171d" }}>
            한국어
          </option>
        </select>
      </div>

      {currentUser && (
        <div style={block} className="settings-section-container">
          <SLabel Icon={Trash2} label={t.danger} />
          <div
            style={{
              ...glassBase(20),
              padding: "18px 20px",
              borderRadius: 18,
              border: "1px solid rgba(255,100,100,0.28)",
              background: "rgba(145,20,35,0.13)",
            }}
          >
            <div
              style={{
                display: "flex",
                flexWrap: "wrap",
                alignItems: "flex-start",
                justifyContent: "space-between",
                gap: 16,
              }}
            >
              <div style={{ flex: "1 1 180px", minWidth: 0 }}>
                <p
                  style={{
                    margin: 0,
                    fontWeight: 700,
                    fontSize: "0.92rem",
                    color: "rgba(255,190,190,0.98)",
                  }}
                >
                  {t.deleteAccount}
                </p>
                <p
                  style={{
                    margin: "5px 0 0",
                    fontSize: "0.76rem",
                    lineHeight: 1.55,
                    color: "rgba(255,220,220,0.62)",
                  }}
                >
                  {t.deleteDescription}
                </p>
              </div>
              <button
                onClick={() => setDeleteOpen(true)}
                style={{
                  padding: "9px 12px",
                  borderRadius: 10,
                  flexShrink: 0,
                  border: "1px solid rgba(255,105,105,0.55)",
                  background: "rgba(230,55,65,0.20)",
                  color: "rgba(255,210,210,0.98)",
                  cursor: "pointer",
                  fontFamily: "inherit",
                  fontSize: "0.76rem",
                  fontWeight: 700,
                }}
              >
                {t.deleteAccount}
              </button>
            </div>
          </div>
        </div>
      )}

      {deleteOpen && currentUser && (
        <DeleteAccountModal
          email={currentUser.email}
          onClose={() => setDeleteOpen(false)}
          onDelete={onDeleteAccount}
          t={t}
        />
      )}
    </div>
  );
}

function DeleteAccountModal({
  email,
  onClose,
  onDelete,
  t,
}: {
  email: string;
  onClose: () => void;
  onDelete: (pw: string) => Promise<string | null>;
  t: Translation;
}) {
  const [password, setPassword] = useState("");
  const [showPw, setShowPw] = useState(false);
  const [error, setError] = useState("");
  const [deleting, setDeleting] = useState(false);
  const trapRef = useFocusTrap<HTMLDivElement>(true, () => {
    if (!deleting) onClose();
  });
  const submit = async () => {
    if (!password) {
      setError(t.authErrPasswordRequired);
      return;
    }
    setError("");
    setDeleting(true);
    const result = await onDelete(password);
    setDeleting(false);
    if (result) setError(result);
  };

  // Pick the right "will be deleted" suffix based on current language.
  const suffix = t.deleteSuffix;

  return (
    <div
      role="presentation"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget && !deleting) onClose();
      }}
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 70,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: 20,
        background: "rgba(0,0,0,0.68)",
        backdropFilter: "blur(5px)",
      }}
    >
      <div
        ref={trapRef}
        role="dialog"
        aria-modal="true"
        className="modal-in"
        style={{
          ...glassBase(28),
          width: "100%",
          maxWidth: 420,
          borderRadius: 22,
          overflow: "hidden",
          border: "1px solid rgba(255,115,115,0.38)",
          boxShadow: "0 28px 80px rgba(0,0,0,0.70)",
        }}
      >
        <div style={{ padding: "22px 22px 20px" }}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              gap: 16,
              marginBottom: 14,
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <div
                style={{
                  width: 34,
                  height: 34,
                  borderRadius: 10,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  background: "rgba(235,55,65,0.18)",
                }}
              >
                <Trash2 size={17} color="rgba(255,145,145,0.95)" />
              </div>
              <h2
                style={{
                  margin: 0,
                  fontSize: "1rem",
                  fontWeight: 700,
                  color: "rgba(255,215,215,0.98)",
                }}
              >
                {t.deleteConfirmTitle}
              </h2>
            </div>
            <button
              type="button"
              onClick={onClose}
              disabled={deleting}
              aria-label={t.close}
              style={{
                background: "transparent",
                border: "none",
                padding: 4,
                cursor: deleting ? "not-allowed" : "pointer",
                lineHeight: 0,
              }}
            >
              <X size={18} color={G.textSecondary} />
            </button>
          </div>
          <p
            style={{
              margin: "0 0 18px",
              fontSize: "0.82rem",
              lineHeight: 1.6,
              color: G.textSecondary,
            }}
          >
            {t.deleteWarning} <strong style={{ color: G.textPrimary }}>{email}</strong>
            {suffix}
          </p>
          <label
            htmlFor="delete-pw"
            style={{
              display: "block",
              marginBottom: 7,
              fontSize: "0.72rem",
              fontWeight: 700,
              color: "rgba(255,220,220,0.78)",
            }}
          >
            {t.confirmPassword}
          </label>
          <div style={{ position: "relative" }}>
            <input
              id="delete-pw"
              type={showPw ? "text" : "password"}
              value={password}
              autoComplete="current-password"
              autoFocus
              data-autofocus
              disabled={deleting}
              onChange={(e) => {
                setPassword(e.target.value);
                setError("");
              }}
              onKeyDown={(e) => {
                if (e.key === "Enter") void submit();
              }}
              placeholder={t.passwordPlaceholder}
              style={{
                width: "100%",
                padding: "11px 42px 11px 13px",
                borderRadius: 12,
                outline: "none",
                fontFamily: "inherit",
                fontSize: "0.86rem",
                color: G.textPrimary,
                background: "rgba(255,255,255,0.05)",
                border: "1px solid rgba(255,160,160,0.30)",
              }}
            />
            <button
              type="button"
              aria-label={showPw ? t.hidePassword : t.showPassword}
              onClick={() => setShowPw((v) => !v)}
              disabled={deleting}
              style={{
                position: "absolute",
                right: 11,
                top: "50%",
                transform: "translateY(-50%)",
                background: "transparent",
                border: "none",
                cursor: "pointer",
                lineHeight: 0,
                padding: 2,
              }}
            >
              {showPw ? (
                <EyeOff size={16} color={G.textMuted} />
              ) : (
                <Eye size={16} color={G.textMuted} />
              )}
            </button>
          </div>
          {error && (
            <p
              role="alert"
              style={{
                margin: "9px 0 0",
                fontSize: "0.75rem",
                lineHeight: 1.45,
                color: "rgba(255,145,145,0.96)",
              }}
            >
              {error}
            </p>
          )}
          <div style={{ display: "flex", gap: 10, justifyContent: "flex-end", marginTop: 22 }}>
            <button
              type="button"
              onClick={onClose}
              disabled={deleting}
              style={{
                padding: "10px 14px",
                borderRadius: 11,
                border: `1px solid ${G.border}`,
                background: "rgba(255,255,255,0.05)",
                color: G.textSecondary,
                cursor: deleting ? "not-allowed" : "pointer",
                fontFamily: "inherit",
                fontSize: "0.8rem",
                fontWeight: 600,
              }}
            >
              {t.cancel}
            </button>
            <button
              type="button"
              onClick={() => void submit()}
              disabled={deleting || !password}
              style={{
                padding: "10px 14px",
                borderRadius: 11,
                border: "1px solid rgba(255,105,105,0.55)",
                background: deleting || !password ? "rgba(180,50,55,0.18)" : "rgba(225,55,65,0.42)",
                color: "white",
                cursor: deleting || !password ? "not-allowed" : "pointer",
                fontFamily: "inherit",
                fontSize: "0.8rem",
                fontWeight: 700,
              }}
            >
              {deleting ? t.deleting : t.deleteForever}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function AccountCard({
  user,
  onLogout,
  t,
}: {
  user: AuthUser;
  onLogout: () => void;
  t: Translation;
}) {
  return (
    <div
      style={{
        ...glassBase(20),
        padding: "18px 20px",
        display: "flex",
        alignItems: "center",
        gap: 16,
        borderRadius: 18,
      }}
    >
      <div style={{ flex: "1 1 auto", minWidth: 0 }}>
        <p
          style={{
            margin: 0,
            fontWeight: 700,
            fontSize: "0.92rem",
            color: G.textPrimary,
            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
        >
          {user.name || user.email}
        </p>
        <p
          style={{
            margin: "2px 0 0",
            fontSize: "0.74rem",
            color: G.textMuted,
            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
        >
          {user.email}
        </p>
      </div>
      <div
        title={t.synced}
        aria-label={t.synced}
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          flexShrink: 0,
          width: 36,
          height: 36,
          borderRadius: 10,
          background: "rgba(0,200,80,0.10)",
          border: "1px solid rgba(0,200,80,0.20)",
        }}
      >
        <Shield size={15} color="rgba(0,220,100,0.80)" />
      </div>
      <button
        onClick={onLogout}
        title={t.logout}
        aria-label={t.logout}
        style={{
          ...glassBase(12),
          width: 36,
          height: 36,
          borderRadius: 10,
          border: "none",
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          flexShrink: 0,
        }}
      >
        <LogOut size={15} color={G.textSecondary} />
      </button>
    </div>
  );
}

function AuthPanel() {
  const { t } = useTranslation();
  const [mode, setMode] = useState<"login" | "register">("login");
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [pw, setPw] = useState("");
  const [showPw, setShowPw] = useState(false);
  const [err, setErr] = useState("");
  const [ok, setOk] = useState(false);
  const [resetMsg, setResetMsg] = useState("");
  const [resetErr, setResetErr] = useState("");

  const submit = async () => {
    setErr("");
    setOk(false);
    if (mode === "register") {
      const e = await authRegister(email, name, pw, t);
      if (e) {
        setErr(e);
        return;
      }
      setOk(true);
    } else {
      const e = await authLogin(email, pw, t);
      if (e) {
        setErr(e);
        return;
      }
    }
  };

  const handleForgot = async () => {
    setResetErr("");
    setResetMsg("");
    const e = await authResetPassword(email, t);
    if (e) setResetErr(e);
    else setResetMsg(t.resetSent);
  };

  const inputS: CSSProperties = {
    width: "100%",
    boxSizing: "border-box",
    background: "rgba(255,255,255,0.04)",
    border: `1px solid ${G.border}`,
    borderRadius: 12,
    padding: "11px 14px",
    outline: "none",
    fontFamily: "inherit",
    fontSize: "0.88rem",
    color: G.textPrimary,
  };

  if (!hasFirebaseConfig) {
    return (
      <div style={{ ...glassBase(20), padding: "22px 24px", borderRadius: 20 }}>
        <p
          role="alert"
          style={{
            margin: 0,
            fontSize: "0.82rem",
            color: "rgba(255,160,160,0.95)",
            lineHeight: 1.55,
          }}
        >
          {t.authErrNotConfigured}
        </p>
      </div>
    );
  }

  return (
    <div style={{ ...glassBase(20), padding: "22px 24px", borderRadius: 20 }}>
      <div style={{ display: "flex", gap: 8, marginBottom: 22 }}>
        {(["login", "register"] as const).map((m) => (
          <button
            key={m}
            onClick={() => {
              setMode(m);
              setErr("");
              setOk(false);
            }}
            style={{
              flex: 1,
              padding: "9px 0",
              borderRadius: 12,
              border: "none",
              cursor: "pointer",
              fontFamily: "inherit",
              fontSize: "0.82rem",
              fontWeight: 600,
              transition: "all 0.2s",
              background: mode === m ? G.bgHov : G.bg,
              color: mode === m ? G.textPrimary : G.textMuted,
              boxShadow: mode === m ? G.shadow : "none",
              outline: `1px solid ${mode === m ? G.border : "rgba(255,255,255,0.12)"}`,
            }}
          >
            {m === "login" ? t.login : t.register}
          </button>
        ))}
      </div>

      <form
        onSubmit={(e) => {
          e.preventDefault();
          void submit();
        }}
        style={{ display: "flex", flexDirection: "column", gap: 12 }}
      >
        {mode === "register" && (
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder={t.namePlaceholder}
            aria-label={t.name}
            style={inputS}
            onFocus={(e) =>
              ((e.target as HTMLElement).style.borderColor = "rgba(255,255,255,0.40)")
            }
            onBlur={(e) => ((e.target as HTMLElement).style.borderColor = G.border)}
          />
        )}
        <input
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder={t.emailPlaceholder}
          type="email"
          autoComplete="email"
          aria-label={t.email}
          style={inputS}
          onFocus={(e) => ((e.target as HTMLElement).style.borderColor = "rgba(255,255,255,0.40)")}
          onBlur={(e) => ((e.target as HTMLElement).style.borderColor = G.border)}
        />
        <div style={{ position: "relative" }}>
          <input
            value={pw}
            onChange={(e) => setPw(e.target.value)}
            placeholder={t.passwordPlaceholderLogin}
            type={showPw ? "text" : "password"}
            autoComplete="current-password"
            aria-label={t.password}
            style={{ ...inputS, paddingRight: 42 }}
            onFocus={(e) =>
              ((e.target as HTMLElement).style.borderColor = "rgba(255,255,255,0.40)")
            }
            onBlur={(e) => ((e.target as HTMLElement).style.borderColor = G.border)}
          />
          <button
            type="button"
            aria-label={showPw ? t.hidePassword : t.showPassword}
            onMouseDown={(e) => e.preventDefault()}
            onClick={() => setShowPw((p) => !p)}
            style={{
              position: "absolute",
              right: 12,
              top: "50%",
              transform: "translateY(-50%)",
              background: "none",
              border: "none",
              cursor: "pointer",
              lineHeight: 0,
              padding: 2,
            }}
          >
            {showPw ? (
              <EyeOff size={16} color={G.textMuted} />
            ) : (
              <Eye size={16} color={G.textMuted} />
            )}
          </button>
        </div>
        {err && (
          <p style={{ margin: 0, fontSize: "0.78rem", color: "rgba(255,100,100,0.90)" }}>{err}</p>
        )}
        {ok && (
          <p style={{ margin: 0, fontSize: "0.78rem", color: "rgba(80,220,120,0.90)" }}>
            {t.registerOk}
          </p>
        )}
        <button
          type="submit"
          style={{
            marginTop: 4,
            padding: "12px 0",
            borderRadius: 14,
            cursor: "pointer",
            border: `1px solid ${G.border}`,
            background: "rgba(255,255,255,0.12)",
            fontFamily: "inherit",
            fontSize: "0.88rem",
            fontWeight: 700,
            color: G.textPrimary,
            transition: "background 0.2s,box-shadow 0.2s,border-color 0.2s",
            boxShadow: G.shadow,
          }}
          onMouseEnter={(e) => {
            const el = e.currentTarget as HTMLElement;
            el.style.background = "rgba(255,255,255,0.20)";
            el.style.borderColor = G.borderHov;
          }}
          onMouseLeave={(e) => {
            const el = e.currentTarget as HTMLElement;
            el.style.background = "rgba(255,255,255,0.12)";
            el.style.borderColor = G.border;
          }}
        >
          {mode === "login" ? t.loginBtn : t.registerBtn}
        </button>
        {mode === "login" && (
          <button
            type="button"
            onClick={() => void handleForgot()}
            style={{
              marginTop: 2,
              background: "none",
              border: "none",
              cursor: "pointer",
              fontFamily: "inherit",
              fontSize: "0.76rem",
              fontWeight: 600,
              color: G.textSecondary,
              textDecoration: "underline",
              textUnderlineOffset: 3,
              padding: "4px 0",
              alignSelf: "flex-start",
            }}
          >
            {t.forgotPassword}
          </button>
        )}
        {resetMsg && (
          <p
            role="status"
            style={{ margin: 0, fontSize: "0.78rem", color: "rgba(80,220,120,0.90)" }}
          >
            {resetMsg}
          </p>
        )}
        {resetErr && (
          <p
            role="alert"
            style={{ margin: 0, fontSize: "0.78rem", color: "rgba(255,100,100,0.90)" }}
          >
            {resetErr}
          </p>
        )}
      </form>
      <p
        style={{
          margin: "14px 0 0",
          fontSize: "0.72rem",
          color: G.textMuted,
          textAlign: "center",
          lineHeight: 1.6,
        }}
      >
        {t.authHint}
      </p>
    </div>
  );
}

function SLabel({ Icon, label }: { Icon?: LucideIcon; label: string }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 12 }}>
      {Icon && <Icon size={13} color={G.textMuted} />}
      <span
        style={{
          fontSize: "0.68rem",
          fontWeight: 600,
          color: G.textMuted,
          letterSpacing: "0.08em",
          textTransform: "uppercase",
        }}
      >
        {label}
      </span>
    </div>
  );
}
