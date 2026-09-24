import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/note.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null || user.email == null) return null;
      return AppUser(
        email: user.email!,
        name: user.displayName ?? user.email!.split('@').first,
        uid: user.uid,
      );
    });
  }

  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return null;
    return AppUser(
      email: user.email!,
      name: user.displayName ?? user.email!.split('@').first,
      uid: user.uid,
    );
  }

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

    // Delete user's notes in Firestore
    final snapshot = await _db
        .collection('notes')
        .where('ownerUid', isEqualTo: user.uid)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
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

  String _createDocId() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(20, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<String> writeNote(Note note, String ownerUid) async {
    final docId = note.firestoreId ?? _createDocId();
    final docRef = _db.collection('notes').doc(docId);
    await docRef.set(note.toFirestore(ownerUid), SetOptions(merge: true));
    return docId;
  }

  Future<void> deleteNote(Note note) async {
    if (note.firestoreId == null) return;
    await _db.collection('notes').doc(note.firestoreId).delete();
  }
}
