import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'config/env.dart';
import 'data/care_api.dart';
import 'data/models.dart';
import 'data/supabase_care_api.dart';

final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('prefsProvider must be overridden'),
);

/// The swap point. With a real session the console reads the shared platform —
/// the same rows the ASHA app writes and the mother sees in Thayi. Without
/// one it falls back to demo data rather than showing an empty screen.
final apiProvider = Provider<CareApi>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final signedIn = ref.watch(authProvider) != null;
  // Watched, not read once. This used to sample currentSession at first build
  // and never look again, so a session that arrived a moment later — the
  // normal case on a cold start, because Supabase.initialize does not await
  // its own session recovery — left the console on demo data until the doctor
  // signed out and in again.
  ref.watch(authStateProvider);
  if (client != null && signedIn && client.auth.currentSession != null) {
    return SupabaseCareApi(
      client,
      // Resolved from her staff row when a write actually happens. It was the
      // literal MockData.doctorName, which meant an invented doctor's name was
      // written into clinical_notes.author_name and tasks.created_by in the
      // real database — and the ASHA receiving the task read that name as the
      // person who had asked her for the work.
      doctorName: () async => ref.read(staffProvider.future).then(
            (staff) =>
                staff?.name ?? client.auth.currentUser?.email ?? 'Medical officer',
          ),
    );
  }
  return MockCareApi();
});

/// Supabase's own view of whether anyone is signed in.
///
/// Nothing in this app listened to it before, so the console could not notice
/// a session arriving late or expiring mid-shift.
final authStateProvider = StreamProvider<sb.AuthState?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const Stream<sb.AuthState?>.empty();
  return client.auth.onAuthStateChange;
});

/// True when the console is serving demo data rather than the real caseload.
///
/// This has to be visible on screen. A sign-in that persisted locally but never
/// obtained a Supabase session lands on [MockCareApi], and its invented
/// mothers are indistinguishable from a real facility's — so the console looks
/// like it is working while showing a caseload that does not exist. A doctor
/// must never be left guessing which of the two she is reading.
final isDemoDataProvider =
    Provider<bool>((ref) => ref.watch(apiProvider) is! SupabaseCareApi);

/// The signed-in medical officer, as the database has her.
///
/// Her name, facility and phone used to be constants out of the demo data —
/// shown on her own profile screen, and worse, written into the record as the
/// author of every note and the origin of every task she assigned.
class StaffProfile {
  const StaffProfile({
    required this.name,
    required this.role,
    this.facility,
    this.phone,
  });

  final String name;
  final String role;
  final String? facility;
  final String? phone;
}

/// public.staff records a role, not a designation, so this says what the role
/// means rather than inventing a title she may not hold.
String designationOf(String? role) => switch (role) {
      'doctor' => 'Medical Officer',
      'asha' => 'ASHA worker',
      _ => '—',
    };

final staffProvider = FutureProvider<StaffProfile?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  ref.watch(authStateProvider);
  final user = client?.auth.currentUser;
  if (client == null || user == null) return null;
  try {
    final row = await client
        .from('staff')
        .select('name, role, facility, phone')
        .eq('auth_user_id', user.id)
        .maybeSingle();
    if (row == null) return null;
    final name = (row['name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;
    return StaffProfile(
      name: name,
      role: (row['role'] as String?) ?? 'doctor',
      facility: (row['facility'] as String?)?.trim(),
      phone: (row['phone'] as String?)?.trim(),
    );
  } catch (_) {
    // Offline. Nothing invented is better than somebody else's name.
    return null;
  }
});

/// Her facility. Null rather than a stand-in, so a screen shows a dash.
final facilityProvider = FutureProvider<String?>((ref) async {
  final staff = await ref.watch(staffProvider.future);
  return staff?.facility;
});

// -------------------------------------------------------------------- auth

/// A signed-in medical officer. Protected by construction: no session, no app.
class Session {
  const Session({required this.email});
  final String email;
}

