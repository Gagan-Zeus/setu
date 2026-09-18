import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/asha_scaffold.dart';
import '../widgets/empty_state.dart';
import 'home_screen.dart' show TaskCard;
import 'new_visit_screen.dart';

/// The receiving end of the doctor assigning work back to the field.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: AshaScaffold(
        title: l.tasksTitle,
        bottom: TabBar(
          tabs: [
            Tab(height: S.tapMin, text: l.tabOpen),
            Tab(height: S.tapMin, text: l.tabDone),
            Tab(height: S.tapMin, text: l.tabMissed),
          ],
        ),
        body: const TabBarView(
          children: [
            _TaskList(status: 'open'),
            _TaskList(status: 'done'),
            _TaskList(status: 'missed'),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.status});

  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tasks = ref.watch(tasksProvider(status)).valueOrNull;
    final mothers = ref.watch(mothersProvider).valueOrNull ?? const <Mother>[];

    if (tasks == null) return const SkeletonList();
    if (tasks.isEmpty) {
      return EmptyState(icon: Icons.checklist_rtl, message: l.noTasksHere);
    }

    Mother? lookup(String id) {
      for (final m in mothers) {
        if (m.id == id) return m;
      }
      return null;
    }

    return ListView.separated(
      padding: const EdgeInsets.all(S.screen),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: S.md),
      itemBuilder: (context, i) {
        final task = tasks[i];
        final mother = lookup(task.motherId);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TaskCard(task: task, mother: mother),
            if (status == 'open' && mother != null) ...[
              const SizedBox(height: S.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(visitRepositoryProvider).closeTask(task.id),
                      icon: const Icon(Icons.check, size: 22),
                      label: Text(l.markDone),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        textStyle: T.button.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: S.sm),
                  Expanded(
                    child: FilledButton.icon(
                      // Completing through a visit links the two, so the
                      // record shows what actually closed the task.
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => NewVisitScreen(
                            mother: mother,
                            closesTaskId: task.id,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 22),
                      label: Text(l.newVisit),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        textStyle: T.button.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
