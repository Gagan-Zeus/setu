import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/qr_token_service.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/big_action_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class ThayiCardScreen extends ConsumerWidget {
  const ThayiCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final motherAsync = ref.watch(motherProvider);
    final qrSize = MediaQuery.of(context).size.width * 0.6;

    return SetuScaffold(
      title: l.thayiCardTitle,
      body: motherAsync.when(
        loading: () => const SkeletonList(count: 2),
        error: (_, __) => EmptyState(
          icon: Icons.cloud_off_outlined,
          message: l.errorTitle,
        ),
        data: (m) => ListView(
          padding: const EdgeInsets.all(S.screen),
          children: [
            SetuCard(
              padding:
                  const EdgeInsets.symmetric(vertical: S.lg, horizontal: S.md),
              child: Column(
                children: [
                  // A five minute signed token, not her record id. A QR that
                  // resolves to her file is a permanent credential: photograph
                  // it once and it works forever. This one stops working
                  // before she has left the building.
                  _LiveQr(size: qrSize, fallbackPayload: m.qrPayload),
                  const SizedBox(height: S.lg),
                  Text(
                    l.qrCaption,
                    style: T.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: S.md),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.offline_pin_outlined,
                          size: 22, color: C.green),
                      const SizedBox(width: S.xs),
                      Text(
                        l.worksOffline,
                        style: T.label.copyWith(color: C.green, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: S.md),
            SetuCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
              child: Column(
                children: [
                  DetailRow(label: l.fieldName, value: l.motherName(m)),
                  const Divider(height: 1),
                  DetailRow(label: l.fieldAge, value: l.ageYears(m.age)),
                  const Divider(height: 1),
                  DetailRow(label: l.fieldGuardian, value: l.guardian(m)),
                  const Divider(height: 1),
                  DetailRow(
                    label: l.fieldVillage,
                    value: '${l.village(m)}, ${l.district(m)}',
                  ),
                  const Divider(height: 1),
                  DetailRow(label: l.fieldBloodGroup, value: m.bloodGroup),
                  const Divider(height: 1),
                  DetailRow(label: l.fieldEdd, value: l.formatDate(m.edd)),
                  const Divider(height: 1),
                  DetailRow(
                    label: l.fieldCardNumber,
                    value: m.thayiCardNumber,
                  ),
                  const Divider(height: 1),
                  DetailRow(
                    label: l.fieldAsha,
                    value: l.ashaName(m.asha),
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

/// The code itself: minted for her session, refreshed before it lapses, and
/// honest when it cannot be.
class _LiveQr extends ConsumerStatefulWidget {
  const _LiveQr({required this.size, required this.fallbackPayload});

  final double size;

  /// Used only in the offline demo build, where there is no Supabase to mint
  /// from. Never on a real handset - falling back to a permanent code there
  /// would quietly restore the thing the token exists to prevent.
  final String fallbackPayload;

  @override
  ConsumerState<_LiveQr> createState() => _LiveQrState();
}

class _LiveQrState extends ConsumerState<_LiveQr> {
  QrToken? _token;
  QrFailure? _failure;
  bool _busy = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _token = ref.read(qrTokenServiceProvider).cached;
    _load();
    // Drives the countdown, and refreshes the code before it lapses rather
    // than after - a code that expires while she is holding the phone out is
    // refused at the counter with no explanation she can act on.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final token = _token;
      if (token != null && token.needsRefresh && !_busy) {
        _load();
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(qrTokenServiceProvider).current();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _token = result.token;
      _failure = result.failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    // The offline demo build has no server to mint from, and showing an error
    // there would be a bug report about a deliberate configuration.
    if (_failure == QrFailure.unavailable) {
      return _qr(widget.fallbackPayload);
    }

    // Not a connection problem, and telling her it is sends her walking to the
    // top of the village for signal that will not help. Only her ASHA can fix
    // this one, so say so.
    if (_failure == QrFailure.notAMother && _token == null) {
      return SizedBox(
        width: widget.size,
        child: Column(
          children: [
            SizedBox(
              height: widget.size,
              child: const Center(
                child: Icon(Icons.badge_outlined, size: 56, color: C.textSoft),
              ),
            ),
            const SizedBox(height: S.sm),
            Text(l.qrNoCard, style: T.body, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final token = _token;
    if (token != null && !token.isExpired) {
      final seconds = token.remaining.inSeconds;
      return Column(
        children: [
          _qr(token.token),
          const SizedBox(height: S.sm),
          Text(
            _busy ? l.qrRefreshing : l.qrExpiresIn(seconds.toString()),
            style: T.label.copyWith(
              fontSize: 15,
              // Amber only in the last fifteen seconds, so the colour means
              // "about to change" rather than decorating every glance.
              color: seconds <= 15 ? C.amber : C.textSoft,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: widget.size,
      child: Column(
        children: [
          SizedBox(
            height: widget.size,
            child: Center(
              child: _busy
                  ? const CircularProgressIndicator(color: C.teal)
                  : Icon(Icons.wifi_off_rounded, size: 56, color: C.textSoft),
            ),
          ),
          const SizedBox(height: S.sm),
          Text(
            _busy ? l.qrRefreshing : l.qrNeedsSignal,
            style: T.body,
            textAlign: TextAlign.center,
          ),
          if (!_busy) ...[
            const SizedBox(height: S.md),
            BigActionButton(
              label: l.qrRetry,
              icon: Icons.refresh_rounded,
              onPressed: _load,
            ),
          ],
        ],
      ),
    );
  }

  Widget _qr(String data) => QrImageView(
        // Only the signed token is encoded. Never her name, her phone number,
        // or anything clinical.
        data: data,
        version: QrVersions.auto,
        size: widget.size,
        backgroundColor: C.card,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: C.ink,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: C.ink,
        ),
      );
}
