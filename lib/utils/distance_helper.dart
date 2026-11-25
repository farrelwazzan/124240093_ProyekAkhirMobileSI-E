
import 'package:geolocator/geolocator.dart';

class DistanceHelper {
  static double calculateDistance({
    required double userLatitude,
    required double userLongitude,
    required double restaurantLatitude,
    required double restaurantLongitude,
  }) {
    return Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      restaurantLatitude,
      restaurantLongitude,
    );
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    }

    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }
}
