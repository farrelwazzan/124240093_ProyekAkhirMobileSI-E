
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/restaurant.dart';

class RestaurantApiService {
  static const String _baseUrl =
    'https://ovp.dresel.systems/api-as/interpreter';

  Future<List<Restaurant>> fetchNearbyRestaurants({
    required double latitude,
    required double longitude,
    int radius = 2000,
  }) async {
    final query = '''
      [out:json][timeout:25];
      nwr["amenity"~"restaurant|fast_food|cafe|food_court"]
        (around:$radius,$latitude,$longitude);
      out center;
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': 'KuliNear/1.0',
      },
      body: {
        'data': query,
      },
    )
    .timeout(const Duration(seconds: 30));

    // Log untuk pemeriksaan respons server
    debugPrint('Overpass Status: ${response.statusCode}');
    debugPrint('Overpass Headers: ${response.headers}');
    debugPrint('Overpass Body: ${response.body}');

    if (response.statusCode == 429) {
      throw Exception(
        'Server sedang membatasi permintaan. '
        'Silakan coba kembali beberapa saat lagi.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data restoran: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> jsonData =
        jsonDecode(response.body);

    final List elements = jsonData['elements'] ?? [];

    return elements
        .where((element) {
          final tags = element['tags'] ?? {};
          final coordinates = element['center'] ?? element;

          return tags['name'] != null &&
              coordinates['lat'] != null &&
              coordinates['lon'] != null;
        })
        .map(
          (element) => Restaurant.fromOverpassJson(element),
        )
        .toList();
  }
}
