import { useEffect, useState } from "react";
import type { DocumentReference, DocumentSnapshot, Query, QuerySnapshot } from "firebase/firestore";
import { onSnapshot } from "firebase/firestore";

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

    let settled = false;
    setState((prev) => ({ ...prev, loading: true, error: null }));

    // Firestore normally emits an initial cache snapshot immediately. Browser
    // storage locks, a suspended network stack, or a broken proxy can prevent
    // that callback altogether, though. Never leave the product behind an
    // endless spinner: expose the existing retry state while keeping the live
    // listener active so a late snapshot can still recover automatically.
    const watchdog = window.setTimeout(() => {
      if (settled) return;
      setState((prev) => ({
        ...prev,
        loading: false,
        error: new Error("Firestore did not return an initial snapshot in time."),
      }));
    }, 10_000);

    const unsubscribe = onSnapshot(
      ref as any,
      (snapshot: any) => {
        settled = true;
        window.clearTimeout(watchdog);
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
        window.clearTimeout(watchdog);
        setState({ data: null, loading: false, error, fromCache: false });
      }
    );

    return () => {
      settled = true;
      window.clearTimeout(watchdog);
      unsubscribe();
    };
  }, [ref]);

  return state;
}
