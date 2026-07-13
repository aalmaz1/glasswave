import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

/// Экран редактора заметки
class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  final FocusNode _bodyFocusNode = FocusNode();
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
    _titleController.addListener(() => setState(() => _isDirty = true));
    _bodyController.addListener(() => setState(() => _isDirty = true));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final body = _bodyController.text;
    
    if (title.isEmpty && body.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now();
    
    if (widget.note == null) {
      // Новая заметка
      final newNote = Note(
        id: now.millisecondsSinceEpoch,
        title: title.isEmpty ? 'Без названия' : title,
        body: body,
        updatedAt: now,
        accentIdx: 0,
        userEmail: ref.read(notesProvider).currentUserEmail ?? '',
      );
      ref.read(notesProvider.notifier).addNote(newNote);
    } else {
      // Обновление существующей
      final updatedNote = widget.note!.copyWith(
        title: title.isEmpty ? 'Без названия' : title,
        body: body,
        updatedAt: now,
      );
      ref.read(notesProvider.notifier).updateNote(updatedNote);
    }

    Navigator.pop(context);
  }

  void _applyFormat(String prefix, String suffix) {
    final selection = _bodyController.selection;
    if (!selection.isValid) return;

    final text = _bodyController.text;
    final selectedText = text.substring(selection.start, selection.end);
    
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );

    _bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length + suffix.length,
      ),
    );
  }

  void _applyLinePrefix(String prefix) {
    final selection = _bodyController.selection;
    if (!selection.isValid) return;

    final text = _bodyController.text;
    final lines = text.split('\n');
    
    // Найти строку с курсором
    int charCount = 0;
    int targetLineIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length >= selection.start) {
        targetLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1;
    }

    // Добавить префикс к строке
    final lineStart = charCount;
    final newLine = '$prefix${lines[targetLineIndex]}';
    lines[targetLineIndex] = newLine;

    final newText = lines.join('\n');
    final newOffset = selection.start + prefix.length;

    _bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = width >= 1280;
    final isTablet = width >= 768 && width < 1280;

    // Размеры для модалки на десктопе/планшете
    final modalWidth = isDesktop 
        ? (width * 0.62).clamp(0, 720)
        : isTablet 
            ? width * 0.82 
            : width;
    final modalHeight = isDesktop || isTablet ? height * 0.88 : height;

    final content = Container(
      color: const Color(0xFF121218),
      child: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                // Кнопка закрытия
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Лейбл
                Text(
                  isEditing ? 'Редактировать' : 'Новая заметка',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Кнопка сохранения
                GestureDetector(
                  onTap: _saveNote,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFFFB74D).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          color: Color(0xFFFFB74D),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Сохранить',
                          style: TextStyle(
                            color: Color(0xFFFFB74D),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // TITLE INPUT
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: TextField(
              controller: _titleController,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: 'Заголовок...',
                hintStyle: GoogleFonts.manrope(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
            ),
          ),
          // META
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.note != null
                      ? 'Изменено ${_formatDate(widget.note!.updatedAt)}'
                      : 'Создано сейчас',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.tag_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_getWordCount(_bodyController.text)} слов',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 24),
          // BODY TEXTAREA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _bodyController,
                focusNode: _bodyFocusNode,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.75,
                ),
                decoration: InputDecoration(
                  hintText: 'Начните писать...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 16,
                    height: 1.75,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
          // TOOLBAR
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                _ToolbarButton(
                  label: 'B',
                  onTap: () => _applyFormat('**', '**'),
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  label: 'I',
                  onTap: () => _applyFormat('_', '_'),
                ),
                const SizedBox(width: 16),
                _ToolbarButton(
                  icon: Icons.format_list_bulleted_rounded,
                  onTap: () => _applyLinePrefix('- '),
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  icon: Icons.format_list_numbered_rounded,
                  onTap: () => _applyLinePrefix('1. '),
                ),
                const SizedBox(width: 8),
                _ToolbarButton(
                  label: 'H1',
                  onTap: () => _applyLinePrefix('# '),
                ),
                const Spacer(),
                _ToolbarButton(
                  icon: Icons.link_rounded,
                  onTap: () => _applyFormat('[', '](url)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // На мобильном - fullscreen, на десктопе/планшете - модалка
    if (isDesktop || isTablet) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            // Modal
            Center(
              child: Container(
                width: modalWidth,
                height: modalHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF121218),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                clipBehavior: Clip.antiAlias,
                child: content,
              ),
            ),
          ],
        ),
      );
    }

    return content;
  }

  String _formatDate(DateTime date) {
    final months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${date.day} ${months[date.month - 1]}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ToolbarButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _ToolbarButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        // Не снимаем фокус с textarea
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: label != null
            ? Text(
                label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
      ),
    );
  }
}
