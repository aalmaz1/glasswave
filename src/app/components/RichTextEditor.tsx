import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Placeholder from '@tiptap/extension-placeholder';
import Underline from '@tiptap/extension-underline';
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

export const RichTextEditor: React.FC<RichTextEditorProps> = ({
  content,
  onChange,
  placeholder = 'Start writing...',
}) => {
  const editor = useEditor({
    extensions: [
      StarterKit.configure({
        heading: { levels: [1, 2, 3] },
      }),
      Underline,
      Placeholder.configure({
        placeholder,
        emptyNodeClass: 'is-editor-empty',
      }),
    ],
    content: content || '',
    onUpdate: ({ editor: ed }) => {
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
    if (!editor) return;
    if (content !== editor.getHTML()) {
      editor.commands.setContent(content || '', { emitUpdate: false });
    }
  }, [content, editor]);

  if (!editor) return null;

  return (
    <div className="rich-text-editor-container">
      <MenuBar editor={editor} />
      <EditorContent editor={editor} />
    </div>
  );
};
