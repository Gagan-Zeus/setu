import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/line_chart.dart';
import '../widgets/risk_chip.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final motherAsync = ref.watch(motherProvider);
    final recordAsync = ref.watch(healthRecordProvider);

    return SetuScaffold(
      title: l.healthTitle,
      body: (motherAsync.isLoading || recordAsync.isLoading)
          ? const SkeletonList(count: 4)
          : (motherAsync.hasError || recordAsync.hasError)
              ? EmptyState(
                  icon: Icons.cloud_off_outlined,
                  message: l.errorTitle,
                )
              : _Body(
                  mother: motherAsync.requireValue,
                  record: recordAsync.requireValue,
                ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.mother, required this.record});

  final Mother mother;
  final HealthRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tablets = ref.watch(tabletControllerProvider);
    final tabletCtrl = ref.read(tabletControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(S.screen),
      children: [
        SectionHeader(l.riskFlagsSection),
        SetuCard(
          padding: const EdgeInsets.all(S.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l.bloodGroupLabel, style: T.label),
                  const Spacer(),
                  Text(mother.bloodGroup, style: T.h1.copyWith(color: C.teal)),
                ],
              ),
              const Divider(height: S.lg),
              Wrap(
                spacing: S.sm,
                runSpacing: S.sm,
                children: mother.riskFlagIds.isEmpty
                    ? [
                        RiskChip(
                          label: l.noRiskFlags,
                          level: RiskLevel.normal,
                          icon: Icons.check,
                        )
                      ]
                    : [
                        for (final id in mother.riskFlagIds)
                          RiskChip(
                            label: l.riskFlag(id),
                            level: RiskLevel.caution,
                            icon: Icons.priority_high,
                          ),
                      ],
              ),
            ],
          ),
        ),
        const SizedBox(height: S.lg),
        SectionHeader(l.weightHistory),
        SetuCard(
          padding: const EdgeInsets.all(S.md),
          child: record.weights.isEmpty
              ? Text(l.chartNoData, style: T.bodySoft)
              : SimpleLineChart(
                  xLabels: [
                    for (final w in record.weights) l.weekShort(w.week)
                  ],
                  series: [
                    ChartSeries(
                      values: [for (final w in record.weights) w.kg],
                      color: C.teal,
                      label: l.weightLabel,
                    ),
                  ],
                ),
        ),
        const SizedBox(height: S.lg),
        SectionHeader(l.bpHistory),
        SetuCard(
          padding: const EdgeInsets.all(S.md),
          child: record.bloodPressure.isEmpty
              ? Text(l.chartNoData, style: T.bodySoft)
              : SimpleLineChart(
                  xLabels: [
                    for (final b in record.bloodPressure) l.weekShort(b.week)
                  ],
                  series: [
                    ChartSeries(
                      values: [
                        for (final b in record.bloodPressure)
                          b.systolic.toDouble()
                      ],
                      color: C.terra,
                      label: l.systolic,
                    ),
                    ChartSeries(
                      values: [
                        for (final b in record.bloodPressure)
                          b.diastolic.toDouble()
                      ],
                      color: C.teal,
                      label: l.diastolic,
                    ),
                  ],
                ),
        ),
        const SizedBox(height: S.lg),
        SectionHeader(l.tabletsSection),
        _TabletRow(
          title: l.tabletIfa,
          note: l.tabletIfaNote,
          taken: tablets.ifaTaken,
          onChanged: tabletCtrl.setIfa,
        ),
        const SizedBox(height: S.md),
        _TabletRow(
          title: l.tabletCalcium,
          note: l.tabletCalciumNote,
          taken: tablets.calciumTaken,
          onChanged: tabletCtrl.setCalcium,
        ),
        const SizedBox(height: S.lg),
        SectionHeader(l.ttSection),
        SetuCard(
          padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
          child: Column(
            children: [
              for (final dose in record.ttDoses) ...[
                if (dose != record.ttDoses.first) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: S.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.ttDose(dose.number), style: T.body),
                            if (dose.givenOn != null)
                              Text(
                                l.givenOn(l.formatDate(dose.givenOn!)),
                                style: T.label,
                              ),
                          ],
                        ),
                      ),
                      RiskChip(
                        label: dose.given ? l.statusGiven : l.statusDue,
                        level:
                            dose.given ? RiskLevel.normal : RiskLevel.caution,
                        icon: dose.given ? Icons.check : Icons.schedule,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        kFabClearance,
      ],
    );
  }
}

class _TabletRow extends StatelessWidget {
  const _TabletRow({
    required this.title,
    required this.note,
    required this.taken,
    required this.onChanged,
  });

  final String title;
  final String note;
  final bool taken;
  final Future<void> Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SetuCard(
      padding: const EdgeInsets.all(S.md),
      color: taken ? C.greenSoft : C.card,
      onTap: () => onChanged(!taken),
      child: Row(
        children: [
          Icon(
            taken ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 36,
            color: taken ? C.green : C.textSoft,
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: T.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: S.xs),
                Text(note, style: T.label),
              ],
            ),
          ),
          const SizedBox(width: S.sm),
          Text(
            taken ? l.markTaken : l.markNotTaken,
            style: T.label.copyWith(
              color: taken ? C.green : C.textSoft,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
