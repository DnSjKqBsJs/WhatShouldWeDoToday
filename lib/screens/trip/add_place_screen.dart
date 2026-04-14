import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/services/geocoding_service.dart';
import 'package:japan_app/services/place_service.dart';
import 'package:latlong2/latlong.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({
    super.key,
    required this.lat,
    required this.lng,
    required this.tripId,
  });

  final double lat;
  final double lng;
  final String? tripId;

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final placeName = TextEditingController();
  final placeDescription = TextEditingController();
  final placeAdress = TextEditingController();
  late double _lat;
  late double _lng;

  @override
  void initState() {
    super.initState();
    _lat = widget.lat;
    _lng = widget.lng;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Adress",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
              controller: placeAdress,
            ),
            ElevatedButton(
              onPressed: () async {
                LatLng? latlng = await GeocodingService().getLocalisation(
                  placeAdress.text,
                );
                if (latlng != null) {
                  setState(() {
                    _lat = latlng.latitude;
                    _lng = latlng.longitude;
                  });
                }
              },
              child: Text('Search'),
            ),
            Text('Localisation : $_lat, $_lng'),
            Padding(padding: EdgeInsets.all(4.0)),
            Text(
              "Place Name",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(4.0)),
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
              controller: placeName,
            ),
            Padding(padding: EdgeInsets.all(8.0)),
            Text(
              "Place Description",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(4.0)),
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
              controller: placeDescription,
            ),
            Padding(padding: EdgeInsets.all(4.0)),
            ElevatedButton(
              onPressed: () async {
                if (widget.tripId == null) return;
                await PlaceService().addPlace(
                  PlaceModel(
                    id: '',
                    tripId: widget.tripId!,
                    creatorId: FirebaseAuth.instance.currentUser!.uid,
                    lat: _lat,
                    lng: _lng,
                    name: placeName.text,
                    description: placeDescription.text,
                    tags: [],
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
