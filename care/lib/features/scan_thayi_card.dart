import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/supabase_care_api.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';

/// Scanning the code a mother holds out at the counter.
///
/// This is the one path into her record that needs no request: she is standing
/// here and has physically presented it, which is the consent.
///
/// Her phone now shows a five-minute signed token rather than a permanent card
/// id, so a photograph of it is useless minutes later and the thing being shown
/// is proof she was here, not merely that someone once saw her card. The older
/// `setu://m/<uuid>?t=<token>` form is still accepted, because a handset that
/// has not been updated yet is not her problem to solve at a counter.
class ScanThayiCard extends ConsumerStatefulWidget {
  const ScanThayiCard({super.key});

  /// Returns the mother id when a card was scanned and access opened.
  static Future<String?> show(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ScanThayiCard(),
      ),
    );
  }

  @override
  ConsumerState<ScanThayiCard> createState() => _ScanThayiCardState();
}

class _ScanThayiCardState extends ConsumerState<ScanThayiCard> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handling = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The old card: `setu://m/{uuid}?t={token}`.
  (String id, String token)? _parseLegacy(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'setu') return null;
    final token = uri.queryParameters['t'];
    final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    if (id == null || id.isEmpty || token == null || token.isEmpty) return null;
    return (id, token);
  }

  /// Three dot-separated base64url segments. Only shape is checked here — the
  /// signature is an HMAC and only the server holds the key, so a token that
  /// looks right and is forged fails there, which is where it should.
  bool _looksLikeToken(String raw) =>
      RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$')
          .hasMatch(raw.trim());

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;

    final legacy = _parseLegacy(raw);
    final isToken = legacy == null && _looksLikeToken(raw);
    if (legacy == null && !isToken) {
      setState(() => _error = 'That is not a Thayi code');
      return;
    }

    setState(() {
      _handling = true;
      _error = null;
    });

    final api = ref.read(apiProvider);
    if (api is! SupabaseCareApi) {
      // Not signed in to the real record, so there is nothing to resolve
      // against. This used to pop with the literal string 'demo' as a mother
      // id, which opened a record screen for a row that does not exist: the
      // scan appeared to work and then showed nothing, with no way to tell
      // that the app was on demo data rather than the code being bad.
      if (!mounted) return;
      setState(() {
        _handling = false;
        _error = 'Not connected to the health record. Sign out and sign in '
            'again, then scan.';
      });
      return;
    }

    try {
      if (isToken) {
        final outcome = await api.resolveQrToken(raw.trim());
        if (!mounted) return;
        if (!outcome.ok) {
          setState(() {
            _handling = false;
            // The scanner suppresses duplicates, so without this she would have
            // to move the phone away and back before a second try registered.
            _error = outcome.message;
          });
          return;
        }
        Navigator.of(context).pop(outcome.motherId);
        return;
      }

      final ok = await api.grantByQr(legacy!.$1, legacy.$2);
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _handling = false;
          _error = 'This card could not be verified';
        });
        return;
      }
      Navigator.of(context).pop(legacy.$1);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _handling = false;
        _error = 'Could not open her record. Check the connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.ink,
      appBar: AppBar(
        backgroundColor: C.ink,
        foregroundColor: C.onDark,
        title: const Text('Scan her code',
            style: TextStyle(color: C.onDark, fontSize: 19)),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // A window to aim at, so she knows where to hold the card.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: C.onDark, width: 2),
                borderRadius: BorderRadius.circular(S.radius),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: C.ink,
              padding: const EdgeInsets.all(S.md),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_handling)
                      const Text('Opening her record…',
                          style: TextStyle(color: C.onDark, fontSize: 15))
                    else if (_error != null)
                      Text(_error!,
                          style: const TextStyle(color: C.red, fontSize: 15),
                          textAlign: TextAlign.center)
                    else
                      const Text(
                        'Ask her to show the QR code in her app. '
                        'Scanning it opens her record for 24 hours.',
                        style: TextStyle(color: C.onDark, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown in place of a mother's clinical tabs until access exists.
class AccessLocked extends StatelessWidget {
  const AccessLocked({
    super.key,
    required this.state,
    required this.onRequest,
    required this.onScan,
    required this.busy,
  });

  /// none | pending | rejected | expired
  final String state;
  final VoidCallback onRequest;
  final VoidCallback onScan;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (state) {
      'pending' => (
          'Waiting for her to agree',
          'She has been asked and has not answered yet. Her record opens as '
              'soon as she allows it.'
        ),
      'rejected' => (
          'She did not allow this',
          'You can ask again, or scan her Thayi Card if she is here with you.'
        ),
      'expired' => (
          'Access has ended',
          'The permission she gave has run out. Ask again, or scan her card.'
        ),
      _ => (
          'Her record is private',
          'She decides who reads it. Ask her, or scan the Thayi Card she is '
              'holding — showing it is her consent.'
        ),
    };

    return ListView(
      padding: const EdgeInsets.all(S.screen),
      children: [
        CareCard(
          padding: const EdgeInsets.all(S.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    state == 'pending'
                        ? Icons.hourglass_empty
                        : Icons.lock_outline,
                    size: 22,
                    color: C.textSoft,
                  ),
                  const SizedBox(width: S.sm),
                  Expanded(child: Text(title, style: T.h2)),
                ],
              ),
              const SizedBox(height: S.sm),
              Text(body, style: T.bodySoft),
              const SizedBox(height: S.lg),
              if (state != 'pending')
                FilledButton.icon(
                  onPressed: busy ? null : onRequest,
                  icon: const Icon(Icons.mark_email_read_outlined, size: 18),
                  label: Text(state == 'none' ? 'Ask her' : 'Ask again'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              const SizedBox(height: S.sm),
              OutlinedButton.icon(
                onPressed: busy ? null : onScan,
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('Scan her Thayi Card'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
