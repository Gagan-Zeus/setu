import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Supabase exports an AuthState of its own; this file has its own session type.
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'config/env.dart';
import 'data/ocr_service.dart';
import 'data/supabase_sync_service.dart';
import 'data/sync_service.dart';
import 'db/database.dart';
import 'risk/risk_engine.dart';

/// Both are overridden in main() once opened.
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('prefsProvider must be overridden'),
);

final dbProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('dbProvider must be overridden'),
);

// ---------------------------------------------------------------- language

const kSupportedLocales = [Locale('kn'), Locale('en')];

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs) : super(_read(_prefs));

  static const _key = 'locale_code';
  final SharedPreferences _prefs;

  /// Kannada is the default. English is the toggle.
  static Locale _read(SharedPreferences prefs) =>
      prefs.getString(_key) == 'en' ? const Locale('en') : const Locale('kn');

  Future<void> set(Locale locale) async {
    state = locale;
    await _prefs.setString(_key, locale.languageCode);
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(ref.watch(prefsProvider)),
);

// -------------------------------------------------------------------- auth

@immutable
class AshaSession {
  const AshaSession({
    this.email,
    this.name,
    this.pin,
    this.subCentre,
    this.unlocked = false,
  });

  final String? email;
  final String? name;
  final String? pin;

  /// The sub-centre she is posted to, read from her staff row rather than
  /// typed. Row Level Security scopes her to it, so a mother registered into
  /// any other one is a mother she cannot open afterwards.
  final String? subCentre;

  /// PIN entered this run. The phone is shared, so this resets on every open.
  final bool unlocked;

  bool get isSignedIn => email != null;
  bool get hasPin => pin != null && pin!.length == 4;

  AshaSession copyWith({
    String? email,
    String? name,
    String? pin,
    String? subCentre,
    bool? unlocked,
  }) =>
      AshaSession(
        email: email ?? this.email,
        name: name ?? this.name,
        pin: pin ?? this.pin,
        subCentre: subCentre ?? this.subCentre,
        unlocked: unlocked ?? this.unlocked,
      );
}

class AuthController extends StateNotifier<AshaSession> {
  AuthController(this._prefs, this._client) : super(_read(_prefs));

  static const _emailKey = 'asha_email';
  static const _nameKey = 'asha_name';
  static const _pinKey = 'asha_pin';
  static const _subCentreKey = 'asha_sub_centre';
  final SharedPreferences _prefs;

  /// Null when Supabase is switched off or failed to initialise.
  final sb.SupabaseClient? _client;

  static AshaSession _read(SharedPreferences prefs) => AshaSession(
        email: prefs.getString(_emailKey),
        name: prefs.getString(_nameKey),
        pin: prefs.getString(_pinKey),
        subCentre: prefs.getString(_subCentreKey),
      );

  /// Set when the backend could not send a code — no signal, or no email
  /// provider configured. She then signs in locally and the app keeps working
  /// on local data, because being stuck at a login screen in a village is
  /// worse than an unverified session.
  bool _otpUnavailable = false;

  bool get otpUnavailable => _otpUnavailable;

  static bool _cannotSend(Object error) {
    if (error is sb.AuthException) {
      final code = error.code ?? '';
      final message = error.message.toLowerCase();
      if (code == 'email_provider_disabled' ||
          message.contains('provider disabled') ||
          message.contains('unsupported')) {
        return true;
      }
    }
    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('connection closed') ||
        text.contains('timed out');
  }

  /// Emails a six digit code. SMTP credentials live in Supabase's server-side
  /// config and never touch this app.
  Future<void> sendOtp(String email) async {
    final client = _client;
    if (client == null) {
      _otpUnavailable = true;
      return;
    }
    // Whatever session this handset is already carrying is what authorises
    // every write, no matter which address the screen shows. The two were
    // never reconciled: the app read "signed in" out of SharedPreferences
    // while the server read it out of the Supabase session, so a phone could
    // display one worker and write as another — or as nobody at all, if the
    // account behind the session was never registered as staff. Row Level
    // Security then refused the mother, and that refusal surfaced as a flat
    // "failed to sync". Dropping a session that belongs to someone else here
    // is what makes the screen and the server agree once this code is used.
    final leftover = client.auth.currentUser?.email;
    if (leftover != null &&
        leftover.toLowerCase() != email.trim().toLowerCase()) {
      try {
        await client.auth.signOut();
      } catch (_) {
        // The point is that the stale session stops being used from here on;
        // whether the server managed to revoke it does not change that.
      }
    }

    try {
      await client.auth.signInWithOtp(email: email.trim());
      _otpUnavailable = false;
    } catch (error) {
      if (_cannotSend(error)) {
        _otpUnavailable = true;
        debugPrint('OTP could not be sent; falling back to local sign-in.');
        return;
      }
      rethrow;
    }
  }

