import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme_data.dart';
import '../theme/design_tokens.dart';
import '../widgets/glass_container.dart';
import '../widgets/confirm_dialog.dart';

/// Opens the editor as a centered glass modal — same as the React Native
/// `EditorModal` (overlay, 62% / 82% / mobile width, 88vh/92dvh height).
Future<void> openEditorOverlay(BuildContext context, {Note? note}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'editor',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) => child,
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return EditorScreen(note: note);
    },
  );
}

class EditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  const EditorScreen({super.key, this.note});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  String _baselineTitle = '';
  String _baselineBody = '';
  int? _noteId;

  bool _restoring = false;
  List<String> _undoStack = [];
  List<String> _redoStack = [];
  String _lastBodyText = '';

  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _baselineTitle = widget.note?.title ?? '';
    _baselineBody = widget.note?.body ?? '';
    _noteId = widget.note?.id;
    _titleController = TextEditingController(text: _baselineTitle);
    _bodyController = TextEditingController(text: _baselineBody);
    _lastBodyText = _baselineBody;
    _titleController.addListener(_onTitleChanged);
    _bodyController.addListener(_onBodyChanged);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _titleController.text != _baselineTitle || _bodyController.text != _baselineBody;

  void _onTitleChanged() {
    if (mounted) setState(() {});
    _scheduleAutosave();
  }

  void _onBodyChanged() {
    final v = _bodyController.text;
    if (v == _lastBodyText) return;
    if (!_restoring) {
      _undoStack.add(_lastBodyText);
      if (_undoStack.length > 100) _undoStack.removeAt(0);
      _redoStack.clear();
    }
    _lastBodyText = v;
    if (mounted) setState(() {});
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    if (!_dirty) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 1500), _persistSilent);
  }

  String _dateLocale(String langCode) {
    switch (langCode) {
      case 'ru':
        return 'ru_RU';
      case 'ko':
        return 'ko_KR';
      default:
        return 'en_US';
    }
  }

  int get _wordCount {
    final text = _bodyController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  Note _buildNote() {
    final title = _titleController.text.trim().isEmpty
        ? tr('editor_no_title')
        : _titleController.text.trim();
    final body = _bodyController.text.trim();
    final prefs = ref.read(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final now = DateTime.now();
    if (widget.note == null && _noteId == null) {
      final id = now.millisecondsSinceEpoch;
      _noteId = id;
      return Note(
        id: id,
        title: title,
        body: body,
        updatedAt: now,
        accentIdx: now.millisecondsSinceEpoch % theme.accents.length,
      );
    }
    if (widget.note != null) {
      return widget.note!.copyWith(title: title, body: body, updatedAt: now);
    }
    final existing = ref.read(notesProvider.notifier).findById(_noteId!);
    return (existing ??
            Note(
              id: _noteId!,
              title: title,
              body: body,
              updatedAt: now,
              accentIdx: now.millisecondsSinceEpoch % theme.accents.length,
            ))
        .copyWith(title: title, body: body, updatedAt: now);
  }

  void _persistSilent() {
    if (_titleController.text.trim().isEmpty && _bodyController.text.trim().isEmpty) return;
    final created = _buildNote();
    final notifier = ref.read(notesProvider.notifier);
    if (widget.note == null) {
      notifier.upsert(created);
    } else {
      notifier.updateNote(created);
    }
    _baselineTitle = _titleController.text;
    _baselineBody = _bodyController.text;
    if (mounted) setState(() {});
  }

  void _save() {
    if (_titleController.text.trim().isEmpty && _bodyController.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    final note = _buildNote();
    final notifier = ref.read(notesProvider.notifier);
    if (widget.note == null) {
      notifier.upsert(note);
    } else {
      notifier.updateNote(note);
    }
    Navigator.pop(context);
  }

  Future<void> _requestClose() async {
    if (!_dirty) {
      Navigator.pop(context);
      return;
    }
    final choice = await showGlassConfirm(
      context,
      title: tr('unsaved_changes_title'),
      body: tr('unsaved_changes_body'),
      confirmLabel: tr('unsaved_save'),
      cancelLabel: tr('cancel'),
      extraLabel: tr('unsaved_discard'),
      danger: false,
    );
    if (!mounted) return;
    if (choice == GlassConfirmChoice.confirm) {
      _save();
    } else if (choice == GlassConfirmChoice.extra) {
      Navigator.pop(context);
    }
  }

  // ── Markdown helpers ──────────────────────────────────────────────
  void _insertFormat(String prefix, [String suffix = '']) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final selectedText = selection.textInside(text);
      final newText =
          text.replaceRange(selection.start, selection.end, '$prefix$selectedText$suffix');
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + prefix.length,
          extentOffset: selection.end + prefix.length,
        ),
      );
    } else {
      final currentPos = selection.baseOffset != -1 ? selection.baseOffset : text.length;
      final newText = text.replaceRange(currentPos, currentPos, '$prefix$suffix');
      _bodyController.text = newText;
      _bodyController.selection = TextSelection.collapsed(offset: currentPos + prefix.length);
    }
  }

  void _toggleLinePrefix(String prefix) {
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
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _restoring = true;
    _redoStack.add(_lastBodyText);
    final previous = _undoStack.removeLast();
    _bodyController.text = previous;
    _bodyController.selection = TextSelection.collapsed(offset: previous.length);
    _restoring = false;
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _restoring = true;
    _undoStack.add(_lastBodyText);
    final next = _redoStack.removeLast();
    _bodyController.text = next;
    _bodyController.selection = TextSelection.collapsed(offset: next.length);
    _restoring = false;
  }

  String _currentLine() {
    final text = _bodyController.text;
    final pos = _bodyController.selection.baseOffset;
    final caret = pos != -1 ? pos : text.length;
    final lineStart = text.lastIndexOf('\n', caret - 1);
    final start = lineStart == -1 ? 0 : lineStart + 1;
    final lineEnd = text.indexOf('\n', caret);
    final end = lineEnd == -1 ? text.length : lineEnd;
    return text.substring(start, end).trimLeft();
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1280;

    final mW = isMobile
        ? double.infinity
        : isTablet
            ? width * 0.82
            : math.min(720.0, width * 0.62);
    final mH = media.size.height * (isMobile ? 0.92 : 0.88);
    final screenRadius = isMobile ? 20.0 : 24.0;
    final today = DateFormat('d MMMM yyyy', _dateLocale(context.locale.languageCode))
        .format(DateTime.now());

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.escape): _requestClose,
        SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
        SingleActivator(LogicalKeyboardKey.keyS, meta: true): _save,
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _requestClose,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isMobile ? 0 : 2,
                  sigmaY: isMobile ? 0 : 2,
                ),
                child: Container(color: G.overlay),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
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
                child: SizedBox(
                  width: mW,
                  height: mH,
                  child: GlassContainer(
                    blur: 32,
                    borderRadius: screenRadius,
                    color: G.bg,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                    boxShadow: G.modalShadow,
                    fit: StackFit.expand,
                    child: Column(
                      children: [
                        // Header: close chip · "New note" · save chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GlassChip(
                                onTap: _requestClose,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.x, size: 14, color: G.textSecondary),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr('editor_close'),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: G.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isMobile && widget.note == null)
                                Text(
                                  tr('editor_new').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10.6,
                                    fontWeight: FontWeight.w500,
                                    color: G.textMuted,
                                    letterSpacing: 1.3,
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              GlassChip(
                                highlight: true,
                                onTap: _save,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.check, size: 14, color: G.textPrimary),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr('editor_save'),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: G.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Title
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: TextField(
                            controller: _titleController,
                            autofocus: true,
                            style: TextStyle(
                              color: G.textPrimary,
                              fontWeight: FontWeight.w300,
                              fontSize: isMobile ? 24 : 28,
                              letterSpacing: -0.7,
                            ),
                            decoration: InputDecoration(
                              hintText: tr('editor_title'),
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.24),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        // Meta row: date · words
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 6, 24, 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.clock, size: 10, color: G.textMuted),
                              const SizedBox(width: 8),
                              Text(
                                today,
                                style: const TextStyle(fontSize: 10.9, color: G.textMuted),
                              ),
                              const SizedBox(width: 8),
                              const Text('·', style: TextStyle(fontSize: 10.9, color: G.textMuted)),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.hash, size: 10, color: G.textMuted),
                              const SizedBox(width: 8),
                              Text(
                                '${_wordCount} ${tr('editor_words')}',
                                style: const TextStyle(fontSize: 10.9, color: G.textMuted),
                              ),
                            ],
                          ),
                        ),
                        // Body scroll area with formatting toolbar
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                            child: Column(
                              children: [
                                _buildToolbar(),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _bodyController,
                                    maxLines: null,
                                    minLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    keyboardType: TextInputType.multiline,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      height: 1.75,
                                      color: Colors.white.withValues(alpha: 0.82),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: tr('editor_body'),
                                      hintStyle: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.30),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final line = _currentLine();
    bool startsWith(String s) => line.startsWith(s);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Wrap(
            spacing: 2,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _FmtBtn('H1', () => _toggleLinePrefix('# '), active: startsWith('# ')),
              _FmtBtn('H2', () => _toggleLinePrefix('## '), active: startsWith('## ')),
              const _FmtSep(),
              _FmtBtn('B', () => _insertFormat('**', '**'),
                  active: _bodyController.text.contains('**')),
              _FmtBtn('I', () => _insertFormat('_', '_'),
                  active: _bodyController.text.contains('_')),
              _FmtBtn('S', () => _insertFormat('~~', '~~'),
                  active: _bodyController.text.contains('~~')),
              _FmtBtn('U', () => _insertFormat('__', '__'),
                  active: _bodyController.text.contains('__')),
              const _FmtSep(),
              _FmtBtn('•', () => _toggleLinePrefix('- '), active: startsWith('- ')),
              _FmtBtn('1.', () => _toggleLinePrefix('1. '),
                  active: RegExp(r'^\d+\. ').hasMatch(line)),
              _FmtBtn('❝', () => _toggleLinePrefix('> '), active: startsWith('> ')),
              _FmtBtn('</>', () {
                _insertFormat('```\n', '\n```');
              }),
              _FmtBtn('―', () {
                final text = _bodyController.text;
                final needsNl = text.isNotEmpty && !text.endsWith('\n') ? '\n' : '';
                _bodyController.text = '$text$needsNl\n---\n';
                _bodyController.selection =
                    TextSelection.collapsed(offset: _bodyController.text.length);
              }),
              const _FmtSep(),
              _FmtBtn('↶', _undo, active: false, disabled: _undoStack.isEmpty),
              _FmtBtn('↷', _redo, active: false, disabled: _redoStack.isEmpty),
            ],
          ),
        ),
      ),
    );
  }
}

class _FmtBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool disabled;

  const _FmtBtn(this.label, this.onTap, {this.active = false, this.disabled = false});

  @override
  State<_FmtBtn> createState() => _FmtBtnState();
}

class _FmtBtnState extends State<_FmtBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color color;
    if (widget.disabled) {
      bg = Colors.transparent;
      color = Colors.white.withValues(alpha: 0.18);
    } else if (widget.active) {
      bg = Colors.white.withValues(alpha: 0.18);
      color = Colors.white;
    } else if (_hovered) {
      bg = Colors.white.withValues(alpha: 0.12);
      color = Colors.white.withValues(alpha: 0.95);
    } else {
      bg = Colors.transparent;
      color = Colors.white.withValues(alpha: 0.55);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.disabled ? null : widget.onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 12.2,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _FmtSep extends StatelessWidget {
  const _FmtSep();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.14),
    );
  }
}
