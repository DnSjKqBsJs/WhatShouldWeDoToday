class DayModel {
  final String id;
  final String tripId;
  final String name;

  DayModel({required this.id, required this.tripId, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'tripId': tripId, 'name': name};
  }

  factory DayModel.fromMap(Map<String, dynamic> map) {
    return DayModel(id: map['id'], tripId: map['tripId'], name: map['name']);
  }
}