  /// Verifies the code and caches the session. The session is never expired by
  /// this app — she must not be asked to re-authenticate with no signal.
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    final client = _client;
    if (client == null || _otpUnavailable) {
      await _signInLocally(email);
      return;
    }

    final response = await client.auth.verifyOTP(
      type: sb.OtpType.email,
      email: email.trim(),
      token: code,
    );
    if (response.session == null) {
      throw const sb.AuthException('Verification did not return a session');
    }
    await _signInAsStaff(client, email.trim());
  }

  /// Re-reads her name and posting from the server.
  ///
  /// _signInAsStaff only runs at OTP verification, so a worker who is already
  /// signed in never picks up what her staff row says — which is why a handset
  /// went on greeting her by a name out of the practice caseload long after
  /// she had been registered properly. This runs on every open.
  ///
  /// It only ever writes on success. Offline, or with the staff row missing,
  /// it leaves what is already stored alone: showing her nothing, or her email
  /// local part, would be a worse answer than a slightly stale name, and
  /// _signInAsStaff's own fallbacks would actively clear her sub-centre —
  /// which is the field the registration form fills itself from.
  Future<void> refreshStaffProfile() async {
    final client = _client;
    final email = state.email;
    if (client == null || email == null) return;
    final id = client.auth.currentUser?.id;
    if (id == null) return;

    final Map<String, dynamic>? staff;
    try {
      staff = await client
          .from('staff')
          .select('name, sub_centre')
          .eq('auth_user_id', id)
          .maybeSingle();
    } catch (_) {
      return;
    }
    if (staff == null) return;

    final name = (staff['name'] as String?)?.trim();
    final subCentre = (staff['sub_centre'] as String?)?.trim();
    if (name == null || name.isEmpty) return;
    if (name == state.name && subCentre == state.subCentre) return;

    await _prefs.setString(_nameKey, name);
    if (subCentre != null && subCentre.isNotEmpty) {
      await _prefs.setString(_subCentreKey, subCentre);
    }

    // Built directly rather than with copyWith, whose `?? this.x` can never
    // put a field back to null.
    state = AshaSession(
      email: email,
      name: name,
      subCentre: subCentre ?? state.subCentre,
      pin: state.pin,
      unlocked: state.unlocked,
    );
  }

  /// Records who she is from her own staff row.
  ///
  /// This used to stamp SeedData.ashaName — a worker out of the practice
  /// caseload — so every handset greeted the same person and wrote that name
  /// onto every visit it recorded, whoever had actually signed in.
  Future<void> _signInAsStaff(sb.SupabaseClient client, String email) async {
    String? name;
    String? subCentre;
    final id = client.auth.currentUser?.id;
    if (id != null) {
      try {
        final staff = await client
            .from('staff')
            .select('name, sub_centre')
            .eq('auth_user_id', id)
            .maybeSingle();
        name = (staff?['name'] as String?)?.trim();
        subCentre = (staff?['sub_centre'] as String?)?.trim();
      } catch (_) {
        // She is signed in either way. If there is no staff row behind the
        // login, the sync layer is where that gets said, in the one place it
        // actually matters and with the words for what to do about it.
      }
    }

    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_nameKey, name ?? _nameFrom(email));
    if (subCentre != null && subCentre.isNotEmpty) {
      await _prefs.setString(_subCentreKey, subCentre);
    } else {
      await _prefs.remove(_subCentreKey);
    }

    state = AshaSession(
      email: email,
      name: name ?? _nameFrom(email),
      subCentre: subCentre,
      pin: state.pin,
      unlocked: true,
    );
  }

  /// Signed in with no backend to ask. Her own address is a truer label than
  /// somebody else's name out of the demo data.
  Future<void> _signInLocally(String email) async {
    await _prefs.setString(_emailKey, email);
    await _prefs.setString(_nameKey, _nameFrom(email));
    state = state.copyWith(
      email: email,
      name: _nameFrom(email),
      unlocked: true,
    );
  }

  static String _nameFrom(String email) {
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  Future<void> setPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
    state = state.copyWith(pin: pin, unlocked: true);
  }

  bool checkPin(String pin) => state.pin == pin;

  void unlock() => state = state.copyWith(unlocked: true);

  Future<void> signOut() async {
    await _client?.auth.signOut();
    await _prefs.remove(_emailKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_pinKey);
    await _prefs.remove(_subCentreKey);
    state = const AshaSession();
  }
}

