import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/asha_directory.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../routes.dart';
import '../../theme/tokens.dart';
import '../../widgets/big_action_button.dart';
import '../../widgets/call_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/setu_card.dart';

/// The point of the whole first-open flow: give her a real person to phone.
/// Every row is a call button — she does not have to work out what to tap.
class AshaNearbyScreen extends ConsumerWidget {
  const AshaNearbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(nearbyAshasProvider);
    final located = ref.watch(coordsProvider) != null;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: Text(l.ashaNearbyTitle)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: async.when(
                loading: () => const SkeletonList(count: 3),
                error: (_, __) => EmptyState(
                  icon: Icons.cloud_off_outlined,
                  message: l.errorTitle,
                ),
                data: (list) => ListView(
                  padding: const EdgeInsets.all(S.screen),
                  children: [
                    Text(
                      located ? l.ashaNearbyIntro : l.ashaNearbyIntroNoLocation,
                      style: T.body,
                    ),
                    const SizedBox(height: S.md),
                    for (final asha in list) ...[
                      _AshaCard(asha: asha),
                      const SizedBox(height: S.md),
                    ],
                    const SizedBox(height: S.sm),
                    Container(
                      padding: const EdgeInsets.all(S.md),
                      decoration: BoxDecoration(
                        color: C.tealSoft,
                        borderRadius: BorderRadius.circular(S.radius),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 24, color: C.teal),
                          const SizedBox(width: S.sm),
                          Expanded(
                            child: Text(l.ashaNearbyWhatToSay,
                                style: T.bodySoft.copyWith(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: S.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(S.screen),
              child: BigActionButton(
                label: l.ashaNearbyDone,
                icon: Icons.check,
                onPressed: () async {
                  await ref.read(onboardingProvider.notifier).markCalledAsha();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(
                      context, Routes.onboardingWait);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AshaCard extends StatelessWidget {
  const _AshaCard({required this.asha});

  final DirectoryAsha asha;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isKn = l.localeName.startsWith('kn');
    final name = isKn ? asha.nameKn : asha.nameEn;
    final subCentre = isKn ? asha.subCentreKn : asha.subCentreEn;

    return SetuCard(
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: C.tealSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 32, color: C.teal),
              ),
              const SizedBox(width: S.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: T.h2),
                    const SizedBox(height: S.xs),
                    Text(subCentre, style: T.bodySoft.copyWith(fontSize: 16)),
                    if (asha.distanceKm != null) ...[
                      const SizedBox(height: S.xs),
                      Text(
                        l.distanceKm(asha.distanceKm!.toStringAsFixed(1)),
                        style: T.label.copyWith(color: C.green, fontSize: 15),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: S.md),
          CallButton(
            title: l.ashaNearbyCall,
            number: asha.phone,
            subtitle: asha.phone,
            onFailureMessage: l.callFailed,
          ),
        ],
      ),
    );
  }
}
