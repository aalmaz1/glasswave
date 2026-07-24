
  import { createRoot } from "react-dom/client";
  import App from "./app/App.tsx";
import { FirestoreProvider } from "./context/FirestoreProvider";
import "./styles/index.css";

createRoot(document.getElementById("root")!).render(
  <FirestoreProvider>
    <App />
  </FirestoreProvider>
);
  