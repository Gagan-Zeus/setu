import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/asha_scaffold.dart';
import '../widgets/big_action_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/setu_card.dart';

/// Built entirely from local rows, so it is readable even if sync has never
/// succeeded. Counts and categories only — never a guaranteed rupee amount.
class IncentiveScreen extends ConsumerWidget {
  const IncentiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final mothers = ref.watch(mothersProvider).valueOrNull;

    if (mothers == null) {
      return AshaScaffold(title: l.incentiveTitle, body: const SkeletonList());
    }

    return AshaScaffold(
      title: l.incentiveTitle,
      body: FutureBuilder<_Claim>(
        future: _build(ref, mothers),
        builder: (context, snapshot) {
          final claim = snapshot.data;
          if (claim == null) return const SkeletonList();

          final rows = <(String, int)>[
            (l.catRegistration, claim.registrations),
            (l.catAncVisit, claim.ancVisits),
            (l.catReferral, claim.referrals),
            (l.catHighRiskFollowUp, claim.highRiskFollowUps),
          ];

          return ListView(
            padding: const EdgeInsets.all(S.screen),
            children: [
              SetuCard(
                padding: const EdgeInsets.all(S.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${claim.total}',
                      style: T.display.copyWith(color: C.teal),
                    ),
                    const SizedBox(height: S.xs),
                    Text(l.claimableItems(claim.total), style: T.body),
                    const SizedBox(height: S.md),
                    Row(
                      children: [
                        const Icon(Icons.offline_pin_outlined,
                            size: 20, color: C.green),
                        const SizedBox(width: S.xs),
                        Expanded(
                          child: Text(
                            l.incentiveOffline,
                            style: T.label.copyWith(
                              color: C.green,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: S.lg),
              SetuCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: S.md, vertical: S.sm),
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: S.md),
                        child: Row(
                          children: [
                            Expanded(child: Text(rows[i].$1, style: T.body)),
                            Text('${rows[i].$2}', style: T.h2),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: S.md),
              Container(
                padding: const EdgeInsets.all(S.md),
                decoration: BoxDecoration(
                  color: C.amberSoft,
                  borderRadius: BorderRadius.circular(S.radius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 24, color: C.amber),
                    const SizedBox(width: S.sm),
                    Expanded(
                      child: Text(
                        l.incentiveNote,
                        style: T.bodySoft.copyWith(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: S.lg),
              BigActionButton(
                label: l.shareSummary,
                icon: Icons.share_outlined,
                outlined: true,
                onPressed: () => _copy(context, l, claim, rows),
              ),
              const SizedBox(height: S.xl),
            ],
          );
        },
      ),
    );
  }

  Future<_Claim> _build(WidgetRef ref, List<Mother> mothers) async {
    final db = ref.read(dbProvider);
    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    var visits = 0;
    var followUps = 0;
    for (final m in mothers) {
      final list = await db.visitsFor(m.id);
      final recent = list.where((v) => v.visitDate.isAfter(cutoff)).length;
      visits += recent;
      if (m.riskLevel != 'green') followUps += recent;
    }

    final registrations =
        mothers.where((m) => m.createdAt.isAfter(cutoff)).length;
    final referrals = await db.select(db.referrals).get();
    final recentReferrals =
        referrals.where((r) => r.createdAt.isAfter(cutoff)).length;

    return _Claim(
      registrations: registrations,
      ancVisits: visits,
      referrals: recentReferrals,
      highRiskFollowUps: followUps,
    );
  }

  Future<void> _copy(
    BuildContext context,
    AppLocalizations l,
    _Claim claim,
    List<(String, int)> rows,
  ) async {
    final buffer = StringBuffer()
      ..writeln(l.incentiveTitle)
      ..writeln(DateFormat('MMMM yyyy', l.localeName).format(DateTime.now()))
      ..writeln();
    for (final r in rows) {
      buffer.writeln('${r.$1}: ${r.$2}');
    }
    buffer
      ..writeln()
      ..writeln(l.claimableItems(claim.total))
      ..writeln(l.incentiveNote);

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.shareSummary, style: T.body)),
    );
  }
}

class _Claim {
  const _Claim({
    required this.registrations,
    required this.ancVisits,
    required this.referrals,
    required this.highRiskFollowUps,
  });

  final int registrations;
  final int ancVisits;
  final int referrals;
  final int highRiskFollowUps;

  int get total => registrations + ancVisits + referrals + highRiskFollowUps;
}
