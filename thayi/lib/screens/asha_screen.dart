import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/call_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class AshaScreen extends ConsumerWidget {
  const AshaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(motherProvider);

    return SetuScaffold(
      title: l.ashaTitle,
      body: async.when(
        loading: () => const SkeletonList(count: 2),
        error: (_, __) => EmptyState(
          icon: Icons.cloud_off_outlined,
          message: l.errorTitle,
        ),
        data: (m) => ListView(
          padding: const EdgeInsets.all(S.screen),
          children: [
            SetuCard(
              padding: const EdgeInsets.all(S.lg),
              child: Column(
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: const BoxDecoration(
                      color: C.tealSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 62, color: C.teal),
                  ),
                  const SizedBox(height: S.md),
                  Text(l.ashaName(m.asha), style: T.h1),
                  const SizedBox(height: S.xs),
                  Text(l.ashaRole, style: T.bodySoft),
                ],
              ),
            ),
            const SizedBox(height: S.md),
            SetuCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
              child: Column(
                children: [
                  DetailRow(
                    label: l.subCentreLabel,
                    value: l.subCentre(m.asha),
                  ),
                  const Divider(height: 1),
                  DetailRow(
                    label: l.phoneNumberLabel,
                    value: m.asha.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: S.md),
            CallButton(
              title: l.callNow,
              number: m.asha.phone,
              subtitle: l.ashaName(m.asha),
              onFailureMessage: l.callFailed,
            ),
            const SizedBox(height: S.md),
            Container(
              padding: const EdgeInsets.all(S.md),
              decoration: BoxDecoration(
                color: C.tealSoft,
                borderRadius: BorderRadius.circular(S.radius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 24, color: C.teal),
                  const SizedBox(width: S.sm),
                  Expanded(
                    child: Text(
                      l.ashaNote,
                      style: T.bodySoft.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            kFabClearance,
          ],
        ),
      ),
    );
  }
}
