import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? firestoreId;
  final int id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final DateTime? createdAt;
  final int accentIdx;
  final bool pinned;
  final bool archived;
  final bool trashed;
  final DateTime? reminder;

  const Note({
    this.firestoreId,
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.createdAt,
    required this.accentIdx,
    this.pinned = false,
    this.archived = false,
    this.trashed = false,
    this.reminder,
  });

  Note copyWith({
    String? firestoreId,
    int? id,
    String? title,
    String? body,
    DateTime? updatedAt,
    DateTime? createdAt,
    int? accentIdx,
    bool? pinned,
    bool? archived,
    bool? trashed,
    DateTime? reminder,
    bool clearReminder = false,
  }) {
    return Note(
      firestoreId: firestoreId ?? this.firestoreId,
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      accentIdx: accentIdx ?? this.accentIdx,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      trashed: trashed ?? this.trashed,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (firestoreId != null) 'firestoreId': firestoreId,
      'id': id,
      'title': title,
      'body': body,
      'updatedAt': updatedAt.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'accentIdx': accentIdx,
      'pinned': pinned,
      'archived': archived,
      'trashed': trashed,
      'reminder': reminder?.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      firestoreId: json['firestoreId'] as String?,
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      accentIdx: (json['accentIdx'] as num?)?.toInt() ?? 0,
      pinned: json['pinned'] == true,
      archived: json['archived'] == true,
      trashed: json['trashed'] == true,
      reminder: json['reminder'] != null ? DateTime.parse(json['reminder'] as String) : null,
    );
  }

  factory Note.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final updatedAt = parseDate(data['updatedAt']);
    final idVal = data['id'];
    final id = idVal is num ? idVal.toInt() : (int.tryParse(idVal?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch);

    return Note(
      firestoreId: doc.id,
      id: id,
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      updatedAt: updatedAt,
      createdAt: data['createdAt'] != null ? parseDate(data['createdAt']) : null,
      accentIdx: (data['accentIdx'] is num) ? (data['accentIdx'] as num).toInt() : 0,
      pinned: data['pinned'] == true,
      archived: data['archived'] == true,
      trashed: data['trashed'] == true,
      reminder: data['reminder'] != null ? parseDate(data['reminder']) : null,
    );
  }

  Map<String, dynamic> toFirestore(String ownerUid) {
    return {
      'ownerUid': ownerUid,
      'id': id,
      'title': title,
      'body': body,
      'accentIdx': accentIdx,
      'pinned': pinned,
      'archived': archived,
      'trashed': trashed,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'reminder': reminder != null ? Timestamp.fromDate(reminder!) : null,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          firestoreId == other.firestoreId &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          updatedAt == other.updatedAt &&
          createdAt == other.createdAt &&
          accentIdx == other.accentIdx &&
          pinned == other.pinned &&
          archived == other.archived &&
          trashed == other.trashed &&
          reminder == other.reminder;

  @override
  int get hashCode => Object.hash(
        firestoreId,
        id,
        title,
        body,
        updatedAt,
        createdAt,
        accentIdx,
        pinned,
        archived,
        trashed,
        reminder,
      );
}

