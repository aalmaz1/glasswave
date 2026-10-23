import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/note.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _mapUser(User? user) {
    if (user == null || user.email == null) return null;
    return AppUser(
      email: user.email!,
      name: user.displayName ?? user.email!.split('@').first,
      uid: user.uid,
    );
  }

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  AppUser? get currentUser => _mapUser(_auth.currentUser);

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String email, String name, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (cred.user != null && name.trim().isNotEmpty) {
      await cred.user!.updateDisplayName(name.trim());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);

    // Delete user's notes in Firestore using chunked atomic batches (max 500 per batch)
    final snapshot = await _db
        .collection('notes')
        .where('ownerUid', isEqualTo: user.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      const chunkSize = 500;
      for (var i = 0; i < snapshot.docs.length; i += chunkSize) {
        final end = (i + chunkSize < snapshot.docs.length) ? i + chunkSize : snapshot.docs.length;
        final chunk = snapshot.docs.sublist(i, end);
        final batch = _db.batch();
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }

    await user.delete();
  }

  Stream<List<Note>> streamNotes(String ownerUid) {
    return _db
        .collection('notes')
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  Future<String> writeNote(Note note, String ownerUid) async {
    final docRef = note.firestoreId != null
        ? _db.collection('notes').doc(note.firestoreId)
        : _db.collection('notes').doc();
    await docRef.set(note.toFirestore(ownerUid), SetOptions(merge: true));
    return docRef.id;
  }

  Future<void> deleteNote(Note note) async {
    if (note.firestoreId == null) return;
    await _db.collection('notes').doc(note.firestoreId).delete();
  }

  Future<void> deleteNotes(List<Note> notes) async {
    final validNotes = notes.where((n) => n.firestoreId != null).toList();
    if (validNotes.isEmpty) return;

    const chunkSize = 500;
    for (var i = 0; i < validNotes.length; i += chunkSize) {
      final end = (i + chunkSize < validNotes.length) ? i + chunkSize : validNotes.length;
      final chunk = validNotes.sublist(i, end);
      final batch = _db.batch();
      for (final note in chunk) {
        batch.delete(_db.collection('notes').doc(note.firestoreId));
      }
      await batch.commit();
    }
  }
}