/// Null when Supabase is off, unconfigured, or failed to initialise.
final supabaseClientProvider = Provider<sb.SupabaseClient?>((ref) {
  if (!Env.useSupabase || !Env.isSupabaseConfigured) return null;
  try {
    return sb.Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AshaSession>(
  (ref) => AuthController(
    ref.watch(prefsProvider),
    ref.watch(supabaseClientProvider),
  ),
);

// -------------------------------------------------------------------- risk

/// Loaded once from the JSON asset at startup.
final riskEngineProvider = FutureProvider<RiskEngine>(
  (ref) => RiskEngine.load(),
);

// -------------------------------------------------------------------- sync

/// The real thing once she is signed in. Without a session there is nothing to
/// push to, and the mock keeps the offline demo working — but it must never be
/// what a real handset uses, because it throws the work away.
final syncServiceProvider = Provider<SyncService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return MockSyncService();
  return SupabaseSyncService(client);
});

final syncWorkerProvider = Provider<SyncWorker>(
  (ref) => SyncWorker(ref.watch(dbProvider), ref.watch(syncServiceProvider)),
);

/// Real device connectivity, folded into the mock service so the demo toggle
/// and genuine airplane mode behave identically.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  bool up(List<ConnectivityResult> r) =>
      r.isNotEmpty && !r.contains(ConnectivityResult.none);
  yield up(initial);
  yield* connectivity.onConnectivityChanged.map(up);
});

/// Rebuilt whenever the toggle flips so banners repaint immediately.
final offlineModeProvider = StateProvider<bool>((ref) => false);

final pendingCountProvider = StreamProvider<int>(
  (ref) => ref.watch(dbProvider).watchPendingCount(),
);

final outboxProvider = StreamProvider<List<OutboxData>>(
  (ref) => ref.watch(dbProvider).watchOutbox(),
);

// -------------------------------------------------------------------- data

final mothersProvider = StreamProvider<List<Mother>>(
  (ref) => ref.watch(dbProvider).watchMothers(),
);

final motherProvider = StreamProvider.family<Mother?, String>(
  (ref, id) => ref.watch(dbProvider).watchMother(id),
);

final visitsProvider = StreamProvider.family<List<AncVisit>, String>(
  (ref, motherId) => ref.watch(dbProvider).watchVisits(motherId),
);

final alertsProvider = StreamProvider.family<List<Alert>, String>(
  (ref, motherId) => ref.watch(dbProvider).watchAlerts(motherId),
);

final tasksProvider = StreamProvider.family<List<Task>, String>(
  (ref, status) => ref.watch(dbProvider).watchTasks(status),
);

final ocrServiceProvider =
    Provider<OcrService>((ref) => const MockOcrService());

// ------------------------------------------------------------ write paths

/// Every write goes through here: local row and outbox entry, one transaction,
/// no network call anywhere on the path.
class VisitRepository {
  VisitRepository(this._db);

  final AppDatabase _db;

