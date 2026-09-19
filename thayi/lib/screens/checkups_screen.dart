import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/risk_chip.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class CheckupsScreen extends ConsumerWidget {
  const CheckupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(checkupsProvider);
    final now = DateTime.now();

    return DefaultTabController(
      length: 2,
      child: SetuScaffold(
        title: l.checkupsTitle,
        bottom: TabBar(
          tabs: [
            Tab(height: S.tapMin, text: l.tabUpcoming),
            Tab(height: S.tapMin, text: l.tabCompleted),
          ],
        ),
        body: async.when(
          loading: () => const SkeletonList(),
          error: (_, __) => EmptyState(
            icon: Icons.cloud_off_outlined,
            message: l.errorTitle,
          ),
          data: (all) {
            final upcoming = all.where((c) => !c.completed).toList()
              ..sort((a, b) => a.date.compareTo(b.date));
            final completed = all.where((c) => c.completed).toList()
              ..sort((a, b) => b.date.compareTo(a.date));
            // Overdue first, in amber.
            upcoming.sort((a, b) {
              final ao = a.isOverdueOn(now) ? 0 : 1;
              final bo = b.isOverdueOn(now) ? 0 : 1;
              return ao != bo ? ao - bo : a.date.compareTo(b.date);
            });

            return TabBarView(
              children: [
                _List(
                  items: upcoming,
                  now: now,
                  emptyMessage: l.emptyUpcoming,
                ),
                _List(
                  items: completed,
                  now: now,
                  emptyMessage: l.emptyCompleted,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.items,
    required this.now,
    required this.emptyMessage,
  });

  final List<Checkup> items;
  final DateTime now;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.event_note_outlined,
        message: emptyMessage,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(S.screen),
      itemCount: items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: S.md),
      itemBuilder: (context, i) => i == items.length
          ? kFabClearance
          : _CheckupCard(checkup: items[i], now: now),
    );
  }
}

class _CheckupCard extends StatelessWidget {
  const _CheckupCard({required this.checkup, required this.now});

  final Checkup checkup;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = checkup;
    final overdue = c.isOverdueOn(now);

    return SetuCard(
      color: overdue ? C.amberSoft : C.card,
      borderColor: overdue ? C.amber : null,
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l.visitNumber(c.visitNumber), style: T.h2),
              ),
              if (overdue)
                RiskChip(
                  label: l.checkupOverdueBadge,
                  level: RiskLevel.caution,
                  icon: Icons.warning_amber_rounded,
                )
              else if (c.completed)
                RiskChip(
                  label: l.statusGiven,
                  level: RiskLevel.normal,
                  icon: Icons.check,
                ),
            ],
          ),
          const SizedBox(height: S.sm),
          _Line(
              icon: Icons.calendar_today_outlined, text: l.formatDate(c.date)),
          // A visit recorded by her ASHA carries no place of its own, and a
          // pin beside an empty line reads as missing data rather than as
          // "this was a home visit".
          if (l.checkupLocation(c).isNotEmpty)
            _Line(icon: Icons.place_outlined, text: l.checkupLocation(c)),
          if (!c.completed && c.activityIds.isNotEmpty) ...[
            const SizedBox(height: S.sm),
            Text(l.whatHappensLabel, style: T.label),
            const SizedBox(height: S.xs),
            Wrap(
              spacing: S.sm,
              runSpacing: S.sm,
              children: [
                for (final a in c.activityIds)
                  RiskChip(
                    label: l.checkupActivity(a),
                    level: RiskLevel.neutral,
                  ),
              ],
            ),
          ],
          if (c.completed) ...[
            const Divider(height: S.lg),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: l.weightLabel,
                    value: c.weightKg == null
                        ? l.notRecorded
                        : l.weightKg(c.weightKg!.toStringAsFixed(1)),
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: l.bpLabel,
                    value: c.systolic == null || c.diastolic == null
                        ? l.notRecorded
                        : l.bpValue(c.systolic!, c.diastolic!),
                  ),
                ),
              ],
            ),
            if (l.checkupRecordedBy(c) != null) ...[
              const SizedBox(height: S.sm),
              Text(l.recordedBy(l.checkupRecordedBy(c)!), style: T.bodySoft),
            ],
          ],
          if (overdue) ...[
            const SizedBox(height: S.md),
            Text(l.overdueBody, style: T.body),
            const SizedBox(height: S.md),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.asha),
              icon: const Icon(Icons.person_outline, size: 26),
              label: Text(l.contactAsha),
              style: FilledButton.styleFrom(
                backgroundColor: C.amber,
                foregroundColor: C.onDark,
                minimumSize: const Size.fromHeight(S.tapMin),
                textStyle: T.button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: S.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: C.textSoft),
          const SizedBox(width: S.sm),
          Expanded(child: Text(text, style: T.body)),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: T.label),
        const SizedBox(height: S.xs),
        Text(value, style: T.h2),
      ],
    );
  }
}
