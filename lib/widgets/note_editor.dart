import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../themes/app_themes.dart';
import '../utils/glass_style.dart';

/// Редактор заметки (Modal/FullScreen)
class NoteEditor extends StatefulWidget {
  final Note? note;
  final AppTheme theme;
  final Function(Note)? onSave;
  
  const NoteEditor({
    super.key,
    this.note,
    required this.theme,
    this.onSave,
  });
  
  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late bool _isEditing;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.note != null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _save() {
    if (_titleController.text.trim().isEmpty && _bodyController.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    
    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? now.millisecondsSinceEpoch,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      updatedAt: now,
      accentIdx: widget.note?.accentIdx ?? 0,
      pinned: widget.note?.pinned ?? false,
      archived: widget.note?.archived ?? false,
      trashed: widget.note?.trashed ?? false,
      reminder: widget.note?.reminder,
      userEmail: widget.note?.userEmail ?? '',
    );
    
    widget.onSave?.call(note);
    Navigator.pop(context);
  }
  
  void _applyFormat(String before, String after) {
    final selection = _bodyController.selection;
    if (!selection.isValid) return;
    
    final text = _bodyController.text;
    final selectedText = text.substring(selection.start, selection.end);
    
    if (selectedText.isEmpty) {
      // Insert formatting markers at cursor position
      _bodyController.text = text.substring(0, selection.start) + 
                            before + after + 
                            text.substring(selection.end);
      _bodyController.selection = TextSelection.collapsed(
        offset: selection.start + before.length,
      );
    } else {
      // Wrap selected text
      _bodyController.text = text.substring(0, selection.start) + 
                            before + selectedText + after + 
                            text.substring(selection.end);
      _bodyController.selection = TextSelection(
        baseOffset: selection.start,
        extentOffset: selection.end + before.length + after.length,
      );
    }
  }
  
  void _insertLinePrefix(String prefix) {
    final selection = _bodyController.selection;
    if (!selection.isValid) return;
    
    final text = _bodyController.text;
    final lines = text.substring(0, selection.start).split('\n');
    final currentLineStart = text.substring(0, selection.start).lastIndexOf('\n') + 1;
    
    _bodyController.text = text.substring(0, currentLineStart) + 
                          prefix + ' ' + 
                          text.substring(currentLineStart);
    
    _bodyController.selection = TextSelection.collapsed(
      offset: selection.start + prefix.length + 1,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = width >= 1280;
    
    // Modal dimensions for desktop/tablet
    double modalWidth;
    double modalHeight;
    
    if (isDesktop) {
      modalWidth = (width * 0.62).clamp(0.0, 720.0);
      modalHeight = height * 0.88;
    } else if (width >= 768) {
      modalWidth = width * 0.82;
      modalHeight = height * 0.88;
    } else {
      modalWidth = width;
      modalHeight = height;
    }
    
    Widget editor = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GlassContainer(
          borderRadius: isDesktop ? 20 : 0,
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Title input
              _buildTitleInput(),
              
              // Meta info
              _buildMeta(),
              
              // Body textarea
              Expanded(child: _buildBody()),
              
              // Formatting toolbar
              _buildToolbar(),
            ],
          ),
        ),
      ),
    );
    
    if (isDesktop) {
      editor = Center(
        child: SizedBox(
          width: modalWidth,
          height: modalHeight,
          child: editor,
        ),
      );
    }
    
    return Stack(
      children: [
        // Backdrop for desktop/tablet
        if (isDesktop || width >= 768)
          Positioned.fill(
            child: GestureDetector(
              onTap: _save,
              child: Container(
                color: Colors.black54,
              ),
            ),
          ),
        
        // Editor
        if (isDesktop || width >= 768)
          editor
        else
          Positioned.fill(child: editor),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GlassContainer(
            borderRadius: 12,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: _save,
              padding: const EdgeInsets.all(8),
            ),
          ),
          
          // Label
          Text(
            _isEditing ? 'Редактировать' : 'Новая заметка',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          
          // Save button
          GlassContainer(
            borderRadius: 12,
            child: IconButton(
              icon: const Icon(Icons.check, size: 20, color: Colors.amber),
              onPressed: _save,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitleInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          hintText: 'Заголовок...',
          hintStyle: TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
        maxLines: null,
      ),
    );
  }
  
  Widget _buildMeta() {
    final wordCount = _bodyController.text.trim().isEmpty 
        ? 0 
        : _bodyController.text.trim().split(RegExp(r'\s+')).length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.white38),
          const SizedBox(width: 6),
          Text(
            DateFormat('d MMMM y, HH:mm', 'ru').format(DateTime.now()),
            style: const TextStyle(fontSize: 12, color: Colors.white38),
          ),
          const SizedBox(width: 16),
          Icon(Icons.tag, size: 14, color: Colors.white38),
          const SizedBox(width: 6),
          Text(
            '$wordCount слов',
            style: const TextStyle(fontSize: 12, color: Colors.white38),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _bodyController,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white70,
          height: 1.75,
        ),
        decoration: const InputDecoration(
          hintText: 'Начните писать...',
          hintStyle: TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ToolbarButton(label: 'B', onTap: () => _applyFormat('**', '**')),
          _ToolbarButton(label: 'I', onTap: () => _applyFormat('_', '_')),
          const SizedBox(width: 8),
          _ToolbarButton(label: '•', onTap: () => _insertLinePrefix('•')),
          _ToolbarButton(label: '1.', onTap: () => _insertLinePrefix('1.')),
          _ToolbarButton(label: 'H1', onTap: () => _insertLinePrefix('#')),
          _ToolbarButton(label: '🔗', onTap: () => _applyFormat('[', '](url)')),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _ToolbarButton({required this.label, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
