import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/friend_request_model.dart';
import 'package:japan_app/models/trip_invitation_model.dart';
import 'package:japan_app/models/user_model.dart';
import 'package:japan_app/screens/map/map_screen.dart';
import 'package:japan_app/screens/profile/profile_screen.dart';
import 'package:japan_app/screens/trip/trips_screen.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:japan_app/services/friend_service.dart';
import 'package:japan_app/services/trip_invitation_service.dart';
import 'package:japan_app/widgets/notification_card_widget.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _notificationCenterOpen = false;
  List<FriendRequestModel> friendNotification = [];
  List<TripInvitationModel> tripNotification = [];
  List<UserModel?> friendSender = [];
  List<UserModel?> tripSender = [];

  Future<void> tripRequestAction(
    TripInvitationModel tripRequest,
    int index,
    bool accept,
  ) async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (accept) {
      await TripInvitationService().acceptTripInvitation(tripRequest);
    } else {
      await TripInvitationService().declineTripInvitation(tripRequest);
    }
    if (context.mounted) {
      setState(() {
        tripSender.removeAt(index);
        tripNotification.removeAt(index);
      });
      if (accept) appState.requestTripRefresh();
    }
  }

  Future<void> friendRequestAction(
    FriendRequestModel friendRequest,
    int index,
    bool accept,
  ) async {
    if (accept) {
      await FriendService().acceptFriendRequest(friendRequest);
    } else {
      await FriendService().declineFriendRequest(friendRequest);
    }
    if (context.mounted) {
      setState(() {
        friendSender.removeAt(index);
        friendNotification.removeAt(index);
      });
    }
  }

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
                  friendNotification = await FriendService().getFriendRequests(
                    FirebaseAuth.instance.currentUser!.uid,
                  );
                  tripNotification = await TripInvitationService()
                      .getTripInvitations(
                        FirebaseAuth.instance.currentUser!.uid,
                      );
                  friendSender = [];
                  for (final element in friendNotification) {
                    friendSender.add(
                      await FirestoreService().getUser(element.fromId),
                    );
                  }
                  tripSender = [];
                  for (final element in tripNotification) {
                    tripSender.add(
                      await FirestoreService().getUser(element.fromId),
                    );
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
                              ...friendNotification.asMap().entries.map(
                                (e) => NotificationCardWidget(
                                  sender: friendSender[e.key]!,
                                  type: 'friendRequest',
                                  onAccept: () {
                                    friendRequestAction(
                                      friendNotification[e.key],
                                      e.key,
                                      true,
                                    );
                                    Provider.of<AppState>(
                                      context,
                                      listen: false,
                                    ).requestMapRefresh();
                                  },
                                  onRefuse: () => friendRequestAction(
                                    friendNotification[e.key],
                                    e.key,
                                    false,
                                  ),
                                ),
                              ),
                              ...tripNotification.asMap().entries.map(
                                (e) => NotificationCardWidget(
                                  sender: tripSender[e.key]!,
                                  type: 'tripRequest',
                                  onAccept: () {
                                    tripRequestAction(
                                      tripNotification[e.key],
                                      e.key,
                                      true,
                                    );
                                    Provider.of<AppState>(
                                      context,
                                      listen: false,
                                    ).requestTripRefresh();
                                  },
                                  onRefuse: () => tripRequestAction(
                                    tripNotification[e.key],
                                    e.key,
                                    false,
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
