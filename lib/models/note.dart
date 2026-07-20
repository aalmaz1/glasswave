class Note {
  final int id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final int accentIdx;
  final bool pinned;
  final bool archived;
  final bool trashed;
  final DateTime? reminder;

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
    );
  }
}