  Future<String> saveVisit({
    required String motherId,
    required int visitNo,
    required String recordedBy,
    int? bpSys,
    int? bpDia,
    double? weightKg,
    double? fundalHeightCm,
    double? hb,
    String? urineAlbumin,
    int? fetalHr,
    bool? fetalMovement,
    List<String> dangerSigns = const [],
    bool ifaTaken = false,
    bool calciumTaken = false,
    int? ttDoseGiven,
    String? notes,
    double? gpsLat,
    double? gpsLng,
    List<String> photoPaths = const [],
    String? correctsId,
  }) async {
    final now = DateTime.now();
    final id = 'v-$motherId-${now.microsecondsSinceEpoch}';

    await _db.transaction(() async {
      await _db.into(_db.ancVisits).insert(
            AncVisitsCompanion.insert(
              id: id,
              motherId: motherId,
              visitNo: visitNo,
              visitDate: DateTime(now.year, now.month, now.day),
              bpSys: Value(bpSys),
              bpDia: Value(bpDia),
              weightKg: Value(weightKg),
              fundalHeightCm: Value(fundalHeightCm),
              hb: Value(hb),
              urineAlbumin: Value(urineAlbumin),
              fetalHr: Value(fetalHr),
              fetalMovement: Value(fetalMovement),
              dangerSigns: Value(jsonEncode(dangerSigns)),
              ifaTaken: Value(ifaTaken),
              calciumTaken: Value(calciumTaken),
              ttDoseGiven: Value(ttDoseGiven),
              notes: Value(notes),
              gpsLat: Value(gpsLat),
              gpsLng: Value(gpsLng),
              photoPaths: Value(jsonEncode(photoPaths)),
              recordedBy: recordedBy,
              clientCreatedAt: now,
              correctsId: Value(correctsId),
            ),
          );

      await _db.enqueue(
        entityTable: 'anc_visits',
        recordId: id,
        operation: 'insert',
        payload: payloadOf({
          'id': id,
          'mother_id': motherId,
          'visit_no': visitNo,
          'bp_sys': bpSys,
          'bp_dia': bpDia,
          'weight_kg': weightKg,
          'hb': hb,
          'danger_signs': dangerSigns,
          'client_created_at': now,
        }),
      );
    });

    return id;
  }

  Future<void> saveAlerts(
    String motherId,
    String? visitId,
    List<RiskAlert> alerts,
  ) async {
    if (alerts.isEmpty) return;
    final now = DateTime.now();
    await _db.transaction(() async {
      for (var i = 0; i < alerts.length; i++) {
        final a = alerts[i];
        final id = 'a-$motherId-${now.microsecondsSinceEpoch}-$i';
        await _db.into(_db.alerts).insert(
              AlertsCompanion.insert(
                id: id,
                motherId: motherId,
                ruleId: a.ruleId,
                severity: a.isRed ? 'red' : 'amber',
                messageKn: a.messageKn,
                messageEn: a.messageEn,
                visitId: Value(visitId),
                createdAt: now,
              ),
            );
        await _db.enqueue(
          entityTable: 'alerts',
          recordId: id,
          operation: 'insert',
          payload: payloadOf({
            'id': id,
            'mother_id': motherId,
            'rule_id': a.ruleId,
            'severity': a.isRed ? 'red' : 'amber',
            'created_at': now,
          }),
        );
      }
      await _db.setRiskLevel(motherId, RiskEngine.levelOf(alerts));
    });
  }

  Future<void> createReferral({
    required String motherId,
    required String facility,
    required String reasonKn,
    required String reasonEn,
    String? visitId,
  }) async {
    final now = DateTime.now();
    final id = 'r-$motherId-${now.microsecondsSinceEpoch}';
    await _db.transaction(() async {
      await _db.into(_db.referrals).insert(
            ReferralsCompanion.insert(
              id: id,
              motherId: motherId,
              toFacility: facility,
              reasonKn: reasonKn,
              reasonEn: reasonEn,
              visitId: Value(visitId),
              createdAt: now,
            ),
          );
      await _db.enqueue(
        entityTable: 'referrals',
        recordId: id,
        operation: 'insert',
        payload: payloadOf({
          'id': id,
          'mother_id': motherId,
          'to_facility': facility,
          'created_at': now,
        }),
      );
    });
  }

