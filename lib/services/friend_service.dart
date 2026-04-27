import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:japan_app/models/friend_request_model.dart';
import 'package:japan_app/services/firestore_service.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> sendFriendRequest(String fromId, String toId) async {
    final user1 = await FirestoreService().getUser(fromId);
    if (user1 != null) {
      if (!user1.friends!.contains(toId) && !await requestExit(fromId, toId)) {
        final id = _db.collection('friendsRequest').doc().id;
        final friendRequest = FriendRequestModel(
          requestId: id,
          fromId: fromId,
          toId: toId,
        );
        await _db
            .collection('friendsRequest')
            .doc(id)
            .set(friendRequest.toMap());
        return true;
      }
    }

    return false;
  }

  Future<bool> requestExit(String id1, String id2) async {
    final n1 = await _db
        .collection('friendsRequest')
        .where('fromId', isEqualTo: id1)
        .where('toId', isEqualTo: id2)
        .get();
    final n2 = await _db
        .collection('friendsRequest')
        .where('fromId', isEqualTo: id2)
        .where('toId', isEqualTo: id1)
        .get();
    if (n1.docs.isNotEmpty || n2.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> acceptFriendRequest(FriendRequestModel friendRequest) async {
    final batch = _db.batch();
    final fromIdUser = await FirestoreService().getUser(friendRequest.fromId);
    final toIdUser = await FirestoreService().getUser(friendRequest.toId);
    if (fromIdUser != null && toIdUser != null) {
      fromIdUser.friends!.add(friendRequest.toId);
      toIdUser.friends!.add(friendRequest.fromId);

      batch.update(
        _db.collection('users').doc(friendRequest.fromId),
        fromIdUser.toMap(),
      );
      batch.update(
        _db.collection('users').doc(friendRequest.toId),
        toIdUser.toMap(),
      );
      batch.delete(
        _db.collection('friendsRequest').doc(friendRequest.requestId),
      );

      await batch.commit();
    }
  }

  Future<void> declineFriendRequest(FriendRequestModel friendRequest) async {
    await _db
        .collection('friendsRequest')
        .doc(friendRequest.requestId)
        .delete();
  }

  Future<List<FriendRequestModel>> getFriendRequests(String toId) async {
    final snapshot = await _db
        .collection('friendsRequest')
        .where('toId', isEqualTo: toId)
        .get();
    return snapshot.docs.map((doc) => FriendRequestModel.fromMap(doc.data())).toList();
  }
}
