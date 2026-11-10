// @vitest-environment jsdom
import { afterEach, describe, expect, it, vi } from "vitest";
import { cleanup, render, waitFor } from "@testing-library/react";
import React from "react";
import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import { LanguageProvider, loadTranslation } from "../../i18n";
import { RichTextEditor, syncEditorContent } from "./RichTextEditor";

afterEach(cleanup);

describe("RichTextEditor", () => {
  it("registers extensions without duplicate names (underline lives in StarterKit)", async () => {
    const t = await loadTranslation("en");
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});

    const { container } = render(
      <LanguageProvider initialLanguage="en" initialT={t}>
        <RichTextEditor content="<p>hello</p>" onChange={() => {}} placeholder="x" />
      </LanguageProvider>
    );

    await waitFor(() => {
      expect(container.querySelector(".rich-text-editor-container")).toBeTruthy();
    });

    const duplicates = warnSpy.mock.calls.filter((call) =>
      String(call[0]).includes("Duplicate extension names")
    );
    expect(duplicates).toEqual([]);
    warnSpy.mockRestore();
  });

  it("renders the underline toolbar button from the StarterKit mark", async () => {
    const t = await loadTranslation("en");
    const { findByTitle } = render(
      <LanguageProvider initialLanguage="en" initialT={t}>
        <RichTextEditor content="" onChange={() => {}} placeholder="x" />
      </LanguageProvider>
    );
    expect(await findByTitle(t.fmtUnderline)).toBeTruthy();
  });
});

describe("syncEditorContent", () => {
  function createEditor() {
    return new Editor({
      extensions: [
        StarterKit.configure({
          heading: { levels: [1, 2, 3] },
        }),
      ],
      content: "<p>a</p>",
    });
  }

  it("updates a live editor when content drifts", () => {
    const editor = createEditor();
    syncEditorContent(editor, "<p>b</p>");
    expect(editor.getHTML()).toContain("b");
    editor.destroy();
  });

  it("survives a destroyed editor (production crash: getHTML after destroy)", () => {
    const editor = createEditor();
    editor.destroy();

    // This is exactly what crashed the deployed app:
    // TypeError: Cannot read properties of null (reading 'cached')
    expect(() => editor.getHTML()).toThrow();

    // The guard must swallow it instead of propagating to the UI.
    expect(() => syncEditorContent(editor, "<p>b</p>")).not.toThrow();
    expect(() => syncEditorContent(null, "<p>b</p>")).not.toThrow();
    expect(() => syncEditorContent(undefined, "<p>b</p>")).not.toThrow();
  });
});
