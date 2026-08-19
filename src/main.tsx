/// <reference types="vite/client" />
import { createRoot } from "react-dom/client";
import "./styles/index.css";
import { LanguageProvider } from "./i18n";
import { AppErrorBoundary } from "./app/components/ErrorBoundary";
import { initNativeShell } from "./native";

void initNativeShell();

const rootEl = document.getElementById("root");

/** Static, pre-i18n configuration error shown when `.env` is missing. */
function renderConfigError(message: string) {
  if (!rootEl) return;
  const lang = (navigator.language || "ru").toLowerCase();
  const title =
    lang.startsWith("ko") ? "설정 오류" : lang.startsWith("en") ? "Configuration error" : "Ошибка конфигурации";
  const hint =
    lang.startsWith("ko")
      ? "Firebase 설정이 누락되었습니다. .env 파일을 만드세요 (.env.example 참조)."
      : lang.startsWith("en")
        ? "Firebase configuration is missing. Create a .env file (see .env.example)."
        : "Отсутствует конфигурация Firebase. Создайте файл .env (см. .env.example).";
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
    renderConfigError(error instanceof Error ? error.message : String(error));
  }
}

void bootstrap();
