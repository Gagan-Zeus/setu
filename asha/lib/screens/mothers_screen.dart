import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/asha_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/risk_chip.dart';
import '../widgets/setu_card.dart';
import 'mother_profile_screen.dart';

class MothersScreen extends ConsumerStatefulWidget {
  const MothersScreen({super.key});

  @override
  ConsumerState<MothersScreen> createState() => _MothersScreenState();
}

class _MothersScreenState extends ConsumerState<MothersScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(mothersProvider).valueOrNull;
    final initialTab =
        ModalRoute.of(context)?.settings.arguments == 'highRisk' ? 1 : 0;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: AshaScaffold(
        title: l.mothersTitle,
        bottom: TabBar(
          tabs: [
            Tab(height: S.tapMin, text: l.tabAll),
            Tab(height: S.tapMin, text: l.tabHighRisk),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(S.screen, S.md, S.screen, S.sm),
              child: TextField(
                controller: _search,
                style: T.body,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: l.searchMothers,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: S.md, right: S.sm),
                    child: Icon(Icons.search, size: 26, color: C.textSoft),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                ),
              ),
            ),
            Expanded(
              child: all == null
                  ? const SkeletonList()
                  : TabBarView(
                      children: [
                        _List(mothers: _filter(all, _query)),
                        _List(
                          mothers: _filter(
                            all.where((m) => m.riskLevel != 'green').toList(),
                            _query,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Mother> _filter(List<Mother> mothers, String query) {
    if (query.isEmpty) return mothers;
    final q = query.toLowerCase();
    return mothers
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.village.toLowerCase().contains(q))
        .toList();
  }
}

class _List extends StatelessWidget {
  const _List({required this.mothers});

  final List<Mother> mothers;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (mothers.isEmpty) {
      return EmptyState(icon: Icons.groups_outlined, message: l.noMothers);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(S.screen),
      itemCount: mothers.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: S.md),
      itemBuilder: (context, i) =>
          i == mothers.length ? kFabClearance : MotherCard(mother: mothers[i]),
    );
  }
}

class MotherCard extends StatelessWidget {
  const MotherCard({super.key, required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final weeks = gestationWeeks(mother.lmp);
    final (level, label) = switch (mother.riskLevel) {
      'red' => (RiskLevel.danger, l.riskRed),
      'amber' => (RiskLevel.caution, l.riskAmber),
      _ => (RiskLevel.normal, l.riskGreen),
    };

    return SetuCard(
      padding: const EdgeInsets.all(S.md),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MotherProfileScreen(motherId: mother.id),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: C.tealSoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              // A record can reach the phone with no name at all now that
              // rows come down from the server; Characters.first throws on an
              // empty string and takes the card down with it.
              mother.name.characters.isEmpty
                  ? '?'
                  : mother.name.characters.first,
              style: T.h2.copyWith(color: C.teal),
            ),
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mother.name, style: T.h2, maxLines: 1),
                const SizedBox(height: S.xs),
                Text(
                  '${mother.village} · ${l.gestationWeeks(weeks)}',
                  style: T.label.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(width: S.sm),
          RiskChip(label: label, level: level),
        ],
      ),
    );
  }
}
