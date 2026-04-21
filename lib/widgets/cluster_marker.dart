import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class ClusterMarker extends StatelessWidget {
  const ClusterMarker({super.key, required this.markers, this.color = const Color.fromRGBO(215, 126, 126, 1)});

  final List<Marker> markers;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      child: Center(
        child: Text(
          markers.length.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
