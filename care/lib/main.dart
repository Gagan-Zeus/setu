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
      // Supabase.initialize does not await session recovery — it fires
      // recoverSession off into a CancelableOperation and returns. So on a
      // cold start currentSession is usually still null when the first widget
      // builds, and apiProvider decided real-versus-demo from exactly that.
      // The console came up on demo data every morning, with the doctor's own
      // caseload sitting in the database untouched, and nothing re-decided for
      // the rest of the run. Waiting briefly for the restore closes the race;
      // authStateProvider handles the case where it is slower than this.
      await _awaitRestoredSession();
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

/// Gives a stored session a moment to come back before the first frame.
///
/// Bounded, because a doctor opening the app on a hospital corridor's signal
/// must not be held on a blank screen: if it has not arrived by then the app
/// starts anyway and switches over when it does.
Future<void> _awaitRestoredSession() async {
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession != null) return;
  try {
    await auth.onAuthStateChange
        .firstWhere((event) => event.session != null)
        .timeout(const Duration(seconds: 3));
  } catch (_) {
    // No stored session, or it could not be refreshed. Either way the login
    // screen is the right next thing.
  }
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
