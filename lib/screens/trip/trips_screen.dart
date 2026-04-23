import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/trip_model.dart';
import 'package:japan_app/screens/trip/create_trip_screen.dart';
import 'package:japan_app/screens/trip/day_screen.dart';
import 'package:japan_app/screens/trip/invite_user_screen.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:provider/provider.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key, required this.onTripSelected});

  final VoidCallback onTripSelected;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  late Future<List<TripModel>> _future;
  bool _isLoading = false;
  List<TripModel> _trips = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = FirestoreService().getTrips(
        FirebaseAuth.instance.currentUser!.uid,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<TripModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // chargement
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Aucun trip pour l instant'); // liste vide
          }
          _trips = snapshot.data!;
          if (_trips.isEmpty && snapshot.hasData) {
            _trips = snapshot.data!;
          }
          return ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _trips.removeAt(oldIndex);
                _trips.insert(newIndex, item);

                for (int i = 0; i < _trips.length; i++) {
                  FirestoreService().updateTrip(
                    TripModel(
                      id: _trips[i].id,
                      name: _trips[i].name,
                      countryName: _trips[i].countryName,
                      centerLat: _trips[i].centerLat,
                      centerLng: _trips[i].centerLng,
                      users: _trips[i].users,
                      order: i,
                    ),
                    _trips[i].id,
                  ).catchError((e) {
                    _refresh();
                  });
                }
              });
            },
            itemCount: _trips.length,
            itemBuilder: (context, index) {
              return Card(
                key: ValueKey(_trips[index].id),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_trips[index].name),
                            Text(_trips[index].countryName),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<AppState>(
                            context,
                            listen: false,
                          ).setCurrentTrip(_trips[index]);
                          widget.onTripSelected();
                        },
                        child: Text('Select'),
                      ),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DayScreen(tripId: _trips[index].id),
                            ),
                          );
                        },
                        child: Text('OpenDays'),
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'invite',
                            child: Text('Inviter'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Supprimer'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'invite') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InviteUserScreen(tripId: _trips[index].id),
                              ),
                            );
                          }
                          if (value == 'delete') {
                            FirestoreService()
                                .deleteUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  _trips[index].id,
                                )
                                .then((value) {
                                  if (_trips[index].id ==
                                      Provider.of<AppState>(
                                        context,
                                        listen: false,
                                      ).currentTrip?.id) {
                                    Provider.of<AppState>(
                                      context,
                                      listen: false,
                                    ).resetCurrentTrip();
                                  }
                                  _refresh();
                                });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateTripScreen()),
        ).then((_) => _refresh()),
        child: Icon(Icons.add),
      ),
    );
  }
}
