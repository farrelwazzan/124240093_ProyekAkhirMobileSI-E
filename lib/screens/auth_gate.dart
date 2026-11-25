
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/favorite_provider.dart';
import '../services/favorite_service.dart';
import 'auth_screen.dart';
import 'main_navigation_screen.dart';
import '../providers/saved_place_provider.dart';
import '../services/saved_place_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? supabase.auth.currentSession;

        if (session != null) {
          return MultiProvider(
            key: ValueKey(session.user.id),
            providers: [
              ChangeNotifierProvider(
                create: (_) => SavedPlaceProvider(
                  SavedPlaceService(),
                )..fetchSavedPlaces(),
              ),
            ],
            child: const MainNavigationScreen(),
          );
        }

        return const AuthScreen();
      },
    );
  }
}
