import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:setu_care/data/supabase_care_api.dart';

/// Whose name ends up on a real clinical record.
///
/// A medical officer's name was already found written into clinical_notes and
/// tasks as the literal MockData.doctorName — an invented doctor credited with
/// work a real one did. The prescription upload kept doing it after the other
/// two were fixed, because the name arrived as a parameter and the only caller
/// passed the constant. These tests are the guard on that, and on the quieter
/// version of the same fault: a stand-in remembered for the rest of a session.
void main() {
  /// Nothing reaches the network; the write fails on connect, which is after
  /// the author has already been resolved.
  SupabaseCareApi apiWith(Future<String?> Function() name) => SupabaseCareApi(
        SupabaseClient('http://127.0.0.1:1', 'anon-key-for-tests'),
        doctorName: name,
      );

  Future<void> attemptNote(SupabaseCareApi api) async {
    try {
      await api.addNote(motherId: 'm-1', body: 'test');
    } catch (_) {
      // Expected: there is no server here.
    }
  }

  group('record authorship', () {
    test('her real name is resolved once and kept', () async {
      var calls = 0;
      final api = apiWith(() async {
        calls++;
        return 'Dr. Anitha K';
      });
      await attemptNote(api);
      await attemptNote(api);
      expect(calls, 1, reason: 'a resolved name need not be fetched again');
    });

    test('a stand-in is never remembered', () async {
      var calls = 0;
      final api = apiWith(() async {
        calls++;
        return null; // Her staff row could not be read this time.
      });
      await attemptNote(api);
      await attemptNote(api);
      expect(
        calls, 2,
        reason: 'caching the fallback made one moment offline the permanent '
            'author of every note and task for the rest of the session',
      );
    });
  });

  group('no invented doctor reaches the database', () {
    /// The mock API is allowed to use the demo name — it never writes to the
    /// platform. Everything else that can reach Supabase is not.
    const mockOnly = {
      'lib/data/mock_data.dart',
      'lib/data/care_api.dart',
      'lib/data/demo_dataset.dart',
    };

    test('no server writer carries MockData.doctorName', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final path = entity.path;
        if (mockOnly.contains(path)) continue;
        // Comments explain why this must not happen; only code counts.
        final code = entity
            .readAsLinesSync()
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        if (code.contains('MockData.doctorName')) offenders.add(path);
      }
      expect(
        offenders, isEmpty,
        reason: 'these write a demo constant into a real record: $offenders',
      );
    });
  });
}
