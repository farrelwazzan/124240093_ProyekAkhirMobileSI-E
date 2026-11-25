
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/restaurant.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  // Membuat link Google Maps dari koordinat restoran
  String get mapsUrl {
    return 'https://www.google.com/maps/search/?api=1&query='
        '${restaurant.latitude},${restaurant.longitude}';
  }

  // Membuka Google Maps
  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse(mapsUrl);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka Google Maps.'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat membuka lokasi.'),
        ),
      );
    }
  }

  // Menyalin link Google Maps
  Future<void> _copyMapsLink(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: mapsUrl),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link Google Maps berhasil disalin.'),
      ),
    );
  }

  // Widget informasi restoran
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: Colors.grey,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = restaurant.imageUrl != null &&
        restaurant.imageUrl!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Restoran'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto restoran jika tersedia
            if (hasImage)
              Image.network(
                restaurant.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Colors.grey,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama dan kategori
                  Text(
                    restaurant.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  Chip(
                    avatar: const Icon(
                      Icons.restaurant_menu,
                      size: 18,
                    ),
                    label: Text(restaurant.category.name),
                  ),

                  const SizedBox(height: 24),

                  // Informasi restoran
                  Text(
                    'Informasi Restoran',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 18),

                  if (restaurant.address != null &&
                      restaurant.address!.trim().isNotEmpty)
                    _buildInfoItem(
                      icon: Icons.location_on_outlined,
                      title: 'Alamat',
                      value: restaurant.address!,
                    ),

                  if (restaurant.cuisine != null &&
                      restaurant.cuisine!.trim().isNotEmpty)
                    _buildInfoItem(
                      icon: Icons.restaurant_menu,
                      title: 'Jenis Kuliner',
                      value: restaurant.cuisine!,
                    ),

                  if (restaurant.openingHours != null &&
                      restaurant.openingHours!.trim().isNotEmpty)
                    _buildInfoItem(
                      icon: Icons.access_time,
                      title: 'Jam Operasional',
                      value: restaurant.openingHours!,
                    ),

                  if (restaurant.phone != null &&
                      restaurant.phone!.trim().isNotEmpty)
                    _buildInfoItem(
                      icon: Icons.phone_outlined,
                      title: 'Nomor Telepon',
                      value: restaurant.phone!,
                    ),

                  if (restaurant.website != null &&
                      restaurant.website!.trim().isNotEmpty)
                    _buildInfoItem(
                      icon: Icons.language,
                      title: 'Website',
                      value: restaurant.website!,
                    ),

                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Lokasi Google Maps
                  Text(
                    'Lokasi Restoran',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Koordinat: ${restaurant.latitude}, '
                    '${restaurant.longitude}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Google Maps dan salin link
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openMaps(context),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Buka Google Maps'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _copyMapsLink(context),
                      icon: const Icon(Icons.copy),
                      label: const Text('Salin Link Google Maps'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
