import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/auth_service.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  bool _editProfile = false;
  String _localImagePath = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    final result = await FirestoreService().getUser(
      FirebaseAuth.instance.currentUser!.uid,
    );
    user = result;
    if (user != null) {
      firstName.text = user!.firstName;
      lastName.text = user?.lastName ?? '';
      email.text = user!.email;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              if (_editProfile) {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() {
                    _localImagePath = image.path;
                  });
                }
              }
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _localImagePath.isNotEmpty
                  ? FileImage(File(_localImagePath))
                  : user!.photoUrl.isNotEmpty
                  ? NetworkImage(user!.photoUrl)
                  : null,
              child: _localImagePath.isEmpty && user!.photoUrl.isEmpty
                  ? Icon(Icons.person, size: 50)
                  : null,
            ),
          ),
          SizedBox(height: 16),
          Text('First Name'),
          TextField(enabled: _editProfile, controller: firstName),
          SizedBox(height: 12),
          Text('Last Name'),
          TextField(enabled: _editProfile, controller: lastName),
          SizedBox(height: 12),
          Text('email'),
          TextField(enabled: false, controller: email),
          ElevatedButton(
            onPressed: () async {
              if (_editProfile) {
                final ref = FirebaseStorage.instance.ref().child(
                  'users/${user!.id}/profile.jpg',
                );

                await ref.putFile(File(_localImagePath));

                // 2. Récupérer l'URL publique
                final url = await ref.getDownloadURL();
                FirestoreService().updateUser(
                  UserModel(
                    id: user!.id,
                    email: email.text,
                    firstName: firstName.text,
                    lastName: lastName.text,
                    photoUrl: _localImagePath.isNotEmpty
                        ? url
                        : user!.photoUrl,
                  ),
                );
              }
              setState(() {
                _editProfile = !_editProfile;
              });
            },
            child: _editProfile ? Text('Save') : Text('Edit'),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).cancelNotificationListener();
              AuthService().signOut();
            },
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
