import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/services/foursquare_service.dart';
import 'package:japan_app/services/place_service.dart';

class Foursquarebottomsheet extends StatelessWidget {
  const Foursquarebottomsheet({super.key, required this.selectedPlace,required this.tripId, required this.onAddTrip});

  final FoursquarePlace selectedPlace;
  final String tripId;
  final VoidCallback onAddTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedPlace.name),
          Text(selectedPlace.formattedAddress),
          Text(selectedPlace.categorie[0]),
          Center(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    PlaceModel place = PlaceModel(
                      id: selectedPlace.fsqPlaceId,
                      tripId: tripId,
                      creatorId: FirebaseAuth.instance.currentUser!.uid,
                      lat: selectedPlace.latLng.latitude,
                      lng: selectedPlace.latLng.longitude,
                      name: selectedPlace.name,
                      description: '',
                      tags: [],
                      imageUrls: [],
                    );
                    PlaceService().addPlace(place);
                    onAddTrip.call();
                  },
                  child: Text("Add to Trip"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
