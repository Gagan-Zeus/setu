import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/big_action_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/risk_chip.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';
import '../widgets/stat_card.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final motherAsync = ref.watch(motherProvider);
    final checkupsAsync = ref.watch(checkupsProvider);
    final now = DateTime.now();

    return SetuScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(S.screen, S.md, S.screen, 0),
        children: [
          _Header(
            name: motherAsync.maybeWhen(
              data: (m) => l.motherName(m),
              orElse: () => null,
            ),
          ),
          const SizedBox(height: S.lg),
          motherAsync.when(
            loading: () => const Column(
              children: [
                SkeletonCard(height: 168),
                SizedBox(height: S.md),
                SkeletonCard(height: 110),
              ],
            ),
            error: (_, __) => EmptyState(
              icon: Icons.cloud_off_outlined,
              message: l.errorTitle,
              action: BigActionButton(
                label: l.retry,
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(motherProvider),
              ),
            ),
            data: (m) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WeeksCard(mother: m, now: now),
                const SizedBox(height: S.md),
                StatCard(
                  icon: Icons.event_available_outlined,
                  label: l.eddLabel,
                  value: l.formatDate(m.edd),
                  valueStyle: T.h1,
                  caption: l.daysRemaining(m.daysToEddOn(now)),
                ),
              ],
            ),
          ),
          const SizedBox(height: S.md),
          checkupsAsync.when(
            loading: () => const SkeletonCard(height: 120),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) {
              final next = nextCheckup(list, now);
              if (next == null) {
                return SetuCard(
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined,
                          color: C.textSoft, size: 26),
                      const SizedBox(width: S.sm),
                      Expanded(
                        child: Text(l.emptyUpcoming, style: T.bodySoft),
                      ),
                    ],
                  ),
                );
              }
              return _NextCheckupCard(checkup: next, now: now);
            },
          ),
          const SizedBox(height: S.md),
          _AskSetuCard(),
          const SizedBox(height: S.lg),
          SectionHeader(l.exploreLabel),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: S.md,
            crossAxisSpacing: S.md,
            childAspectRatio: 1.28,
            children: [
              TileButton(
                label: l.navThayiCard,
                icon: Icons.qr_code_2,
                onTap: () => Navigator.pushNamed(context, Routes.thayiCard),
              ),
              TileButton(
                label: l.navCheckups,
                icon: Icons.event_note_outlined,
                onTap: () => Navigator.pushNamed(context, Routes.checkups),
              ),
              TileButton(
                label: l.navHealth,
                icon: Icons.favorite_outline,
                onTap: () => Navigator.pushNamed(context, Routes.health),
              ),
              TileButton(
                label: l.navSchemes,
                icon: Icons.volunteer_activism_outlined,
                onTap: () => Navigator.pushNamed(context, Routes.schemes),
              ),
            ],
          ),
          const SizedBox(height: S.lg),
          SectionHeader(l.moreLabel),
          _RowLink(
            label: l.navProfile,
            icon: Icons.badge_outlined,
            onTap: () => Navigator.pushNamed(context, Routes.profile),
          ),
          const SizedBox(height: S.sm),
          _RowLink(
            label: l.navDangerSigns,
            icon: Icons.warning_amber_rounded,
            accent: C.red,
            onTap: () => Navigator.pushNamed(context, Routes.dangerSigns),
          ),
          const SizedBox(height: S.sm),
          _RowLink(
            label: l.navAsha,
            icon: Icons.person_outline,
            onTap: () => Navigator.pushNamed(context, Routes.asha),
          ),
          const SizedBox(height: S.sm),
          _RowLink(
            label: l.navAfterDelivery,
            icon: Icons.child_friendly_outlined,
            onTap: () => Navigator.pushNamed(context, Routes.afterDelivery),
          ),
          kFabClearance,
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({this.name});

  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name == null ? l.appName : l.greeting(name!),
                style: T.h1,
              ),
              const SizedBox(height: S.xs),
              Text(l.homeToday, style: T.bodySoft),
            ],
          ),
        ),
        const ProfileAvatarButton(),
      ],
    );
  }
}

class _WeeksCard extends StatelessWidget {
  const _WeeksCard({required this.mother, required this.now});

  final Mother mother;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final weeks = mother.weeksPregnantOn(now);
    return SetuCard(
      padding: const EdgeInsets.all(S.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.weeksPregnantLabel, style: T.label),
          const SizedBox(height: S.sm),
          Text(l.weeksValue(weeks), style: T.display.copyWith(color: C.teal)),
          const SizedBox(height: S.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (weeks / 40).clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: C.tealSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(C.teal),
            ),
          ),
          const SizedBox(height: S.sm),
          Text(l.weeksProgress(weeks), style: T.bodySoft),
        ],
      ),
    );
  }
}

class _NextCheckupCard extends StatelessWidget {
  const _NextCheckupCard({required this.checkup, required this.now});

  final Checkup checkup;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final overdue = checkup.isOverdueOn(now);
    return SetuCard(
      onTap: () => Navigator.pushNamed(context, Routes.checkups),
      color: overdue ? C.amberSoft : C.card,
      borderColor: overdue ? C.amber : null,
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                overdue ? Icons.warning_amber_rounded : Icons.event_outlined,
                size: 24,
                color: overdue ? C.amber : C.teal,
              ),
              const SizedBox(width: S.sm),
              Expanded(child: Text(l.nextCheckupLabel, style: T.label)),
              if (overdue)
                RiskChip(
                  label: l.checkupOverdueBadge,
                  level: RiskLevel.caution,
                ),
            ],
          ),
          const SizedBox(height: S.sm),
          Text(
            l.formatDate(checkup.date),
            style: T.h1.copyWith(color: overdue ? C.amber : C.ink),
          ),
          const SizedBox(height: S.xs),
          Text(l.checkupLocation(checkup), style: T.bodySoft),
        ],
      ),
    );
  }
}

class _AskSetuCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SetuCard(
      color: C.terraSoft,
      padding: const EdgeInsets.all(S.lg),
      onTap: () => Navigator.pushNamed(context, Routes.askSetu),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: C.terra,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.forum_outlined, color: C.onDark, size: 30),
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.askSetuCardTitle, style: T.h2),
                const SizedBox(height: S.xs),
                Text(l.askSetuCardBody, style: T.bodySoft),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 30, color: C.terra),
        ],
      ),
    );
  }
}

class _RowLink extends StatelessWidget {
  const _RowLink({
    required this.label,
    required this.icon,
    required this.onTap,
    this.accent = C.teal,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SetuCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.md),
      child: Row(
        children: [
          Icon(icon, size: 28, color: accent),
          const SizedBox(width: S.md),
          Expanded(
            child: Text(
              label,
              style: T.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right, size: 28, color: C.textSoft),
        ],
      ),
    );
  }
}
