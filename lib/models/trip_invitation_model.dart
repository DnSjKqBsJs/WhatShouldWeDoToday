class TripInvitationModel {
  final String invitationId;
  final String fromId;
  final String toId;
  final String tripId;

  TripInvitationModel({
    required this.invitationId,
    required this.fromId,
    required this.toId,
    required this.tripId,
  });

  Map<String, dynamic> toMap() {
    return {
      'invitationId': invitationId,
      'fromId': fromId,
      'toId': toId,
      'tripId': tripId,
    };
  }

  factory TripInvitationModel.fromMap(Map<String, dynamic> map) {
    return TripInvitationModel(
      invitationId: map['invitationId'],
      fromId: map['fromId'],
      toId: map['toId'],
      tripId: map['tripId'],
    );
  }
}
