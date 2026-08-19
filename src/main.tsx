/// <reference types="vite/client" />
import { createRoot } from "react-dom/client";
import "./styles/index.css";
import { LanguageProvider } from "./i18n";
import { AppErrorBoundary } from "./app/components/ErrorBoundary";
import { initNativeShell } from "./native";

void initNativeShell();

const rootEl = document.getElementById("root");

/** Static, pre-i18n fallback shown if the app module fails to load. */
function renderStartupError(message: string) {
  if (!rootEl) return;
  const lang = (navigator.language || "ru").toLowerCase();
  const title =
    lang.startsWith("ko") ? "시작 오류" : lang.startsWith("en") ? "Startup error" : "Ошибка запуска";
  const hint =
    lang.startsWith("ko")
      ? "앱을 시작하지 못했습니다. 페이지를 새로고침하세요."
      : lang.startsWith("en")
        ? "GlassWave failed to start. Reload the page and try again."
        : "Не удалось запустить GlassWave. Обновите страницу и повторите попытку.";
  rootEl.innerHTML = `
    <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:#0b0b1a;color:#fff;font-family:system-ui,sans-serif;padding:24px">
      <div style="max-width:460px;text-align:center">
        <h1 style="font-size:1.2rem;margin:0 0 12px">${title}</h1>
        <p style="color:rgba(255,255,255,0.6);font-size:0.88rem;line-height:1.6;margin:0 0 16px">${hint}</p>
        <code style="display:block;font-size:0.72rem;color:rgba(255,255,255,0.4);word-break:break-all">${message}</code>
      </div>
    </div>`;
}

async function bootstrap() {
  try {
    const [{ default: App }] = await Promise.all([import("./app/App")]);
    if (rootEl) {
      createRoot(rootEl).render(
        <LanguageProvider>
          <AppErrorBoundary>
            <App />
          </AppErrorBoundary>
        </LanguageProvider>
      );
    }
  } catch (error) {
    console.error("[GlassWave] Failed to start:", error);
    renderStartupError(error instanceof Error ? error.message : String(error));
  }
}

void bootstrap();
