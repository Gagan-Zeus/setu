import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../risk/risk_engine.dart';
import '../theme/tokens.dart';
import '../widgets/call_button.dart';

/// Fires full-screen the moment a red rule triggers — before she can save and
/// move on. Everything here works with no network: the advice is on-device,
/// the referral is a local row that syncs later.
class RiskAlertScreen extends ConsumerStatefulWidget {
  const RiskAlertScreen({
    super.key,
    required this.motherId,
    required this.motherName,
    required this.alerts,
    this.visitId,
  });

  final String motherId;
  final String motherName;
  final List<RiskAlert> alerts;
  final String? visitId;

  static Future<void> show(
    BuildContext context, {
    required String motherId,
    required String motherName,
    required List<RiskAlert> alerts,
    String? visitId,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => RiskAlertScreen(
          motherId: motherId,
          motherName: motherName,
          alerts: alerts,
          visitId: visitId,
        ),
      ),
    );
  }

  @override
  ConsumerState<RiskAlertScreen> createState() => _RiskAlertScreenState();
}

class _RiskAlertScreenState extends ConsumerState<RiskAlertScreen> {
  bool _referred = false;
  bool _busy = false;

  Future<void> _refer(AppLocalizations l) async {
    setState(() => _busy = true);
    final worst = widget.alerts.first;
    await ref.read(visitRepositoryProvider).createReferral(
          motherId: widget.motherId,
          facility: l.phcName,
          reasonKn: worst.messageKn,
          reasonEn: worst.messageEn,
          visitId: widget.visitId,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _referred = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: C.green,
        content: Text(
          l.referralCreated,
          style: T.body.copyWith(color: C.onDark),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isKn = l.localeName.startsWith('kn');
    final red = widget.alerts.where((a) => a.isRed).toList();
    final shown = red.isNotEmpty ? red : widget.alerts;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: C.red,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(S.screen),
                  children: [
                    const SizedBox(height: S.sm),
                    const Icon(Icons.warning_amber_rounded,
                        size: 72, color: C.onDark),
                    const SizedBox(height: S.md),
                    Text(
                      l.riskAlertTitle,
                      style: T.display.copyWith(color: C.onDark, fontSize: 34),
                    ),
                    const SizedBox(height: S.xs),
                    Text(
                      widget.motherName,
                      style: T.h2.copyWith(
                        color: C.onDark.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: S.lg),
                    for (final a in shown) ...[
                      Container(
                        padding: const EdgeInsets.all(S.md),
                        margin: const EdgeInsets.only(bottom: S.md),
                        decoration: BoxDecoration(
                          color: C.onDark.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(S.radius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  a.ruleId,
                                  style: T.label.copyWith(
                                    color: C.onDark.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: S.sm),
                                Expanded(
                                  child: Text(
                                    isKn ? a.titleKn : a.titleEn,
                                    style: T.h2.copyWith(color: C.onDark),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: S.sm),
                            Text(
                              isKn ? a.messageKn : a.messageEn,
                              style: T.body
                                  .copyWith(color: C.onDark, fontSize: 19),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: S.sm),
                    if (_referred)
                      Container(
                        padding: const EdgeInsets.all(S.md),
                        decoration: BoxDecoration(
                          color: C.onDark,
                          borderRadius: BorderRadius.circular(S.radius),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: C.green, size: 28),
                            const SizedBox(width: S.sm),
                            Expanded(
                              child: Text(
                                l.referralTo(l.phcName),
                                style: T.body.copyWith(color: C.ink),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _refer(l),
                        icon:
                            const Icon(Icons.local_hospital_outlined, size: 26),
                        label: Text(l.referToPhc),
                        style: FilledButton.styleFrom(
                          backgroundColor: C.onDark,
                          foregroundColor: C.red,
                          minimumSize: const Size.fromHeight(S.tapMin),
                          textStyle: T.button,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    const SizedBox(height: S.md),
                    CallButton(
                      title: l.callPhc,
                      number: '+918212345678',
                      subtitle: l.phcName,
                      background: C.ink,
                      onFailureMessage: l.callFailed,
                    ),
                    const SizedBox(height: S.lg),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: C.onDark,
                        minimumSize: const Size.fromHeight(S.tapMin),
                        side: BorderSide(
                          color: C.onDark.withValues(alpha: 0.6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l.dismissAlert),
                    ),
                  ],
                ),
              ),
              // The clinical officer's judgement always prevails.
              Container(
                width: double.infinity,
                color: C.ink,
                padding: const EdgeInsets.symmetric(
                    horizontal: S.screen, vertical: S.sm),
                child: Text(
                  l.advisoryFooter,
                  textAlign: TextAlign.center,
                  style: T.label.copyWith(
                    color: C.onDark.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
