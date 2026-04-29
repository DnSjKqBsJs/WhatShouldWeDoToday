import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/trip_model.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:japan_app/services/trip_invitation_service.dart';

class InviteUserScreen extends StatefulWidget {
  const InviteUserScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  final lien = TextEditingController();
  List<UserModel> _friends = [];
  Map<int, String> _feedbackMessages = {};

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
      body: Center(
        child: Column(
          children: [
            Text("Lien pour invitation"),
            TextField(controller: lien),
            Expanded(
              child: ListView.builder(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(_friends[index].firstName),
                                  Text(_friends[index].lastName),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await TripInvitationService()
                                      .sendTripInvitation(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        _friends[index].id,
                                        widget.tripId,
                                      );
                                  switch (result) {
                                    case RequestIssue.successSend:
                                      setState(() {
                                        _feedbackMessages[index] =
                                            "Request sent!";
                                      });
                                    case RequestIssue.alreadySend:
                                      setState(() {
                                        _feedbackMessages[index] =
                                            "Request already send";
                                      });

                                    case RequestIssue.alreadyInTrip:
                                      setState(() {
                                        _feedbackMessages[index] =
                                            "User already in trip";
                                      });
                                  }
                                  Future.delayed(Duration(seconds: 2), () {
                                    if (context.mounted) {
                                      setState(
                                        () => _feedbackMessages.remove(index),
                                      );
                                    }
                                  });
                                },
                                child: Text('Invite'),
                              ),
                            ],
                          ),
                          if (_feedbackMessages[index] != null)
                            Text(_feedbackMessages[index]!),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
