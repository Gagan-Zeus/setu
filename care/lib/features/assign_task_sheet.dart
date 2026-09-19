import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';

/// Tasks shown immediately after submit, before the API has answered. Merged
/// into the timeline so the doctor sees the result at once.
final optimisticTasksProvider =
    StateProvider<List<Task>>((ref) => const <Task>[]);

/// Assign Task to ASHA — the most important feature in the product.
///
/// A modal over the Mother Record, never a route: she must not lose her place.
/// The ASHA is resolved automatically from the mother's assignment and shown,
/// not chosen. There is deliberately no worker picker here — the system
/// already knows who covers this mother, and making the doctor choose would
/// reintroduce exactly the manual coordination this product exists to remove.
class AssignTaskSheet extends ConsumerStatefulWidget {
  const AssignTaskSheet({super.key, required this.mother});

  final Mother mother;

  static Future<void> show(BuildContext context, Mother mother) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(S.radius)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AssignTaskSheet(mother: mother),
      ),
    );
  }

  @override
  ConsumerState<AssignTaskSheet> createState() => _AssignTaskSheetState();
}

class _AssignTaskSheetState extends ConsumerState<AssignTaskSheet> {
  final _instruction = TextEditingController();
  TaskType _type = TaskType.revisit;
  TaskPriority _priority = TaskPriority.normal;
  late DateTime _due = DateTime.now().add(const Duration(days: 2));
  bool _busy = false;

  @override
  void dispose() {
    _instruction.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 120)),
    );
    if (picked != null) setState(() => _due = picked);
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);

    final m = widget.mother;
    final instruction = _instruction.text.trim().isEmpty
        ? taskTypeLabel(_type)
        : _instruction.text.trim();

    // Optimistic: the task lands in the timeline before the API answers.
    final pending = Task(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      motherId: m.id,
      createdBy: 'You',
      assignedToAshaId: m.ashaId,
      assignedToAshaName: m.ashaName,
      type: _type,
      instruction: instruction,
      dueDate: _due,
      priority: _priority,
      status: TaskStatus.open,
      createdAt: DateTime.now(),
    );
    ref.read(optimisticTasksProvider.notifier).update((l) => [pending, ...l]);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    navigator.pop();

    try {
      await ref.read(apiProvider).assignTask(
            motherId: m.id,
            type: _type,
            instruction: instruction,
            dueDate: _due,
            priority: _priority,
          );
      ref.invalidate(motherTasksProvider(m.id));
      ref.read(optimisticTasksProvider.notifier).update(
            (l) => l.where((t) => t.id != pending.id).toList(),
          );
      messenger.showSnackBar(
        SnackBar(
          content: Text('Task assigned to ${m.ashaName}'),
          action: SnackBarAction(
            label: 'OK',
            textColor: C.onDark,
            onPressed: messenger.hideCurrentSnackBar,
          ),
        ),
      );
    } catch (error) {
      // Roll the optimistic entry back rather than leave a task that never was.
      ref.read(optimisticTasksProvider.notifier).update(
            (l) => l.where((t) => t.id != pending.id).toList(),
          );
      // 42501 is Row Level Security refusing the insert, and for a doctor it
      // means one thing: she has no consent for this mother yet. It was being
      // reported as "Could not assign the task", which reads as a network
      // problem and sends her to look in the wrong place.
      final refused = error is PostgrestException &&
          (error.code == '42501' ||
              error.message.contains('row-level security'));
      messenger.showSnackBar(
        SnackBar(
          content: Text(refused
              ? 'She has not given you access yet. Ask her, or scan her '
                  'Thayi Card if she is with you.'
              : 'Could not assign the task'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mother;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(S.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Assign task', style: T.h2)),
                IconButton(
                  iconSize: 20,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text('${m.name} · ${m.gestationalWeeks}w · ${m.village}',
                style: T.small),
            const SizedBox(height: S.md),

            // Resolved, not chosen. No dropdown here on purpose.
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: C.tealSoft,
                borderRadius: BorderRadius.circular(S.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hiking_outlined, size: 18, color: C.teal),
                  const SizedBox(width: S.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Goes to ${m.ashaName}',
                            style: T.body.copyWith(
                                color: C.teal, fontWeight: FontWeight.w600)),
                        Text('${m.subCentre} · covers ${m.village}',
                            style: T.small.copyWith(color: C.teal)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: S.md),

            const SectionLabel('Task type'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in TaskType.values)
                  _Choice(
                    label: taskTypeLabel(t),
                    selected: _type == t,
                    onTap: () => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: S.md),

            const SectionLabel('Instruction'),
            TextField(
              controller: _instruction,
              minLines: 2,
              maxLines: 4,
              style: T.body,
              decoration: InputDecoration(
                hintText: 'What should ${m.ashaName} do?',
              ),
            ),
            const SizedBox(height: S.md),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Due'),
                      OutlinedButton.icon(
                        onPressed: _pickDue,
                        icon: const Icon(Icons.event_outlined, size: 16),
                        label: Text(DateFormat('d MMM').format(_due)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: S.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Priority'),
                      Row(
                        children: [
                          Expanded(
                            child: _Choice(
                              label: 'Normal',
                              selected: _priority == TaskPriority.normal,
                              onTap: () => setState(
                                  () => _priority = TaskPriority.normal),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _Choice(
                              label: 'High',
                              selected: _priority == TaskPriority.high,
                              onTap: () =>
                                  setState(() => _priority = TaskPriority.high),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: S.lg),

            // Terracotta: the single most important action on this screen.
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: C.terra),
              child: Text(_busy ? 'Assigning…' : 'Assign to ${m.ashaName}'),
            ),
            const SizedBox(height: S.sm),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(S.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? C.tealSoft : C.card,
          borderRadius: BorderRadius.circular(S.sm),
          border: Border.all(color: selected ? C.teal : C.divider),
        ),
        child: Text(
          label,
          style: T.small.copyWith(
            color: selected ? C.teal : C.text,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
