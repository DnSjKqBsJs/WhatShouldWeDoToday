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
          final trips = snapshot.data!;
          return ListView.builder(
            itemCount: trips.length,
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
                            Text(trips[index].name),
                            Text(trips[index].countryName),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<AppState>(
                            context,
                            listen: false,
                          ).setCurrentTrip(trips[index]);
                          widget.onTripSelected();
                        },
                        child: Text('Select'),
                      ),
                      Padding(padding: EdgeInsets.only(right:10)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DayScreen(
                                tripId: trips[index].id,
                              ),
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
                                    InviteUserScreen(tripId: trips[index].id),
                              ),
                            );
                          }
                          if (value == 'delete') {
                            // on fera la suppression après
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
