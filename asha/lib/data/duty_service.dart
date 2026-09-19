import 'dart:async';
import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Why going on duty did not work, for the screen to put into words.
enum DutyProblem {
  /// GPS is off, refused, or gave nothing in the time allowed.
  noLocation,

  /// The server could not be reached at all. She is not on duty; nothing is
  /// queued, because a position sent later would be a position she has left.
  offline,

  /// The server answered and refused. Almost always that the duty functions
  /// have not been applied to this project yet, which is not the same thing as
  /// having no signal and must not be worded as though it were — being told
  /// "no signal" while the bars are full sends you looking in the wrong place.
  unavailable,

  /// Her login has no ASHA posting behind it, so there is no row to mark.
  noPosting,
}

class DutyState {
  const DutyState({
    this.onDuty = false,
    this.busy = false,
    this.until,
    this.problem,
  });

  final bool onDuty;
  final bool busy;
  final DateTime? until;
  final DutyProblem? problem;

  DutyState copyWith({
    bool? onDuty,
    bool? busy,
    DateTime? until,
    DutyProblem? problem,
    bool clearProblem = false,
  }) =>
      DutyState(
        onDuty: onDuty ?? this.onDuty,
        busy: busy ?? this.busy,
        until: until ?? this.until,
        problem: clearProblem ? null : (problem ?? this.problem),
      );
}

/// "I am working right now" — and the mothers around her can see it.
///
/// While she is on duty her phone reports where she is, and Thayi badges her
/// as available to any woman within 2 km. Off duty, the row is deleted and
/// nothing about her is reported at all.
///
/// Two rules shape everything here.
///
/// It is **never** queued through the outbox. Every other write in this app is
/// local-first and syncs later, because a visit recorded in a village with no
/// signal must survive. A position is the opposite: one replayed three hours
/// later says she is somewhere she left long ago, which is worse than saying
/// nothing. Failures are dropped on the floor by design.
///
/// And it reports on a **timer as well as on movement**. The position stream
/// only fires when she has moved 250 m — which is the right trade for a
/// battery, but it means an ASHA sitting in her sub-centre all morning would
/// emit nothing, go stale after fifteen minutes, and vanish from the list
/// while she was sitting there available. The heartbeat is what stops that.
class DutyService {
  DutyService(this._client);

  final SupabaseClient? _client;

  /// Comfortably inside the fifteen minutes the server treats as fresh.
  static const _heartbeat = Duration(minutes: 5);

  /// She has to have moved this far before a new fix is worth the battery.
  static const _movedMetres = 250;

  /// Renewed on every report, so it only runs out once her phone goes quiet.
  static const _shiftMinutes = 240;

  StreamSubscription<Position>? _stream;
  Timer? _timer;
  Position? _last;

  bool get isRunning => _stream != null || _timer != null;

  /// Whether the server still has her on duty. Asked at app open, because a
  /// restart must not silently drop her off the list — and because the server's
  /// clock is the one that decides, not a cheap handset's.
  Future<DateTime?> serverDutyUntil() async {
    final client = _client;
    if (client == null) return null;
    try {
      final until = await client
          .rpc('asha_my_duty')
          .timeout(const Duration(seconds: 6));
      return until == null ? null : DateTime.parse(until as String).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Best-effort fix, the same tolerant way a home visit is pinned.
  Future<Position?> _fix({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Reports a position and renews the shift. Throws only so [start] can tell
  /// a refusal from a dropped connection; the stream and timer swallow it.
  Future<DateTime?> _report(Position? at) async {
    final client = _client;
    if (client == null) throw const _Offline();
    try {
      final until = await client.rpc('asha_set_duty', params: {
        'p_on': true,
        'p_lat': at?.latitude,
        'p_lng': at?.longitude,
        'p_minutes': _shiftMinutes,
      }).timeout(const Duration(seconds: 8));
      return until == null ? null : DateTime.parse(until as String).toLocal();
    } on PostgrestException catch (e) {
      // The function raises when the login has no ASHA posting behind it.
      if (e.message.contains('no ASHA posting')) throw const _NoPosting();
      // Anything else here means the request arrived and the database said no
      // — a missing function, a permission. That is not a dead network.
      throw const _Unavailable();
    } on TimeoutException {
      throw const _Offline();
    } catch (_) {
      throw const _Offline();
    }
  }

  /// Goes on duty: one fix now, then movement and the heartbeat keep it fresh.
  ///
  /// Returns the problem to show her, or null when she is on.
  Future<({DutyProblem? problem, DateTime? until})> start() async {
    final at = await _fix();
    if (at == null) {
      return (problem: DutyProblem.noLocation, until: null);
    }

    final DateTime? until;
    try {
      until = await _report(at);
    } on _NoPosting {
      return (problem: DutyProblem.noPosting, until: null);
    } on _Unavailable {
      return (problem: DutyProblem.unavailable, until: null);
    } catch (_) {
      return (problem: DutyProblem.offline, until: null);
    }

    _last = at;
    await _arm();
    return (problem: null, until: until);
  }

  /// Per platform, because the two phones do this differently and a setting
  /// meant for one of them is not merely ignored by the other.
  ///
  /// Android runs a foreground service with a notification. The notification is
  /// not a formality: a woman broadcasting where she is should be able to see
  /// at a glance that she is doing it, and stop.
  ///
  /// iOS gets AppleSettings with background updates explicitly OFF. The default
  /// is on, and switching it on without the background-location entitlement —
  /// which this app deliberately does not ask for — throws at runtime the
  /// moment the stream starts. On iOS she is on duty while the app is open,
  /// and that is the whole of it.
  static LocationSettings _streamSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _movedMetres,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'ASHA Setu',
          notificationText: 'On duty — mothers nearby can see you are available',
          notificationChannelName: 'On duty',
          enableWakeLock: false,
          setOngoing: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _movedMetres,
        allowBackgroundLocationUpdates: false,
        showBackgroundLocationIndicator: false,
        pauseLocationUpdatesAutomatically: false,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: _movedMetres,
    );
  }

  Future<void> _arm() async {
    await _stream?.cancel();
    _timer?.cancel();

    _stream = Geolocator.getPositionStream(
      locationSettings: _streamSettings(),
    ).listen(
      (p) {
        _last = p;
        _report(p).catchError((_) => null);
      },
      onError: (_) {},
      cancelOnError: false,
    );

    _timer = Timer.periodic(_heartbeat, (_) async {
      final at = await _fix(timeout: const Duration(seconds: 8)) ?? _last;
      if (at != null) _last = at;
      await _report(at).catchError((_) => null);
    });
  }

  /// Goes off duty and deletes the row. Local state is cleared even when the
  /// server could not be told, so the switch never lies about what it did —
  /// the row expires on its own within the shift window either way.
  Future<bool> stop() async {
    await _stream?.cancel();
    _timer?.cancel();
    _stream = null;
    _timer = null;
    _last = null;

    final client = _client;
    if (client == null) return false;
    try {
      await client.rpc('asha_set_duty', params: {
        'p_on': false,
      }).timeout(const Duration(seconds: 8));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Re-arms the stream for a shift the server says is still running, without
  /// re-asking for a fix first.
  Future<void> resume() => _arm();

  void dispose() {
    _stream?.cancel();
    _timer?.cancel();
  }
}

class _Offline implements Exception {
  const _Offline();
}

class _NoPosting implements Exception {
  const _NoPosting();
}

class _Unavailable implements Exception {
  const _Unavailable();
}
