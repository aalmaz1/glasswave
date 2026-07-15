import 'dart:convert';

/// Модель заметки с поддержкой всех функций приложения
class Note {
  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int accentIdx; // индекс в массиве accents текущей темы
  final bool pinned;
  final bool archived;
  final bool trashed;
  final DateTime? reminder;

  Note({
    required this.id,
    this.title = '',
    this.body = '',
    DateTime? updatedAt,
    DateTime? createdAt,
    this.accentIdx = 0,
    this.pinned = false,
    this.archived = false,
    this.trashed = false,
    this.reminder,
  })  : updatedAt = updatedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Note copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? updatedAt,
    DateTime? createdAt,
    int? accentIdx,
    bool? pinned,
    bool? archived,
    bool? trashed,
    DateTime? reminder,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      accentIdx: accentIdx ?? this.accentIdx,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      trashed: trashed ?? this.trashed,
      reminder: reminder ?? this.reminder,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'updatedAt': updatedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'accentIdx': accentIdx,
        'pinned': pinned,
        'archived': archived,
        'trashed': trashed,
        'reminder': reminder?.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        accentIdx: json['accentIdx'] as int? ?? 0,
        pinned: json['pinned'] as bool? ?? false,
        archived: json['archived'] as bool? ?? false,
        trashed: json['trashed'] as bool? ?? false,
        reminder: json['reminder'] != null
            ? DateTime.parse(json['reminder'] as String)
            : null,
      );
}
