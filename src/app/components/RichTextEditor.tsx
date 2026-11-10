import { useEditor, EditorContent } from '@tiptap/react';
import type { Editor } from '@tiptap/core';
import StarterKit from '@tiptap/starter-kit';
import Placeholder from '@tiptap/extension-placeholder';
import React, { useEffect } from 'react';
import { useTranslation } from '../../i18n';

interface RichTextEditorProps {
  content: string;
  onChange: (html: string) => void;
  placeholder?: string;
}

const ToolbarBtn = ({
  onClick,
  isActive,
  disabled,
  title,
  children,
}: {
  onClick: () => void;
  isActive?: boolean;
  disabled?: boolean;
  title: string;
  children: React.ReactNode;
}) => (
  <button
    type="button"
    onClick={onClick}
    disabled={disabled}
    title={title}
    aria-label={title}
    className={`rt-btn${isActive ? ' is-active' : ''}`}
  >
    {children}
  </button>
);

const MenuBar = ({
  editor,
}: {
  editor: ReturnType<typeof useEditor>;
}) => {
  const { t } = useTranslation();
  if (!editor) return null;

  return (
    <div className="rich-text-toolbar">
      <ToolbarBtn onClick={() => editor.chain().focus().toggleHeading({ level: 1 }).run()} isActive={editor.isActive('heading', { level: 1 })} title={t.fmtH1}>H1</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleHeading({ level: 2 }).run()} isActive={editor.isActive('heading', { level: 2 })} title={t.fmtH2}>H2</ToolbarBtn>
      <span className="rt-sep" />
      <ToolbarBtn onClick={() => editor.chain().focus().toggleBold().run()} isActive={editor.isActive('bold')} title={t.fmtBold}>
        <b>B</b>
      </ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleItalic().run()} isActive={editor.isActive('italic')} title={t.fmtItalic}>
        <i>I</i>
      </ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleStrike().run()} isActive={editor.isActive('strike')} title={t.fmtStrike}>
        <s>S</s>
      </ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleUnderline().run()} isActive={editor.isActive('underline')} title={t.fmtUnderline}>
        <u>U</u>
      </ToolbarBtn>
      <span className="rt-sep" />
      <ToolbarBtn onClick={() => editor.chain().focus().toggleBulletList().run()} isActive={editor.isActive('bulletList')} title={t.fmtBullet}>•</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleOrderedList().run()} isActive={editor.isActive('orderedList')} title={t.fmtOrdered}>1.</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleBlockquote().run()} isActive={editor.isActive('blockquote')} title={t.fmtQuote}>❝</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleCodeBlock().run()} isActive={editor.isActive('codeBlock')} title={t.fmtCode}>{`</>`}</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().setHorizontalRule().run()} title={t.fmtHr}>―</ToolbarBtn>
      <span className="rt-sep" />
      <ToolbarBtn onClick={() => editor.chain().focus().undo().run()} disabled={!editor.can().undo()} title={t.fmtUndo}>↶</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().redo().run()} disabled={!editor.can().redo()} title={t.fmtRedo}>↷</ToolbarBtn>
    </div>
  );
};

/**
 * Push external content into the editor if it drifted.
 *
 * Guarded against destroyed editors: `useEditor` can schedule destruction on a
 * timer (unmount/remount races under Suspense), and React may still flush a
 * pending effect that holds the old instance. Reading `getHTML()` after
 * `destroy()` throws `TypeError: Cannot read properties of null (reading
 * 'cached')` because the schema is torn down with the editor.
 */
export function syncEditorContent(editor: Editor | null | undefined, content: string): void {
  if (!editor || editor.isDestroyed) return;
  if (content !== editor.getHTML()) {
    editor.commands.setContent(content || '', { emitUpdate: false });
  }
}

export const RichTextEditor: React.FC<RichTextEditorProps> = ({
  content,
  onChange,
  placeholder = 'Start writing...',
}) => {
  const editor = useEditor({
    extensions: [
      // NOTE: StarterKit already bundles the underline mark (@tiptap/
      // extension-underline) — adding it again produces "Duplicate extension
      // names" and corrupts the editor schema. Do not re-add it here.
      StarterKit.configure({
        heading: { levels: [1, 2, 3] },
      }),
      Placeholder.configure({
        placeholder,
        emptyNodeClass: 'is-editor-empty',
      }),
    ],
    content: content || '',
    onUpdate: ({ editor: ed }) => {
      // The editor can already be destroyed when deferred updates land
      // (TipTap schedules destruction on a timer); never read from it then.
      if (ed.isDestroyed) return;
      onChange(ed.getHTML());
    },
    editorProps: {
      attributes: {
        class: 'rich-text-content',
      },
    },
  });

  // Sync external content changes (e.g. opening another note)
  useEffect(() => {
    syncEditorContent(editor, content);
  }, [content, editor]);

  if (!editor) return null;

  return (
    <div className="rich-text-editor-container">
      <MenuBar editor={editor} />
      <EditorContent editor={editor} />
    </div>
  );
};
