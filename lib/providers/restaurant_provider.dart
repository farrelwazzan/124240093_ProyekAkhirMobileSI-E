
import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../services/restaurant_api_service.dart';
import '../utils/distance_helper.dart';

class RestaurantProvider extends ChangeNotifier {
  final RestaurantApiService _apiService;

  RestaurantProvider(this._apiService);

  List<Restaurant> restaurants = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchNearbyRestaurants({
    required double latitude,
    required double longitude,
  }) async {
    if (isLoading) return;
    
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      restaurants = await _apiService.fetchNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
        radius: 2000,
      );

      // Urutkan restoran dari yang terdekat
      restaurants.sort((a, b) {
        final distanceA = DistanceHelper.calculateDistance(
          userLatitude: latitude,
          userLongitude: longitude,
          restaurantLatitude: a.latitude,
          restaurantLongitude: a.longitude,
        );

        final distanceB = DistanceHelper.calculateDistance(
          userLatitude: latitude,
          userLongitude: longitude,
          restaurantLatitude: b.latitude,
          restaurantLongitude: b.longitude,
        );

        return distanceA.compareTo(distanceB);
      });
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
