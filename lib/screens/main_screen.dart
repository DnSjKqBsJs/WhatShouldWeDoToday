import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/friend_request_model.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/screens/map/map_screen.dart';
import 'package:japan_app/screens/profile/profile_screen.dart';
import 'package:japan_app/screens/trip/trips_screen.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:japan_app/services/friend_service.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _notificationCenterOpen = false;
  List<FriendRequestModel> notification = [];
  List<UserModel?> users = [];

  @override
  Widget build(BuildContext context) {
    final pendingCount = context.watch<AppState>().pendingNotification;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar:
          true, // le body passe derrière l'appbar transparence réelle
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  notification = await FriendService().getFriendRequests(
                    FirebaseAuth.instance.currentUser!.uid,
                  );
                  users = [];
                  for (final element in notification) {
                    users.add(await FirestoreService().getUser(element.fromId));
                  }
                  setState(() {
                    _notificationCenterOpen = !_notificationCenterOpen;
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _notificationCenterOpen ? Icons.close : Icons.notifications,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              if (pendingCount > 0)
                Positioned(
                  top: 6,
                  right: 18,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              TripsScreen(
                onTripSelected: () => setState(() => _currentIndex = 1),
              ),
              MapScreen(),
              ProfileScreen(),
            ],
          ),

          // Panel notifs — Positioned en haut à droite, comme FilterPanel
          if (_notificationCenterOpen)
            Positioned(
              top: 70, // juste sous l'appbar
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  constraints: BoxConstraints(maxHeight: 400),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: pendingCount == 0
                      ? Center(child: Text('No notifications'))
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Text('Notifications ici'),
                              ...notification.asMap().entries.map(
                                (e) => Card(
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Invitation à etre amis de :',
                                                ),
                                                Text(users[e.key]!.firstName),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await FriendService()
                                                  .acceptFriendRequest(
                                                    notification[e.key],
                                                  );
                                              if (context.mounted) {
                                                setState(() {
                                                  users.removeAt(e.key);
                                                  notification.removeAt(e.key);
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: Text('Accept'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await FriendService()
                                                  .declineFriendRequest(
                                                    notification[e.key],
                                                  );
                                              if (context.mounted) {
                                                setState(() {
                                                  users.removeAt(e.key);
                                                  notification.removeAt(e.key);
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: Text('Refuse'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (value) => setState(() => _currentIndex = value),
      ),
    );
  }
}

// return Card(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(2),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Column(
//                                               children: [
//                                                 Text("Invitation d'amis de:"),
//                                                 Text(
//                                                   FirestoreService()
//                                                       .getUser(
//                                                         notification[index]
//                                                             .fromId,
//                                                       )
//                                                       .firstName,
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           ElevatedButton(
//                                             onPressed: () {
//                                               FriendService()
//                                                   .acceptFriendRequest(
//                                                     notification[index],
//                                                   );
//                                             },
//                                             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                                             ),
//                                             child: Text("Accept"),
//                                           ),
//                                           Padding(padding: EdgeInsets.all(3)),
//                                           ElevatedButton(
//                                             onPressed: () {
//                                               FriendService()
//                                                   .declineFriendRequest(
//                                                     notification[index],
//                                                   );
//                                             },
//                                             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                                             ),
//                                             child: Text("Refuse"),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
