import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
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
                Text(MockData.doctorName, style: T.h2),
                Text(MockData.doctorDesignation, style: T.small),
                const Divider(height: S.lg),
                KeyValue(label: 'Facility', value: MockData.facility),
                KeyValue(label: 'Email', value: session?.email ?? '—'),
                const KeyValue(label: 'Phone', value: '+91 82123 45678'),
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
