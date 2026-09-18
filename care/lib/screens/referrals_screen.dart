import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';

/// Beyond the demo arc (step 9), so this is the list and status only — no
/// close-with-outcome flow yet.
class ReferralsScreen extends ConsumerWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referrals = ref.watch(referralsProvider).valueOrNull;
    final api = ref.watch(apiProvider);
    if (referrals == null) return const SkeletonList(count: 4);
    if (referrals.isEmpty) {
      return const EmptyState(message: 'No referrals');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(S.screen),
      itemCount: referrals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final r = referrals[i];
        final mother = api.motherOf(r.motherId);
        final (fg, bg, label) = switch (r.status) {
          ReferralStatus.open => (C.amber, C.amberSoft, 'Open'),
          ReferralStatus.arrived => (C.teal, C.tealSoft, 'Arrived'),
          ReferralStatus.closed => (C.green, C.greenSoft, 'Closed'),
        };
        return CareCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(mother?.name ?? '—',
                        style: T.body.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(label,
                        style: T.label.copyWith(color: fg, letterSpacing: 0.4)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(r.reason, style: T.small),
              const SizedBox(height: 6),
              Text('${r.fromUser} → ${r.toFacility}', style: T.small),
              const SizedBox(height: 2),
              Text(DateFormat('d MMM yyyy').format(r.createdAt),
                  style: T.small),
            ],
          ),
        );
      },
    );
  }
}
