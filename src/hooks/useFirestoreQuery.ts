import { useEffect, useState } from "react";
import type { DocumentReference, DocumentSnapshot, Query, QuerySnapshot } from "firebase/firestore";
import { getFirebase } from "../firebase";

export type FirestoreQueryResult<T> = {
  data: T | T[] | null;
  loading: boolean;
  error: Error | null;
  fromCache: boolean;
};

const isDocumentSnapshot = <T>(
  snapshot: DocumentSnapshot<T> | QuerySnapshot<T>
): snapshot is DocumentSnapshot<T> => {
  return (snapshot as DocumentSnapshot<T>).exists !== undefined;
};

/**
 * Subscribe to a Firestore document or query using onSnapshot().
 *
 * This hook returns live-updated data, loading state, errors, and a
 * `fromCache` flag tracking whether the payload came from local cache.
 *
 * Pass a memoized query/document reference. A direct reference API keeps Hook
 * dependencies statically verifiable and makes subscription ownership clear.
 *
 * The Firestore SDK itself is imported lazily: a query reference can only be
 * built after the SDK has been loaded (see src/firebase.ts), so by the time a
 * subscription starts the module resolves from the module cache with no added
 * latency — but guests who never sign in never pay for it.
 */
export function useFirestoreQuery<T = unknown>(
  ref: DocumentReference<T> | Query<T> | null
): FirestoreQueryResult<T> {
  const [state, setState] = useState<FirestoreQueryResult<T>>({
    data: null,
    loading: Boolean(ref),
    error: null,
    fromCache: false,
  });

  useEffect(() => {
    if (!ref) {
      setState({ data: null, loading: false, error: null, fromCache: false });
      return;
    }

    let disposed = false;
    let unsubscribe: (() => void) | null = null;
    let subscribing = false;
    // Invalidates an in-flight subscription when stop() runs before the SDK
    // has finished resolving.
    let generation = 0;
    let watchdog: number | undefined;

    setState((prev) => ({ ...prev, loading: true, error: null }));

    // Firestore's BrowserChannel can keep a long-polling request open while a
    // tab is in the background. Browsers may then create thousands of heartbeat
    // requests for a tab nobody is looking at. The current snapshot remains in
    // state while hidden; resubscribing on return gets any changes made while
    // the tab was away and, importantly, gives the listener one clear owner.
    const stop = () => {
      if (watchdog !== undefined) window.clearTimeout(watchdog);
      watchdog = undefined;
      generation++;
      unsubscribe?.();
      unsubscribe = null;
      subscribing = false;
    };

    const start = () => {
      if (disposed || document.visibilityState === "hidden" || unsubscribe || subscribing) return;
      subscribing = true;
      const token = generation;

      let settled = false;
      setState((prev) => ({ ...prev, loading: true, error: null }));

      // Firestore normally emits an initial cache snapshot immediately. Storage
      // locks, a suspended network stack, or a broken proxy can prevent that
      // callback altogether, though. Do not leave the product behind a spinner.
      watchdog = window.setTimeout(() => {
        if (settled || disposed) return;
        setState((prev) => ({
          ...prev,
          loading: false,
          error: new Error("Firestore did not return an initial snapshot in time."),
        }));
      }, 10_000);

      void getFirebase().then(
        (fb) => {
          subscribing = false;
          if (disposed || token !== generation || document.visibilityState === "hidden") return;
          if (!fb) {
            if (watchdog !== undefined) window.clearTimeout(watchdog);
            watchdog = undefined;
            setState({ data: null, loading: false, error: null, fromCache: false });
            return;
          }
          unsubscribe = fb.fs.onSnapshot(
            ref as any,
            (snapshot: any) => {
              settled = true;
              if (watchdog !== undefined) window.clearTimeout(watchdog);
              watchdog = undefined;
              const data = isDocumentSnapshot(snapshot)
                ? snapshot.exists()
                  ? snapshot.data()
                  : null
                : snapshot.docs.map((doc: any) => ({ ...doc.data(), firestoreId: doc.id }));

              setState({
                data: data as T,
                loading: false,
                error: null,
                fromCache: snapshot.metadata.fromCache,
              });
            },
            (error: Error) => {
              settled = true;
              if (watchdog !== undefined) window.clearTimeout(watchdog);
              watchdog = undefined;
              unsubscribe = null;
              setState({ data: null, loading: false, error, fromCache: false });
            }
          );
        },
        (error: unknown) => {
          subscribing = false;
          if (disposed || token !== generation) return;
          if (watchdog !== undefined) window.clearTimeout(watchdog);
          watchdog = undefined;
          setState({
            data: null,
            loading: false,
            error: error instanceof Error ? error : new Error(String(error)),
            fromCache: false,
          });
        }
      );
    };

    const handleVisibilityChange = () => {
      if (document.visibilityState === "hidden") {
        stop();
      } else {
        start();
      }
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);
    if (document.visibilityState === "hidden") {
      setState((prev) => ({ ...prev, loading: false }));
    } else {
      start();
    }

    return () => {
      disposed = true;
      document.removeEventListener("visibilitychange", handleVisibilityChange);
      stop();
    };
  }, [ref]);

  return state;
}
