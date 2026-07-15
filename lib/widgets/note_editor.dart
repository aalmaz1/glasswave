import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';

/// Редактор заметок с форматированием текста
class NoteEditor extends StatefulWidget {
  final Note? note;
  final Function(Note) onSave;
  final VoidCallback onClose;

  const NoteEditor({
    super.key,
    this.note,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  final GlobalKey _bodyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  /// Вставить текст форматирования в выделенную позицию
  void _insertFormat(String before, [String? after]) {
    final bodyField = _bodyKey.currentState as RenderObject?;
    if (bodyField == null) return;

    final selection = _bodyController.selection;
    if (selection.baseOffset == -1) {
      // Нет выделения - вставляем в конец
      _bodyController.text += before + (after ?? '');
      return;
    }

    final selectedText = _bodyController.text.substring(
      selection.baseOffset,
      selection.extentOffset,
    );

    final newText = _bodyController.text.replaceRange(
      selection.baseOffset,
      selection.extentOffset,
      '$before$selectedText${after ?? ''}',
    );

    setState(() {
      _bodyController.text = newText;
      _bodyController.selection = TextSelection(
        baseOffset: selection.baseOffset + before.length,
        extentOffset: selection.extentOffset + before.length + (after?.length ?? 0),
      );
    });
  }

  /// Сохранить заметку
  void _save() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      widget.onClose();
      return;
    }

    final note = widget.note?.copyWith(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
    ) ?? Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
    );

    widget.onSave(note);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Затемнение фона
        ModalBarrier(
          color: Colors.black.withOpacity(0.5),
          dismissible: true,
          onDismiss: widget.onClose,
        ),
        // Центрированное модальное окно
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(30, 30, 30, 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Заголовок редактора
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: widget.onClose,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Заголовок',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('Сохранить'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Тулбар форматирования
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _formatButton('**B**', () => _insertFormat('**', '**')),
                            _formatButton('*I*', () => _insertFormat('_', '_')),
                            const VerticalDivider(width: 20, color: Colors.white24),
                            _formatButton('# H', () => _insertFormat('# ')),
                            _formatButton('- L', () => _insertFormat('- ')),
                            _formatButton('1. L', () => _insertFormat('1. ')),
                            const VerticalDivider(width: 20, color: Colors.white24),
                            _formatButton('🔗', () => _insertFormat('[', '](url)')),
                          ],
                        ),
                      ),
                    ),
                    // Тело заметки
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          key: _bodyKey,
                          controller: _bodyController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.6,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Текст заметки...\n\nПоддерживается простое форматирование:\n**жирный**, _курсив_, # заголовок, - список',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formatButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }
}
