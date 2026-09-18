import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/asha_scaffold.dart';
import '../widgets/big_action_button.dart';
import '../widgets/language_toggle.dart';
import '../widgets/setu_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider);
    final pending = ref.watch(pendingCountProvider).valueOrNull ?? 0;

    return AshaScaffold(
      title: l.settingsTitle,
      showBanner: false,
      body: ListView(
        padding: const EdgeInsets.all(S.screen),
        children: [
          SectionHeader(l.languageLabel),
          const LanguageToggle(),
          const SizedBox(height: S.lg),
          SectionHeader(l.accountSection),
          SetuCard(
            padding: const EdgeInsets.all(S.md),
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
                  child: const Icon(Icons.person, size: 30, color: C.teal),
                ),
                const SizedBox(width: S.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.name ?? '', style: T.h2),
                      if (session.email != null) ...[
                        const SizedBox(height: S.xs),
                        Text(
                          session.email!,
                          style: T.label.copyWith(fontSize: 15),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: S.md),
          if (pending > 0)
            Container(
              margin: const EdgeInsets.only(bottom: S.md),
              padding: const EdgeInsets.all(S.md),
              decoration: BoxDecoration(
                color: C.amberSoft,
                borderRadius: BorderRadius.circular(S.radius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cloud_upload_outlined,
                      size: 24, color: C.amber),
                  const SizedBox(width: S.sm),
                  Expanded(
                    child: Text(
                      l.logoutPendingWarning(pending),
                      style: T.bodySoft.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          BigActionButton(
            label: l.logout,
            icon: Icons.logout,
            outlined: true,
            background: C.red,
            onPressed: () => _confirmSignOut(context, ref, pending),
          ),
          const SizedBox(height: S.xl),
        ],
      ),
    );
  }

  /// Signing out clears the cached session, and signing back in needs a
  /// network. In a village with no signal that would lock her out of her own
  /// caseload, so she is warned before it happens.
  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    int pending,
  ) async {
    final l = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.radius),
        ),
        title: Text(l.logoutWarningTitle, style: T.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.logoutWarningBody, style: T.body),
            if (pending > 0) ...[
              const SizedBox(height: S.md),
              Text(
                l.logoutPendingWarning(pending),
                style: T.body.copyWith(color: C.amber),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: C.red,
              minimumSize: const Size(150, S.tapMin),
            ),
            child: Text(l.logoutConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authControllerProvider.notifier).signOut();
    navigator.pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }
}
