import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';

/// Beyond the demo arc (step 9): the roster only, no drill-down yet.
class AshaWorkersScreen extends ConsumerWidget {
  const AshaWorkersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ashas = ref.watch(ashasProvider).valueOrNull;
    if (ashas == null) return const SkeletonList(count: 4);

    return ListView.separated(
      padding: const EdgeInsets.all(S.screen),
      itemCount: ashas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final a = ashas[i];
        return CareCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.name, style: T.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${a.subCentre} · ${a.village}', style: T.small),
              const SizedBox(height: 2),
              Text(a.phone, style: T.small),
              const Divider(height: S.md),
              Row(
                children: [
                  _Stat(value: '${a.assignedMotherCount}', label: 'Mothers'),
                  _Stat(value: '${a.visitsThisMonth}', label: 'Visits (mo)'),
                  _Stat(value: '${a.openTasks}', label: 'Open tasks'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: T.mono.copyWith(fontSize: 18)),
          Text(label.toUpperCase(), style: T.label),
        ],
      ),
    );
  }
}
