import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<UserModel> _friends = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllFriends();
  }

  void getAllFriends() async {
    UserModel? friendsIds = await FirestoreService().getUser(
      FirebaseAuth.instance.currentUser!.uid,
    );
    if (friendsIds != null) {
      _friends = await FirestoreService().getUsers(friendsIds.friends ?? []);
    }
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_friends[index].firstName),
                        Text(_friends[index].lastName),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
