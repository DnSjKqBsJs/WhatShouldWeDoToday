import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/trip_model.dart';

class AppState extends ChangeNotifier {
  TripModel? currentTrip;
  bool mapNeedsRefresh = false;
  bool tripNeedRefresh = true;
  int _friendCount = 0;
  int _tripsCount = 0;
  int pendingNotification = 0;
  StreamSubscription? _subFriends;
  StreamSubscription? _subTrips;

  void setCurrentTrip(TripModel trip) {
    currentTrip = trip;
    notifyListeners();
  }

  void resetCurrentTrip() {
    currentTrip = null;
    notifyListeners();
  }

  void requestMapRefresh() {
    mapNeedsRefresh = true;
    notifyListeners();
  }

  void mapRefreshDone() {
    mapNeedsRefresh = false;
  }

  void requestTripRefresh() {
    tripNeedRefresh = true;
    notifyListeners();
  }

  void tripRefreshDone() {
    tripNeedRefresh = false;
  }

  void listenToNotification(String userId) {
    _subFriends ??= FirebaseFirestore.instance
        .collection('friendsRequest')
        .where('toId', isEqualTo: userId)
        .snapshots()
        .listen((event) {
          _friendCount = event.size;
          pendingNotification = _friendCount + _tripsCount;
          notifyListeners();
        });
    _subTrips ??= FirebaseFirestore.instance
        .collection('tripInvitation')
        .where('toId', isEqualTo: userId)
        .snapshots()
        .listen((event) {
          _tripsCount = event.size;
          pendingNotification = _friendCount + _tripsCount;
          notifyListeners();
        });
  }

  void cancelNotificationListener() {
    _subFriends?.cancel();
    _subTrips?.cancel();
    _subFriends = null;
    _subTrips = null;
    pendingNotification = 0;
    notifyListeners();
  }
}
