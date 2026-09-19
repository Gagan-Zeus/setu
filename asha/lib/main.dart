import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env.dart';
import 'data/seed_data.dart';
import 'data/sync_service.dart';
import 'db/database.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'routes.dart';
import 'screens/home_screen.dart';
import 'screens/incentive_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mothers_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/register_mother_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/sync_status_screen.dart';
import 'screens/tasks_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Only the publishable key ever reaches the device. If this fails — no
  // signal in the field, project down — the app still starts and runs
  // entirely on local data.
  if (Env.useSupabase && Env.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
    } catch (error) {
      debugPrint('Supabase init failed, continuing offline: $error');
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();
  // A real caseload, seeded once. Everything the UI reads comes from here.
  await SeedData.seedIfEmpty(db);

  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        dbProvider.overrideWithValue(db),
      ],
      child: const SetuAshaApp(),
    ),
  );
}

class SetuAshaApp extends ConsumerStatefulWidget {
  const SetuAshaApp({super.key});

  @override
  ConsumerState<SetuAshaApp> createState() => _SetuAshaAppState();
}

class _SetuAshaAppState extends ConsumerState<SetuAshaApp> {
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    // Background drain. Nothing in the UI ever waits on this.
    _syncTimer = Timer.periodic(const Duration(seconds: 8), (_) => _drain());
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  /// Runs once, the first time this build starts with a real backend.
  ///
  /// Records saved while sync was a stub were marked sent without ever having
  /// arrived, which makes them invisible to the queue for good. Nothing reports
  /// a failure because nothing failed, so the only symptom is a mother who is
  /// simply not on the server. Re-queueing once puts them back in line; the
  /// pushes are upserts, so anything already up there is written again to the
  /// same row rather than duplicated.
  // v2: the first pass also uploaded the handset's practice caseload.
  // v3: re-queueing appended a new outbox row per record per run, so phones
  //     that have already repaired are carrying several identical entries for
  //     every mother. Running once more now collapses them, because requeue()
  //     reuses the row that is already there.
  static const _repairKey = 'outbox_repaired_v3';

  Future<void> _repairOnce() async {
    final prefs = ref.read(prefsProvider);
    if (prefs.getBool(_repairKey) ?? false) return;
    if (ref.read(syncServiceProvider) is MockSyncService) return;
    await ref.read(dbProvider).requeueEverything();
    await prefs.setBool(_repairKey, true);
  }

  Future<void> _drain() async {
    final service = ref.read(syncServiceProvider);
    final connected = ref.read(connectivityProvider).valueOrNull ?? true;
    final forced = ref.read(offlineModeProvider);

    service.forceOffline = forced;
    service.networkUp = connected;
    if (!service.isOnline) return;

    await _repairOnce();
    await ref.read(syncWorkerProvider).drain();
  }

  @override
  Widget build(BuildContext context) {
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
        Routes.pin: (_) => const PinScreen(),
        Routes.home: (_) => const HomeScreen(),
        Routes.mothers: (_) => const MothersScreen(),
        Routes.registerMother: (_) => const RegisterMotherScreen(),
        Routes.tasks: (_) => const TasksScreen(),
        Routes.syncStatus: (_) => const SyncStatusScreen(),
        Routes.incentive: (_) => const IncentiveScreen(),
        Routes.settings: (_) => const SettingsScreen(),
      },
      builder: (context, child) {
        final scale = MediaQuery.textScalerOf(context)
            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scale),
          child: child!,
        );
      },
    );
  }
}
