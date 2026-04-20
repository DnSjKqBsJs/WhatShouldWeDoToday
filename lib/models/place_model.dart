class PlaceModel {
  final String id;
  final String tripId;
  final String creatorId;
  String? fsqPlaceId;
  final double lat;
  final double lng;
  final String name;
  final String description;
  List<String>? imageUrls;
  String? category;
  final List<String> tags;
  String? day;

  PlaceModel({
    required this.id,
    required this.tripId,
    required this.creatorId,
    this.fsqPlaceId,
    required this.lat,
    required this.lng,
    required this.name,
    required this.description,
    this.imageUrls,
    this.category,
    required this.tags,
    this.day,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'creatorId': creatorId,
      'fsqPlaceId': fsqPlaceId,
      'lat': lat,
      'lng': lng,
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'category': category,
      'tags': tags,
      'day': day,
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'],
      tripId: map['tripId'],
      creatorId: map['creatorId'],
      fsqPlaceId: map['fsqPlaceId'],
      lat: map['lat'],
      lng: map['lng'],
      name: map['name'],
      description: map['description'],
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(map['imageUrls'])
          : null,
      category: map['category'],
      tags: List<String>.from(map['tags']),
      day: map['day'],
    );
  }
}
