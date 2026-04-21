import 'package:flutter/material.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/screens/trip/edit_place_screen.dart';
import 'package:japan_app/services/place_service.dart';

class PlaceMarker extends StatelessWidget {
  const PlaceMarker({super.key, required this.place, required this.onRefresh});

  final PlaceModel place;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return EditPlaceScreen(place: place);
                              },
                            ),
                          ).then((_) {
                            onRefresh.call();
                          });
                        },
                        child: Text('Update'),
                      ),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      ElevatedButton(
                        onPressed: () =>
                            PlaceService().deletePlace(place).then((value) {
                              onRefresh.call();
                            }),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
