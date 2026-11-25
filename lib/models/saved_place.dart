
class SavedPlace {
  final String id;
  final String userId;
  final String name;
  final String mapsUrl;
  final String? note;
  final DateTime? createdAt;

  const SavedPlace({
    required this.id,
    required this.userId,
    required this.name,
    required this.mapsUrl,
    this.note,
    this.createdAt,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      mapsUrl: json['maps_url'],
      note: json['note'],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
    );
  }
}
