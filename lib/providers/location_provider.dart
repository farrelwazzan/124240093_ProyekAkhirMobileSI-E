
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;

  LocationProvider(this._locationService);

  Position? position;
  bool isLoading = false;
  String? error;

  Future<void> getCurrentLocation() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      position = await _locationService.getCurrentLocation();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
