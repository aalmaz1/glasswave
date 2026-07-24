import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Underline from '@tiptap/extension-underline';
import React, { useEffect } from 'react';

interface RichTextEditorProps {
  content: string;
  onChange: (html: string) => void;
  placeholder?: string;
}

const MenuBar = ({ editor }: { editor: any }) => {
  if (!editor) return null;

  return (
    <div className="rich-text-toolbar">
      <button
        onClick={() => editor.chain().focus().toggleHeading({ level: 1 }).run()}
        className={editor.isActive('heading', { level: 1 }) ? 'is-active' : ''}
        title="Заголовок 1"
      >
        H1
      </button>
      <button
        onClick={() => editor.chain().focus().toggleHeading({ level: 2 }).run()}
        className={editor.isActive('heading', { level: 2 }) ? 'is-active' : ''}
        title="Заголовок 2"
      >
        H2
      </button>
      <button
        onClick={() => editor.chain().focus().toggleBold().run()}
        className={editor.isActive('bold') ? 'is-active' : ''}
        title="Жирный"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <path d="M6 4h8a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z"/>
          <path d="M6 12h9a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleItalic().run()}
        className={editor.isActive('italic') ? 'is-active' : ''}
        title="Курсив"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <line x1="19" y1="4" x2="10" y2="4"/>
          <line x1="14" y1="20" x2="5" y2="20"/>
          <line x1="15" y1="4" x2="9" y2="20"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleStrike().run()}
        className={editor.isActive('strike') ? 'is-active' : ''}
        title="Зачёркнутый"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <path d="M16 4H9a3 3 0 0 0-2.83 4"/>
          <path d="M14 12a4 4 0 0 1 0 8H6"/>
          <line x1="4" y1="12" x2="20" y2="12"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleUnderline().run()}
        className={editor.isActive('underline') ? 'is-active' : ''}
        title="Подчёркнутый"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <path d="M6 3v7a6 6 0 0 0 6 6 6 6 0 0 0 6-6V3"/>
          <line x1="4" y1="21" x2="20" y2="21"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleBulletList().run()}
        className={editor.isActive('bulletList') ? 'is-active' : ''}
        title="Маркированный список"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <circle cx="9" cy="12" r="1"/>
          <circle cx="9" cy="5" r="1"/>
          <circle cx="9" cy="19" r="1"/>
          <line x1="13" y1="12" x2="21" y2="12"/>
          <line x1="13" y1="5" x2="21" y2="5"/>
          <line x1="13" y1="19" x2="21" y2="19"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleOrderedList().run()}
        className={editor.isActive('orderedList') ? 'is-active' : ''}
        title="Нумерованный список"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <line x1="10" y1="6" x2="21" y2="6"/>
          <line x1="10" y1="12" x2="21" y2="12"/>
          <line x1="10" y1="18" x2="21" y2="18"/>
          <path d="M4 6h1v4"/>
          <path d="M4 10h2"/>
          <path d="M6 18H4c0-1 2-2 2-3s-1-1.5-2-1"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleBlockquote().run()}
        className={editor.isActive('blockquote') ? 'is-active' : ''}
        title="Цитата"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <path d="M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V20c0 1 0 1 1 1z"/>
          <path d="M15 21c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.237 0 3-3 3s-3 1-3 3c0 1 0 1 1 1z"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleCodeBlock().run()}
        className={editor.isActive('codeBlock') ? 'is-active' : ''}
        title="Блок кода"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <polyline points="16 18 22 12 16 6"/>
          <polyline points="8 6 2 12 8 18"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().setHorizontalRule().run()}
        title="Горизонтальная линия"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <line x1="3" y1="12" x2="21" y2="12"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().undo().run()}
        disabled={!editor.can().undo()}
        title="Отменить"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <path d="M3 7v6h6"/>
          <path d="M21 17a9 9 0 0 0-9-9 9 9 0 0 0-6 2.3L3 13"/>
        </svg>
      </button>
      <button
        onClick={() => editor.chain().focus().redo().run()}
        disabled={!editor.can().redo()}
        title="Вернуть"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
          <path d="M21 7v6h-6"/>
          <path d="M3 17a9 9 0 0 1 9-9 9 9 0 0 1 6 2.3l3 3.7"/>
        </svg>
      </button>
    </div>
  );
};

export const RichTextEditor: React.FC<RichTextEditorProps> = ({ 
  content, 
  onChange,
  placeholder = "Начните писать..."
}) => {
  const editor = useEditor({
    extensions: [
      StarterKit.configure({
        heading: {
          levels: [1, 2, 3],
        },
        underline: false,
      }),
      Underline,
    ],
    content: content || '',
    onUpdate: ({ editor }) => {
      onChange(editor.getHTML());
    },
    editorProps: {
      attributes: {
        class: 'rich-text-content',
      },
    },
  });

  // Обновляем содержимое редактора при изменении внешнего content
  useEffect(() => {
    if (editor && content !== editor.getHTML()) {
      editor.commands.setContent(content || '', false);
    }
  }, [content, editor]);

  if (!editor) {
    return null;
  }

  return (
    <div className="rich-text-editor-container">
      <EditorContent editor={editor} />
      <MenuBar editor={editor} />
    </div>
  );
};
