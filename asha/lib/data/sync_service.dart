import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../db/database.dart';

/// The contract the sync worker talks to. A Supabase implementation drops in
/// behind this later; no UI knows either exists.
abstract class SyncService {
  /// Whether the backend is reachable *right now*. Never awaited by the UI.
  bool get isOnline;

  /// Demo switch. The core demo is: force offline, record a visit, watch the
  /// alert fire anyway, go online, watch the outbox drain.
  set forceOffline(bool value);
  bool get forceOffline;

  /// Real device connectivity, folded in by whoever drains the queue.
  ///
  /// Only the mock used to have this, so with a real backend the app pushed
  /// into an aeroplane-moded handset, the socket failed, and every row was
  /// marked red and failed — a queue that was merely waiting for signal looked
  /// like a queue that had been rejected.
  set networkUp(bool value);

  /// Pushes one outbox row. Throws to signal a retryable failure.
  Future<void> push(OutboxData item);

  /// Reads the caseload down into [db]. Returns how many mothers it wrote.
  ///
  /// Without this the app is push-only: what a worker sees is whatever this
  /// handset happens to hold, which is not what the website shows and not what
  /// another phone would show.
  Future<int> pull(AppDatabase db);
}

class MockSyncService implements SyncService {
  MockSyncService({
    this.latency = const Duration(milliseconds: 600),
    this.failurePercent = 5,
  });

  final Duration latency;

  /// A small failure rate keeps the retry path honest in the app. Tests set
  /// it to 0 so they are not flaky.
  final int failurePercent;

  final _random = Random();

  bool _forceOffline = false;
  bool _networkUp = true;

  @override
  bool get forceOffline => _forceOffline;

  @override
  set forceOffline(bool value) => _forceOffline = value;

  @override
  set networkUp(bool value) => _networkUp = value;

  @override
  bool get isOnline => !_forceOffline && _networkUp;

  @override
  Future<void> push(OutboxData item) async {
    if (!isOnline) {
      throw const SyncFailure('offline');
    }
    await Future.delayed(latency);
    // The Sync Status screen exists precisely to answer "what happens when
    // this fails", so failures have to actually happen.
    if (failurePercent > 0 && _random.nextInt(100) < failurePercent) {
      throw const SyncFailure('server rejected the request');
    }
    debugPrint('synced ${item.entityTable}/${item.recordId}');
  }

  /// Nothing to read down: the mock has no server behind it.
  @override
  Future<int> pull(AppDatabase db) async => 0;
}

class SyncFailure implements Exception {
  const SyncFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Drains the outbox in the background. Nothing in the UI ever awaits this.
class SyncWorker {
  SyncWorker(this._db, this._service);

  final AppDatabase _db;
  final SyncService _service;

  bool _running = false;

  bool get isRunning => _running;

  /// Reads the server's copy of the caseload down.
  ///
  /// Shares [_running] with [drain] so a pull can never overwrite a row the
  /// drain is in the middle of pushing, or read a half-written one.
  Future<int> pull() async {
    if (_running) return 0;
    if (!_service.isOnline) return 0;
    _running = true;
    try {
      return await _service.pull(_db);
    } finally {
      _running = false;
    }
  }

  /// Returns the number of rows successfully pushed.
  Future<int> drain() async {
    if (_running) return 0;
    _running = true;
    var sent = 0;
    try {
      final pending = await _db.pendingOutbox();
      for (final item in pending) {
        if (!_service.isOnline) break;
        await _db.markOutbox(item.id, 'syncing');
        try {
          await _service.push(item);
          await _db.markOutbox(item.id, 'synced');
          await _markRecordSynced(item);
          sent++;
        } catch (error) {
          // A row the server actively refused is worth showing in red: only
          // she can fix it, and the message says how. A row that never
          // reached the server is not a failure — it is a row still waiting
          // for signal, and marking it failed spent a retry and told her
          // something untrue.
          if (_isTransport(error)) {
            await _db.markOutbox(item.id, 'pending', error: error.toString());
            break;
          }
          await _db.bumpRetry(item.id, error.toString());
        }
      }
    } finally {
      _running = false;
    }
    return sent;
  }

  static bool _isTransport(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('clientexception') ||
        text.contains('failed host lookup') ||
        text.contains('connection closed') ||
        text.contains('connection refused') ||
        text.contains('connection reset') ||
        text.contains('network is unreachable') ||
        text.contains('timed out') ||
        text.contains('offline');
  }

  Future<void> _markRecordSynced(OutboxData item) async {
    switch (item.entityTable) {
      case 'mothers':
        await (_db.update(_db.mothers)
              ..where((m) => m.id.equals(item.recordId)))
            .write(const MothersCompanion(synced: Value(true)));
      case 'anc_visits':
        await (_db.update(_db.ancVisits)
              ..where((v) => v.id.equals(item.recordId)))
            .write(const AncVisitsCompanion(synced: Value(true)));
    }
  }
}

/// Payload helper so every queued row is shaped the same way.
Map<String, dynamic> payloadOf(Map<String, dynamic> values) {
  return values.map((key, value) {
    if (value is DateTime) return MapEntry(key, value.toIso8601String());
    return MapEntry(key, value);
  });
}

String encodeList(List<String> items) => jsonEncode(items);

List<String> decodeList(String raw) {
  try {
    return (jsonDecode(raw) as List).cast<String>();
  } catch (_) {
    return const [];
  }
}
