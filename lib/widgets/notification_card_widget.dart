import 'package:flutter/material.dart';
import 'package:japan_app/models/user_model.dart';

class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({
    super.key,
    required this.sender,
    required this.type,
    required this.onAccept,
    required this.onRefuse,
  });

  final UserModel sender;
  final String type;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    type == 'friendRequest'
                        ? 'Demande d\'ami de :'
                        : 'Invitation trip de :',
                  ),
                  Text(sender.firstName),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                onAccept.call();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Accept'),
            ),
            ElevatedButton(
              onPressed: () async {
                onRefuse.call();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Refuse'),
            ),
          ],
        ),
      ),
    );
  }
}