  Future<String> registerMother({
    required String name,
    required int age,
    required String village,
    required DateTime lmp,
    String? husbandName,
    String? phone,
    String? email,
    double? homeLat,
    double? homeLng,
    String? subCentre,
    String? abhaId,
    int gravida = 1,
    int para = 0,
    String? bloodGroup,
    double? heightCm,
    bool isBpl = false,
    List<String> prevComplications = const [],
    String riskLevel = 'green',
  }) async {
    final now = DateTime.now();
    final id = 'm-${now.microsecondsSinceEpoch}';
    await _db.transaction(() async {
      await _db.into(_db.mothers).insert(
            MothersCompanion.insert(
              id: id,
              name: name,
              age: age,
              husbandName: Value(husbandName),
              phone: Value(phone),
              email: Value(email),
              village: village,
              subCentre: Value(subCentre),
              abhaId: Value(abhaId),
              lmp: lmp,
              gravida: Value(gravida),
              para: Value(para),
              bloodGroup: Value(bloodGroup),
              heightCm: Value(heightCm),
              isBpl: Value(isBpl),
              prevComplications: Value(jsonEncode(prevComplications)),
              riskLevel: Value(riskLevel),
              createdAt: now,
              workerCreated: const Value(true),
            ),
          );
      await _db.enqueue(
        entityTable: 'mothers',
        recordId: id,
        operation: 'insert',
        // Everything the form collected goes up, not a subset. A field left
        // out here is a field the doctor never sees and the mother cannot be
        // matched on — her email in particular is what lets her sign in to
        // Thayi Setu at all.
        payload: payloadOf({
          'id': id,
          'name': name,
          'age': age,
          'village': village,
          'sub_centre': subCentre,
          'email': email,
          'phone': phone,
          'husband_name': husbandName,
          'abha_id': abhaId,
          'home_lat': homeLat,
          'home_lng': homeLng,
          'lmp': lmp,
          'gravida': gravida,
          'para': para,
          'blood_group': bloodGroup,
          'height_cm': heightCm,
          'is_bpl': isBpl,
          'risk_level': riskLevel,
          'prev_complications': prevComplications,
          'created_at': now,
        }),
      );
    });
    return id;
  }

  /// Pin or correct where she lives. Called from her profile when the first
  /// registration had no fix, or the pin turned out to be wrong.
  Future<void> setHomeLocation({
    required String motherId,
    required double lat,
    required double lng,
  }) async {
    await (_db.update(_db.mothers)..where((m) => m.id.equals(motherId))).write(
      MothersCompanion(
        homeLat: Value(lat),
        homeLng: Value(lng),
        homeLocatedAt: Value(DateTime.now()),
      ),
    );
    await _db.enqueue(
      entityTable: 'mothers',
      recordId: motherId,
      operation: 'update',
      payload: payloadOf({'id': motherId, 'home_lat': lat, 'home_lng': lng}),
    );
  }

  /// Records that her address has been proved to reach her.
  ///
  /// Written locally as well as queued, so the profile stops offering to
  /// verify the moment it succeeds — even if the outbox has not drained yet.
  Future<void> markEmailVerified(String motherId) async {
    await (_db.update(_db.mothers)..where((m) => m.id.equals(motherId)))
        .write(const MothersCompanion(emailVerified: Value(true)));
    await _db.enqueue(
      entityTable: 'mothers',
      recordId: motherId,
      operation: 'update',
      payload: payloadOf({'id': motherId, 'email_verified': true}),
    );
  }

  Future<void> closeTask(String taskId, {String? visitId}) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        status: const Value('done'),
        closedAt: Value(DateTime.now()),
        closedByVisitId: Value(visitId),
      ),
    );
    await _db.enqueue(
      entityTable: 'tasks',
      recordId: taskId,
      operation: 'update',
      payload: payloadOf({'id': taskId, 'status': 'done'}),
    );
  }
}

final visitRepositoryProvider =
    Provider<VisitRepository>((ref) => VisitRepository(ref.watch(dbProvider)));

// ----------------------------------------------------------------- helpers

int gestationWeeks(DateTime lmp, [DateTime? now]) {
  final n = now ?? DateTime.now();
  return (n.difference(lmp).inDays / 7).floor().clamp(0, 45);
}

int gestationDays(DateTime lmp, [DateTime? now]) {
  final n = now ?? DateTime.now();
  return n.difference(lmp).inDays.remainder(7).clamp(0, 6);
}

DateTime eddOf(DateTime lmp) => lmp.add(const Duration(days: 280));

List<String> decodeIds(String raw) {
  try {
    return (jsonDecode(raw) as List).cast<String>();
  } catch (_) {
    return const [];
  }
}
