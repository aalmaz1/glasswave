import 'package:easy_localization/easy_localization.dart';
import '../models/note.dart';

List<Note> buildWelcomeNotes() {
  final now = DateTime.now();

  Note make(int slot, String title, String body, {bool pinned = false}) {
    return Note(
      id: -slot,
      title: title,
      body: body,
      updatedAt: now.subtract(Duration(minutes: slot)),
      accentIdx: (slot - 1) % 4,
      pinned: pinned,
    );
  }

  return [
    make(1, tr('welcome_note1_title'), tr('welcome_note1_body'), pinned: true),
    make(2, tr('welcome_note2_title'), tr('welcome_note2_body')),
    make(3, tr('welcome_note3_title'), tr('welcome_note3_body')),
    make(4, tr('welcome_note4_title'), tr('welcome_note4_body')),
  ];
}

bool isWelcomeNoteId(int id) => id < 0;
