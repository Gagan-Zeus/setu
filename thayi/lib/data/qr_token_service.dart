import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Her QR code, and why it is not simply her record id.
///
/// A QR containing the mother's id is a permanent, un-revocable credential. It
/// is printed on a card she carries, photographed over her shoulder in a queue,
/// left on a screen in a waiting room — and once copied, that record is
/// readable by whoever kept the picture, for as long as the record exists.
///
/// So the code is a five-minute signed token minted by the server for whoever
/// is holding the session. A photograph stops working almost immediately, and
/// her holding the phone out is what makes reading her file consent rather than
/// a lookup someone did.
///
/// ---------------------------------------------------------------------------
/// THE COST, STATED PLAINLY
/// ---------------------------------------------------------------------------
/// This screen used to say "works without internet", and it did. A token minted
/// by a server cannot be. That is a real loss for a woman in a village with one
/// bar, and it is not papered over here: the token is cached and reused until it
/// expires, refreshed early while there is signal, and when it cannot be
/// refreshed the screen says so rather than showing a code that will be refused
/// at the counter.
///
/// The alternative — keeping a permanent offline code as a fallback — would
/// mean the permanent credential still exists and is still copyable, which is
/// the whole problem. A code that sometimes needs a moment of signal is a
/// smaller harm than a code that can be stolen once and used forever.
@immutable
class QrToken {
  const QrToken({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Refreshed before it actually lapses, so the code on screen is never the
  /// one that stops working while she is holding the phone out.
  bool get needsRefresh =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 45)));

  Duration get remaining {
    final left = expiresAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }
}

enum QrFailure {
  /// No connection, and the cached token has run out.
  offline,

  /// Signed in, but this account has no mother record to present.
  notAMother,

  /// No Supabase at all — the offline demo build.
  unavailable,
}

class QrTokenResult {
  const QrTokenResult.ok(this.token) : failure = null;
  const QrTokenResult.failed(this.failure) : token = null;

  final QrToken? token;
  final QrFailure? failure;
}

class QrTokenService {
  QrTokenService(this._client, this._prefs);

  final sb.SupabaseClient? _client;
  final SharedPreferences _prefs;

  static const _tokenKey = 'qr_token';
  static const _expiryKey = 'qr_token_expires_at';

  /// The cached token, whatever its state. Read synchronously so the screen can
  /// paint immediately rather than flashing a spinner on every open.
  QrToken? get cached {
    final token = _prefs.getString(_tokenKey);
    final expiry = _prefs.getString(_expiryKey);
    if (token == null || expiry == null) return null;
    final at = DateTime.tryParse(expiry);
    if (at == null) return null;
    return QrToken(token: token, expiresAt: at);
  }

  /// A usable code, minting a new one only when the cached one is close to
  /// lapsing. Being offline with a token that still has minutes left is not a
  /// failure, so it does not reach the network at all.
  Future<QrTokenResult> current({bool force = false}) async {
    final existing = cached;
    if (!force && existing != null && !existing.needsRefresh) {
      return QrTokenResult.ok(existing);
    }

    final fresh = await _mint();
    if (fresh.token != null) return fresh;

    // The mint failed. A cached token that has not actually expired is still
    // good, and showing it beats showing an error she cannot act on.
    if (existing != null && !existing.isExpired) {
      return QrTokenResult.ok(existing);
    }
    return fresh;
  }

  Future<QrTokenResult> _mint() async {
    final client = _client;
    if (client == null) return const QrTokenResult.failed(QrFailure.unavailable);

    try {
      // No mother id is sent, and the endpoint accepts none. It mints for
      // whoever holds the session, so this cannot ask for anyone else's code.
      final res = await client.functions.invoke('partner-api/qr/mint');

      final body = res.data is String
          ? jsonDecode(res.data as String) as Map<String, dynamic>
          : (res.data as Map).cast<String, dynamic>();

      if (res.status == 403) {
        return const QrTokenResult.failed(QrFailure.notAMother);
      }
      final token = body['qr_token'] as String?;
      final ttl = (body['expires_in_seconds'] as num?)?.toInt() ?? 300;
      if (token == null) return const QrTokenResult.failed(QrFailure.offline);

      final expiresAt = DateTime.now().add(Duration(seconds: ttl));
      await _prefs.setString(_tokenKey, token);
      await _prefs.setString(_expiryKey, expiresAt.toIso8601String());
      return QrTokenResult.ok(QrToken(token: token, expiresAt: expiresAt));
    } catch (error) {
      // No signal, a dropped connection, a function that is down. All the same
      // to her, and all recoverable by trying again in a moment.
      debugPrint('QR mint failed: $error');
      return const QrTokenResult.failed(QrFailure.offline);
    }
  }

  /// On sign-out. A token left behind would keep working for its five minutes
  /// on a handset that has been passed to someone else.
  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_expiryKey);
  }
}
