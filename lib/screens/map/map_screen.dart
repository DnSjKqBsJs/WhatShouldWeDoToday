import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/screens/trip/add_place_screen.dart';
import 'package:japan_app/screens/trip/create_trip_screen.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/place_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<PlaceModel>> _future;
  final _mapController = MapController();
  String? currentTrip = '';

  void moveCam() {
    final trip = Provider.of<AppState>(context, listen: false).currentTrip;
    if (trip != null) {
      _mapController.move(LatLng(trip.centerLat, trip.centerLng), 6);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //WidgetsBinding.instance.addPostFrameCallback((_) { moveCam();});
    _refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final trip = Provider.of<AppState>(context).currentTrip;
    if (trip != null) {
      if (currentTrip != trip.id) {
        _refresh();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          moveCam();
        });
        currentTrip = trip.id;
      }
    }
  }

  void _refresh() {
    final tripId = Provider.of<AppState>(
      context,
      listen: false,
    ).currentTrip?.id;
    setState(() {
      _future = tripId != null
          ? PlaceService().getPlaces(tripId)
          : Future.value([]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<PlaceModel>>(
        future: _future,
        builder: (context, asyncSnapshot) {
          final places = asyncSnapshot.data ?? [];
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onLongPress: (tapPosition, point) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AddPlaceScreen(
                        lat: point.latitude,
                        lng: point.longitude,
                        tripId: Provider.of<AppState>(
                          context,
                          listen: false,
                        ).currentTrip?.id,
                      );
                    },
                  ),
                ).then((_) => _refresh());
              },
              initialCenter: LatLng(35.6762, 139.6503),
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.japan_app',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 15,
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  markers: places
                      .map(
                        (place) => Marker(
                          point: LatLng(place.lat, place.lng),
                          child: GestureDetector(
                            child: Icon(Icons.location_pin, color: Colors.red),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (context) => Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(place.name),
                                      Text(place.description),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTripScreen()),
          );
        },
        child: Icon(Icons.flight),
      ),
    );
  }
}
