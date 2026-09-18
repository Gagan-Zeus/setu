import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/data/supabase_sync_service.dart';

/// Local rows are keyed on text ids the handset invents (`m-1755364…`) while
/// Supabase keys on uuid. The mapping between them has to be a pure function of
/// the local id, because sync runs on a connection that drops mid-request: a
/// push that succeeded server-side but lost its reply will be retried, and if
/// the id came out different the second time the mother would be registered
/// twice.
void main() {
  test('the same local id always maps to the same uuid', () {
    const local = 'm-1755364512345678';
    final first = SupabaseSyncService.uuidFor(local);
    final second = SupabaseSyncService.uuidFor(local);
    expect(first, second);
    expect(
      first,
      matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-'
          r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
      reason: 'must be a well-formed v5 uuid',
    );
  });

  test('different local ids do not collide', () {
    final ids = {
      for (var i = 0; i < 500; i++)
        SupabaseSyncService.uuidFor('m-17553645123456$i'),
    };
    expect(ids, hasLength(500));
  });

  test('an id that is already a uuid passes through untouched', () {
    // Rows that came down from the server keep their key; re-mapping one would
    // turn an update into a brand new row.
    const existing = 'e7879569-8164-593b-87c2-ec2e4bd4d92a';
    expect(SupabaseSyncService.uuidFor(existing), existing);
  });

  test('the mapping is stable across records of different kinds', () {
    // Visits, alerts and referrals all go through the same function, so a
    // visit's mother_id must resolve to exactly the mother's own id.
    const motherLocal = 'm-1755364512345678';
    expect(
      SupabaseSyncService.uuidFor(motherLocal),
      SupabaseSyncService.uuidFor(motherLocal),
    );
    expect(
      SupabaseSyncService.uuidFor('v-$motherLocal-1'),
      isNot(SupabaseSyncService.uuidFor(motherLocal)),
    );
  });
}
