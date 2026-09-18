import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../data/supabase_care_api.dart';
import '../features/assign_task_sheet.dart';
import '../features/prescription_capture.dart';
import '../features/scan_thayi_card.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';
import '../widgets/charts.dart';

/// The brief's three columns become: identity panel, tabs, and an actions bar
/// pinned to the bottom. Assign Task is the primary action, in terracotta.
class MotherRecordScreen extends ConsumerWidget {
  const MotherRecordScreen({super.key, required this.motherId});

  final String motherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(motherProvider(motherId));
    final mother = async.valueOrNull;

    if (mother == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record')),
        body: const SkeletonList(count: 4),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: C.bg,
        appBar: AppBar(
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mother.name, style: T.h2),
              Text('${mother.village} · ${mother.ashaName}', style: T.small),
            ],
          ),
          actions: [
            RiskBadge(level: mother.riskLevel),
            const SizedBox(width: S.md)
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Timeline'),
              Tab(text: 'Vitals'),
              Tab(text: 'Labs'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: Column(
          children: [
            _IdentityPanel(mother: mother),
            Expanded(
              child: _Gated(
                motherId: motherId,
                child: TabBarView(
                  children: [
                    _TimelineTab(mother: mother),
                    _VitalsTab(motherId: motherId),
                    _LabsTab(motherId: motherId),
                    _NotesTab(motherId: motherId),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _ActionsBar(mother: mother),
      ),
    );
  }
}

class _IdentityPanel extends StatelessWidget {
  const _IdentityPanel({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    final m = mother;
    return Container(
      color: C.bg,
      padding: const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, S.sm),
      child: CareCard(
        padding: const EdgeInsets.all(S.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'GA ${m.gestationalWeeks}w ${m.gestationalDays}d',
                    style: T.h1,
                  ),
                ),
                Text('EDD ${DateFormat('d MMM yyyy').format(m.edd)}',
                    style: T.small),
              ],
            ),
            const Divider(height: S.md),
            KeyValue(label: 'Age', value: '${m.age}'),
            KeyValue(label: 'Husband', value: m.husbandName),
            KeyValue(label: 'Phone', value: m.phone),
            KeyValue(label: 'Sub-centre', value: m.subCentre),
            KeyValue(label: 'Blood group', value: m.bloodGroup),
            KeyValue(
                label: 'Gravida / Para', value: '${m.gravida} / ${m.para}'),
            KeyValue(label: 'BPL', value: m.isBpl ? 'Yes' : 'No'),
            if (m.riskReasons.isNotEmpty) ...[
              const SizedBox(height: S.sm),
              const SectionLabel('Risk flags'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final r in m.riskReasons)
                    ReasonChip(text: r, level: m.riskLevel),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The heart of the product: visits, tasks, notes and labs in one feed, each
/// showing who recorded it.
class _TimelineTab extends ConsumerWidget {
  const _TimelineTab({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visits = ref.watch(visitsProvider(mother.id)).valueOrNull;
    final tasks = ref.watch(motherTasksProvider(mother.id)).valueOrNull;
    final notes = ref.watch(notesProvider(mother.id)).valueOrNull;
    final rx = ref.watch(prescriptionsProvider(mother.id)).valueOrNull;
    final optimistic = ref
        .watch(optimisticTasksProvider)
        .where((t) => t.motherId == mother.id)
        .toList();

    if (visits == null) return const SkeletonList(count: 4);

    final entries = <_Entry>[
      for (final v in visits) _Entry(v.visitDate, visit: v),
      for (final t in [...optimistic, ...?tasks]) _Entry(t.createdAt, task: t),
      for (final n in notes ?? const <ClinicalNote>[])
        _Entry(n.createdAt, note: n),
      for (final p in rx ?? const <Prescription>[])
        _Entry(p.takenAt, prescription: p),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (entries.isEmpty) {
      return const EmptyState(message: 'Nothing recorded yet');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, S.xl),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) => _TimelineTile(entry: entries[i]),
    );
  }
}

class _Entry {
  _Entry(this.date, {this.visit, this.task, this.note, this.prescription});
  final DateTime date;
  final AncVisit? visit;
  final Task? task;
  final ClinicalNote? note;
  final Prescription? prescription;
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy').format(entry.date);

    if (entry.task != null) {
      final t = entry.task!;
      return CareCard(
        padding: const EdgeInsets.all(S.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 15, color: C.terra),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Task · ${taskTypeLabel(t.type)}',
                    style: T.small
                        .copyWith(color: C.terra, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(date, style: T.small),
              ],
            ),
            const SizedBox(height: 6),
            Text(t.instruction, style: T.body),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Assigned to ${t.assignedToAshaName}', style: T.small),
                const Spacer(),
                Text('Due ${DateFormat('d MMM').format(t.dueDate)}',
                    style: T.small),
              ],
            ),
          ],
        ),
      );
    }

    if (entry.prescription != null) {
      return _PrescriptionTile(rx: entry.prescription!, date: date);
    }

    if (entry.note != null) {
      final n = entry.note!;
      return CareCard(
        padding: const EdgeInsets.all(S.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sticky_note_2_outlined,
                    size: 15, color: C.textSoft),
                const SizedBox(width: 6),
                Expanded(child: Text('Clinical note', style: T.label)),
                Text(date, style: T.small),
              ],
            ),
            const SizedBox(height: 6),
            Text(n.body, style: T.body),
            const SizedBox(height: 6),
            RoleTag(name: n.authorName, source: VisitSource.doctor),
          ],
        ),
      );
    }

    final v = entry.visit!;
    final flagged = v.dangerSigns.isNotEmpty;
    return CareCard(
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_outlined, size: 15, color: C.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text('ANC visit ${v.visitNo}',
                    style: T.small
                        .copyWith(color: C.teal, fontWeight: FontWeight.w600)),
              ),
              Text(date, style: T.small),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: S.lg,
            runSpacing: 6,
            children: [
              if (v.bpSys != null)
                _Metric('BP', '${v.bpSys}/${v.bpDia}',
                    warn: (v.bpSys ?? 0) >= 140 || (v.bpDia ?? 0) >= 90),
              if (v.weightKg != null)
                _Metric('Weight', '${v.weightKg!.toStringAsFixed(1)} kg'),
              if (v.hb != null)
                _Metric('Hb', v.hb!.toStringAsFixed(1),
                    warn: (v.hb ?? 99) < 10),
              if (v.fetalHr != null) _Metric('FHR', '${v.fetalHr}'),
            ],
          ),
          if (flagged) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final s in v.dangerSigns)
                  ReasonChip(text: _sign(s), level: RiskLevel.red),
              ],
            ),
          ],
          if (v.notes != null) ...[
            const SizedBox(height: 6),
            Text(v.notes!, style: T.small),
          ],
          const SizedBox(height: 8),
          RoleTag(name: v.recordedBy, source: v.source),
        ],
      ),
    );
  }

  static String _sign(String id) => switch (id) {
        'headache' => 'Severe headache',
        'swelling' => 'Facial oedema',
        'reducedFetalMovement' => 'Reduced fetal movement',
        'bleeding' => 'Bleeding',
        _ => id,
      };
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, {this.warn = false});

  final String label;
  final String value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: T.label),
        Text(value, style: T.mono.copyWith(color: warn ? C.red : C.ink)),
      ],
    );
  }
}

