import 'package:flutter/material.dart';
import 'package:japan_app/models/trip_model.dart';

class AppState extends ChangeNotifier {
  TripModel? currentTrip;
  bool mapNeedsRefresh = false;

  void setCurrentTrip(TripModel trip) {
    currentTrip = trip;
    notifyListeners();
  }

  void resetCurrentTrip()
  {
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
}
