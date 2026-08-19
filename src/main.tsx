/// <reference types="vite/client" />
import { createRoot } from "react-dom/client";
import App from "./app/App";
import "./styles/index.css";
import { LanguageProvider } from "./i18n";
import { AppErrorBoundary } from "./app/components/ErrorBoundary";
import { initNativeShell } from "./native";

void initNativeShell();

const rootEl = document.getElementById("root");
if (rootEl) {
  createRoot(rootEl).render(
    <LanguageProvider>
      <AppErrorBoundary>
        <App />
      </AppErrorBoundary>
    </LanguageProvider>
  );
}
