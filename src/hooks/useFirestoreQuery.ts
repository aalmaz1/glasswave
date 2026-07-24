import { useEffect, useMemo, useState } from "react";
import type {
  DocumentReference,
  DocumentSnapshot,
  Query,
  QuerySnapshot,
} from "firebase/firestore";
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
 * To avoid resubscribing on every render, pass a memoized query/document
 * reference or use the `deps` array to control when the subscription should
 * actually change.
 */
export function useFirestoreQuery<T = unknown>(
  getRef: () => DocumentReference<T> | Query<T> | null,
  deps: unknown[] = []
): FirestoreQueryResult<T> {
  const ref = useMemo(() => getRef(), deps);
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

    setState(prev => ({ ...prev, loading: true }));
    const unsubscribe = onSnapshot(
      ref,
      snapshot => {
        const data = isDocumentSnapshot(snapshot)
          ? snapshot.exists()
            ? snapshot.data()
            : null
          : snapshot.docs.map(doc => ({ ...(doc.data() as any), firestoreId: doc.id }));

        setState({
          data: data as T,
          loading: false,
          error: null,
          fromCache: snapshot.metadata.fromCache,
        });
      },
      error => {
        setState({ data: null, loading: false, error, fromCache: false });
      }
    );

    return unsubscribe;
  }, [ref]);

  return state;
}
