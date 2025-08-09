import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/attendance_record.dart';

class AttendanceService {
  AttendanceService(this._firestore);
  final FirebaseFirestore _firestore;

  Future<String> checkIn({
    required String userId,
    required String officeId,
  }) async {
    // Get user name from Firestore
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';

    final record = AttendanceRecord(
      userId: userId,
      userName: userName,
      checkInAt: DateTime.now().toUtc(),
      officeId: officeId,
    );
    final ref = await _firestore.collection('attendance').add(record.toJson());
    return ref.id;
  }

  Future<void> checkOut({required String recordId}) async {
    await _firestore.collection('attendance').doc(recordId).update({
      'checkOutAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Stream<AttendanceRecord?> activeRecordForUser(String userId) {
    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .where('checkOutAt', isNull: true)
        .limit(1)
        .snapshots()
        .map(
          (s) => s.docs.isEmpty
              ? null
              : AttendanceRecord.fromJson(s.docs.first.data()),
        );
  }
}
