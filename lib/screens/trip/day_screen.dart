import 'package:flutter/material.dart';
import 'package:japan_app/models/day_model.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/day_service.dart';
import 'package:japan_app/widgets/alert_dialog_widget.dart';
import 'package:provider/provider.dart';

class DayScreen extends StatefulWidget {
  const DayScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  late Future<List<DayModel>> _future;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = DayService().getDays(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // chargement
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text("Aucun jour pour l'instant"); // liste vide
          }
          final days = snapshot.data!;
          return ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(days[index].name)),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialogWidget(
                              day: days[index],
                              tripId: widget.tripId,
                              refresh: () {
                                setState(() {
                                  _refresh();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        child: Text('Modify'),
                      ),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      ElevatedButton(
                        onPressed: () async {
                          await DayService().deleteDay(days[index]);
                          _refresh();
                          Provider.of<AppState>(context, listen: false).requestMapRefresh();
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
