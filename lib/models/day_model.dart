class DayModel {
  final String id;
  final String tripId;
  final String name;
  final int order;

  DayModel({
    required this.id,
    required this.tripId,
    required this.name,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'tripId': tripId, 'name': name, 'order': order};
  }

  factory DayModel.fromMap(Map<String, dynamic> map) {
    return DayModel(
      id: map['id'],
      tripId: map['tripId'],
      name: map['name'],
      order: map['order'],
      
    );
  }
}
