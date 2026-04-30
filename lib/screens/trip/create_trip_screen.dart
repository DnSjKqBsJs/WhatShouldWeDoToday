import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:japan_app/models/trip_model.dart';
import 'package:japan_app/screens/main_screen.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:japan_app/services/geocoding_service.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key, this.trip});

  final TripModel? trip;

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final tripName = TextEditingController();
  final tripDestination = TextEditingController();
  String _localImagePath = '';
  final ImagePicker _picker = ImagePicker();
  CountryResult _selectedCountry = CountryResult(name: "", lat: 0, lng: 0);

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      tripName.text = widget.trip!.name;
      tripDestination.text = widget.trip!.countryName;
      _selectedCountry = CountryResult(
        lat: widget.trip!.centerLat,
        lng: widget.trip!.centerLng,
        name: widget.trip!.countryName,
      );
    }
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
            Center(
              child: GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _localImagePath = image.path;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _localImagePath.isNotEmpty
                      ? FileImage(File(_localImagePath))
                      : (widget.trip?.coverUrl ?? '').isNotEmpty
                      ? NetworkImage(widget.trip!.coverUrl!)
                      : null,
                  child: _localImagePath.isEmpty
                      ? Icon(Icons.supervised_user_circle, size: 50)
                      : null,
                ),
              ),
            ),

            Text(
              "Trip Name",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(4.0)),
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
              controller: tripName,
            ),
            Padding(padding: EdgeInsets.all(8.0)),
            Text(
              "Trip Destination",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(4.0)),
            if (widget.trip != null) ...[
              TextField(controller: tripDestination, enabled: false),
            ] else ...[
              Autocomplete<CountryResult>(
                optionsBuilder: (tripDestination) {
                  if (tripDestination.text == '') {
                    return const Iterable<CountryResult>.empty();
                  }
                  return GeocodingService().searchCountry(tripDestination.text);
                },
                displayStringForOption: (CountryResult option) => option.name,
                onSelected: (CountryResult selectedCountry) {
                  _selectedCountry = selectedCountry;
                },
              ),
            ],

            Padding(padding: EdgeInsets.all(4.0)),
            ElevatedButton(
              onPressed: () async {
                if (_selectedCountry.name.isEmpty) {
                  return;
                }
                final id = FirebaseFirestore.instance
                    .collection('trips')
                    .doc()
                    .id;
                final storageId = widget.trip != null ? widget.trip!.id : id;
                final ref = FirebaseStorage.instance.ref().child(
                  'trip/$storageId/cover.jpg',
                );
                String url = '';
                if (_localImagePath.isNotEmpty) {
                  await ref.putFile(File(_localImagePath));
                  url = await ref.getDownloadURL();
                }

                if (widget.trip != null) {
                  await FirestoreService().updateTrip(
                    TripModel(
                      id: storageId,
                      name: tripName.text,
                      countryName: widget.trip!.countryName,
                      centerLat: widget.trip!.centerLat,
                      centerLng: widget.trip!.centerLng,
                      users: widget.trip!.users,
                      order: widget.trip!.order,
                      coverUrl: _localImagePath.isNotEmpty
                          ? url
                          : widget.trip!.coverUrl!.isNotEmpty
                          ? widget.trip!.coverUrl
                          : '',
                    ),
                    storageId,
                  );
                } else {
                  TripModel tripModel = await FirestoreService().createTrip(
                    TripModel(
                      id: storageId,
                      name: tripName.text,
                      countryName: _selectedCountry.name,
                      centerLat: _selectedCountry.lat,
                      centerLng: _selectedCountry.lng,
                      users: [FirebaseAuth.instance.currentUser!.uid],
                      order: 0,
                      coverUrl: _localImagePath.isNotEmpty ? url : '',
                    ),
                  );
                  // Provider.of<AppState>(
                  //   context,
                  //   listen: false,
                  // ).setCurrentTrip(tripModel); Met direct le trip crée en current trip
                }
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MainScreen();
                    },
                  ),
                );
              },
              child: widget.trip == null ? Text('Create') : Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
