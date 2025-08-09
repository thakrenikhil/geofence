import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  RoleService(this._firestore);
  final FirebaseFirestore _firestore;

  Future<String> fetchRoleForUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    final role = (data != null ? data['role'] as String? : null)?.toLowerCase();
    if (role == 'admin' || role == 'employee') return role!;
    return 'employee';
  }
}


