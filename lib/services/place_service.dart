import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japan_app/models/place_model.dart';

class PlaceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPlace(PlaceModel place) async {
    final id = _db
        .collection('trips')
        .doc(place.tripId)
        .collection('places')
        .doc()
        .id;
    await _db
        .collection('trips')
        .doc(place.tripId)
        .collection('places')
        .doc(id)
        .set({...place.toMap(), 'id': id});
  }

  Future<List<PlaceModel>> getPlaces(String tripId) async {
    final snapshot = await _db
        .collection('trips')
        .doc(tripId)
        .collection('places')
        .get();
    return snapshot.docs.map((doc) => PlaceModel.fromMap(doc.data())).toList();
  }

  Future<void> updatePlace(PlaceModel place) async {
    await _db
        .collection('trips')
        .doc(place.tripId)
        .collection('places')
        .doc(place.id)
        .update(place.toMap());
  }

  Future<void> deletePlace(PlaceModel place) async {
    await _db
        .collection('trips')
        .doc(place.tripId)
        .collection('places')
        .doc(place.id)
        .delete();
  }
}
