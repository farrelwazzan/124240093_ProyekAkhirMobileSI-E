
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/saved_place.dart';

class SavedPlaceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  // READ
  Future<List<SavedPlace>> getSavedPlaces() async {
    final response = await _supabase
        .from('saved_places')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => SavedPlace.fromJson(item))
        .toList();
  }

  // CREATE
  Future<void> addSavedPlace({
    required String name,
    required String mapsUrl,
    String? note,
  }) async {
    await _supabase.from('saved_places').insert({
      'user_id': _userId,
      'name': name,
      'maps_url': mapsUrl,
      'note': note,
    });
  }

  // UPDATE
  Future<void> updateSavedPlace({
    required String id,
    required String name,
    required String mapsUrl,
    String? note,
  }) async {
    await _supabase
        .from('saved_places')
        .update({
          'name': name,
          'maps_url': mapsUrl,
          'note': note,
        })
        .eq('id', id)
        .eq('user_id', _userId);
  }

  // DELETE
  Future<void> deleteSavedPlace(String id) async {
    await _supabase
        .from('saved_places')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
