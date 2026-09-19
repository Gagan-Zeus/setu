import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';
import 'mother_record_screen.dart';

/// Searchable, filterable, sortable. Dense rows — this is a table, not cards.
class MothersScreen extends ConsumerStatefulWidget {
  const MothersScreen({super.key});

  @override
  ConsumerState<MothersScreen> createState() => _MothersScreenState();
}

class _MothersScreenState extends ConsumerState<MothersScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(mothersProvider).isLoading;
    final rows = ref.watch(filteredMothersProvider);
    final filters = ref.watch(motherFiltersProvider);
    final all = ref.watch(mothersProvider).valueOrNull ?? const <Mother>[];
    final ashas = ref.watch(ashasProvider).valueOrNull ?? const <AshaWorker>[];
    final villages = {for (final m in all) m.village}.toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(S.screen, S.md, S.screen, S.sm),
          child: TextField(
            controller: _search,
            style: T.body,
            onChanged: (v) => ref
                .read(motherFiltersProvider.notifier)
                .update((f) => f.copyWith(query: v)),
            decoration: const InputDecoration(
              hintText: 'Search name, village or ASHA',
              prefixIcon: Icon(Icons.search, size: 18, color: C.textSoft),
              prefixIconConstraints:
                  BoxConstraints(minWidth: 38, minHeight: 38),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: S.screen),
            children: [
              _Filter(
                label: 'Risk',
                value: switch (filters.risk) {
                  RiskLevel.red => 'High risk',
                  RiskLevel.amber => 'Watch',
                  RiskLevel.green => 'Normal',
                  null => null,
                },
                onClear: () => ref
                    .read(motherFiltersProvider.notifier)
                    .update((f) => f.copyWith(clearRisk: true)),
                onTap: () => _pick<RiskLevel>(
                  context,
                  title: 'Risk level',
                  options: const {
                    RiskLevel.red: 'High risk',
                    RiskLevel.amber: 'Watch',
                    RiskLevel.green: 'Normal',
                  },
                  onSelected: (v) => ref
                      .read(motherFiltersProvider.notifier)
                      .update((f) => f.copyWith(risk: v)),
                ),
              ),
              _Filter(
                label: 'Village',
                value: filters.village,
                onClear: () => ref
                    .read(motherFiltersProvider.notifier)
                    .update((f) => f.copyWith(clearVillage: true)),
                onTap: () => _pick<String>(
                  context,
                  title: 'Village',
                  options: {for (final v in villages) v: v},
                  onSelected: (v) => ref
                      .read(motherFiltersProvider.notifier)
                      .update((f) => f.copyWith(village: v)),
                ),
              ),
              _Filter(
                label: 'ASHA',
                value: ashas
                    .where((a) => a.id == filters.ashaId)
                    .map((a) => a.name)
                    .firstOrNull,
                onClear: () => ref
                    .read(motherFiltersProvider.notifier)
                    .update((f) => f.copyWith(clearAsha: true)),
                onTap: () => _pick<String>(
                  context,
                  title: 'ASHA worker',
                  options: {for (final a in ashas) a.id: a.name},
                  onSelected: (v) => ref
                      .read(motherFiltersProvider.notifier)
                      .update((f) => f.copyWith(ashaId: v)),
                ),
              ),
              _Toggle(
                label: 'Overdue only',
                on: filters.overdueOnly,
                onTap: () => ref
                    .read(motherFiltersProvider.notifier)
                    .update((f) => f.copyWith(overdueOnly: !f.overdueOnly)),
              ),
              _Filter(
                label: 'Sort',
                value: switch (filters.sort) {
                  MotherSort.risk => 'Risk',
                  MotherSort.name => 'Name',
                  MotherSort.gestation => 'Gestation',
                  MotherSort.lastVisit => 'Last visit',
                },
                onTap: () => _pick<MotherSort>(
                  context,
                  title: 'Sort by',
                  options: const {
                    MotherSort.risk: 'Risk',
                    MotherSort.name: 'Name',
                    MotherSort.gestation: 'Gestation',
                    MotherSort.lastVisit: 'Last visit',
                  },
                  onSelected: (v) => ref
                      .read(motherFiltersProvider.notifier)
                      .update((f) => f.copyWith(sort: v)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, S.xs),
          child: Row(
            children: [
              Text('${rows.length} of ${all.length}'.toUpperCase(),
                  style: T.label),
              const Spacer(),
              if (filters.isActive)
                InkWell(
                  onTap: () => ref.read(motherFiltersProvider.notifier).state =
                      const MotherFilters(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: S.sm, vertical: S.xs),
                    child:
                        Text('CLEAR', style: T.label.copyWith(color: C.teal)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const SkeletonList(count: 6)
              : rows.isEmpty
                  ? const EmptyState(message: 'No mothers match these filters')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          S.screen, 0, S.screen, S.xl),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => _Row(mother: rows[i]),
                    ),
        ),
      ],
    );
  }

  Future<void> _pick<TValue>(
    BuildContext context, {
    required String title,
    required Map<TValue, String> options,
    required void Function(TValue) onSelected,
  }) async {
    final chosen = await showModalBottomSheet<TValue>(
      context: context,
      backgroundColor: C.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(S.radius)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(S.md, S.md, S.md, S.sm),
              child: SectionLabel(title),
            ),
            for (final e in options.entries)
              InkWell(
                onTap: () => Navigator.of(sheetContext).pop(e.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: S.md, vertical: 14),
                  child: Text(e.value, style: T.body),
                ),
              ),
            const SizedBox(height: S.sm),
          ],
        ),
      ),
    );
    if (chosen != null) onSelected(chosen);
  }
}

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return Padding(
      padding: const EdgeInsets.only(right: S.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(S.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Active filters use teal, never a clinical colour.
            color: active ? C.tealSoft : C.card,
            borderRadius: BorderRadius.circular(S.sm),
            border: Border.all(color: active ? C.teal : C.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                active ? '$label: $value' : label,
                style: T.small.copyWith(color: active ? C.teal : C.textSoft),
              ),
              const SizedBox(width: S.xs),
              if (active && onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close, size: 14, color: C.teal),
                )
              else
                const Icon(Icons.expand_more, size: 14, color: C.textSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: S.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(S.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? C.tealSoft : C.card,
            borderRadius: BorderRadius.circular(S.sm),
            border: Border.all(color: on ? C.teal : C.divider),
          ),
          child: Text(label,
              style: T.small.copyWith(color: on ? C.teal : C.textSoft)),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    return CareCard(
      padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: 10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MotherRecordScreen(motherId: mother.id),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        mother.name,
                        style: T.body.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${mother.age}', style: T.small),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${mother.gestationalWeeks}w · ${mother.village} · ${mother.ashaName}',
                  style: T.small,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: S.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RiskBadge(level: mother.riskLevel, compact: true),
              const SizedBox(height: 3),
              Text(
                mother.lastVisitDate == null
                    ? 'No visit'
                    : DateFormat('d MMM').format(mother.lastVisitDate!),
                style: T.small.copyWith(
                  color: mother.isOverdue ? C.amber : C.textSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
