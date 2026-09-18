import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import '../../theme/tokens.dart';
import '../../widgets/big_action_button.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/setu_logo.dart';

/// The very first thing she sees. No account, no form — just congratulations
/// and one way forward.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(S.screen, S.md, S.screen, 0),
              // She can switch language before anything else happens.
              child: const LanguageToggle(compact: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(S.screen),
                child: Column(
                  children: [
                    const SizedBox(height: S.lg),
                    const SetuLogo(size: 132),
                    const SizedBox(height: S.xl),
                    Text(
                      l.welcomeCongrats,
                      style: T.display.copyWith(fontSize: 34),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: S.md),
                    Text(
                      l.welcomeBody,
                      style: T.body.copyWith(fontSize: 19),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: S.lg),
                    Container(
                      padding: const EdgeInsets.all(S.md),
                      decoration: BoxDecoration(
                        color: C.tealSoft,
                        borderRadius: BorderRadius.circular(S.radius),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.volunteer_activism_outlined,
                              size: 26, color: C.teal),
                          const SizedBox(width: S.sm),
                          Expanded(
                            child: Text(l.welcomeHow, style: T.bodySoft),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(S.screen),
              child: Column(
                children: [
                  BigActionButton(
                    label: l.welcomeStart,
                    icon: Icons.arrow_forward,
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.onboardingName),
                  ),
                  const SizedBox(height: S.sm),
                  // Someone whose ASHA has already registered her skips
                  // straight to signing in.
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, Routes.login),
                    child: Text(l.welcomeAlreadyRegistered),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
