import 'package:flutter/material.dart';
import 'package:japan_app/models/trip_model.dart';
import 'package:japan_app/services/foursquare_service.dart';
import 'package:japan_app/widgets/foursquare_bottom_sheet.dart.dart';
import 'package:latlong2/latlong.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.currentTrip,
    required this.onPlaceAdded,
    required this.onPreviewPlace,
    required this.onMoveCamera
  });

  final TripModel currentTrip;
  final VoidCallback onPlaceAdded;
  final Function(FoursquarePlace?) onPreviewPlace;
  final Function(LatLng) onMoveCamera;

  @override
  State<SearchBarWidget> createState() => _SearchBarStateWidget();
}

class _SearchBarStateWidget extends State<SearchBarWidget> {
  bool _searchOpen = false;
  late TextEditingController _autocompleteController;
  final search = TextEditingController();
  FoursquarePlace selectedPlace = FoursquarePlace(
    fsqPlaceId: '',
    name: '',
    latLng: LatLng(0, 0),
    categorie: [],
    formattedAddress: '',
  );

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                fieldViewBuilder:
                    (context, controller, focusNode, onSubmitted) {
                      _autocompleteController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                optionsBuilder: (search) {
                  if (search.text == '') {
                    return const Iterable<FoursquarePlace>.empty();
                  }
                  return FoursquareService().searchPlaces(
                    search.text,
                    widget.currentTrip.centerLat,
                    widget.currentTrip.centerLng,
                  );
                },
                displayStringForOption: (FoursquarePlace option) => option.name,
                onSelected: (FoursquarePlace selectedplace) {
                  selectedPlace = selectedplace;
                  widget.onMoveCamera.call(selectedplace.latLng);
                  widget.onPreviewPlace(selectedplace);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (context) {
                      return Foursquarebottomsheet(
                        selectedPlace: selectedPlace,
                        tripId: widget.currentTrip.id,
                        onAddTrip: () {
                          Navigator.pop(context);
                          widget.onPlaceAdded.call();
                        },
                      );
                    },
                  ).then((_) {
                    _autocompleteController.clear();
                    widget.onPreviewPlace.call(null);
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
    );
  }
}
