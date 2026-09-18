import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'routes.dart';
import 'screens/after_delivery_screen.dart';
import 'screens/asha_screen.dart';
import 'screens/ask_setu_screen.dart';
import 'screens/checkups_screen.dart';
import 'screens/danger_signs_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/health_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding/asha_nearby_screen.dart';
import 'screens/onboarding/location_screen.dart';
import 'screens/onboarding/name_screen.dart';
import 'screens/onboarding/waiting_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/thayi_card_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Only the publishable key ever reaches the device; RLS does the guarding.
  // If this fails (no signal on a field phone, project down), the app still
  // starts and falls back to the mock repository rather than showing nothing.
  if (Env.useSupabase && Env.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
    } catch (error, stack) {
      debugPrint('Supabase init failed, continuing on mock data: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const SetuThayiApp(),
    ),
  );
}

class SetuThayiApp extends ConsumerWidget {
  const SetuThayiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: buildTheme(),
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (_) => const SplashScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.onboardingWelcome: (_) => const WelcomeScreen(),
        Routes.onboardingName: (_) => const NameScreen(),
        Routes.onboardingLocation: (_) => const LocationScreen(),
        Routes.onboardingAshaNearby: (_) => const AshaNearbyScreen(),
        Routes.onboardingWait: (_) => const WaitingScreen(),
        Routes.home: (_) => const HomeScreen(),
        Routes.profile: (_) => const ProfileScreen(),
        Routes.thayiCard: (_) => const ThayiCardScreen(),
        Routes.checkups: (_) => const CheckupsScreen(),
        Routes.health: (_) => const HealthScreen(),
        Routes.schemes: (_) => const SchemesScreen(),
        Routes.askSetu: (_) => const AskSetuScreen(),
        Routes.dangerSigns: (_) => const DangerSignsScreen(),
        Routes.asha: (_) => const AshaScreen(),
        Routes.emergency: (_) => const EmergencyScreen(),
        Routes.afterDelivery: (_) => const AfterDeliveryScreen(),
      },
      builder: (context, child) {
        // Respect the system font size but never let it break the layout on
        // a low-end phone with accessibility scaling turned all the way up.
        final scale = MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scale),
          child: child!,
        );
      },
    );
  }
}
