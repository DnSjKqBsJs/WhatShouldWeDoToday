import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japan_app/models/day_model.dart';

class DayService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createDay(DayModel day) async {
    final id = _db.collection('trips').doc(day.tripId).collection('days').doc().id;

    await _db.collection('trips').doc(day.tripId).collection('days').doc(id).set({
      ...day.toMap(),
      'id': id,
    });
  }

  Future<List<DayModel>> getDays(String tripId) async {
    final snapshot = await _db
        .collection('trips')
        .doc(tripId)
        .collection('days')
        .get();
    return snapshot.docs.map((doc) => DayModel.fromMap(doc.data())).toList();
  }

  Future<void> deleteDay(DayModel day) async
  {
    await _db.collection('trips').doc(day.tripId).collection('days').doc(day.id).delete();
  }
}
