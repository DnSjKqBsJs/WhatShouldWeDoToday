import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/screens/trip/edit_place_screen.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/foursquare_service.dart';
import 'package:japan_app/services/place_service.dart';
import 'package:japan_app/widgets/cluster_marker.dart';
import 'package:japan_app/widgets/place_marker.dart';
import 'package:japan_app/widgets/search_bar_widget.dart';
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
  final search = TextEditingController();
  FoursquarePlace? _previewPlace;

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
      body: Stack(
        children: [
          FutureBuilder<List<PlaceModel>>(
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
                          return EditPlaceScreen(
                            tripId: Provider.of<AppState>(
                              context,
                              listen: false,
                            ).currentTrip!.id,
                            lat: point.latitude,
                            lng: point.longitude,
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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        return ClusterMarker(markers: markers);
                      },
                      markers: places
                          .map(
                            (place) => Marker(
                              point: LatLng(place.lat, place.lng),
                              child: PlaceMarker(
                                place: place,
                                onRefresh: () {
                                  Navigator.pop(context);
                                  _refresh();
                                },
                                tripId: Provider.of<AppState>(context, listen: false).currentTrip!.id,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  MarkerLayer(
                    markers: _previewPlace != null
                        ? [
                            Marker(
                              child: Icon(
                                Icons.location_pin,
                                color: Colors.blue,
                                size: 40,
                              ),
                              point: _previewPlace!.latLng,
                            ),
                          ]
                        : [],
                  ),
                ],
              );
            },
          ),
          if (Provider.of<AppState>(context, listen: false).currentTrip != null)
            SearchBarWidget(
              currentTrip: Provider.of<AppState>(
                context,
                listen: false,
              ).currentTrip!,
              onPlaceAdded: () {
                _refresh();},
              onPreviewPlace: (p0) {setState(() {
                _previewPlace = p0;
              });},
              onMoveCamera: (p0) {_mapController.move(p0, 15);},
            ),
        ],
      ),
    );
  }
}
