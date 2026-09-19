import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/duty_service.dart';
import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/asha_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/setu_card.dart';
import 'mother_profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider);
    final mothers = ref.watch(mothersProvider).valueOrNull ?? const <Mother>[];
    final openTasks = ref.watch(tasksProvider('open')).valueOrNull;
    final now = DateTime.now();

    final highRisk = mothers.where((m) => m.riskLevel != 'green').length;
    final due = (openTasks ?? const <Task>[])
        .where((t) => !t.dueDate.isAfter(now))
        .length;

    return AshaScaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'register-mother',
        backgroundColor: C.terra,
        foregroundColor: C.onDark,
        onPressed: () => Navigator.pushNamed(context, Routes.registerMother),
        icon: const Icon(Icons.person_add_alt, size: 28),
        label: Text(l.registerMother,
            style: T.button.copyWith(color: C.onDark, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(S.screen, S.md, S.screen, 0),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.greeting(session.name ?? l.appName),
                      style: T.h1,
                    ),
                    const SizedBox(height: S.xs),
                    Text(
                      DateFormat('EEEE, d MMM', l.localeName).format(now),
                      style: T.bodySoft,
                    ),
                  ],
                ),
              ),
              IconButton(
                iconSize: 30,
                tooltip: l.incentiveTitle,
                onPressed: () => Navigator.pushNamed(context, Routes.incentive),
                icon: const Icon(Icons.receipt_long_outlined),
              ),
              IconButton(
                iconSize: 30,
                tooltip: l.syncTitle,
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.syncStatus),
                icon: const Icon(Icons.sync),
              ),
              IconButton(
                iconSize: 30,
                tooltip: l.settingsTitle,
                onPressed: () => Navigator.pushNamed(context, Routes.settings),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: S.md),
          const _DutyCard(),
          const SizedBox(height: S.md),
          Row(
            children: [
              Expanded(
                child: _CounterTile(
                  value: '${mothers.length}',
                  label: l.statAssigned,
                  icon: Icons.groups_outlined,
                  accent: C.teal,
                  onTap: () => Navigator.pushNamed(context, Routes.mothers),
                ),
              ),
              const SizedBox(width: S.sm),
              Expanded(
                child: _CounterTile(
                  value: '$highRisk',
                  label: l.statHighRisk,
                  icon: Icons.priority_high,
                  accent: C.red,
                  onTap: () => Navigator.pushNamed(context, Routes.mothers,
                      arguments: 'highRisk'),
                ),
              ),
              const SizedBox(width: S.sm),
              Expanded(
                child: _CounterTile(
                  value: '$due',
                  label: l.statVisitsDue,
                  icon: Icons.event_available_outlined,
                  accent: C.amber,
                  onTap: () => Navigator.pushNamed(context, Routes.tasks),
                ),
              ),
            ],
          ),
          const SizedBox(height: S.lg),
          SectionHeader(
            l.todaysWork,
            trailing: TextButton(
              onPressed: () => Navigator.pushNamed(context, Routes.tasks),
              child: Text(l.tasksTitle, style: T.label.copyWith(color: C.teal)),
            ),
          ),
          if (openTasks == null)
            const Column(
              children: [
                SkeletonCard(height: 116),
                SizedBox(height: S.md),
                SkeletonCard(height: 116),
              ],
            )
          else if (openTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: S.xl),
              child: EmptyState(
                icon: Icons.task_alt,
                message: l.noTasks,
              ),
            )
          else
            for (final task in openTasks) ...[
              TaskCard(
                task: task,
                mother: _lookup(mothers, task.motherId),
              ),
              const SizedBox(height: S.md),
            ],
          kFabClearance,
        ],
      ),
    );
  }

  static Mother? _lookup(List<Mother> mothers, String id) {
    for (final m in mothers) {
      if (m.id == id) return m;
    }
    return null;
  }
}

/// "I am working now", and the mothers around her can see it.
///
/// It sits on the home screen rather than in settings on purpose. She flips it
/// twice a day, and — more to the point — while it is on, her phone is saying
/// where she is. That is not something to leave buried behind a menu where she
/// cannot see at a glance that it is still running.
class _DutyCard extends ConsumerStatefulWidget {
  const _DutyCard();

  @override
  ConsumerState<_DutyCard> createState() => _DutyCardState();
}

