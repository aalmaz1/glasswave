// @vitest-environment jsdom
import { describe, it, expect, vi, afterEach } from "vitest";
import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import en from "../../i18n/lang/en";
import type { Note } from "../model";
import { ReminderModal } from "./NoteOverlays";

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
  afterEach(() => {
    cleanup();
  });

  it("saves the reminder immediately on tap — it must not wait on the notification bridge", () => {
    const onSave = vi.fn();
    render(<ReminderModal note={note} onSave={onSave} onClose={() => {}} language="en" t={en} />);

    fireEvent.click(screen.getByText(en.reminderToday));
    fireEvent.click(screen.getByRole("button", { name: en.reminderSave }));

    // Synchronously — a hung Capacitor permission call used to freeze the modal.
    expect(onSave).toHaveBeenCalledTimes(1);
    const saved = onSave.mock.calls[0][0] as Date;
    expect(saved).toBeInstanceOf(Date);
    expect(Number.isNaN(saved.getTime())).toBe(false);
  });

  it("saves a custom date/time entered in the input", () => {
    const onSave = vi.fn();
    render(<ReminderModal note={note} onSave={onSave} onClose={() => {}} language="en" t={en} />);

    const input = document.querySelector('input[type="datetime-local"]') as HTMLInputElement;
    const future = new Date(Date.now() + 3 * 60 * 60 * 1000);
    const pad = (n: number) => String(n).padStart(2, "0");
    const value = `${future.getFullYear()}-${pad(future.getMonth() + 1)}-${pad(future.getDate())}T${pad(future.getHours())}:${pad(future.getMinutes())}`;
    fireEvent.change(input, { target: { value } });
    fireEvent.click(screen.getByRole("button", { name: en.reminderSave }));

    expect(onSave).toHaveBeenCalledTimes(1);
    expect((onSave.mock.calls[0][0] as Date).getHours()).toBe(future.getHours());
  });

  it("ignores taps while no date is selected", () => {
    const onSave = vi.fn();
    render(<ReminderModal note={note} onSave={onSave} onClose={() => {}} language="en" t={en} />);
    fireEvent.click(screen.getByRole("button", { name: en.reminderSave }));
    expect(onSave).not.toHaveBeenCalled();
  });
});
