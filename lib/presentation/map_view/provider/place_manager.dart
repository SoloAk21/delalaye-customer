import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerManager {
  final Set<Marker> markers = {};

  /// Add a single marker to the map
  void addMarker({
    required LatLng position,
    required String markerId,
    BitmapDescriptor? icon,
    InfoWindow? infoWindow,
    VoidCallback? onTap,
  }) {
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        icon: icon ?? BitmapDescriptor.defaultMarker,
        infoWindow: infoWindow ?? InfoWindow(title: "Marker $markerId"),
        onTap: onTap,
      ),
    );
  }

  /// Remove a marker by ID
  void removeMarker(String markerId) {
    markers.removeWhere((marker) => marker.markerId.value == markerId);
  }

  /// Clear all markers
  void clearMarkers() {
    markers.clear();
  }

  /// Retrieve all markers
  Set<Marker> getMarkers() {
    return markers;
  }
}
