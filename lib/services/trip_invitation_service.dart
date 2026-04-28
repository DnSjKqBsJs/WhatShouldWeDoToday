import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japan_app/models/trip_invitation_model.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/services/firestore_service.dart';

class TripInvitationService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> sendTripInvitation(String fromId, String toId, String tripId) async
  {
    List<UserModel> usersInTrip = await FirestoreService().getUsersInTrip(tripId);
    List<String> usersIdInTrip = [];
    for(final element in usersInTrip)
    {
      usersIdInTrip.add(element.id);
    }
    if(!usersIdInTrip.contains(toId) && !await requestExit(fromId, toId))
    {
      final id = _db.collection('tripInvitation').doc().id;
      TripInvitationModel finalTrip = TripInvitationModel(invitationId: id, fromId: fromId, toId: toId, tripId: tripId);
      await _db.collection('tripInvitation').doc(id).set(finalTrip.toMap());
      return true;
    }
    return false;
  }

  Future<bool> requestExit(String fromId, String toId) async
  {
    final n1 = await _db
        .collection('tripInvitation')
        .where('fromId', isEqualTo: fromId)
        .where('toId', isEqualTo: toId)
        .get();
    final n2 = await _db
        .collection('tripInvitation')
        .where('fromId', isEqualTo: toId)
        .where('toId', isEqualTo: fromId)
        .get();

    if(n1.docs.isNotEmpty || n2.docs.isNotEmpty)
    {
      return true;
    }
    return false;
  }

  Future<void> acceptTripInvitation(TripInvitationModel tripInvitation) async
  {
    UserModel? toUser = await FirestoreService().getUser(tripInvitation.toId);
    if(toUser != null)
    {
      await FirestoreService().addUserToTrip(toUser, tripInvitation.tripId);
      await _db.collection('tripInvitation').doc(tripInvitation.invitationId).delete();
    }
  }

  Future<void> declineTripInvitation(TripInvitationModel tripInvitation) async
  {
    await _db.collection('tripInvitation').doc(tripInvitation.invitationId).delete();
  }

  Future<List<TripInvitationModel>> getTripInvitations(String toId) async
  {
    final snapshot = await _db.collection('tripInvitation').where('toId', isEqualTo: toId).get();
    return snapshot.docs.map((doc) => TripInvitationModel.fromMap(doc.data())).toList();
  }
}
