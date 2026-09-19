import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../features/scan_thayi_card.dart';
import 'mother_record_screen.dart';
import '../theme/tokens.dart';
import 'analytics_screen.dart';
import 'asha_screen.dart';
import 'dashboard_screen.dart';
import 'mothers_screen.dart';
import 'profile_screen.dart';
import 'referrals_screen.dart';

/// The brief's persistent left sidebar becomes a bottom navigation bar on a
/// phone; the top bar keeps the facility name and the user menu. Logout is a
/// menu action, never a route.
class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});

  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  int _index = 0;

  static const _titles = [
    'Dashboard',
    'All Mothers',
    'Referrals',
    'ASHA Workers',
    'Analytics',
  ];

  /// She holds out her phone; her record opens. No name, no searching.
  Future<void> _scanAndOpen(BuildContext context) async {
    final motherId = await ScanThayiCard.show(context);
    if (motherId == null || !context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => MotherRecordScreen(motherId: motherId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        titleSpacing: S.screen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_titles[_index], style: T.h2),
            Text(
              ref.watch(facilityProvider).valueOrNull ?? '—',
              style: T.small,
            ),
          ],
        ),
        actions: [
          // Scanning answers "who is this", so it sits in the header of the
          // screen where that is asked rather than inside a record you can only
          // reach by already knowing the answer.
          //
          // It went next to the search box first and broke it: a TextField in a
          // Row needs its width negotiated, and squeezing a button in beside one
          // styled by the theme is a fight not worth having for a control that
          // belongs in the header anyway.
          if (_index == 1)
            IconButton(
              tooltip: 'Scan her code',
              icon: const Icon(Icons.qr_code_scanner, color: C.teal),
              onPressed: () => _scanAndOpen(context),
            ),
          _UserMenu(),
          const SizedBox(width: S.sm),
        ],
      ),
      body: Column(
        children: [
          if (ref.watch(isDemoDataProvider)) const _DemoDataBanner(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                DashboardScreen(),
                MothersScreen(),
                ReferralsScreen(),
                AshaWorkersScreen(),
                AnalyticsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 20),
            selectedIcon: Icon(Icons.dashboard, size: 20, color: C.teal),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined, size: 20),
            selectedIcon: Icon(Icons.groups, size: 20, color: C.teal),
            label: 'Mothers',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined, size: 20),
            selectedIcon: Icon(Icons.swap_horiz, size: 20, color: C.teal),
            label: 'Referrals',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined, size: 20),
            selectedIcon: Icon(Icons.badge, size: 20, color: C.teal),
            label: 'ASHAs',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined, size: 20),
            selectedIcon: Icon(Icons.insights, size: 20, color: C.teal),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: ref.watch(staffProvider).valueOrNull?.name ?? '—',
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(S.radius),
      ),
      onSelected: (value) async {
        if (value == 'profile') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'logout') {
          // A menu action, not a page. The router returns to /login when the
          // session clears.
          await ref.read(authProvider.notifier).signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          height: 52,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ref.watch(staffProvider).valueOrNull?.name ?? '—',
                  style: T.body),
              Text(designationOf(ref.watch(staffProvider).valueOrNull?.role),
                  style: T.small),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          height: 44,
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: C.textSoft),
              SizedBox(width: S.sm),
              Text('Profile', style: T.body),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          height: 44,
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: C.textSoft),
              SizedBox(width: S.sm),
              Text('Logout', style: T.body),
            ],
          ),
        ),
      ],
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: C.tealSoft,
          shape: BoxShape.circle,
        ),
        child: const Text('SR',
            style: TextStyle(
                color: C.teal, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}

/// Shown whenever the console is not reading the real caseload.
///
/// Amber, not red: nothing is clinically wrong, but every number on screen is
/// invented and no decision should be made from it. Red is reserved for a
/// patient in danger.
class _DemoDataBanner extends StatelessWidget {
  const _DemoDataBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: C.amberSoft,
      padding: const EdgeInsets.symmetric(horizontal: S.screen, vertical: S.sm),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: C.amber),
          const SizedBox(width: S.sm),
          const Expanded(
            child: Text(
              'Demo data — not connected to the health record. '
              'Sign out and sign in again to load real patients.',
              style: T.small,
            ),
          ),
        ],
      ),
    );
  }
}
