import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:japan_app/services/friend_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<UserModel> _friends = [];
  TextEditingController email = TextEditingController();
  UserModel? user;
  String? _feedbackMessage;

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text('Add Friend'),
          Row(
            children: [
              Expanded(child: TextField(controller: email)),
              ElevatedButton(
                onPressed: () async {
                  user = await FirestoreService().getUserByMail(email.text);
                  if (user != null) {
                    final result = await FriendService().sendFriendRequest(
                      FirebaseAuth.instance.currentUser!.uid,
                      user!.id,
                    );
                    switch(result)
                    {
                      case RequestIssue.requestSend:
                        setState(() {
                          _feedbackMessage = "Request sent!";
                        });
                      case RequestIssue.alreadyFriend:
                        setState(() {
                          _feedbackMessage = "User Already friend with you";
                        });
                      case RequestIssue.requestExit:
                      setState(() {
                        _feedbackMessage = "Request Already Send";
                      });
                      case RequestIssue.userInvalid:
                        setState(() {
                          _feedbackMessage = "Invalid User";
                        });
                    }
                    Future.delayed(Duration(seconds: 2), () {
                      if (context.mounted) {
                        setState(() => _feedbackMessage = null);
                      }
                    });
                  } else {
                    setState(() {
                      _feedbackMessage = "No users found";
                    });
                    Future.delayed(Duration(seconds: 2), () {
                      if (context.mounted) {
                        setState(() => _feedbackMessage = null);
                      }
                    });
                  }
                },
                child: Text("Send"),
              ),
            ],
          ),
          if (_feedbackMessage != null) ...[Text(_feedbackMessage!)],
          SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
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
          ),
        ],
      ),
    );
  }
}
