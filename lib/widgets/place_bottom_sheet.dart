import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:japan_app/models/day_model.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/screens/trip/edit_place_screen.dart';
import 'package:japan_app/services/day_service.dart';
import 'package:japan_app/services/place_service.dart';
import 'package:japan_app/widgets/alert_dialog_widget.dart';

class PlaceBottomSheet extends StatefulWidget {
  const PlaceBottomSheet({
    super.key,
    required this.days,
    required this.place,
    required this.onRefresh,
    required this.tripId,
  });

  final List<DayModel> days;
  final PlaceModel place;
  final VoidCallback onRefresh;
  final String tripId;

  @override
  State<PlaceBottomSheet> createState() => _PlaceBottomSheetState();
}

class _PlaceBottomSheetState extends State<PlaceBottomSheet> {
  List<String> days = [];
  bool _isEditing = false;
  TextEditingController dayName = TextEditingController();
  List<DayModel> _allDays = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _refresh();

    if (widget.place.days != null) {
      days = widget.place.days!;
    }
  }

  void _refresh() async {
    final result = await DayService().getDays(widget.tripId);
    setState(() {
      _allDays = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.place.name),
          Text(widget.place.description),
          Padding(padding: EdgeInsets.all(10)),
          GridView.builder(
            itemCount: widget.place.imageUrls?.length ?? 0,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  widget.place.imageUrls![index].startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: widget.place.imageUrls![index],
                          placeholder: (context, url) =>
                              Container(color: Colors.grey.shade200),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.broken_image),
                        )
                      : Image.file(File(widget.place.imageUrls![index])),
                ],
              );
            },
          ),
          SizedBox(height: 10),
          Text('Days'),

          if (!_isEditing) ...[
            ElevatedButton(
              onPressed: () => setState(() {
                _isEditing = true;
              }),
              child: Text('Edit'),
            ),
            if (days.isEmpty) ...[
              Text('No days assigned or days created'),
            ] else
              ...days
                  .map(
                    (day) => Container(
                      color: Colors.green,
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              _allDays
                                  .firstWhere(
                                    (e) => day == e.id,
                                    orElse: () => DayModel(
                                      id: '',
                                      tripId: '',
                                      name: '...',
                                      order: 0,
                                    ),
                                  )
                                  .name,
                            ),
                            Icon(Icons.check),
                          ],
                        ),
                      ),
                    ),
                  )
                  ,
          ],
          if (_isEditing) ...[
            if (_allDays.isEmpty) ...[
              Text('No Days created Yet'),
            ] else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._allDays.map(
                      (e) => Padding(
                        padding: EdgeInsets.all(5.0),
                        child: FilterChip(
                          label: Text(e.name),
                          selected: days.contains(e.id),
                          onSelected: (bool value) {
                            if (days.contains(e.id)) {
                              days.remove(e.id);
                            } else {
                              days.add(e.id);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  widget.place.days = days;
                  PlaceService().updatePlace(widget.place);
                  setState(() {
                    _isEditing = false;
                  });
                  widget.onRefresh.call();
                },
                child: Text('Save'),
              ),
            ],
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialogWidget(
                  tripId: widget.tripId,
                  refresh: () {
                    _refresh();
                    // setState(() {
                    // });
                    Navigator.pop(context);
                  },
                ),
              ),
              child: Text('Create Day'),
            ),
          ],
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
                          return EditPlaceScreen(place: widget.place);
                        },
                      ),
                    ).then((_) {
                      widget.onRefresh.call();
                    });
                  },
                  child: Text('Update'),
                ),
                Padding(padding: EdgeInsets.only(right: 10)),
                ElevatedButton(
                  onPressed: () =>
                      PlaceService().deletePlace(widget.place).then((value) {
                        widget.onRefresh.call();
                      }),
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
