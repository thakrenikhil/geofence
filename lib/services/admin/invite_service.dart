import 'package:cloud_firestore/cloud_firestore.dart';

class InviteService {
  InviteService(this._firestore);
  final FirebaseFirestore _firestore;

  Future<void> createInvite({
    required String name,
    required String email,
    String role = 'employee',
    String? officeId,
  }) async {
    final doc = _firestore.collection('users').doc(email.toLowerCase());
    await doc.set({
      'name': name,
      'email': email.toLowerCase(),
      'role': role,
      'officeId': officeId,
      'defaultPassword': '12345678',
      'invited': true,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getInviteByEmail(String email) async {
    final snap = await _firestore
        .collection('users')
        .doc(email.toLowerCase())
        .get();
    return snap.data();
  }

  Future<void> deleteInvite(String email) async {
    await _firestore.collection('users').doc(email.toLowerCase()).delete();
  }
}
