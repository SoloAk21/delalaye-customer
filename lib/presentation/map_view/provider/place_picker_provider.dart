import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/broker_info_model.dart';
import '../service/place_picker_service.dart';
import 'place_manager.dart';

class PlacePickerProvider extends ChangeNotifier {
  final PlacePickerApiService apiService;
  final MarkerManager markerManager = MarkerManager();

  LatLng initialTarget = const LatLng(8.985006, 38.792100);
  bool isLoading = false;
  List<BrokerInfo> brokers = [];
  LatLng? lastFetchedLocation;
  int? lastServiceId;

  PlacePickerProvider(String apiKey)
      : apiService = PlacePickerApiService(apiKey);

  /// Fetch brokers and update markers
  Future<void> fetchBrokersAndSetMarkers(
      double latitude, double longitude, int serviceId) async {
    // Prevent redundant calls if location and serviceId are unchanged
    if (lastFetchedLocation != null &&
        lastFetchedLocation!.latitude == latitude &&
        lastFetchedLocation!.longitude == longitude &&
        lastServiceId == serviceId) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      brokers = await apiService.fetchBrokers(
        latitude: latitude,
        longitude: longitude,
        serviceId: serviceId,
      );
      lastFetchedLocation = LatLng(latitude, longitude);
      lastServiceId = serviceId;
      _addBrokerMarkers(brokers);
    } catch (e) {
      debugPrint("Error fetching brokers: $e");
      // Optional: Handle errors with a retry or a user-friendly message
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Add broker markers to the map
  void _addBrokerMarkers(List<BrokerInfo> brokers) {
    markerManager.clearMarkers();
    for (var broker in brokers) {
      if (broker.addresses != null && broker.addresses!.isNotEmpty) {
        final address = broker.addresses!.first;
        _createBrokerMarker(
          id: broker.id,
          position: LatLng(address.latitude ?? 0.0, address.longitude ?? 0.0),
          fullName: broker.fullName,
        );
      }
    }
  }

  /// Helper function to create a marker
  void _createBrokerMarker({
    required int? id,
    required LatLng position,
    String? fullName,
  }) {
    markerManager.addMarker(
      position: position,
      markerId: "broker-$id",
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(title: fullName ?? "Broker"),
    );
  }

  /// Get all markers
  Set<Marker> getMarkers() => markerManager.getMarkers();

  void searchPlace(String query) async {
    // if (query.isEmpty) return;

    // isLoading = true;
    // notifyListeners();

    // try {
    //   // Call the Place API to fetch search results
    //   final placeId = await apiService.searchPlace('query');
    //   if (placeId != null) {
    //     final location = await apiService.getLocationFromPlaceId(placeId);
    //     if (location != null) {
    //       // Move camera to the searched location
    //       _addBrokerMarkers(brokers);
    //     }
    //   }
    // } catch (e) {
    //   debugPrint("Error searching place: $e");
    // } finally {
    //   isLoading = false;
    //   notifyListeners();
    // }
  }
}
