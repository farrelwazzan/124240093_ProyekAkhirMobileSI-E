
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MealReminderService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _timeZoneInitialized = false;

  static const List<String> mealIds = [
    'breakfast',
    'lunch',
    'dinner',
  ];

  static const Map<String, String> mealNames = {
    'breakfast': 'Sarapan',
    'lunch': 'Makan Siang',
    'dinner': 'Makan Malam',
  };

  static const Map<String, String> mealMessages = {
    'breakfast':
        'Hai! Waktunya sarapan. Yuk, cari kuliner terdekat!',
    'lunch':
        'Waktunya makan siang! Temukan kuliner terdekat.',
    'dinner':
        'Waktunya makan malam. Yuk, cari makanan enak!',
  };

  static const Map<String, int> defaultHours = {
    'breakfast': 9,
    'lunch': 12,
    'dinner': 19,
  };

  static void _initializeTimeZone() {
    if (_timeZoneInitialized) return;

    tz.initializeTimeZones();
    _timeZoneInitialized = true;
  }

  static Future<void> initialize() async {
    _initializeTimeZone();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<bool> isEnabled(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${id}_enabled') ?? false;
  }

  static Future<TimeOfDayData> getTime(String id) async {
    final prefs = await SharedPreferences.getInstance();

    return TimeOfDayData(
      hour: prefs.getInt('${id}_hour') ?? defaultHours[id]!,
      minute: prefs.getInt('${id}_minute') ?? 0,
    );
  }

  static Future<void> setEnabled(
    String id,
    bool enabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('${id}_enabled', enabled);

    if (enabled) {
      final time = await getTime(id);
      await schedule(id, time);
    } else {
      await _notifications.cancel(id: _notificationId(id));
    }
  }

  static Future<void> setTime(
    String id,
    TimeOfDayData time,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('${id}_hour', time.hour);
    await prefs.setInt('${id}_minute', time.minute);

    if (await isEnabled(id)) {
      await schedule(id, time);
    }
  }

  static Future<void> schedule(
    String id,
    TimeOfDayData time,
  ) async {
    _initializeTimeZone();

    final location = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime.now(location);

    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: _notificationId(id),
      title: 'KuliNear - ${mealNames[id]}',
      body: mealMessages[id],
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminder_channel',
          'Pengingat Waktu Makan',
          channelDescription:
              'Pengingat sarapan, makan siang, dan makan malam',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static int _notificationId(String id) {
    return mealIds.indexOf(id) + 1;
  }
}

class TimeOfDayData {
  final int hour;
  final int minute;

  const TimeOfDayData({
    required this.hour,
    required this.minute,
  });
}
