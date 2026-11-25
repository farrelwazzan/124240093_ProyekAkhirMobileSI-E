
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant.dart';
import 'package:flutter/foundation.dart';

class FavoriteService {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? get currentUserId => _supabase.auth.currentUser?.id;
  // Mengambil ID pengguna yang sedang login
  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  // Mengambil semua restoran favorit pengguna
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    debugPrint('========== FAVORITE DEBUG ==========');
    debugPrint('EMAIL LOGIN: ${user.email}');
    debugPrint('USER ID LOGIN: ${user.id}');

    final response = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final result = List<Map<String, dynamic>>.from(response);

    debugPrint(
      'FAVORITES: ${result.map((item) => item['restaurant_name']).toList()}',
    );
    debugPrint('====================================');

    return result;
  }
  // Memeriksa apakah restoran sudah menjadi favorit
  Future<bool> isFavorite(String restaurantId) async {
    final response = await _supabase
        .from('favorites')
        .select('id')
        .eq('user_id', _userId)
        .eq('restaurant_id', restaurantId)
        .maybeSingle();

    return response != null;
  }

  // Menambahkan restoran ke favorit
  Future<void> addFavorite(Restaurant restaurant) async {
    await _supabase.from('favorites').insert({
      'user_id': _userId,
      'restaurant_id': restaurant.id,
      'restaurant_name': restaurant.name,
      'latitude': restaurant.latitude,
      'longitude': restaurant.longitude,
      'category': restaurant.category.name,
      'address': restaurant.address,
    });
  }

  // Mengubah catatan pribadi
  Future<void> updateNote({
    required String favoriteId,
    required String? note,
  }) async {
    await _supabase
        .from('favorites')
        .update({'note': note})
        .eq('id', favoriteId)
        .eq('user_id', _userId);
  }

  // Menghapus restoran dari favorit
  Future<void> removeFavorite(String restaurantId) async {
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', _userId)
        .eq('restaurant_id', restaurantId);
  }
}
