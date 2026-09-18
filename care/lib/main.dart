import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env.dart';
import 'providers.dart';
import 'screens/login_screen.dart';
import 'screens/shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Only the publishable key ever reaches the device; the staff table and RLS
  // decide what a signed-in doctor can read. If this fails the app still
  // starts and falls back to local sign-in.
  if (Env.useSupabase && Env.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
    } catch (error) {
      debugPrint('Supabase init failed, continuing locally: $error');
    }
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const SetuCareApp(),
    ),
  );
}

class SetuCareApp extends ConsumerWidget {
  const SetuCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Protected by construction: no session, no app. Logout clears the session
    // and this swaps back to Login without it being a route.
    final session = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Setu Care',
      theme: buildTheme(),
      home: session == null ? const LoginScreen() : const Shell(),
      builder: (context, child) {
        final scale = MediaQuery.textScalerOf(context)
            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scale),
          child: child!,
        );
      },
    );
  }
}
