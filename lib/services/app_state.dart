import 'package:flutter/material.dart';
import 'package:japan_app/models/trip_model.dart';

class AppState extends ChangeNotifier{
  TripModel? currentTrip;

  void setCurrentTrip(TripModel trip)
  {
    currentTrip = trip;
    notifyListeners();
  }
}