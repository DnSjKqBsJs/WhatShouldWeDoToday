import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:japan_app/models/trip_model.dart';
import 'package:japan_app/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<TripModel> createTrip(TripModel trip) async {
    final id = _db.collection('trips').doc().id;
    final updatedTrip = TripModel(
      id: id,
      name: trip.name,
      countryName: trip.countryName,
      centerLat: trip.centerLat,
      centerLng: trip.centerLng,
      users: trip.users,
    );
    await _db.collection('trips').doc(id).set(updatedTrip.toMap());
    return updatedTrip;
  }

  Future<List<TripModel>> getTrips(String userId) async {
    final snapshot = await _db
        .collection('trips')
        .where('users', arrayContains: userId)
        .get();
    return snapshot.docs.map((doc) => TripModel.fromMap(doc.data())).toList();
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
    await _db.collection('trips').doc(tripId).update({'users':FieldValue.arrayUnion([user.id])});
  }
}
