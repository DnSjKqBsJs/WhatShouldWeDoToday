import 'package:flutter/material.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/services/day_service.dart';
import 'package:japan_app/widgets/place_bottom_sheet.dart';

class PlaceMarker extends StatelessWidget {
  const PlaceMarker({
    super.key,
    required this.place,
    required this.onRefresh,
    required this.tripId,
  });

  final PlaceModel place;
  final VoidCallback onRefresh;
  final String tripId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(Icons.location_pin, color: Colors.red),
      onTap: () async {
        final days = await DayService().getDays(tripId);
        if (!context.mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => PlaceBottomSheet(
            days: days,
            place: place,
            onRefresh: onRefresh,
            tripId: tripId,
          ),
        );
      },
    );
  }
}