class _VitalsTab extends ConsumerWidget {
  const _VitalsTab({required this.motherId});

  final String motherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visits = ref.watch(visitsProvider(motherId)).valueOrNull;
    if (visits == null) return const SkeletonList(count: 3);
    if (visits.isEmpty) {
      return const EmptyState(message: 'No readings yet');
    }

    // Oldest first for a left-to-right trend.
    final ordered = [...visits].reversed.toList();
    final labels = [
      for (final v in ordered) DateFormat('d MMM').format(v.visitDate)
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, S.xl),
      children: [
        const SectionLabel('Blood pressure'),
        CareCard(
          child: TrendChart(
            xLabels: labels,
            // The 140/90 threshold, so a reading is read against it.
            refLines: const [RefLine(value: 140, label: '140')],
            series: [
              Series(
                values: [
                  for (final v in ordered)
                    if (v.bpSys != null) v.bpSys!.toDouble()
                ],
                color: C.terra,
                label: 'Systolic',
              ),
              Series(
                values: [
                  for (final v in ordered)
                    if (v.bpDia != null) v.bpDia!.toDouble()
                ],
                color: C.teal,
                label: 'Diastolic',
              ),
            ],
          ),
        ),
        const SizedBox(height: S.lg),
        const SectionLabel('Weight'),
        CareCard(
          child: TrendChart(
            xLabels: labels,
            series: [
              Series(
                values: [
                  for (final v in ordered)
                    if (v.weightKg != null) v.weightKg!
                ],
                color: C.teal,
                label: 'kg',
              ),
            ],
          ),
        ),
        const SizedBox(height: S.lg),
        const SectionLabel('Haemoglobin'),
        CareCard(
          child: TrendChart(
            xLabels: labels,
            refLines: const [RefLine(value: 10, label: '10')],
            series: [
              Series(
                values: [
                  for (final v in ordered)
                    if (v.hb != null) v.hb!
                ],
                color: C.green,
                label: 'g/dL',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabsTab extends ConsumerWidget {
  const _LabsTab({required this.motherId});

  final String motherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labs = ref.watch(labsProvider(motherId)).valueOrNull;
    if (labs == null) return const SkeletonList(count: 3);
    if (labs.isEmpty) return const EmptyState(message: 'No results');

    return ListView(
      padding: const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, S.xl),
      children: [
        CareCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < labs.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: S.md, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(labs[i].type, style: T.body),
                            Text(
                              '${DateFormat('d MMM yyyy').format(labs[i].resultDate)} · ${labs[i].orderedBy}',
                              style: T.small,
                            ),
                          ],
                        ),
                      ),
                      Text('${labs[i].value} ${labs[i].unit}'.trim(),
                          style: T.mono),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesTab extends ConsumerStatefulWidget {
  const _NotesTab({required this.motherId});

  final String motherId;

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _busy) return;
    setState(() => _busy = true);
    await ref.read(apiProvider).addNote(motherId: widget.motherId, body: body);
    ref.invalidate(notesProvider(widget.motherId));
    _controller.clear();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider(widget.motherId)).valueOrNull;

    return Column(
      children: [
        Expanded(
          child: notes == null
              ? const SkeletonList(count: 2)
              : notes.isEmpty
                  ? const EmptyState(message: 'No clinical notes yet')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          S.screen, S.sm, S.screen, S.sm),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => CareCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notes[i].body, style: T.body),
                            const SizedBox(height: 6),
                            Text(
                              '${notes[i].authorName} · ${DateFormat('d MMM yyyy').format(notes[i].createdAt)}',
                              style: T.small,
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
        Container(
          padding: const EdgeInsets.all(S.md),
          decoration: const BoxDecoration(
            color: C.card,
            border: Border(top: BorderSide(color: C.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: T.body,
                  decoration: const InputDecoration(hintText: 'Add a note'),
                ),
              ),
              const SizedBox(width: S.sm),
              IconButton.filled(
                onPressed: _busy ? null : _add,
                style: IconButton.styleFrom(backgroundColor: C.teal),
                icon: const Icon(Icons.send, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The brief's actions rail. Assign Task is primary, in terracotta; the rest
/// are quiet. No clinical colour appears on a button.
class _ActionsBar extends StatelessWidget {
  const _ActionsBar({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(S.md, S.sm, S.md, S.sm),
      decoration: const BoxDecoration(
        color: C.card,
        border: Border(top: BorderSide(color: C.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => AssignTaskSheet.show(context, mother),
                style: FilledButton.styleFrom(
                  backgroundColor: C.terra,
                  minimumSize: const Size.fromHeight(44),
                ),
                icon: const Icon(Icons.assignment_add, size: 18),
                label: const Text('Assign Task'),
              ),
            ),
            const SizedBox(width: S.sm),
            _RxButton(motherId: mother.id),
            _Quiet(
              icon: Icons.science_outlined,
              tooltip: 'Order lab',
              onTap: () => _todo(context, 'Order Lab'),
            ),
            _Quiet(
              icon: Icons.swap_horiz,
              tooltip: 'Create referral',
              onTap: () => _todo(context, 'Create Referral'),
            ),
            _Quiet(
              icon: Icons.flag_outlined,
              tooltip: 'Update risk status',
              onTap: () => _todo(context, 'Update Risk Status'),
            ),
          ],
        ),
      ),
    );
  }

  void _todo(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what is not built yet')),
    );
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      iconSize: 20,
      style: IconButton.styleFrom(
        foregroundColor: C.textSoft,
        side: const BorderSide(color: C.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.sm),
        ),
        minimumSize: const Size(44, 44),
      ),
      icon: Icon(icon),
    );
  }
}

/// Nothing clinical renders until she has agreed, or shown her card.
class _Gated extends ConsumerStatefulWidget {
  const _Gated({required this.motherId, required this.child});

  final String motherId;
  final Widget child;

  @override
  ConsumerState<_Gated> createState() => _GatedState();
}

class _GatedState extends ConsumerState<_Gated> {
  bool _busy = false;

  Future<void> _request() async {
    final api = ref.read(apiProvider);
    if (api is! SupabaseCareApi) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await api.requestAccess(widget.motherId,
          reason: 'Review of antenatal record');
      ref.invalidate(accessStateProvider(widget.motherId));
      messenger.showSnackBar(
        const SnackBar(content: Text('Asked. She decides in her app.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not send the request')),
      );
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _scan() async {
    final scanned = await ScanThayiCard.show(context);
    if (scanned == null || !mounted) return;
    ref.invalidate(accessStateProvider(widget.motherId));
    // A different woman's card opens her record, not the one on screen.
    if (scanned != widget.motherId) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MotherRecordScreen(motherId: scanned),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accessStateProvider(widget.motherId));
    return state.when(
      loading: () => const SkeletonList(count: 3),
      error: (_, __) => const EmptyState(message: 'Could not check access'),
      data: (value) => value == 'approved'
          ? widget.child
          : AccessLocked(
              state: value,
              busy: _busy,
              onRequest: _request,
              onScan: _scan,
            ),
    );
  }
}

/// Photograph the prescription written at this visit.
class _RxButton extends ConsumerWidget {
  const _RxButton({required this.motherId});

  final String motherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Add prescription photo',
      onPressed: () => PrescriptionCapture.show(
        context,
        ref,
        motherId: motherId,
        doctorName: MockData.doctorName,
      ),
      iconSize: 20,
      style: IconButton.styleFrom(
        foregroundColor: C.textSoft,
        side: const BorderSide(color: C.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.sm),
        ),
        minimumSize: const Size(44, 44),
      ),
      icon: const Icon(Icons.receipt_long_outlined),
    );
  }
}

/// The photo itself, fetched through a short-lived signed URL because the
/// bucket is private.
class _PrescriptionTile extends ConsumerWidget {
  const _PrescriptionTile({required this.rx, required this.date});

  final Prescription rx;
  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(prescriptionUrlProvider(rx.storagePath)).valueOrNull;

    return CareCard(
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 15, color: C.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Prescription',
                    style: T.small
                        .copyWith(color: C.teal, fontWeight: FontWeight.w600)),
              ),
              Text(date, style: T.small),
            ],
          ),
          if (rx.note != null && rx.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(rx.note!, style: T.body),
          ],
          const SizedBox(height: S.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(S.sm),
            child: url == null
                ? Container(
                    height: 120,
                    color: C.bg,
                    alignment: Alignment.center,
                    child: const Text('Loading image…', style: T.small),
                  )
                : GestureDetector(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: C.ink,
                        insetPadding: const EdgeInsets.all(S.md),
                        child: InteractiveViewer(
                          maxScale: 5,
                          child: Image.network(url, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    child: Image.network(
                      url,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: C.bg,
                        alignment: Alignment.center,
                        child: const Text('Image unavailable', style: T.small),
                      ),
                    ),
                  ),
          ),
          if (rx.prescribedBy != null) ...[
            const SizedBox(height: 6),
            RoleTag(name: rx.prescribedBy!, source: VisitSource.doctor),
          ],
        ],
      ),
    );
  }
}
