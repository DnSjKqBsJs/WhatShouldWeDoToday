import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:japan_app/config.dart';
import 'package:latlong2/latlong.dart';

class FoursquareService {
  Future<List<FoursquarePlace>> searchPlaces(
    String query,
    double lat,
    double lng,
  ) async {
    List<FoursquarePlace> foursquarePlaceFound = [];
    final String key = Config.foursquareApiKey;
    try{
    final response = await http.get(
      Uri.parse(
        'https://places-api.foursquare.com/places/search?query=$query&ll=$lat,$lng&limit=5',
      ),
      headers: {
        'Authorization': 'Bearer $key',
        'X-Places-Api-Version': '2025-06-17',
        'Accept': 'application/json',
      },
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    final List data = json.decode(response.body)['results'];
    
    for (var n in data) {
      foursquarePlaceFound.add(
        FoursquarePlace(
          fsqPlaceId: n['fsq_place_id'],
          name: n['name'],
          latLng: LatLng(n['latitude'], n['longitude']),
          categorie: (n['categories'] as List).map((c) => c['name'] as String).toList(),
          formattedAddress: n['location']['formatted_address'],
        ),
      );
    }
    }catch (e)
    {
        print('Erreur: $e');
    }
    return foursquarePlaceFound;
  }

  
}

class FoursquarePlace {
  final String fsqPlaceId;
  final String name;
  final LatLng latLng;
  final List<String> categorie;
  final String formattedAddress;

  FoursquarePlace({
    required this.fsqPlaceId,
    required this.name,
    required this.latLng,
    required this.categorie,
    required this.formattedAddress,
  });
}
