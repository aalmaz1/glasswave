import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/note.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme_data.dart';
import '../widgets/glass_container.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  const EditorScreen({super.key, this.note});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late FocusNode _bodyFocusNode;
  final bool _isPreview = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _bodyController = TextEditingController(text: widget.note?.body ?? "");
    _bodyFocusNode = FocusNode();
    _bodyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim().isEmpty ? tr('editor_no_title') : _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final prefs = ref.read(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);

    if (widget.note == null) {
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        body: body,
        updatedAt: DateTime.now(),
        accentIdx: (DateTime.now().millisecondsSinceEpoch % theme.accents.length),
      );
      ref.read(notesProvider.notifier).addNote(newNote);
    } else {
      final updatedNote = widget.note!.copyWith(
        title: title,
        body: body,
        updatedAt: DateTime.now(),
      );
      ref.read(notesProvider.notifier).updateNote(updatedNote);
    }
    Navigator.pop(context);
  }

  void _insertFormat(String prefix, [String suffix = ""]) {
    if (_isPreview) return;
    final text = _bodyController.text;
    final selection = _bodyController.selection;

    if (selection.isValid && !selection.isCollapsed) {
      final selectedText = selection.textInside(text);
      final newText = text.replaceRange(selection.start, selection.end, "$prefix$selectedText$suffix");
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + prefix.length,
          extentOffset: selection.end + prefix.length,
        ),
      );
    } else {
      final currentPos = selection.baseOffset != -1 ? selection.baseOffset : text.length;
      final newText = text.replaceRange(currentPos, currentPos, "$prefix$suffix");
      _bodyController.text = newText;
      _bodyController.selection = TextSelection.collapsed(offset: currentPos + prefix.length);
    }
    _bodyFocusNode.requestFocus();
  }

  void _toggleLinePrefix(String prefix) {
    if (_isPreview) return;
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    final currentPos = selection.baseOffset != -1 ? selection.baseOffset : text.length;

    int lineStart = text.lastIndexOf('\n', currentPos - 1);
    if (lineStart == -1) lineStart = 0;
    int lineEnd = text.indexOf('\n', currentPos);
    if (lineEnd == -1) lineEnd = text.length;

    final line = text.substring(lineStart, lineEnd);
    final trimmed = line.trimLeft();

    if (trimmed.startsWith(prefix)) {
      final newLine = line.replaceFirst(prefix, '');
      final newText = text.replaceRange(lineStart, lineEnd, newLine);
      _bodyController.text = newText;
      final newPos = (currentPos - lineStart - prefix.length).clamp(0, newLine.length);
      _bodyController.selection = TextSelection.collapsed(offset: lineStart + newPos);
    } else {
      final newLine = line.replaceFirst(RegExp(r'^\s*'), prefix);
      final newText = text.replaceRange(lineStart, lineEnd, newLine);
      _bodyController.text = newText;
      final newPos = currentPos + prefix.length;
      _bodyController.selection = TextSelection.collapsed(offset: newPos);
    }
    _bodyFocusNode.requestFocus();
  }

  int get _wordCount => _bodyController.text.trim().isEmpty ? 0 : _bodyController.text.trim().split(RegExp(r'\s+')).length;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final localeCode = context.locale.languageCode;
    
    final today = DateFormat("d MMMM yyyy", localeCode == 'ru' ? 'ru_RU' : 'en_US').format(DateTime.now());
    final width = MediaQuery.of(context).size.width;

    double modalWidth = width;
    if (width >= 1280) {
      modalWidth = (width * 0.62).clamp(0, 720);
    } else if (width >= 768) {
      modalWidth = width * 0.82;
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _save,
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.pop(context),
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: const Cubic(0.34, 1.46, 0.64, 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 22 * (1 - value)),
                child: Transform.scale(
                  scale: 0.97 + (0.03 * value),
                  child: Opacity(opacity: value, child: child),
                ),
              );
            },
            child: Container(
              width: modalWidth,
              height: width < 768 ? double.infinity : MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                gradient: theme.bg,
                borderRadius: width < 768 ? BorderRadius.zero : BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  if (width >= 768) const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _headerAction(LucideIcons.x, tr('editor_close'), () => Navigator.pop(context)),
                        Text(widget.note == null ? tr('editor_new') : tr('editor_edit'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                        Row(
                          children: [
                            if (width >= 768)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text("⌘S · Esc", style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 10, fontFamily: 'monospace')),
                              ),
                            _headerAction(LucideIcons.check, tr('editor_save'), _save, highlight: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              hintText: tr('editor_title'),
                              hintStyle: const TextStyle(color: Colors.white24),
                              border: InputBorder.none,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(LucideIcons.clock, size: 10, color: Colors.white30),
                              const SizedBox(width: 4),
                              Text(today, style: const TextStyle(color: Colors.white30, fontSize: 10)),
                              const SizedBox(width: 8),
                              const Text("·", style: TextStyle(color: Colors.white30, fontSize: 10)),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.hash, size: 10, color: Colors.white30),
                              const SizedBox(width: 4),
                              Text("$_wordCount ${tr('editor_words')}", style: const TextStyle(color: Colors.white30, fontSize: 10)),
                            ],
                          ),
                          const Divider(color: Colors.white10, height: 32),
                          Expanded(
                            child: _isPreview 
                              ? Markdown(
                                  data: _bodyController.text,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16, height: 1.75),
                                    h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    em: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                                    listBullet: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                                  ),
                                )
                              : TextField(
                                  controller: _bodyController,
                                  focusNode: _bodyFocusNode,
                                  maxLines: null,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16, height: 1.75, fontFamily: 'Inter'),
                                  decoration: InputDecoration(
                                    hintText: tr('editor_body'),
                                    hintStyle: const TextStyle(color: Colors.white24),
                                    border: InputBorder.none,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildToolbar(width),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerAction(IconData icon, String label, VoidCallback onTap, {bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 12,
        blur: 16,
        color: highlight ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 14, color: highlight ? Colors.white : Colors.white60),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: highlight ? Colors.white : Colors.white60, fontSize: 12, fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(double width) {
    if (_isPreview) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          _fmtBtn("B", () => _insertFormat("**", "**")),
          _fmtBtn("I", () => _insertFormat("_", "_")),
          _fmtBtn("UL", () => _toggleLinePrefix("- ")),
          _fmtBtn("OL", () => _toggleLinePrefix("1. ")),
          _fmtBtn("H1", () => _toggleLinePrefix("# ")),
          IconButton(
            onPressed: () => _insertFormat("[", "](url)"),
            icon: const Icon(LucideIcons.link2, size: 14, color: Colors.white30),
          ),
          if (width >= 768) ...[
            const Spacer(),
            const Text("Esc · ⌘S", style: TextStyle(color: Colors.white10, fontSize: 10, fontFamily: 'monospace')),
          ],
        ],
      ),
    );
  }

  Widget _fmtBtn(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(40, 30),
        padding: EdgeInsets.zero,
      ),
      child: Text(label, style: const TextStyle(color: Colors.white30, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
