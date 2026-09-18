import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../routes.dart';
import '../../theme/tokens.dart';
import '../../widgets/big_action_button.dart';
import '../../widgets/setu_card.dart';

/// The gap between calling an ASHA and being registered by her. It can be days,
/// so this screen explains what happens next rather than spinning, and stays
/// put across app restarts.
class WaitingScreen extends ConsumerWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final name = ref.watch(onboardingProvider).name;

    Widget step(int number, IconData icon, String text, {bool done = false}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: S.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? C.greenSoft : C.tealSoft,
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 22, color: C.green)
                  : Text('$number',
                      style: T.h2.copyWith(color: C.teal, fontSize: 18)),
            ),
            const SizedBox(width: S.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: S.sm),
                child: Text(text, style: done ? T.bodySoft : T.body),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(S.screen),
                children: [
                  const SizedBox(height: S.lg),
                  Center(
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: const BoxDecoration(
                        color: C.tealSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hourglass_empty,
                          size: 54, color: C.teal),
                    ),
                  ),
                  const SizedBox(height: S.lg),
                  Text(
                    name == null ? l.waitingTitle : l.waitingTitleNamed(name),
                    style: T.h1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: S.sm),
                  Text(l.waitingBody,
                      style: T.body, textAlign: TextAlign.center),
                  const SizedBox(height: S.lg),
                  SetuCard(
                    padding: const EdgeInsets.all(S.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(l.waitingWhatNext),
                        const SizedBox(height: S.sm),
                        step(1, Icons.call, l.waitingStep1, done: true),
                        step(2, Icons.home_outlined, l.waitingStep2),
                        step(3, Icons.mail_outline, l.waitingStep3),
                        step(4, Icons.login, l.waitingStep4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(S.screen),
              child: Column(
                children: [
                  BigActionButton(
                    label: l.waitingHaveEmail,
                    icon: Icons.login,
                    onPressed: () async {
                      await ref.read(onboardingProvider.notifier).finish();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                          context, Routes.login, (_) => false);
                    },
                  ),
                  const SizedBox(height: S.sm),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(
                        context, Routes.onboardingAshaNearby),
                    icon: const Icon(Icons.call, size: 22),
                    label: Text(l.waitingCallAgain),
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
