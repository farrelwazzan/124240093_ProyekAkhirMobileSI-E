import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_place.dart';
import '../providers/saved_place_provider.dart';
import 'saved_place_detail_screen.dart';
import 'saved_place_form_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  // Navigasi ke detail tempat
  void _openDetail(
    BuildContext context,
    SavedPlace place,
  ) {
    final provider = context.read<SavedPlaceProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: SavedPlaceDetailScreen(place: place),
        ),
      ),
    );
  }

  // Navigasi ke form tambah
  void _addPlace(BuildContext context) {
    final provider = context.read<SavedPlaceProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const SavedPlaceFormScreen(),
        ),
      ),
    );
  }

  // Navigasi ke form edit
  void _editPlace(
    BuildContext context,
    SavedPlace place,
  ) {
    final provider = context.read<SavedPlaceProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: SavedPlaceFormScreen(place: place),
        ),
      ),
    );
  }

  // Hapus tempat
  Future<void> _deletePlace(
    BuildContext context,
    SavedPlace place,
  ) async {
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

    if (confirmed != true || !context.mounted) return;

    try {
      await context
          .read<SavedPlaceProvider>()
          .deleteSavedPlace(place.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tempat berhasil dihapus.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus tempat: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedPlaceProvider>();

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tempat Tersimpan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => _addPlace(context),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Text(
                        'Gagal memuat tempat: ${provider.error}',
                      ),
                    );
                  }

                  if (provider.savedPlaces.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada tempat tersimpan.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tambahkan tempat kuliner yang ingin kamu kunjungi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    itemCount: provider.savedPlaces.length,
                    itemBuilder: (context, index) {
                      final place = provider.savedPlaces[index];

                      return _buildSavedPlaceCard(
                        context,
                        place,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPlaceCard(
    BuildContext context,
    SavedPlace place,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.restaurant),
        ),

        title: Text(place.name),

        subtitle: Text(
          place.note?.trim().isNotEmpty == true
              ? place.note!.trim()
              : 'Tidak ada catatan',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Ketuk kartu untuk membuka detail
        onTap: () => _openDetail(context, place),

        // Menu edit dan hapus
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editPlace(context, place);
            } else if (value == 'delete') {
              _deletePlace(context, place);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text('Hapus'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}