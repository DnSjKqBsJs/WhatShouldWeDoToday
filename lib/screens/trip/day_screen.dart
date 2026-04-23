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
  List<DayModel> _days = [];

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
          _days = snapshot.data!;
          if (_days.isEmpty && snapshot.hasData) {
            _days = snapshot.data!;
          }
          return ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if(newIndex>oldIndex) newIndex--;
                final item = _days.removeAt(oldIndex);
                _days.insert(newIndex, item);

                for(int i = 0; i < _days.length; i++)
                {
                  
                }
              });
            },
            itemCount: _days.length,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(_days[index].name)),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialogWidget(
                              day: _days[index],
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
                          await DayService().deleteDay(_days[index]);
                          _refresh();
                          Provider.of<AppState>(
                            context,
                            listen: false,
                          ).requestMapRefresh();
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
