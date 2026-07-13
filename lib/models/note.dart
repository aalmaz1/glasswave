import 'package:flutter/material.dart';

/// Модель заметки
class Note {
  final int id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final int accentIdx;
  bool pinned;
  bool archived;
  bool trashed;
  final DateTime? reminder;
  final String userEmail;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.accentIdx = 0,
    this.pinned = false,
    this.archived = false,
    this.trashed = false,
    this.reminder,
    this.userEmail = '',
  });

  Note copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? updatedAt,
    int? accentIdx,
    bool? pinned,
    bool? archived,
    bool? trashed,
    DateTime? reminder,
    String? userEmail,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      accentIdx: accentIdx ?? this.accentIdx,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      trashed: trashed ?? this.trashed,
      reminder: reminder ?? this.reminder,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'updatedAt': updatedAt.toIso8601String(),
      'accentIdx': accentIdx,
      'pinned': pinned,
      'archived': archived,
      'trashed': trashed,
      'reminder': reminder?.toIso8601String(),
      'userEmail': userEmail,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      accentIdx: map['accentIdx'] as int? ?? 0,
      pinned: map['pinned'] as bool? ?? false,
      archived: map['archived'] as bool? ?? false,
      trashed: map['trashed'] as bool? ?? false,
      reminder: map['reminder'] != null 
          ? DateTime.parse(map['reminder'] as String) 
          : null,
      userEmail: map['userEmail'] as String? ?? '',
    );
  }
}
