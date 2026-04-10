import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:meetup/models/meeting.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _meetings {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('meetings');
  }

  // ── Streams ──────────────────────────────────────────────────────────────

  Stream<List<MeetingHistoryItem>>? get meetingsHistory => _meetings
      ?.orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(MeetingHistoryItem.fromDoc).toList());

  // ── Writes ───────────────────────────────────────────────────────────────

  Future<void> addToHistory({
    required String roomId,
    required String displayName,
    required String meetingType,
  }) async {
    try {
      await _meetings?.add({
        'roomId': roomId,
        'displayName': displayName,
        'meetingType': meetingType,
        'createdAt': FieldValue.serverTimestamp(),
        'isFavorite': false,
      });
    } catch (e) {
      debugPrint('addToHistory error: $e');
    }
  }

  Future<void> toggleFavorite(String docId, {required bool value}) async {
    try {
      await _meetings?.doc(docId).update({'isFavorite': value});
    } catch (e) {
      debugPrint('toggleFavorite error: $e');
    }
  }

  Future<void> deleteFromHistory(String docId) async {
    try {
      await _meetings?.doc(docId).delete();
    } catch (e) {
      debugPrint('deleteFromHistory error: $e');
    }
  }
}