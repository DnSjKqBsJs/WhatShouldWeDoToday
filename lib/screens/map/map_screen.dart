import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/screens/trip/add_place_screen.dart';
import 'package:japan_app/services/app_state.dart';
import 'package:japan_app/services/foursquare_service.dart';
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
  bool _searchOpen = false;
  final search = TextEditingController();
  FoursquarePlace selectedPlace = FoursquarePlace(
    fsqPlaceId: '',
    name: '',
    latLng: LatLng(0, 0),
    categorie: [],
    formattedAddress: '',
  );
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
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(255, 255, 255, 255),
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
                                child: Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                ),
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
            Positioned(
              top: 5,
              left: 3,
              right: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () {},
                    child: Icon(Icons.add),
                  ),
                  Padding(padding: EdgeInsets.all(3)),
                  if (_searchOpen)
                    Expanded(
                      child: Autocomplete<FoursquarePlace>(
                        optionsBuilder: (search) {
                          if (search.text == '') {
                            return const Iterable<FoursquarePlace>.empty();
                          }
                          return FoursquareService().searchPlaces(
                            search.text,
                            Provider.of<AppState>(
                              context,
                              listen: false,
                            ).currentTrip!.centerLat,
                            Provider.of<AppState>(
                              context,
                              listen: false,
                            ).currentTrip!.centerLng,
                          );
                        },
                        displayStringForOption: (FoursquarePlace option) =>
                            option.name,
                        onSelected: (FoursquarePlace selectedplace) {
                          selectedPlace = selectedplace;
                          _mapController.move(selectedplace.latLng, 15);
                          setState(() {
                            _previewPlace = selectedplace;
                          });
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,

                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(selectedplace.name),
                                    Text(selectedplace.formattedAddress),
                                    Text(selectedplace.categorie[0]),
                                    ElevatedButton(
                                      onPressed: () {
                                        PlaceService().addPlace(
                                          PlaceModel(
                                            id: selectedplace.fsqPlaceId,
                                            tripId: Provider.of<AppState>(
                                              context,
                                              listen: false,
                                            ).currentTrip!.id,
                                            creatorId: FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                            lat: selectedplace.latLng.latitude,
                                            lng: selectedplace.latLng.longitude,
                                            name: selectedplace.name,
                                            description: '',
                                            tags: [],
                                          ),
                                        );
                                        Navigator.pop(context);
                                        setState(() {
                                          _previewPlace = null;
                                        });
                                        _refresh();
                                      },
                                      child: Text("Add to Trip"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).then((_) {
                            setState(() => _previewPlace = null);
                          });
                        },
                      ),
                    ),
                  Padding(padding: EdgeInsets.all(3)),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      setState(() {
                        _searchOpen = !_searchOpen;
                      });
                    },
                    child: Icon(Icons.search),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
