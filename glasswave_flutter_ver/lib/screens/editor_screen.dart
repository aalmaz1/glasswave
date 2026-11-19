import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../providers/app_providers.dart';
import '../services/date_formats.dart';
import '../theme/app_theme_data.dart';
import '../theme/design_tokens.dart';
import '../widgets/glass_container.dart';

Future<void> openEditorOverlay(
  BuildContext context, {
  Note? note,
  bool asNewNote = false,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'editor',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curvedAnimation),
          child: child,
        ),
      );
    },
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return EditorScreen(note: note, asNewNote: asNewNote);
    },
  );
}

class EditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  final bool asNewNote;

  const EditorScreen({super.key, this.note, this.asNewNote = false});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  final FocusNode _bodyFocus = FocusNode();

  static final _whitespaceRegex = RegExp(r'\s+');
  static final _leadingSpaceRegex = RegExp(r'^\s*');
  static final _numListStartRegex = RegExp(r'^\d+\. ');

  String _baselineTitle = '';
  String _baselineBody = '';
  int? _noteId;

  bool _restoring = false;
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  String _lastBodyText = '';

  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _baselineTitle = widget.note?.title ?? '';
    _baselineBody = widget.note?.body ?? '';
    _noteId = widget.asNewNote ? null : widget.note?.id;
    _titleController = TextEditingController(text: _baselineTitle);
    _bodyController = MarkdownTextEditingController(text: _baselineBody);
    _lastBodyText = _baselineBody;
    _titleController.addListener(_onTitleChanged);
    _bodyController.addListener(_onBodyChanged);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  Note? get _source => widget.asNewNote ? null : widget.note;

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

  int get _wordCount {
    final text = _bodyController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(_whitespaceRegex).length;
  }

  Note _buildNote() {
    final title = _titleController.text.trim().isEmpty
        ? tr('editor_no_title')
        : _titleController.text.trim();
    final body = _bodyController.text.trim();
    final prefs = ref.read(themeProvider);
    final theme = allThemes.firstWhere((t) => t.id == prefs.themeId);
    final now = DateTime.now();
    if (_source == null && _noteId == null) {
      final id = now.millisecondsSinceEpoch;
      _noteId = id;
      return Note(
        id: id,
        title: title,
        body: body,
        updatedAt: now,
        accentIdx:
            widget.note?.accentIdx ?? now.millisecondsSinceEpoch % theme.accents.length,
      );
    }
    if (_source != null) {
      return _source!.copyWith(title: title, body: body, updatedAt: now);
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
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty && body.isEmpty) {
      if (_noteId != null && _source == null) {
        ref.read(notesProvider.notifier).deleteNote(_noteId!);
      }
      return;
    }

    final created = _buildNote();
    final notifier = ref.read(notesProvider.notifier);
    if (_source == null) {
      notifier.upsert(created);
    } else {
      notifier.updateNote(created);
    }
    _baselineTitle = _titleController.text;
    _baselineBody = _bodyController.text;
    if (mounted) setState(() {});
  }

  void _saveAndClose() {
    _autosaveTimer?.cancel();
    _persistSilent();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  bool _hasFormat(String prefix, String suffix) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    if (!selection.isValid) return false;

    if (!selection.isCollapsed) {
      final selectedText = selection.textInside(text);
      if (selectedText.startsWith(prefix) &&
          selectedText.endsWith(suffix) &&
          selectedText.length >= (prefix.length + suffix.length)) {
        return true;
      }
    }

    final start = selection.start;
    final end = selection.end;
    if (start >= prefix.length && end + suffix.length <= text.length) {
      final before = text.substring(start - prefix.length, start);
      final after = text.substring(end, end + suffix.length);
      if (before == prefix && after == suffix) {
        return true;
      }
    }
    return false;
  }

  void _toggleFormat(String prefix, String suffix) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    final start = selection.start;
    final end = selection.end;

    if (!selection.isValid) {
      final newText = '$text$prefix$suffix';
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length - suffix.length),
      );
      _bodyFocus.requestFocus();
      return;
    }

    if (_hasFormat(prefix, suffix)) {
      if (!selection.isCollapsed &&
          selection.textInside(text).startsWith(prefix) &&
          selection.textInside(text).endsWith(suffix)) {
        final inside = selection.textInside(text);
        final unwrapped = inside.substring(prefix.length, inside.length - suffix.length);
        final newText = text.replaceRange(start, end, unwrapped);
        _bodyController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(baseOffset: start, extentOffset: start + unwrapped.length),
        );
      } else if (start >= prefix.length && end + suffix.length <= text.length) {
        final newText = text.substring(0, start - prefix.length) +
            text.substring(start, end) +
            text.substring(end + suffix.length);
        _bodyController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
              baseOffset: start - prefix.length, extentOffset: end - prefix.length),
        );
      }
    } else {
      if (!selection.isCollapsed) {
        final selectedText = selection.textInside(text);
        final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');
        _bodyController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
              baseOffset: start + prefix.length, extentOffset: end + prefix.length),
        );
      } else {
        final pos = selection.baseOffset != -1 ? selection.baseOffset : text.length;
        final newText = text.replaceRange(pos, pos, '$prefix$suffix');
        _bodyController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: pos + prefix.length),
        );
      }
    }
    _bodyFocus.requestFocus();
  }

  void _toggleLinePrefix(String prefix) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    final currentPos = selection.isValid ? selection.baseOffset : text.length;

    int lineStart = currentPos > 0 ? text.lastIndexOf('\n', currentPos - 1) : -1;
    final startIdx = lineStart == -1 ? 0 : lineStart + 1;
    int lineEnd = text.indexOf('\n', currentPos);
    if (lineEnd == -1) lineEnd = text.length;

    final line = text.substring(startIdx, lineEnd);
    final trimmed = line.trimLeft();

    if (trimmed.startsWith(prefix)) {
      final newLine = line.replaceFirst(prefix, '');
      final newText = text.replaceRange(startIdx, lineEnd, newLine);
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: (currentPos - prefix.length).clamp(startIdx, startIdx + newLine.length)),
      );
    } else {
      final newLine = line.replaceFirst(_leadingSpaceRegex, prefix);
      final newText = text.replaceRange(startIdx, lineEnd, newLine);
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: (currentPos + prefix.length).clamp(startIdx, startIdx + newLine.length)),
      );
    }
    _bodyFocus.requestFocus();
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
    final lineStart = caret > 0 ? text.lastIndexOf('\n', caret - 1) : -1;
    final start = lineStart == -1 ? 0 : lineStart + 1;
    final lineEnd = text.indexOf('\n', caret);
    final end = lineEnd == -1 ? text.length : lineEnd;
    return text.substring(start, end).trimLeft();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1280;

    final mW = isMobile
        ? double.infinity
        : isTablet
            ? math.min(760.0, width * 0.82)
            : math.min(720.0, width * 0.62);
    final mH = media.size.height * (isMobile ? 0.92 : 0.88);
    final screenRadius = isMobile ? 20.0 : 24.0;
    final today = GlassDates.long(DateTime.now(), context.locale.languageCode);

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.escape): _saveAndClose,
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _saveAndClose,
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
                        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
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
                      showRing: true,
                      ringColors: G.ringModal,
                      ringStops: G.ringModalStops,
                      fit: StackFit.expand,
                      child: Column(
                        children: [
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
                                  highlight: true,
                                  onTap: _saveAndClose,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.arrowLeft, size: 15, color: G.textPrimary),
                                      const SizedBox(width: 6),
                                      Text(
                                        tr('back'),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: G.textPrimary,
                                          fontWeight: FontWeight.w600,
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
                                      letterSpacing: 0.84,
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.cloudCheck, size: 14, color: G.textMuted),
                                    const SizedBox(width: 5),
                                    Text(
                                      tr('saved'),
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: G.textMuted,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                              const Opacity(
                                opacity: 0.5,
                                child:
                                    Text('·', style: TextStyle(fontSize: 10.9, color: G.textMuted)),
                              ),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.hash, size: 10, color: G.textMuted),
                              const SizedBox(width: 8),
                              Text(
                                plural('editor_words_count', _wordCount),
                                style: const TextStyle(fontSize: 10.9, color: G.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                            child: Column(
                              children: [
                                _buildToolbar(),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(2, 4, 2, 40),
                                    child: TextField(
                                      controller: _bodyController,
                                      focusNode: _bodyFocus,
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
    ),
  );
  }

  Widget _buildToolbar() {
    final line = _currentLine();
    bool startsWith(String s) => line.startsWith(s);

    final isBold = _hasFormat('**', '**');
    final isItalic = _hasFormat('_', '_');
    final isStrike = _hasFormat('~~', '~~');
    final isUnderline = _hasFormat('__', '__');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FmtBtn('H1', () => _toggleLinePrefix('# '), active: startsWith('# ')),
              _FmtBtn('H2', () => _toggleLinePrefix('## '), active: startsWith('## ')),
              const _FmtSep(),
              _FmtBtn('B', () => _toggleFormat('**', '**'), active: isBold),
              _FmtBtn('I', () => _toggleFormat('_', '_'), active: isItalic),
              _FmtBtn('S', () => _toggleFormat('~~', '~~'), active: isStrike),
              _FmtBtn('U', () => _toggleFormat('__', '__'), active: isUnderline),
              const _FmtSep(),
              _FmtBtn('•', () => _toggleLinePrefix('- '), active: startsWith('- ')),
              _FmtBtn('1.', () => _toggleLinePrefix('1. '), active: _numListStartRegex.hasMatch(line)),
              _FmtBtn('☐', () => _toggleLinePrefix('[ ] '), active: startsWith('[ ] ') || startsWith('[x] ')),
              _FmtBtn('❝', () => _toggleLinePrefix('> '), active: startsWith('> ')),
              _FmtBtn('</>', () => _toggleFormat('```\n', '\n```'), active: _hasFormat('```\n', '\n```')),
              _FmtBtn('―', () {
                final text = _bodyController.text;
                final needsNl = text.isNotEmpty && !text.endsWith('\n') ? '\n' : '';
                _bodyController.text = '$text$needsNl\n---\n';
                _bodyController.selection =
                    TextSelection.collapsed(offset: _bodyController.text.length);
                _bodyFocus.requestFocus();
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
          constraints: const BoxConstraints(minWidth: 30),
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
              height: 1,
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

class MarkdownTextEditingController extends TextEditingController {
  MarkdownTextEditingController({super.text});

  static final _markdownPattern = RegExp(
    r'(?<h1_tag>^[ \t]*#[ \t]+[^\n]+)|'
    r'(?<h2_tag>^[ \t]*##[ \t]+[^\n]+)|'
    r'(?<bold>\*\*[^*]+\*\*)|'
    r'(?<italic>_[^_]+_)|'
    r'(?<underline>__[^_]+__)|'
    r'(?<strike>~~[^~]+~~)|'
    r'(?<code>`[^`]+`)',
    multiLine: true,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = [];
    final textVal = text;
    int currentOffset = 0;

    final matches = _markdownPattern.allMatches(textVal);

    for (final match in matches) {
      if (match.start > currentOffset) {
        children.add(TextSpan(
          text: textVal.substring(currentOffset, match.start),
          style: style,
        ));
      }

      final matchedText = match.group(0)!;

      if (match.namedGroup('bold') != null) {
        children.add(TextSpan(
          text: matchedText,
          style: style?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
      } else if (match.namedGroup('italic') != null) {
        children.add(TextSpan(
          text: matchedText,
          style: style?.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ));
      } else if (match.namedGroup('underline') != null) {
        children.add(TextSpan(
          text: matchedText,
          style: style?.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: Colors.white70,
          ),
        ));
      } else if (match.namedGroup('strike') != null) {
        children.add(TextSpan(
          text: matchedText,
          style: style?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: Colors.white54,
          ),
        ));
      } else if (match.namedGroup('code') != null) {
        children.add(TextSpan(
          text: matchedText,
          style: style?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.white10,
            color: const Color(0xFF80D8FF),
          ),
        ));
      } else if (match.namedGroup('h1_tag') != null) {
        children.add(TextSpan(
          text: matchedText,
          style: style?.copyWith(
            fontSize: (style?.fontSize ?? 16) * 1.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
      } else if (match.namedGroup('h2_tag') != null) {
        children.add(TextSpan(
          text: matchedText,
          style: style?.copyWith(
            fontSize: (style?.fontSize ?? 16) * 1.18,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ));
      } else {
        children.add(TextSpan(text: matchedText, style: style));
      }

      currentOffset = match.end;
    }

    if (currentOffset < textVal.length) {
      children.add(TextSpan(
        text: textVal.substring(currentOffset),
        style: style,
      ));
    }

    return TextSpan(style: style, children: children);
  }
}
