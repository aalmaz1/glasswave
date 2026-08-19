import { useEffect, useRef } from "react";

const FOCUSABLE_SELECTOR =
  'a[href], button:not([disabled]), textarea:not([disabled]), input:not([disabled]), ' +
  'select:not([disabled]), [tabindex]:not([tabindex="-1"])';

/**
 * Reusable focus trap for modals/dialogs (accessibility).
 *
 * When `active` is true it:
 *  - moves focus into the dialog on open (first focusable, else the container),
 *  - keeps Tab/Shift-Tab cycling inside the dialog,
 *  - fires `onEscape` on Escape,
 *  - restores focus to the previously focused element on unmount.
 *
 * The Tab handler only acts while focus is *inside* its own container, so two
 * nested dialogs (e.g. the editor's "unsaved changes" confirm) can coexist:
 * only the topmost dialog traps the keyboard.
 */
export function useFocusTrap<T extends HTMLElement>(
  active: boolean,
  onEscape?: () => void
) {
  const ref = useRef<T | null>(null);
  const onEscapeRef = useRef(onEscape);
  onEscapeRef.current = onEscape;

  useEffect(() => {
    if (!active) return;
    const container = ref.current;
    if (!container) return;

    const previouslyFocused = document.activeElement as HTMLElement | null;
    const focusables = () =>
      Array.from(container.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR));

    // Prefer an explicitly marked element (e.g. the editor title input), then
    // the first focusable, then the container itself.
    const preferred = container.querySelector<HTMLElement>("[data-autofocus]");
    (preferred ?? focusables()[0] ?? container).focus();

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        onEscapeRef.current?.();
        return;
      }
      if (e.key !== "Tab") return;
      if (!container.contains(document.activeElement)) return; // another overlay owns focus

      const els = focusables();
      if (els.length === 0) {
        e.preventDefault();
        return;
      }
      const firstEl = els[0];
      const lastEl = els[els.length - 1];
      if (e.shiftKey && document.activeElement === firstEl) {
        e.preventDefault();
        lastEl.focus();
      } else if (!e.shiftKey && document.activeElement === lastEl) {
        e.preventDefault();
        firstEl.focus();
      }
    };

    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("keydown", handleKeyDown);
      previouslyFocused?.focus();
    };
  }, [active]);

  return ref;
}
