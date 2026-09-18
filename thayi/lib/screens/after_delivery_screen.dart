import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/line_chart.dart';
import '../widgets/risk_chip.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class AfterDeliveryScreen extends ConsumerWidget {
  const AfterDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(babyRecordProvider);

    return SetuScaffold(
      title: l.afterDeliveryTitle,
      body: async.when(
        loading: () => const SkeletonList(count: 3),
        error: (_, __) => EmptyState(
          icon: Icons.cloud_off_outlined,
          message: l.errorTitle,
        ),
        data: (record) => ListView(
          padding: const EdgeInsets.all(S.screen),
          children: [
            Container(
              padding: const EdgeInsets.all(S.md),
              decoration: BoxDecoration(
                color: C.tealSoft,
                borderRadius: BorderRadius.circular(S.radius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 24, color: C.teal),
                  const SizedBox(width: S.sm),
                  Expanded(
                    child: Text(
                      l.afterDeliveryNote,
                      style: T.bodySoft.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: S.lg),
            SectionHeader(l.immunisationSection),
            SetuCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
              child: Column(
                children: [
                  for (var i = 0; i < record.vaccines.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: S.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.vaccine(record.vaccines[i].vaccineId),
                                  style: T.body,
                                ),
                                Text(
                                  l.babyAge(record.vaccines[i].ageId),
                                  style: T.label,
                                ),
                              ],
                            ),
                          ),
                          RiskChip(
                            label: record.vaccines[i].given
                                ? l.statusGiven
                                : l.statusPending,
                            level: record.vaccines[i].given
                                ? RiskLevel.normal
                                : RiskLevel.neutral,
                            icon: record.vaccines[i].given
                                ? Icons.check
                                : Icons.schedule,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: S.lg),
            SectionHeader(l.growthSection),
            SetuCard(
              padding: const EdgeInsets.all(S.md),
              child: record.growth.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: S.md),
                      child: EmptyState(
                        icon: Icons.child_friendly_outlined,
                        message: l.growthEmpty,
                      ),
                    )
                  : SimpleLineChart(
                      xLabels: [
                        for (final g in record.growth) l.weekShort(g.week)
                      ],
                      series: [
                        ChartSeries(
                          values: [for (final g in record.growth) g.kg],
                          color: C.teal,
                          label: l.weightLabel,
                        ),
                      ],
                    ),
            ),
            kFabClearance,
          ],
        ),
      ),
    );
  }
}
