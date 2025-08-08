import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/office.dart';

class OfficeService {
  OfficeService(this._firestore);
  final FirebaseFirestore _firestore;

  Future<String> createOffice(Office office) async {
    final ref = await _firestore.collection('offices').add(office.toJson());
    return ref.id;
  }

  Future<void> updateOffice(Office office) async {
    await _firestore.collection('offices').doc(office.id).update(office.toJson());
  }

  Future<void> deleteOffice(String id) async {
    await _firestore.collection('offices').doc(id).delete();
  }

  Stream<List<Office>> offices() {
    return _firestore.collection('offices').snapshots().map((s) => s.docs.map((d) => Office.fromJson(d.id, d.data())).toList());
  }
}


