import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/setu_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Warm the rules asset so the first visit screen never waits on it.
    ref.read(riskEngineProvider);
    Future.delayed(const Duration(milliseconds: 1200), _go);
  }

  void _go() {
    if (!mounted) return;
    final session = ref.read(authControllerProvider);
    final next = !session.isSignedIn
        ? Routes.login
        : (session.hasPin ? Routes.pin : Routes.home);
    Navigator.of(context).pushReplacementNamed(next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: C.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SetuLogo(size: 108),
            const SizedBox(height: S.lg),
            Text(l.appName, style: T.display.copyWith(fontSize: 38)),
            const SizedBox(height: S.sm),
            Text(l.appTagline, style: T.bodySoft),
            const SizedBox(height: S.xl),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: C.tealSoft,
                color: C.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
