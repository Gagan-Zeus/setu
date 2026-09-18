import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/supabase_care_api.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';

/// Scanning the Thayi Card a mother holds out at the counter.
///
/// This is the one path into her record that needs no request: she is standing
/// here and has physically presented the card, which is the consent. The QR
/// carries only her id and a token — no name, no clinical data — so the token
/// is what proves the card was actually shown.
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

  /// Parses `setu://m/{uuid}?t={token}`.
  (String id, String token)? _parse(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;
    final token = uri.queryParameters['t'];
    final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    if (id == null || id.isEmpty || token == null || token.isEmpty) return null;
    return (id, token);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;

    final parsed = _parse(raw);
    if (parsed == null) {
      setState(() => _error = 'That is not a Thayi Card');
      return;
    }

    setState(() {
      _handling = true;
      _error = null;
    });

    final api = ref.read(apiProvider);
    if (api is! SupabaseCareApi) {
      if (!mounted) return;
      Navigator.of(context).pop(parsed.$1);
      return;
    }

    try {
      final ok = await api.grantByQr(parsed.$1, parsed.$2);
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _handling = false;
          _error = 'This card could not be verified';
        });
        return;
      }
      Navigator.of(context).pop(parsed.$1);
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
        title: const Text('Scan Thayi Card',
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
