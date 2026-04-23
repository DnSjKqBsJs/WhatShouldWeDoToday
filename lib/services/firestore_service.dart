import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:japan_app/models/trip_model.dart';
import 'package:japan_app/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<TripModel> createTrip(TripModel trip) async {
    final existing = await getTrips(FirebaseAuth.instance.currentUser!.uid);
    final order = existing.length;

    final id = _db.collection('trips').doc().id;
    final updatedTrip = TripModel(
      id: id,
      name: trip.name,
      countryName: trip.countryName,
      centerLat: trip.centerLat,
      centerLng: trip.centerLng,
      users: trip.users,
      order: order,
    );
    await _db.collection('trips').doc(id).set(updatedTrip.toMap());
    return updatedTrip;
  }

  Future<List<TripModel>> getTrips(String userId) async {
    final snapshot = await _db
        .collection('trips')
        .where('users', arrayContains: userId)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => TripModel.fromMap(doc.data())).toList();
  }

  Future<void> updateTrip(TripModel trip, String tripId) async {
    await _db.collection('trips').doc(tripId).update(trip.toMap());
  }

  Future<void> deleteTrip(String tripId) async {
    final batch = _db.batch();

    final placesSnapshot = await _db
        .collection('trips')
        .doc(tripId)
        .collection('places')
        .get();

    for (final doc in placesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    final daySnapshot = await _db
        .collection('trips')
        .doc(tripId)
        .collection('days')
        .get();
    for (final doc in daySnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_db.collection('trips').doc(tripId));
    await batch.commit();
  }

  Future<void> deleteUser(String userId, String tripId) async {
    final snapshot = await _db.collection('trips').doc(tripId).get();
    final trip = TripModel.fromMap(snapshot.data()!);

    if (trip.users.length <= 1) {
      await deleteTrip(tripId);
    } else {
      if (trip.users.contains(userId)) {
        await _db.collection('trips').doc(tripId).update({
          'users': FieldValue.arrayRemove([userId]),
        });
      }
    }
  }

  Future<UserModel> createUser(String email) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final user = UserModel(id: uid, email: email, name: email.split('@')[0]);
    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  Future<UserModel?> getUserByMail(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromMap(snapshot.docs.first.data());
  }

  Future<void> addUserToTrip(UserModel user, String tripId) async {
    await _db.collection('trips').doc(tripId).update({
      'users': FieldValue.arrayUnion([user.id]),
    });
  }
}
