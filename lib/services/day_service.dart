import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japan_app/models/day_model.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/services/place_service.dart';

class DayService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createDay(DayModel day) async {
    final id = _db
        .collection('trips')
        .doc(day.tripId)
        .collection('days')
        .doc()
        .id;

    await _db
        .collection('trips')
        .doc(day.tripId)
        .collection('days')
        .doc(id)
        .set({...day.toMap(), 'id': id});
  }

  Future<List<DayModel>> getDays(String tripId) async {
    final snapshot = await _db
        .collection('trips')
        .doc(tripId)
        .collection('days')
        .get();
    // print('tripId: $tripId');
    // print('nombre de docs: ${snapshot.docs.length}');
    return snapshot.docs.map((doc) => DayModel.fromMap(doc.data())).toList();
  }

  Future<void> deleteDay(DayModel day) async {
    await _db
        .collection('trips')
        .doc(day.tripId)
        .collection('days')
        .doc(day.id)
        .delete();

    await removeDayFromPlaces(day.tripId, day.id);
  }

  Future<void> modifyDay(DayModel day, String newName) async {
    await _db
        .collection('trips')
        .doc(day.tripId)
        .collection('days')
        .doc(day.id)
        .set({...day.toMap(), 'name': newName});
  }

  Future<void> removeDayFromPlaces(String tripId, String dayId) async {
    final snapshot = await _db
        .collection('trips')
        .doc(tripId)
        .collection('places')
        .where('days', arrayContains: dayId)
        .get();

    for (final doc in snapshot.docs) {
      final place = PlaceModel.fromMap(doc.data());
      place.days?.remove(dayId);
      await PlaceService().updatePlace(place);
    }
  }
}
