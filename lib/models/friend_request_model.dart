class FriendRequestModel {
  final String requestId;
  final String fromId;
  final String toId;

  FriendRequestModel({required this.requestId ,required this.fromId, required this.toId});

  Map<String, dynamic> toMap()
  {
    return {'requestId' : requestId ,'fromId': fromId, 'toId' : toId };
  }

  factory FriendRequestModel.fromMap(Map<String,dynamic> map)
  {
    return FriendRequestModel(requestId: map['requestId'] ,fromId: map['fromId'], toId: map['toId']);
  }
}