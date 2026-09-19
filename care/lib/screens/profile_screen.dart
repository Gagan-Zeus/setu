import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';

/// Step 10 — beyond the demo arc. Read-only; editing and change-password are
/// not built.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final staff = ref.watch(staffProvider).valueOrNull;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(S.screen),
        children: [
          CareCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Her own row, not the demo doctor's. The phone here was the
                // literal '+91 82123 45678', which is nobody's.
                Text(staff?.name ?? '—', style: T.h2),
                Text(designationOf(staff?.role), style: T.small),
                const Divider(height: S.lg),
                KeyValue(label: 'Facility', value: staff?.facility ?? '—'),
                KeyValue(label: 'Email', value: session?.email ?? '—'),
                KeyValue(label: 'Phone', value: staff?.phone ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: S.md),
          const CareCard(
            child: Text(
              'Editing details and changing password are not built — this '
              'screen is past the demo arc.',
              style: T.small,
            ),
          ),
        ],
      ),
    );
  }
}
