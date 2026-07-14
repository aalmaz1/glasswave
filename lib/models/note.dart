import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final int accentIdx;

  @HiveField(5)
  final bool pinned;

  @HiveField(6)
  final bool archived;

  @HiveField(7)
  final bool trashed;

  @HiveField(8)
  final DateTime? reminder;

  @HiveField(9)
  final String userEmail;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    required this.accentIdx,
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

  Map<String, dynamic> toJson() {
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

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      updatedAt: DateTime.parse(json['updatedAt']),
      accentIdx: json['accentIdx'],
      pinned: json['pinned'] ?? false,
      archived: json['archived'] ?? false,
      trashed: json['trashed'] ?? false,
      reminder: json['reminder'] != null ? DateTime.parse(json['reminder']) : null,
      userEmail: json['userEmail'] ?? '',
    );
  }
}
