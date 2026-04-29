import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  Future<LatLng?> getLocalisation(String localisation) async {
    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$localisation&format=json&limit=1&accept-language=en&accept-language=fr',
      ),
      headers: {'User-Agent': 'WanderMap/1.0'},
    );

    final data = json.decode(response.body) as List;
    if (data.isEmpty) return null;
    final lat = double.parse(data[0]['lat']);
    final lng = double.parse(data[0]['lon']);
    return LatLng(lat, lng);
  }

  Future<List<CountryResult>> getCountry(String country) async {
    final response = await http.get(
      Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$country&format=json&accept-language=en&accept-language=fr',
      ),
      headers: {'User-Agent': 'WanderMap/1.0'},
    );

    final data = json.decode(response.body) as List;
    List<CountryResult> cnt = [];
    if (data.isEmpty) return [];
    for (var n in data) {
      if (n['addresstype'] == 'country') {
        cnt.add(
          CountryResult(
            name: n['name'],
            lat: double.parse(n['lat']),
            lng: double.parse(n['lon']),
          ),
        );
      }
    }
    return cnt;
  }

  Future<List<CountryResult>> searchCountry(String query) async {
    final String data = await rootBundle.loadString('lib/assets/countries.json');
    final List countries = json.decode(data)["ref_country_codes"];
    List<CountryResult> finalAnswer = [];
    for (int i = 0; i < countries.length; i++) {
      if (countries[i]["country"].toLowerCase().contains(query.toLowerCase())){
        finalAnswer.add(
          CountryResult(
            name: countries[i]["country"],
            lat: countries[i]["latitude"].toDouble(),
            lng: countries[i]["longitude"].toDouble(),
          ),
        );
      }
    }
    return finalAnswer;
  }
}

class CountryResult {
  final String name;
  final double lat;
  final double lng;

  CountryResult({required this.name, required this.lat, required this.lng});
}
