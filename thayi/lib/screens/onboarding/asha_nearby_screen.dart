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
                // Never a fabricated number. She may be about to dial this in an
                // emergency, and one that does not answer is worse than none.
                error: (_, __) => _Nothing(
                  icon: Icons.wifi_off_rounded,
                  title: l.ashaOffline,
                  body: l.ashaOfflineBody,
                  retryLabel: l.ashaRetry,
                  onRetry: () => ref.invalidate(nearbyAshasProvider),
                ),
                data: (list) => list.isEmpty
                    ? _Nothing(
                        icon: Icons.person_search_outlined,
                        title: l.ashaNoneYet,
                        body: l.ashaNoneYetBody,
                        retryLabel: l.ashaRetry,
                        onRetry: () => ref.invalidate(nearbyAshasProvider),
                      )
                    : ListView(
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
                    if (_proximity(l, asha) != null) ...[
                      const SizedBox(height: S.xs),
                      Text(
                        _proximity(l, asha)!,
                        style: T.label.copyWith(color: C.green, fontSize: 15),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (asha.onDuty) ...[
            const SizedBox(height: S.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: S.sm, vertical: S.xs),
                  decoration: BoxDecoration(
                    color: C.greenSoft,
                    borderRadius: BorderRadius.circular(S.radius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: C.green),
                      const SizedBox(width: S.xs),
                      Text(
                        l.ashaOnDutyNow,
                        style: T.label.copyWith(color: C.green, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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

/// What to say about how far away she is.
///
/// An on-duty worker within 2 km is described by band rather than by an exact
/// figure: her live distance is never given as a number. Everyone else is
/// measured to their sub-centre, and that is worded as approximate unless she
/// pinned the spot herself — a PHC centroid is not a surveyed position and
/// should not read like one.
String? _proximity(AppLocalizations l, DirectoryAsha asha) {
  if (asha.nearby) {
    switch (asha.proximityBand) {
      case 'under_1km':
        return l.ashaBandUnder1km;
      case '1_to_2km':
        return l.ashaBand1to2km;
    }
  }
  final km = asha.distanceKm;
  if (km == null) return null;
  return asha.isApproximate
      ? l.distanceKmApprox(km.toStringAsFixed(1))
      : l.distanceKm(km.toStringAsFixed(1));
}

/// Shown when there is nobody to list, and when we could not find out.
///
/// Both say what to do next. The offline one explicitly says we will not show a
/// number that might not reach anyone, because a woman staring at an empty
/// screen deserves to know it is deliberate.
class _Nothing extends StatelessWidget {
  const _Nothing({
    required this.icon,
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(S.screen),
      children: [
        const SizedBox(height: S.xl),
        Icon(icon, size: 64, color: C.textSoft),
        const SizedBox(height: S.lg),
        Text(title, style: T.h2, textAlign: TextAlign.center),
        const SizedBox(height: S.sm),
        Text(body, style: T.bodySoft, textAlign: TextAlign.center),
        const SizedBox(height: S.xl),
        BigActionButton(
          label: retryLabel,
          icon: Icons.refresh_rounded,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
