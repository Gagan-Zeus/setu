import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';

/// Shown only when there is something to say: no connectivity, or entries
/// still waiting. Silence means everything is sent.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final pending = ref.watch(pendingCountProvider).valueOrNull ?? 0;
    final forcedOffline = ref.watch(offlineModeProvider);
    final connected = ref.watch(connectivityProvider).valueOrNull ?? true;
    final online = connected && !forcedOffline;

    if (online && pending == 0) return const SizedBox.shrink();

    final offline = !online;
    final colour = offline ? C.amber : C.teal;
    final text = offline ? l.syncOffline(pending) : l.syncPending(pending);

    return Material(
      color: offline ? C.amberSoft : C.tealSoft,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, Routes.syncStatus),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          padding:
              const EdgeInsets.symmetric(horizontal: S.screen, vertical: S.sm),
          child: Row(
            children: [
              Icon(
                offline ? Icons.cloud_off : Icons.cloud_upload_outlined,
                size: 24,
                color: colour,
              ),
              const SizedBox(width: S.sm),
              Expanded(
                child: Text(
                  text,
                  style: T.body.copyWith(fontSize: 17, color: colour),
                ),
              ),
              Icon(Icons.chevron_right, size: 24, color: colour),
            ],
          ),
        ),
      ),
    );
  }
}
