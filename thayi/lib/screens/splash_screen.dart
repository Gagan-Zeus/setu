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
    // Warm the record up while the logo is on screen so Home never flashes.
    ref.read(motherProvider);
    Future.delayed(const Duration(milliseconds: 1400), _go);
  }

  void _go() {
    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    final onboarding = ref.read(onboardingProvider);

    // Signed in: straight to her record. Otherwise pick up the first-open
    // flow wherever she left it, so closing the app while waiting for her
    // ASHA does not start her over.
    final next = auth.isSignedIn && auth.consentAt != null
        ? Routes.home
        : onboarding.finished
            ? Routes.login
            : onboarding.calledAsha
                ? Routes.onboardingWait
                : onboarding.hasName
                    ? Routes.onboardingLocation
                    : Routes.onboardingWelcome;
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
            const SetuLogo(size: 112),
            const SizedBox(height: S.lg),
            Text(l.appName, style: T.display.copyWith(fontSize: 40)),
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
