import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/trip_model.dart';
import 'package:japan_app/screens/main_screen.dart';
import 'package:japan_app/services/firestore_service.dart';
import 'package:japan_app/services/geocoding_service.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final tripName = TextEditingController();
  final tripDestination = TextEditingController();
  CountryResult _selectedCountry = CountryResult(name: "", lat: 0, lng: 0);
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
            Padding(padding: EdgeInsets.all(4.0)),
            ElevatedButton(
              onPressed: () async {
                if(_selectedCountry.name.isEmpty)
                {
                  return;
                }
                TripModel tripModel = await FirestoreService().createTrip(
                  TripModel(
                    id: '',
                    name: tripName.text,
                    countryName: _selectedCountry.name,
                    centerLat: _selectedCountry.lat,
                    centerLng: _selectedCountry.lng,
                    users: [FirebaseAuth.instance.currentUser!.uid],
                    order: 0,
                  ),
                );
                // Provider.of<AppState>(
                //   context,
                //   listen: false,
                // ).setCurrentTrip(tripModel); Met direct le trip crée en current trip
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MainScreen();
                    },
                  ),
                );
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}