/// Null when Supabase is switched off, unconfigured, or failed to initialise.
final supabaseClientProvider = Provider<sb.SupabaseClient?>((ref) {
  if (!Env.useSupabase || !Env.isSupabaseConfigured) return null;
  try {
    return sb.Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

class AuthController extends StateNotifier<Session?> {
  AuthController(this._prefs, this._client) : super(_read(_prefs));

  static const _key = 'care_session_email';
  final SharedPreferences _prefs;
  final sb.SupabaseClient? _client;

  static Session? _read(SharedPreferences prefs) {
    final email = prefs.getString(_key);
    return email == null ? null : Session(email: email);
  }

  /// Set when no code could be sent — provider disabled, or the clinic's
  /// connection is down. She then signs in locally rather than being locked
  /// out of records she can still read.
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
    try {
      await client.auth.signInWithOtp(
        email: email.trim(),
        // Never mint an account from this screen. Thayi and the admin portal
        // both pass this; Care did not, so any address typed here became a
        // signed-in user who could see nothing and was told nothing.
        shouldCreateUser: false,
      );
      _otpUnavailable = false;
    } catch (error) {
      if (_cannotSend(error)) {
        _otpUnavailable = true;
        debugPrint('OTP could not be sent; using local sign-in.');
        return;
      }
      rethrow;
    }
  }

  /// Verifies the code and opens a real Supabase session. Her staff row is
  /// what RLS then resolves her scope from — doctor sees the facility.
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    final client = _client;
    if (client == null || _otpUnavailable) {
      await _persist(email);
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
    await _persist(email.trim());
  }

  Future<void> _persist(String email) async {
    await _prefs.setString(_key, email);
    state = Session(email: email);
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
    await _prefs.remove(_key);
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthController, Session?>(
  (ref) => AuthController(
    ref.watch(prefsProvider),
    ref.watch(supabaseClientProvider),
  ),
);

// -------------------------------------------------------------------- data

final dashboardProvider = FutureProvider<DashboardSummary>(
  (ref) => ref.watch(apiProvider).getDashboard(),
);

final mothersProvider = FutureProvider<List<Mother>>(
  (ref) => ref.watch(apiProvider).getMothers(),
);

final motherProvider = FutureProvider.family<Mother?, String>(
  (ref, id) => ref.watch(apiProvider).getMother(id),
);

final visitsProvider = FutureProvider.family<List<AncVisit>, String>(
  (ref, motherId) => ref.watch(apiProvider).getVisits(motherId),
);

final labsProvider = FutureProvider.family<List<Lab>, String>(
  (ref, motherId) => ref.watch(apiProvider).getLabs(motherId),
);

final notesProvider = FutureProvider.family<List<ClinicalNote>, String>(
  (ref, motherId) => ref.watch(apiProvider).getNotes(motherId),
);

final motherTasksProvider = FutureProvider.family<List<Task>, String>(
  (ref, motherId) => ref.watch(apiProvider).getTasks(motherId: motherId),
);

final ashasProvider = FutureProvider<List<AshaWorker>>(
  (ref) => ref.watch(apiProvider).getAshas(),
);

final referralsProvider = FutureProvider<List<Referral>>(
  (ref) => ref.watch(apiProvider).getReferrals(),
);

// ----------------------------------------------------------------- consent

/// Where this doctor stands with a given mother: none, pending, approved,
/// rejected or expired. Mock mode has no gate, so it reports approved.
final accessStateProvider =
    FutureProvider.family<String, String>((ref, motherId) async {
  final api = ref.watch(apiProvider);
  if (api is! SupabaseCareApi) return 'approved';
  return api.accessState(motherId);
});

// ----------------------------------------------------- mothers list filters

@immutable
class MotherFilters {
  const MotherFilters({
    this.query = '',
    this.risk,
    this.village,
    this.ashaId,
    this.overdueOnly = false,
    this.sort = MotherSort.risk,
  });

  final String query;
  final RiskLevel? risk;
  final String? village;
  final String? ashaId;
  final bool overdueOnly;
  final MotherSort sort;

  MotherFilters copyWith({
    String? query,
    RiskLevel? risk,
    String? village,
    String? ashaId,
    bool? overdueOnly,
    MotherSort? sort,
    bool clearRisk = false,
    bool clearVillage = false,
    bool clearAsha = false,
  }) =>
      MotherFilters(
        query: query ?? this.query,
        risk: clearRisk ? null : (risk ?? this.risk),
        village: clearVillage ? null : (village ?? this.village),
        ashaId: clearAsha ? null : (ashaId ?? this.ashaId),
        overdueOnly: overdueOnly ?? this.overdueOnly,
        sort: sort ?? this.sort,
      );

  bool get isActive =>
      query.isNotEmpty ||
      risk != null ||
      village != null ||
      ashaId != null ||
      overdueOnly;
}

enum MotherSort { risk, name, gestation, lastVisit }

final motherFiltersProvider =
    StateProvider<MotherFilters>((ref) => const MotherFilters());

/// The filtered, sorted list the table renders.
final filteredMothersProvider = Provider<List<Mother>>((ref) {
  final all = ref.watch(mothersProvider).valueOrNull ?? const <Mother>[];
  final f = ref.watch(motherFiltersProvider);

  final q = f.query.trim().toLowerCase();
  var list = all.where((m) {
    if (q.isNotEmpty &&
        !m.name.toLowerCase().contains(q) &&
        !m.village.toLowerCase().contains(q) &&
        !m.ashaName.toLowerCase().contains(q)) {
      return false;
    }
    if (f.risk != null && m.riskLevel != f.risk) return false;
    if (f.village != null && m.village != f.village) return false;
    if (f.ashaId != null && m.ashaId != f.ashaId) return false;
    if (f.overdueOnly && !m.isOverdue) return false;
    return true;
  }).toList();

  list.sort((a, b) => switch (f.sort) {
        MotherSort.risk => b.riskLevel.index.compareTo(a.riskLevel.index),
        MotherSort.name => a.name.compareTo(b.name),
        MotherSort.gestation =>
          b.gestationalWeeks.compareTo(a.gestationalWeeks),
        MotherSort.lastVisit => (a.lastVisitDate ?? DateTime(2000))
            .compareTo(b.lastVisitDate ?? DateTime(2000)),
      });
  return list;
});