class _DutyCardState extends ConsumerState<_DutyCard> {
  @override
  void initState() {
    super.initState();
    // A restart must not silently take her off the list. The server is asked
    // whether the shift it knows about is still running.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(dutyControllerProvider.notifier).restore();
    });
  }

  String? _problem(AppLocalizations l, DutyProblem? p) => switch (p) {
        DutyProblem.noLocation => l.dutyNoLocation,
        DutyProblem.offline => l.dutyOffline,
        DutyProblem.unavailable => l.dutyUnavailable,
        DutyProblem.noPosting => l.dutyNoPosting,
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final duty = ref.watch(dutyControllerProvider);
    final problem = _problem(l, duty.problem);

    return SetuCard(
      padding: const EdgeInsets.all(S.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: duty.onDuty ? C.greenSoft : C.tealSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              duty.onDuty ? Icons.my_location : Icons.location_off_outlined,
              size: 24,
              color: duty.onDuty ? C.green : C.teal,
            ),
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.dutyTitle, style: T.h2),
                const SizedBox(height: S.xs),
                Text(
                  problem ?? (duty.onDuty ? l.dutyOnBody : l.dutyOffBody),
                  style: T.bodySoft.copyWith(
                    fontSize: 15,
                    color: problem != null ? C.red : C.textSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: S.sm),
          if (duty.busy)
            const SizedBox(
              width: 32,
              height: 32,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else
            Switch(
              value: duty.onDuty,
              activeThumbColor: C.green,
              onChanged: (v) =>
                  ref.read(dutyControllerProvider.notifier).set(v),
            ),
        ],
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SetuCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: S.md, horizontal: S.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: accent),
          const SizedBox(height: S.sm),
          Text(value, style: T.display.copyWith(fontSize: 34, color: accent)),
          const SizedBox(height: S.xs),
          Text(label, style: T.label.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

/// Origin is the visual signal that matters: doctor-assigned work is the
/// reason this app exists, so it gets the terracotta accent and stands out.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.mother});

  final Task task;
  final Mother? mother;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isKn = l.localeName.startsWith('kn');
    final now = DateTime.now();
    final overdue =
        task.dueDate.isBefore(DateTime(now.year, now.month, now.day));

    final (accent, originLabel) = switch (task.origin) {
      'doctor' => (C.terra, l.originDoctor),
      'system' => (C.amber, l.originSystem),
      _ => (C.textSoft, l.originSelf),
    };

    final riskColour = switch (mother?.riskLevel) {
      'red' => C.red,
      'amber' => C.amber,
      _ => C.green,
    };

    final instruction = (isKn ? task.instructionKn : task.instructionEn) ?? '';

    return SetuCard(
      padding: EdgeInsets.zero,
      onTap: mother == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => MotherProfileScreen(motherId: mother!.id),
                ),
              ),
      // IntrinsicHeight is what lets the stripe match the card's height. A
      // bare CrossAxisAlignment.stretch would give the Row an unbounded
      // height inside a ListView and break the whole list.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The origin stripe. Cheapest possible way to make doctor work
            // scannable from arm's length.
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(S.radius),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(S.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: riskColour,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: S.sm),
                        Expanded(
                          child: Text(
                            mother?.name ?? '—',
                            style: T.h2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: S.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            originLabel,
                            style:
                                T.label.copyWith(color: accent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: S.xs),
                    Text(
                      mother == null
                          ? ''
                          : '${mother!.village} · ${l.gestationWeeks(gestationWeeks(mother!.lmp))}',
                      style: T.label.copyWith(fontSize: 15),
                    ),
                    if (instruction.isNotEmpty) ...[
                      const SizedBox(height: S.sm),
                      Text(instruction, style: T.body.copyWith(fontSize: 17)),
                    ],
                    const SizedBox(height: S.sm),
                    Row(
                      children: [
                        Icon(
                          overdue
                              ? Icons.warning_amber_rounded
                              : Icons.schedule,
                          size: 20,
                          color: overdue ? C.amber : C.textSoft,
                        ),
                        const SizedBox(width: S.xs),
                        Text(
                          overdue
                              ? l.overdue
                              : l.dueOn(DateFormat('d MMM', l.localeName)
                                  .format(task.dueDate)),
                          style: T.label.copyWith(
                            color: overdue ? C.amber : C.textSoft,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
