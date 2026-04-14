class PlaceModel {
  final String id;
  final String tripId;
  final String creatorId;
  final double lat;
  final double lng;
  final String name;
  final String description ;
  final List<String> tags;
  String? day;

  PlaceModel({
    required this.id,
    required this.tripId,
    required this.creatorId,
    required this.lat,
    required this.lng,
    required this.name,
    required this.description ,
    required this.tags,
    this.day
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'creatorId': creatorId,
      'lat': lat,
      'lng': lng,
      'name': name,
      'description': description,
      'tags': tags,
      'day': day,
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'],
      tripId: map['tripId'],
      creatorId: map['creatorId'],
      lat: map['lat'],
      lng: map['lng'],
      name: map['name'],
      description : map['description'],
      tags:List<String>.from(map['tags']),
      day: map['day'],
    );
  }
}
