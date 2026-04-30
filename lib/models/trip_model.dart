class TripModel {
  final String id;
  final String name;
  final String countryName;
  final double centerLat;
  final double centerLng;
  final List<String> users;
  final int order;
  final String? coverUrl;

  TripModel({
    required this.id,
    required this.name,
    required this.countryName,
    required this.centerLat,
    required this.centerLng,
    required this.users,
    required this.order,
    this.coverUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'countryName': countryName,
      'centerLat': centerLat,
      'centerLng': centerLng,
      'users': users,
      'order' : order,
      'coverUrl' : coverUrl
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'],
      name: map['name'],
      countryName: map['countryName'],
      centerLat: map['centerLat'].toDouble(),
      centerLng: map['centerLng'].toDouble(),
      users: List<String>.from(map['users']),
      order: map['order'],
      coverUrl: map['coverUrl'] ?? ''
    );
  }
}
