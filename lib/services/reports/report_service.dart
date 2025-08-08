import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';

class ReportService {
  ReportService(this._firestore);
  final FirebaseFirestore _firestore;

  Future<Uint8List> generateAttendanceExcel({required DateTime from, required DateTime to}) async {
    final query = await _firestore
        .collection('attendance')
        .where('checkInAt', isGreaterThanOrEqualTo: from.toIso8601String())
        .where('checkInAt', isLessThanOrEqualTo: to.toIso8601String())
        .get();

    final excel = Excel.createExcel();
    final sheet = excel['Attendance'];
    sheet.appendRow(<CellValue?>[
      TextCellValue('User ID'),
      TextCellValue('Office ID'),
      TextCellValue('Check In'),
      TextCellValue('Check Out'),
    ]);
    for (final doc in query.docs) {
      final data = doc.data();
      sheet.appendRow(<CellValue?>[
        TextCellValue((data['userId'] ?? '') as String),
        TextCellValue((data['officeId'] ?? '') as String),
        TextCellValue((data['checkInAt'] ?? '') as String),
        TextCellValue((data['checkOutAt'] ?? '') as String),
      ]);
    }
    return Uint8List.fromList(excel.encode()!);
  }
}


