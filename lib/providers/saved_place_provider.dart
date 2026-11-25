
import 'package:flutter/material.dart';

import '../models/saved_place.dart';
import '../services/saved_place_service.dart';

class SavedPlaceProvider extends ChangeNotifier {
  final SavedPlaceService _service;

  SavedPlaceProvider(this._service);

  List<SavedPlace> savedPlaces = [];
  bool isLoading = false;
  String? error;

  // READ
  Future<void> fetchSavedPlaces() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      savedPlaces = await _service.getSavedPlaces();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // CREATE
  Future<void> addSavedPlace({
    required String name,
    required String mapsUrl,
    String? note,
  }) async {
    await _service.addSavedPlace(
      name: name,
      mapsUrl: mapsUrl,
      note: note,
    );

    await fetchSavedPlaces();
  }

  // UPDATE
  Future<void> updateSavedPlace({
    required String id,
    required String name,
    required String mapsUrl,
    String? note,
  }) async {
    await _service.updateSavedPlace(
      id: id,
      name: name,
      mapsUrl: mapsUrl,
      note: note,
    );

    await fetchSavedPlaces();
  }

  // DELETE
  Future<void> deleteSavedPlace(String id) async {
    await _service.deleteSavedPlace(id);

    await fetchSavedPlaces();
  }
}
