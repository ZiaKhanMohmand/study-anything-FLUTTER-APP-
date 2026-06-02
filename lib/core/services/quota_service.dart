import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuotaService {
  static final _db = FirebaseFirestore.instance;

  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static DocumentReference get _doc => _db.collection('user_quotas').doc(_uid);

  /// Returns true if user can generate (under limit).
  /// Returns false if limit hit (must watch ad first).
  static Future<bool> canGenerate() async {
    final today = _todayString();
    final snap = await _doc.get();

    if (!snap.exists) return true;

    final data = snap.data() as Map<String, dynamic>;
    final lastDate = data['date'] as String?;
    final count = data['count'] as int? ?? 0;

    if (lastDate != today) return true; // new day, reset
    return count < 1; // 1 free per day
  }

  /// Call after successful generation.
  static Future<void> incrementCount() async {
    final today = _todayString();
    final snap = await _doc.get();

    if (!snap.exists) {
      await _doc.set({'date': today, 'count': 1});
      return;
    }

    final data = snap.data() as Map<String, dynamic>;
    final lastDate = data['date'] as String?;

    if (lastDate != today) {
      await _doc.set({'date': today, 'count': 1});
    } else {
      await _doc.update({'count': FieldValue.increment(1)});
    }
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
