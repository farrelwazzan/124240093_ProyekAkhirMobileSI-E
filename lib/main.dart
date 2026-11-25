
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/location_provider.dart';
import 'providers/restaurant_provider.dart';
import 'services/location_service.dart';
import 'services/restaurant_api_service.dart';
import 'services/meal_reminder_service.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vgnjxuhgxztqtnjrkzgo.supabase.co',
    publishableKey: 'sb_publishable_PSaAYVgObgmwAog5LaRobQ_D0wEP0b7',
  );

  // Inisialisasi pengingat makan
  await MealReminderService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocationProvider(LocationService()),
        ),
        ChangeNotifierProvider(
          create: (_) => RestaurantProvider(RestaurantApiService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KuliNear',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
      ),
      home: const AuthGate(),
    );
  }
}
