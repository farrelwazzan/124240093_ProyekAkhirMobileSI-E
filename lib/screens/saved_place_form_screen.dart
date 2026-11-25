import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_place.dart';
import '../providers/saved_place_provider.dart';

class SavedPlaceFormScreen extends StatefulWidget {
  final SavedPlace? place;

  const SavedPlaceFormScreen({
    super.key,
    this.place,
  });

  @override
  State<SavedPlaceFormScreen> createState() =>
      _SavedPlaceFormScreenState();
}

class _SavedPlaceFormScreenState
    extends State<SavedPlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mapsUrlController = TextEditingController();
  final _noteController = TextEditingController();

  bool isSaving = false;

  bool get isEditing => widget.place != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _nameController.text = widget.place!.name;
      _mapsUrlController.text = widget.place!.mapsUrl;
      _noteController.text = widget.place!.note ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapsUrlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> savePlace() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final provider = context.read<SavedPlaceProvider>();

      if (isEditing) {
        await provider.updateSavedPlace(
          id: widget.place!.id,
          name: _nameController.text.trim(),
          mapsUrl: _mapsUrlController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
      } else {
        await provider.addSavedPlace(
          name: _nameController.text.trim(),
          mapsUrl: _mapsUrlController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Tempat berhasil diperbarui.'
                : 'Tempat berhasil ditambahkan.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan tempat: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Tempat' : 'Tambah Tempat',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Tempat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Kopi Kenangan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tempat wajib diisi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Link Google Maps',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mapsUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: 'Tempel link Google Maps',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  final url = Uri.tryParse(value?.trim() ?? '');

                  if (value == null || value.trim().isEmpty) {
                    return 'Link lokasi wajib diisi.';
                  }

                  if (url == null ||
                      !url.hasScheme ||
                      !['http', 'https'].contains(url.scheme) ||
                      url.host.isEmpty) {
                    return 'Masukkan link yang valid.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Catatan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan pribadi...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : savePlace,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditing ? 'Simpan Perubahan' : 'Simpan Tempat',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
