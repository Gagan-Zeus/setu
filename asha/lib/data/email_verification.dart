/// Confirming, at the doorstep, that a mother's email actually reaches her.
///
/// The ASHA types the address while standing in the house. A slip there is
/// silent: nobody discovers it until the mother tries to sign in weeks later,
/// and by then the worker has gone and the record is unreachable by the person
/// it belongs to.
///
/// The code sent is Supabase's own login OTP, not a second scheme of ours. So
/// what the worker is confirming is exactly the thing that matters — that this
/// address receives the code the mother will later sign in with. A parallel
/// code would need its own delivery, expiry and brute-force limit, and would
/// prove something weaker.
///
/// It runs on an isolated Supabase client. Verifying an OTP returns a session,
/// and that session belongs to the mother — putting it on the app's own client
/// would sign the ASHA out of her account and into the mother's, on the ASHA's
/// handset. The isolated client is signed out and thrown away immediately.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

enum VerifyOutcome {
  sent,
  verified,

  /// The code was wrong or has expired.
  wrongCode,

  /// No signal, or the mail could not be sent.
  offline,

  /// Verified with the mother, but her record has not reached the server yet,
  /// so there is nothing to mark. It will be marked when the outbox drains.
  notSyncedYet,
}

class EmailVerification {
  EmailVerification(this._appClient);

  /// The signed-in ASHA's client, used only to record the result.
  final SupabaseClient _appClient;

  SupabaseClient? _isolated;

  SupabaseClient get _scratch => _isolated ??= SupabaseClient(
        Env.supabaseUrl,
        Env.supabaseAnonKey,
        // In-memory only. Nothing about the mother's half-finished sign-in may
        // touch the storage holding the ASHA's own session.
        authOptions:
            const AuthClientOptions(authFlowType: AuthFlowType.implicit),
      );

  /// Emails the mother her login code.
  Future<VerifyOutcome> sendCode(String email) async {
    try {
      await _scratch.auth.signInWithOtp(
        email: email.trim(),
        // She may not have signed in before — this is often the first time her
        // address is used at all.
        shouldCreateUser: true,
      );
      return VerifyOutcome.sent;
    } catch (_) {
      return VerifyOutcome.offline;
    }
  }

  /// Checks the code the mother read out, then records the address as verified.
  Future<VerifyOutcome> confirm({
    required String email,
    required String code,
    required String motherServerId,
  }) async {
    try {
      final response = await _scratch.auth.verifyOTP(
        type: OtpType.email,
        email: email.trim(),
        token: code.trim(),
      );
      if (response.session == null) return VerifyOutcome.wrongCode;
    } on AuthException {
      return VerifyOutcome.wrongCode;
    } catch (_) {
      return VerifyOutcome.offline;
    } finally {
      // Never leave the mother signed in on the worker's phone.
      await _scratch.auth.signOut().catchError((_) {});
    }

    // Recorded as the ASHA, because only she has the right to write it.
    try {
      final ok = await _appClient.rpc<bool>(
        'mark_email_verified',
        params: {'p_mother_id': motherServerId, 'p_email': email.trim()},
      );
      return ok == true ? VerifyOutcome.verified : VerifyOutcome.notSyncedYet;
    } catch (_) {
      // The mother is verified as far as she is concerned — she received the
      // code — but her row is not on the server yet. Not a failure to show her.
      return VerifyOutcome.notSyncedYet;
    }
  }

  Future<void> dispose() async {
    await _isolated?.auth.signOut().catchError((_) {});
    await _isolated?.dispose();
    _isolated = null;
  }
}
