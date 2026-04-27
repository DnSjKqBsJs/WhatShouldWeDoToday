import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/trip_model.dart';

class AppState extends ChangeNotifier {
  TripModel? currentTrip;
  bool mapNeedsRefresh = false;
  int pendingNotification = 0;
  StreamSubscription? _sub;

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

  void listenToNotification(String userId) {
    if (_sub != null) return;
    _sub = FirebaseFirestore.instance
        .collection('friendsRequest')
        .where('toId', isEqualTo: userId)
        .snapshots()
        .listen((event) {
          pendingNotification = event.size;
          notifyListeners();
        });
  }

  void cancelNotificationListener()
  {
    _sub?.cancel();
    _sub = null;
    pendingNotification = 0;
    notifyListeners();
  }
}
