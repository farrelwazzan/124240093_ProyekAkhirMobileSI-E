import 'category.dart';

class Restaurant {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final Category category;

  final String? address;
  final String? cuisine;
  final String? openingHours;
  final String? phone;
  final String? website;
  final String? imageUrl;

  const Restaurant({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.address,
    this.cuisine,
    this.openingHours,
    this.phone,
    this.website,
    this.imageUrl,
  });

  factory Restaurant.fromOverpassJson(Map<String, dynamic> json) {
    final tags = Map<String, dynamic>.from(
      json['tags'] ?? {},
    );

    final coordinates = json['center'] ?? json;

    final street = tags['addr:street'];
    final houseNumber = tags['addr:housenumber'];
    final city = tags['addr:city'];

    final address = [
      street,
      houseNumber,
      city,
    ].where((value) => value != null).join(', ');

    return Restaurant(
      id: '${json['type']}_${json['id']}',
      name: tags['name'] ?? 'Tanpa Nama',
      latitude: (coordinates['lat'] as num).toDouble(),
      longitude: (coordinates['lon'] as num).toDouble(),
      category: Category.fromOverpassTags(tags),
      address: address.isEmpty ? null : address,
      cuisine: tags['cuisine'],
      openingHours: tags['opening_hours'],
      phone: tags['phone'],
      website: tags['website'],
      imageUrl: tags['image'],
    );
  }
}