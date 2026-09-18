import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/call_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/risk_chip.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

/// Breaks the calm palette on purpose. Someone else may be holding her phone.
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final motherAsync = ref.watch(motherProvider);

    return SetuScaffold(
      showEmergencyButton: false,
      backgroundColor: C.bg,
      body: Column(
        children: [
          _RedHeader(),
          Expanded(
            child: motherAsync.when(
              loading: () => const SkeletonList(count: 3),
              error: (_, __) => EmptyState(
                icon: Icons.cloud_off_outlined,
                message: l.errorTitle,
              ),
              data: (m) => _Body(mother: m),
            ),
          ),
        ],
      ),
    );
  }
}

class _RedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      color: C.red,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(S.sm, S.sm, S.screen, S.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 30,
                color: C.onDark,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.emergencyTitle,
                      style: T.h1.copyWith(color: C.onDark),
                    ),
                    const SizedBox(height: S.xs),
                    Text(
                      l.emergencyIntro,
                      style: T.bodySoft.copyWith(
                        color: C.onDark.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = mother;

    return ListView(
      padding: const EdgeInsets.all(S.screen),
      children: [
        SetuCard(
          padding: const EdgeInsets.all(S.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.bloodGroupLabel, style: T.label),
              const SizedBox(height: S.xs),
              Text(m.bloodGroup, style: T.display.copyWith(color: C.red)),
              const SizedBox(height: S.md),
              Text(l.fieldEdd, style: T.label),
              const SizedBox(height: S.xs),
              Text(l.formatDate(m.edd), style: T.h1),
              const SizedBox(height: S.md),
              Text(l.riskFlagsLabel, style: T.label),
              const SizedBox(height: S.sm),
              if (m.riskFlagIds.isEmpty)
                Text(l.noneRecorded, style: T.h2)
              else
                Wrap(
                  spacing: S.sm,
                  runSpacing: S.sm,
                  children: [
                    for (final id in m.riskFlagIds)
                      RiskChip(
                        label: l.riskFlag(id),
                        level: RiskLevel.danger,
                        icon: Icons.priority_high,
                      ),
                  ],
                ),
              const SizedBox(height: S.md),
              Text(l.allergiesLabel, style: T.label),
              const SizedBox(height: S.xs),
              Text(
                m.allergyIds.isEmpty ? l.noneRecorded : m.allergyIds.join(', '),
                style: T.h2,
              ),
            ],
          ),
        ),
        const SizedBox(height: S.lg),
        CallButton(
          title: l.callAmbulance,
          number: '108',
          subtitle: '108',
          background: C.red,
          onFailureMessage: l.callFailed,
        ),
        const SizedBox(height: S.md),
        CallButton(
          title: l.callAsha,
          number: m.asha.phone,
          subtitle: l.ashaName(m.asha),
          onFailureMessage: l.callFailed,
        ),
        const SizedBox(height: S.md),
        CallButton(
          title: l.callPhc,
          number: m.phc.phone,
          subtitle: l.centreName(m.phc),
          onFailureMessage: l.callFailed,
        ),
        const SizedBox(height: S.lg),
        SetuCard(
          padding: const EdgeInsets.all(S.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.nearestHospitalLabel, style: T.label),
              const SizedBox(height: S.sm),
              Text(l.centreName(m.phc), style: T.h2),
              const SizedBox(height: S.xs),
              Text(
                l.distanceKm(m.phc.distanceKm.toStringAsFixed(1)),
                style: T.bodySoft,
              ),
              const SizedBox(height: S.md),
              OutlinedButton.icon(
                onPressed: () => _openDirections(context, m.phc),
                icon: const Icon(Icons.directions, size: 26),
                label: Text(l.directions),
              ),
            ],
          ),
        ),
        const SizedBox(height: S.lg),
      ],
    );
  }

  Future<void> _openDirections(
      BuildContext context, HealthCentre centre) async {
    final l = AppLocalizations.of(context);
    final lat = centre.latitude;
    final lng = centre.longitude;
    final query = lat != null && lng != null
        ? '$lat,$lng'
        : Uri.encodeComponent(centre.nameEn);

    final candidates = [
      Uri.parse('geo:$query?q=$query'),
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
    ];

    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      } catch (_) {
        // Try the next one.
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.callFailed, style: T.body)),
      );
    }
  }
}
