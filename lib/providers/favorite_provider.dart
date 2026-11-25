
import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService;

  FavoriteProvider(this._favoriteService);

  List<Map<String, dynamic>> favorites = [];
  bool isLoading = false;
  String? error;

  bool _isDisposed = false;

  // Mengambil daftar favorit
  Future<void> fetchFavorites() async {
    final userId = _favoriteService.currentUserId;

    if (userId == null) {
      favorites = [];
      isLoading = false;
      return;
    }

    isLoading = true;
    error = null;

    if (!_isDisposed) notifyListeners();

    try {
      final result = await _favoriteService.getFavorites();

      // Pastikan hasil berasal dari akun yang masih aktif.
      if (_isDisposed ||
          userId != _favoriteService.currentUserId) {
        return;
      }

      favorites = result;
    } catch (e) {
      if (!_isDisposed) {
        error = e.toString();
      }
    } finally {
      if (!_isDisposed &&
          userId == _favoriteService.currentUserId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // Memeriksa status favorit
  bool isFavorite(String restaurantId) {
    return favorites.any(
      (favorite) => favorite['restaurant_id'] == restaurantId,
    );
  }

  // Menambahkan restoran ke favorit
  Future<void> addFavorite(Restaurant restaurant) async {
    try {
      await _favoriteService.addFavorite(restaurant);
      await fetchFavorites();

      if (error != null) {
        throw Exception(error);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Mengubah catatan favorit
  Future<void> updateNote({
    required String favoriteId,
    required String? note,
  }) async {
    await _favoriteService.updateNote(
      favoriteId: favoriteId,
      note: note,
    );

    await fetchFavorites();

    if (error != null) {
      throw Exception(error);
    }
  }

  // Menghapus restoran dari favorit
  Future<void> removeFavorite(String restaurantId) async {
    await _favoriteService.removeFavorite(restaurantId);
    await fetchFavorites();

    if (error != null) {
      throw Exception(error);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
