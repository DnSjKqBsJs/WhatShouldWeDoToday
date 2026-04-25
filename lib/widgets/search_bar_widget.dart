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
    required this.onMoveCamera,
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
  FoursquarePlace selectedPlace = FoursquarePlace(
    fsqPlaceId: '',
    name: '',
    latLng: LatLng(0, 0),
    categorie: [],
    formattedAddress: '',
  );

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchOpen)
            Container(
              width: 220,
              height: 44,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Autocomplete<FoursquarePlace>(
                fieldViewBuilder:
                    (context, controller, focusNode, onSubmitted) {
                      _autocompleteController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un lieu...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black38,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                        },
                      );
                    },
                  ).then((_) {
                    _autocompleteController.clear();
                    widget.onPreviewPlace.call(null);
                    widget.onPlaceAdded.call();
                  });
                },
              ),
            ),
          _buildButton(
            icon: Icons.search,
            active: _searchOpen,
            onTap: () => setState(() => _searchOpen = !_searchOpen),
          ),
        ],
      ),
    );
  }
}
