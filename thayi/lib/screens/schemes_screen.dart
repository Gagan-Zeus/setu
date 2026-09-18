import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/risk_chip.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class SchemesScreen extends ConsumerWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(schemesProvider);

    return SetuScaffold(
      title: l.schemesTitle,
      body: async.when(
        loading: () => const SkeletonList(count: 4),
        error: (_, __) => EmptyState(
          icon: Icons.cloud_off_outlined,
          message: l.errorTitle,
        ),
        data: (schemes) => ListView.separated(
          padding: const EdgeInsets.all(S.screen),
          itemCount: schemes.length + 2,
          separatorBuilder: (_, __) => const SizedBox(height: S.md),
          itemBuilder: (context, i) {
            if (i < schemes.length) return _SchemeCard(scheme: schemes[i]);
            if (i == schemes.length) return const _Footnote();
            return kFabClearance;
          },
        ),
      ),
    );
  }
}

class _SchemeCard extends StatefulWidget {
  const _SchemeCard({required this.scheme});

  final Scheme scheme;

  @override
  State<_SchemeCard> createState() => _SchemeCardState();
}

class _SchemeCardState extends State<_SchemeCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = widget.scheme;

    return SetuCard(
      padding: const EdgeInsets.all(S.md),
      onTap: () => setState(() => _open = !_open),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(l.schemeName(s.id), style: T.h2)),
              const SizedBox(width: S.sm),
              Icon(
                _open ? Icons.expand_less : Icons.expand_more,
                size: 30,
                color: C.textSoft,
              ),
            ],
          ),
          const SizedBox(height: S.sm),
          RiskChip(
            label: s.eligible ? l.badgeEligible : l.badgeNotEligible,
            level: s.eligible ? RiskLevel.normal : RiskLevel.neutral,
            icon: s.eligible ? Icons.check_circle_outline : Icons.info_outline,
          ),
          const SizedBox(height: S.md),
          Text(l.whatYouGet, style: T.label),
          const SizedBox(height: S.xs),
          Text(l.schemeBenefit(s.id), style: T.body),
          if (_open) ...[
            const Divider(height: S.lg),
            Text(l.documentsNeeded, style: T.label),
            const SizedBox(height: S.sm),
            for (final doc in s.documentIds)
              Padding(
                padding: const EdgeInsets.only(bottom: S.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_box_outline_blank,
                        size: 26, color: C.textSoft),
                    const SizedBox(width: S.sm),
                    Expanded(child: Text(l.document(doc), style: T.body)),
                  ],
                ),
              ),
            const SizedBox(height: S.sm),
            Text(l.nearbyHospitals, style: T.label),
            const SizedBox(height: S.sm),
            for (final h in s.hospitals)
              Padding(
                padding: const EdgeInsets.only(bottom: S.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_hospital_outlined,
                        size: 24, color: C.teal),
                    const SizedBox(width: S.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.centreName(h), style: T.body),
                          Text(
                            l.distanceKm(h.distanceKm.toStringAsFixed(1)),
                            style: T.label,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(S.md),
      decoration: BoxDecoration(
        color: C.amberSoft,
        borderRadius: BorderRadius.circular(S.radius),
        border: Border.all(color: C.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 24, color: C.amber),
          const SizedBox(width: S.sm),
          Expanded(
            child: Text(
              l.schemesFootnote,
              style: T.bodySoft.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
