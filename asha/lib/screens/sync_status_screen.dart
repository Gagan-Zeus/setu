import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/asha_scaffold.dart';
import '../widgets/big_action_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/setu_card.dart';

/// "What happens when sync fails" — this screen is the answer.
class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  bool _draining = false;

  Future<void> _retry() async {
    setState(() => _draining = true);
    final service = ref.read(syncServiceProvider);
    service.forceOffline = ref.read(offlineModeProvider);
    service.networkUp = ref.read(connectivityProvider).valueOrNull ?? true;
    await ref.read(syncWorkerProvider).drain();
    if (mounted) setState(() => _draining = false);
  }

  /// Re-queues everything on the phone and pushes it again.
  ///
  /// A record can be marked sent without ever having arrived: the sync service
  /// used to be a stub that returned success, so the worker marked those rows
  /// done and they became invisible to the queue for good. Nothing reports a
  /// failure, because nothing failed — the mother is simply not there. This is
  /// the way back.
  Future<void> _resendAll() async {
    setState(() => _draining = true);
    final count = await ref.read(dbProvider).requeueEverything();
    ref.invalidate(outboxProvider);
    await _retry();
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.resendQueued(count), style: T.body)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(outboxProvider).valueOrNull;
    final offline = ref.watch(offlineModeProvider);

    return AshaScaffold(
      title: l.syncTitle,
      showBanner: false,
      body: Column(
        children: [
          // The demo switch. Flip it, record a visit, watch the alert fire
          // anyway, flip it back, watch the queue drain.
          Padding(
            padding: const EdgeInsets.fromLTRB(S.screen, S.md, S.screen, 0),
            child: SetuCard(
              color: offline ? C.amberSoft : C.card,
              padding:
                  const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: offline,
                activeThumbColor: C.amber,
                onChanged: (v) =>
                    ref.read(offlineModeProvider.notifier).state = v,
                title: Text(l.demoOfflineToggle, style: T.body),
                subtitle: offline
                    ? Text(l.demoOfflineOn,
                        style: T.label.copyWith(fontSize: 14))
                    : null,
                secondary: Icon(
                  offline ? Icons.airplanemode_active : Icons.wifi,
                  size: 28,
                  color: offline ? C.amber : C.teal,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(S.screen, S.screen, S.screen, 0),
            child: BigActionButton(
              label: _draining ? l.syncing : l.retryNow,
              icon: Icons.sync,
              onPressed: _draining ? null : _retry,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, S.sm),
            child: TextButton.icon(
              onPressed: _draining ? null : _resendAll,
              icon: const Icon(Icons.cloud_upload_outlined, size: 22),
              label: Text(l.resendEverything),
              style: TextButton.styleFrom(
                foregroundColor: C.teal,
                minimumSize: const Size.fromHeight(S.tapMin),
              ),
            ),
          ),
          Expanded(
            child: items == null
                ? const SkeletonList()
                : items.isEmpty
                    ? EmptyState(
                        icon: Icons.cloud_done_outlined,
                        message: l.outboxEmpty,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            S.screen, 0, S.screen, S.screen),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: S.md),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          final (colour, label) = switch (item.status) {
                            'synced' => (C.green, l.outStatusSynced),
                            'syncing' => (C.teal, l.outStatusSyncing),
                            'failed' => (C.red, l.outStatusFailed),
                            _ => (C.amber, l.outStatusPending),
                          };
                          final what = switch (item.entityTable) {
                            'anc_visits' => l.recordVisit,
                            'mothers' => l.recordMother,
                            'referrals' => l.recordReferral,
                            'alerts' => l.recordAlert,
                            _ => l.recordTask,
                          };

                          return SetuCard(
                            padding: const EdgeInsets.all(S.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    color: colour,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: S.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(what, style: T.h2),
                                      const SizedBox(height: S.xs),
                                      Text(
                                        DateFormat('d MMM, HH:mm', l.localeName)
                                            .format(item.createdAt),
                                        style: T.label.copyWith(fontSize: 14),
                                      ),
                                      if (item.retryCount > 0) ...[
                                        const SizedBox(height: S.xs),
                                        Text(
                                          l.retryCountLabel(item.retryCount),
                                          style: T.label.copyWith(
                                            fontSize: 14,
                                            color: C.red,
                                          ),
                                        ),
                                      ],
                                      if (item.lastError != null) ...[
                                        const SizedBox(height: S.xs),
                                        Text(
                                          item.lastError!,
                                          style: T.label.copyWith(
                                            fontSize: 13,
                                            color: C.textSoft,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  label,
                                  style: T.label.copyWith(color: colour),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
