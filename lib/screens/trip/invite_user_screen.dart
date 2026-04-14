import 'package:flutter/material.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/services/firestore_service.dart';

class InviteUserScreen extends StatefulWidget {
  const InviteUserScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  final email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(decoration: InputDecoration(border: OutlineInputBorder()),
              controller: email,),
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            ElevatedButton(onPressed: () async {
              UserModel? user = await FirestoreService().getUserByMail(email.text);
              if(user != null)
              {
                await FirestoreService().addUserToTrip(user, widget.tripId);
                Navigator.pop(context);
              }
            }, child: Text("Inviter"))
          ],
        ),
      ),
    );
  }
}