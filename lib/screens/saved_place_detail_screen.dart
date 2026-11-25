
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/saved_place.dart';
import '../providers/saved_place_provider.dart';
import 'saved_place_form_screen.dart';

class SavedPlaceDetailScreen extends StatefulWidget {
  final SavedPlace place;

  const SavedPlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  State<SavedPlaceDetailScreen> createState() =>
      _SavedPlaceDetailScreenState();
}

class _SavedPlaceDetailScreenState
    extends State<SavedPlaceDetailScreen> {
  late SavedPlace place;

  @override
  void initState() {
    super.initState();
    place = widget.place;
  }

  // Membuka Google Maps
  Future<void> _openMaps() async {
    final uri = Uri.tryParse(place.mapsUrl);

    if (uri == null ||
        !uri.hasScheme ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link Google Maps tidak valid.'),
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka Google Maps.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat membuka lokasi.'),
        ),
      );
    }
  }

  // Membuka halaman edit
  Future<void> _editPlace() async {
    final provider = context.read<SavedPlaceProvider>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: SavedPlaceFormScreen(place: place),
        ),
      ),
    );

    if (!mounted || result != true) return;

    // Ambil data terbaru dari Provider
    final updatedPlace = provider.savedPlaces.firstWhere(
      (item) => item.id == place.id,
      orElse: () => place,
    );

    setState(() {
      place = updatedPlace;
    });
  }

  // Menghapus tempat
  Future<void> _deletePlace() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Tempat'),
          content: Text(
            'Apakah kamu yakin ingin menghapus ${place.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      await context
          .read<SavedPlaceProvider>()
          .deleteSavedPlace(place.id);

      if (!mounted) return;

      Navigator.pop(context);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tempat berhasil dihapus.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus tempat: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tempat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama tempat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 26,
                    child: Icon(Icons.restaurant, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    place.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tempat kuliner tersimpan',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Catatan
            Text(
              'Catatan Pribadi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                place.note?.trim().isNotEmpty == true
                    ? place.note!.trim()
                    : 'Belum ada catatan untuk tempat ini.',
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 28),

            // Lokasi
            Text(
              'Lokasi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _openMaps,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Buka lokasi di Google Maps',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tombol edit dan hapus
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editPlace,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deletePlace,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
