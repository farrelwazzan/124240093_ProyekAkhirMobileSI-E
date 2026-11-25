
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/meal_reminder_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authService = AuthService();

  Map<String, bool> enabledReminders = {};
  Map<String, TimeOfDayData> reminderTimes = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Membaca pengaturan yang tersimpan
  Future<void> _loadSettings() async {
    for (final id in MealReminderService.mealIds) {
      enabledReminders[id] =
          await MealReminderService.isEnabled(id);

      reminderTimes[id] =
          await MealReminderService.getTime(id);
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // Mengaktifkan atau menonaktifkan pengingat
  Future<void> _toggleReminder(
    String id,
    bool value,
  ) async {
    try {
      await MealReminderService.setEnabled(id, value);

      if (!mounted) return;

      setState(() {
        enabledReminders[id] = value;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengatur pengingat: $e')),
      );
    }
  }

  // Mengubah waktu pengingat
  Future<void> _changeTime(String id) async {
    final currentTime = reminderTimes[id]!;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
    );

    if (selectedTime == null) return;

    final newTime = TimeOfDayData(
      hour: selectedTime.hour,
      minute: selectedTime.minute,
    );

    try {
      await MealReminderService.setTime(id, newTime);

      if (!mounted) return;

      setState(() {
        reminderTimes[id] = newTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu pengingat berhasil diperbarui'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah waktu: $e')),
      );
    }
  }

  // Tampilan satu pengingat makan
  Widget _buildReminderTile({
    required String id,
    required IconData icon,
  }) {
    final time = reminderTimes[id]!;

    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.15),
          child: Icon(icon, color: Colors.orange),
        ),
        title: Text(
          MealReminderService.mealNames[id]!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: InkWell(
          onTap: () => _changeTime(id),
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.edit,
                  size: 15,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        trailing: Switch(
          value: enabledReminders[id] ?? false,
          activeThumbColor: Colors.orange,
          onChanged: (value) => _toggleReminder(id, value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            const Text(
              'Profil Pengguna',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              authService.currentUser?.email ?? 'Tidak diketahui',
            ),

            const SizedBox(height: 28),

            const Divider(),

            const SizedBox(height: 12),

            const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Pengingat Waktu Makan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Atur pengingat harian sesuai waktu makanmu.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 12),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              )
            else ...[
              _buildReminderTile(
                id: 'breakfast',
                icon: Icons.wb_twilight,
              ),
              _buildReminderTile(
                id: 'lunch',
                icon: Icons.wb_sunny,
              ),
              _buildReminderTile(
                id: 'dinner',
                icon: Icons.nightlight_round,
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await authService.logout();
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal Logout: $e'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
