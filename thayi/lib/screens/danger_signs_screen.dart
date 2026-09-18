import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../safety/danger_sign_detector.dart';
import '../theme/tokens.dart';
import '../widgets/call_button.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class DangerSignsScreen extends ConsumerWidget {
  const DangerSignsScreen({super.key});

  static const _icons = {
    DangerSign.bleeding: Icons.water_drop_outlined,
    DangerSign.severeHeadache: Icons.psychology_alt_outlined,
    DangerSign.blurredVision: Icons.visibility_off_outlined,
    DangerSign.swelling: Icons.back_hand_outlined,
    DangerSign.fever: Icons.thermostat,
    DangerSign.convulsions: Icons.bolt_outlined,
    DangerSign.reducedFetalMovement: Icons.child_care_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final mother = ref.watch(motherProvider).valueOrNull;

    return SetuScaffold(
      title: l.dangerSignsTitle,
      body: ListView(
        padding: const EdgeInsets.all(S.screen),
        children: [
          Container(
            padding: const EdgeInsets.all(S.md),
            decoration: BoxDecoration(
              color: C.redSoft,
              borderRadius: BorderRadius.circular(S.radius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 28, color: C.red),
                const SizedBox(width: S.sm),
                Expanded(
                  child: Text(
                    l.dangerSignsIntro,
                    style: T.body.copyWith(color: C.red),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: S.md),
          for (final sign in DangerSign.values) ...[
            SetuCard(
              padding: const EdgeInsets.all(S.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: C.redSoft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(_icons[sign], size: 32, color: C.red),
                      ),
                      const SizedBox(width: S.md),
                      Expanded(
                        child: Text(l.dangerSignTitle(sign), style: T.h2),
                      ),
                    ],
                  ),
                  const SizedBox(height: S.md),
                  Text(l.dangerSignBody(sign), style: T.body),
                  const SizedBox(height: S.md),
                  Text(l.whatToDoLabel, style: T.label),
                  const SizedBox(height: S.xs),
                  Text(l.dangerSignDo(sign), style: T.body),
                  const SizedBox(height: S.md),
                  if (mother != null)
                    CallButton(
                      title: l.callMyAsha,
                      number: mother.asha.phone,
                      subtitle: l.ashaName(mother.asha),
                      onFailureMessage: l.callFailed,
                    ),
                ],
              ),
            ),
            const SizedBox(height: S.md),
          ],
          kFabClearance,
        ],
      ),
    );
  }
}
