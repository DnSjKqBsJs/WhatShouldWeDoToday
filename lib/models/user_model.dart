class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String photoUrl;
  List<String>? friends;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    this.friends

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'friends' : friends
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      photoUrl: map['photoUrl'],
      friends: map['friends'] ?? [],
    );
  }
}
