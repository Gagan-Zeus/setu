import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';
import '../widgets/charts.dart';
import 'mother_record_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);

    return async.when(
      loading: () => const SkeletonList(count: 5),
      error: (_, __) => const EmptyState(
        message: 'Could not load the dashboard',
        icon: Icons.cloud_off_outlined,
      ),
      data: (d) => ListView(
        padding: const EdgeInsets.all(S.screen),
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '${d.totalMothers}',
                  label: 'Registered',
                ),
              ),
              const SizedBox(width: S.sm),
              Expanded(
                child: StatTile(
                  value: '${d.highRisk}',
                  label: 'High risk',
                  tone: RiskLevel.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: S.sm),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '${d.visitsOverdue}',
                  label: 'Visits overdue',
                  tone: RiskLevel.amber,
                ),
              ),
              const SizedBox(width: S.sm),
              Expanded(
                child: StatTile(
                  value: '${d.openReferrals}',
                  label: 'Open referrals',
                ),
              ),
            ],
          ),
          const SizedBox(height: S.lg),
          const SectionLabel('Needs attention'),
          CareCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < d.needsAttention.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _AttentionRow(mother: d.needsAttention[i]),
                ],
                if (d.needsAttention.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(S.md),
                    child: Text('Nothing flagged', style: T.small),
                  ),
              ],
            ),
          ),
          const SizedBox(height: S.lg),
          const SectionLabel('Recent activity'),
          CareCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < d.recentVisits.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ActivityRow(visit: d.recentVisits[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: S.lg),
          const SectionLabel('Registrations by village'),
          CareCard(
            child: MiniBarChart(data: d.registrationsByVillage),
          ),
          const SizedBox(height: S.xl),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    final reason =
        mother.riskReasons.isNotEmpty ? mother.riskReasons.first : 'Flagged';
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MotherRecordScreen(motherId: mother.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(mother.name,
                            style: T.body.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: S.sm),
                      Text('${mother.gestationalWeeks}w', style: T.small),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(reason,
                      style: T.small.copyWith(
                        color:
                            mother.riskLevel == RiskLevel.red ? C.red : C.amber,
                      )),
                  const SizedBox(height: 2),
                  Text('${mother.village} · ${mother.ashaName}',
                      style: T.small),
                ],
              ),
            ),
            const SizedBox(width: S.sm),
            RiskBadge(level: mother.riskLevel, compact: true),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.visit});

  final AncVisit visit;

  @override
  Widget build(BuildContext context) {
    final bp = visit.bpSys != null && visit.bpDia != null
        ? '${visit.bpSys}/${visit.bpDia}'
        : '—';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visit ${visit.visitNo} · BP $bp', style: T.body),
                const SizedBox(height: 2),
                RoleTag(name: visit.recordedBy, source: visit.source),
              ],
            ),
          ),
          Text(DateFormat('d MMM').format(visit.visitDate), style: T.small),
        ],
      ),
    );
  }
}
