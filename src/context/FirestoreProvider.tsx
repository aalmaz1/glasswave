import React, { ReactNode, useMemo } from "react";
import { db } from "../firebase";

export type FirestoreContextValue = {
  db: typeof db;
};

const FirestoreContext = React.createContext<FirestoreContextValue | null>(null);

export function FirestoreProvider({ children }: { children: ReactNode }) {
  const value = useMemo(() => ({ db }), []);
  return <FirestoreContext.Provider value={value}>{children}</FirestoreContext.Provider>;
}

export function useFirestore() {
  const context = React.useContext(FirestoreContext);
  if (!context) {
    throw new Error("useFirestore must be used within FirestoreProvider");
  }
  return context;
}
