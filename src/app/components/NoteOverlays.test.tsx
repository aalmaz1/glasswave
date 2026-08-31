// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import en from "../../i18n/lang/en";
import type { Note } from "../model";
import { ReminderModal } from "./NoteOverlays";

vi.mock("../../notifications", () => ({
  ensureNotificationPermission: vi.fn(),
}));

import { ensureNotificationPermission } from "../../notifications";

const note: Note = {
  id: 1,
  title: "Groceries",
  body: "Milk",
  updatedAt: new Date(),
  createdAt: new Date(),
  accentIdx: 0,
  pinned: false,
  archived: false,
  trashed: false,
  reminder: null,
};

describe("ReminderModal", () => {
  beforeEach(() => {
    vi.mocked(ensureNotificationPermission).mockReset();
    vi.mocked(ensureNotificationPermission).mockResolvedValue(true);
  });
  afterEach(() => {
    cleanup();
  });

  it("awaits notification permission before saving so the system dialog can show", async () => {
    let resolvePerm!: (v: boolean) => void;
    vi.mocked(ensureNotificationPermission).mockImplementation(
      () =>
        new Promise<boolean>((resolve) => {
          resolvePerm = resolve;
        })
    );
    const onSave = vi.fn();
    render(<ReminderModal note={note} onSave={onSave} onClose={() => {}} language="en" t={en} />);

    fireEvent.click(screen.getByText(en.reminderToday));
    fireEvent.click(screen.getByRole("button", { name: en.reminderSave }));

    expect(ensureNotificationPermission).toHaveBeenCalledTimes(1);
    expect(onSave).not.toHaveBeenCalled();

    resolvePerm(true);
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1));
    const saved = onSave.mock.calls[0][0] as Date;
    expect(saved).toBeInstanceOf(Date);
    expect(Number.isNaN(saved.getTime())).toBe(false);
  });

  it("still saves the reminder if the user denies permission", async () => {
    vi.mocked(ensureNotificationPermission).mockResolvedValue(false);
    const onSave = vi.fn();
    render(<ReminderModal note={note} onSave={onSave} onClose={() => {}} language="en" t={en} />);
    fireEvent.click(screen.getByText(en.reminderTomorrow));
    fireEvent.click(screen.getByRole("button", { name: en.reminderSave }));
    await waitFor(() => expect(onSave).toHaveBeenCalledTimes(1));
  });
});
