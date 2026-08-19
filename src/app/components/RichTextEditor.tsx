import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Underline from '@tiptap/extension-underline';
import Placeholder from '@tiptap/extension-placeholder';
import React, { useEffect } from 'react';

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
  t,
}: {
  editor: ReturnType<typeof useEditor>;
  t: {
    h1: string; h2: string; bold: string; italic: string; strike: string; underline: string;
    bullet: string; ordered: string; quote: string; code: string; hr: string;
    undo: string; redo: string;
  };
}) => {
  if (!editor) return null;

  return (
    <div className="rich-text-toolbar">
      <ToolbarBtn onClick={() => editor.chain().focus().toggleHeading({ level: 1 }).run()} isActive={editor.isActive('heading', { level: 1 })} title={t.h1}>H1</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleHeading({ level: 2 }).run()} isActive={editor.isActive('heading', { level: 2 })} title={t.h2}>H2</ToolbarBtn>
      <span className="rt-sep" />
      <ToolbarBtn onClick={() => editor.chain().focus().toggleBold().run()} isActive={editor.isActive('bold')} title={t.bold}>
        <b>B</b>
      </ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleItalic().run()} isActive={editor.isActive('italic')} title={t.italic}>
        <i>I</i>
      </ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleStrike().run()} isActive={editor.isActive('strike')} title={t.strike}>
        <s>S</s>
      </ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleUnderline().run()} isActive={editor.isActive('underline')} title={t.underline}>
        <u>U</u>
      </ToolbarBtn>
      <span className="rt-sep" />
      <ToolbarBtn onClick={() => editor.chain().focus().toggleBulletList().run()} isActive={editor.isActive('bulletList')} title={t.bullet}>•</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleOrderedList().run()} isActive={editor.isActive('orderedList')} title={t.ordered}>1.</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleBlockquote().run()} isActive={editor.isActive('blockquote')} title={t.quote}>❝</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().toggleCodeBlock().run()} isActive={editor.isActive('codeBlock')} title={t.code}>{`</>`}</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().setHorizontalRule().run()} title={t.hr}>―</ToolbarBtn>
      <span className="rt-sep" />
      <ToolbarBtn onClick={() => editor.chain().focus().undo().run()} disabled={!editor.can().undo()} title={t.undo}>↶</ToolbarBtn>
      <ToolbarBtn onClick={() => editor.chain().focus().redo().run()} disabled={!editor.can().redo()} title={t.redo}>↷</ToolbarBtn>
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
      <MenuBar
        editor={editor}
        t={{
          h1: 'Heading 1', h2: 'Heading 2', bold: 'Bold', italic: 'Italic',
          strike: 'Strikethrough', underline: 'Underline', bullet: 'Bullet list',
          ordered: 'Ordered list', quote: 'Quote', code: 'Code block', hr: 'Horizontal rule',
          undo: 'Undo', redo: 'Redo',
        }}
      />
      <EditorContent editor={editor} />
    </div>
  );
};
