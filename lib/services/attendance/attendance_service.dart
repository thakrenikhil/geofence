import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/attendance_record.dart';

class AttendanceService {
  AttendanceService(this._firestore);
  final FirebaseFirestore _firestore;

  Future<void> checkIn({required String userId, required String officeId}) async {
    final record = AttendanceRecord(userId: userId, checkInAt: DateTime.now().toUtc(), officeId: officeId);
    await _firestore.collection('attendance').add(record.toJson());
  }

  Future<void> checkOut({required String recordId}) async {
    await _firestore.collection('attendance').doc(recordId).update({'checkOutAt': DateTime.now().toUtc().toIso8601String()});
  }
}


