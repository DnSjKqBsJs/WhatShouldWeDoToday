import 'package:flutter/material.dart';
import 'package:japan_app/models/day_model.dart';
import 'package:japan_app/services/day_service.dart';

class AlertDialogWidget extends StatelessWidget {
  const AlertDialogWidget({
    super.key,
    required this.tripId,
    required this.refresh,
    this.day,
  });

  final String tripId;
  final VoidCallback refresh;
  final DayModel? day;

  @override
  Widget build(BuildContext context) {
    TextEditingController dayNameController = TextEditingController();
    return AlertDialog(
      title: Text('New Day'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text('New Day Name'),
            TextField(controller: dayNameController),
            ElevatedButton(
              onPressed: () async {
                if (day != null) {
                  await DayService().modifyDay(
                    DayModel(
                      id: day!.id,
                      tripId: day!.tripId,
                      name: dayNameController.text,
                      order: day!.order,
                    ),
                  );
                } else {
                  await DayService().createDay(
                    DayModel(
                      id: '',
                      tripId: tripId,
                      name: dayNameController.text,
                      order: 0,
                    ),
                  );
                }

                refresh.call();
              },
              child: Builder(
                builder: (context) {
                  if (day != null) {
                    return Text('Modify');
                  }
                  return Text('Add');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
