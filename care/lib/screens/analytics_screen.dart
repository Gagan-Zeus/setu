import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';
import '../widgets/charts.dart';

/// Step 10 — beyond the demo arc. Two charts from data already loaded; the
/// other two the brief lists are not built.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mothers = ref.watch(mothersProvider).valueOrNull;
    if (mothers == null) return const SkeletonList(count: 3);

    final byVillage = <String, int>{};
    final highRiskByVillage = <String, int>{};
    final overdueByVillage = <String, int>{};
    for (final m in mothers) {
      byVillage[m.village] = (byVillage[m.village] ?? 0) + 1;
      if (m.riskLevel != RiskLevel.green) {
        highRiskByVillage[m.village] = (highRiskByVillage[m.village] ?? 0) + 1;
      }
      if (m.isOverdue) {
        overdueByVillage[m.village] = (overdueByVillage[m.village] ?? 0) + 1;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(S.screen),
      children: [
        const SectionLabel('Registrations by village'),
        CareCard(child: MiniBarChart(data: byVillage)),
        const SizedBox(height: S.lg),
        const SectionLabel('High-risk cases by village'),
        CareCard(
          child: MiniBarChart(data: highRiskByVillage, colour: C.terra),
        ),
        const SizedBox(height: S.lg),
        const SectionLabel('Overdue visits by village'),
        CareCard(
          child: MiniBarChart(data: overdueByVillage, colour: C.terra),
        ),
        const SizedBox(height: S.lg),
        const CareCard(
          child: Text(
            'Registrations over time and ANC completion rate are not built — '
            'this screen is past the demo arc.',
            style: T.small,
          ),
        ),
        const SizedBox(height: S.xl),
      ],
    );
  }
}
