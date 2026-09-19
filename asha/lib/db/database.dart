import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

// Column names here MUST match core/schema.sql and the doctor console. This is
// the one thing that has to stay identical across all three clients.

class Mothers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get husbandName => text().nullable()();
  TextColumn get phone => text().nullable()();

  /// How she signs in to Thayi Setu. Entered by the ASHA at registration;
  /// without it she cannot open her own record.
  TextColumn get email => text().nullable()();

  /// Proved to reach her, by sending the login code and having her read it
  /// back. An address typed at a doorstep and never tested is the quietest way
  /// for a mother to lose access to her own record.
  BoolColumn get emailVerified =>
      boolean().withDefault(const Constant(false))();

  /// Where she lives, pinned on the first home visit so the next visit —
  /// by anyone covering the sub-centre — can navigate straight there.
  RealColumn get homeLat => real().nullable()();
  RealColumn get homeLng => real().nullable()();
  TextColumn get homeNote => text().nullable()();
  DateTimeColumn get homeLocatedAt => dateTime().nullable()();
  TextColumn get village => text()();
  TextColumn get subCentre => text().nullable()();
  TextColumn get abhaId => text().nullable()();
  DateTimeColumn get lmp => dateTime()();
  IntColumn get gravida => integer().withDefault(const Constant(1))();
  IntColumn get para => integer().withDefault(const Constant(0))();
  TextColumn get bloodGroup => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  BoolColumn get isBpl => boolean().withDefault(const Constant(false))();

  /// JSON list of ids: cSection, stillbirth, pph, hypertension, gdm, anaemia.
  TextColumn get prevComplications =>
      text().withDefault(const Constant('[]'))();

  /// green | amber | red — the worst level currently known for her.
  TextColumn get riskLevel => text().withDefault(const Constant('green'))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  /// True when a worker entered her on this handset, false when she arrived in
  /// a pull from the server.
  ///
  /// This used to be inferred from the shape of the id by _isWorkerCreated,
  /// which reads the last '-' group and is wrong in both directions once
  /// pulled rows exist: a server uuid ending in twelve digits reads as
  /// worker-made, and every mother pulled down would be pushed straight back
  /// up, overwriting her name and posting with this phone's copy.
  BoolColumn get workerCreated => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// APPEND-ONLY. A correction is a new row whose [correctsId] points at the
/// original. Two devices writing offline can therefore never conflict, and the
/// audit trail comes for free. Never write an UPDATE against this table.
class AncVisits extends Table {
  TextColumn get id => text()();
  TextColumn get motherId => text().references(Mothers, #id)();
  IntColumn get visitNo => integer()();
  DateTimeColumn get visitDate => dateTime()();
  IntColumn get bpSys => integer().nullable()();
  IntColumn get bpDia => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get fundalHeightCm => real().nullable()();
  RealColumn get hb => real().nullable()();
  TextColumn get urineAlbumin => text().nullable()();
  IntColumn get fetalHr => integer().nullable()();
  BoolColumn get fetalMovement => boolean().nullable()();

  /// JSON list of danger sign ids.
  TextColumn get dangerSigns => text().withDefault(const Constant('[]'))();
  BoolColumn get ifaTaken => boolean().withDefault(const Constant(false))();
  BoolColumn get calciumTaken => boolean().withDefault(const Constant(false))();
  IntColumn get ttDoseGiven => integer().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get gpsLat => real().nullable()();
  RealColumn get gpsLng => real().nullable()();
  TextColumn get photoPaths => text().withDefault(const Constant('[]'))();
  TextColumn get recordedBy => text()();
  DateTimeColumn get clientCreatedAt => dateTime()();
  TextColumn get correctsId => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  /// Recorded on this handset rather than pulled down. See Mothers.
  BoolColumn get workerCreated => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get motherId => text().references(Mothers, #id)();

  /// ancVisit | followUp | referralFollowUp | labResult | counselling
  TextColumn get type => text()();
  TextColumn get instructionKn => text().nullable()();
  TextColumn get instructionEn => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();

  /// high | normal
  TextColumn get priority => text().withDefault(const Constant('normal'))();

  /// open | done | missed
  TextColumn get status => text().withDefault(const Constant('open'))();

  /// doctor | system | self — doctor-assigned work is the point of the product.
  TextColumn get origin => text().withDefault(const Constant('self'))();
  TextColumn get closedByVisitId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Alerts extends Table {
  TextColumn get id => text()();
  TextColumn get motherId => text().references(Mothers, #id)();
  TextColumn get ruleId => text()();

  /// red | amber
  TextColumn get severity => text()();
  TextColumn get messageKn => text()();
  TextColumn get messageEn => text()();
  TextColumn get visitId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get acknowledged => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Referrals extends Table {
  TextColumn get id => text()();
  TextColumn get motherId => text().references(Mothers, #id)();

  /// Who sent her. NOT NULL on the server with no default, and this column did
  /// not exist at all — so every referral was refused with 23502 and the
  /// facility never heard that a woman was on her way.
  TextColumn get fromUser => text().withDefault(const Constant(''))();
  TextColumn get toFacility => text()();
  TextColumn get reasonKn => text()();
  TextColumn get reasonEn => text()();

  /// open | arrived | closed — the server's own check constraint. It read
  /// `pending | accepted | completed` here, three values the database would
  /// have rejected had any of them ever been pushed.
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get visitId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Every local write also lands here. The sync worker drains it when online.
class Outbox extends Table {
  TextColumn get id => text()();
  // Named explicitly: `tableName` is taken by Drift's own Table.tableName.
  TextColumn get entityTable => text().named('table_name')();
  TextColumn get recordId => text()();

  /// insert | update
  TextColumn get operation => text()();
  TextColumn get payload => text()();

  /// pending | syncing | synced | failed
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Mothers, AncVisits, Tasks, Alerts, Referrals, Outbox],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  /// Without this, every phone that already has the database would crash on
  /// "no such column: email" — a fresh install would look fine and every real
  /// device would not.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.addColumn(mothers, mothers.email);
          if (from < 3) {
            await m.addColumn(mothers, mothers.homeLat);
            await m.addColumn(mothers, mothers.homeLng);
            await m.addColumn(mothers, mothers.homeNote);
            await m.addColumn(mothers, mothers.homeLocatedAt);
          }
          if (from < 4) {
            await m.addColumn(mothers, mothers.emailVerified);
          }
          if (from < 6) {
            await m.addColumn(referrals, referrals.fromUser);
            // 'pending' is not a value the server's check constraint allows.
            await customStatement(
                "update referrals set status = 'open' where status = 'pending'");
          }
          if (from < 5) {
            await m.addColumn(mothers, mothers.workerCreated);
            await m.addColumn(ancVisits, ancVisits.workerCreated);
            // Backfilled by purgePracticeCaseload, which runs at startup: once
            // the invented caseload is gone, everything still here was entered
            // on this phone. Doing it that way round means the flag never
            // depends on the id-shape guess it exists to replace.
          }
        },
      );

  // ------------------------------------------------------------- mothers

  Stream<List<Mother>> watchMothers() =>
      (select(mothers)..orderBy([(m) => OrderingTerm(expression: m.name)]))
          .watch();

  Future<List<Mother>> allMothers() => select(mothers).get();

  Stream<Mother?> watchMother(String id) =>
      (select(mothers)..where((m) => m.id.equals(id))).watchSingleOrNull();

  Future<Mother?> findMother(String id) =>
      (select(mothers)..where((m) => m.id.equals(id))).getSingleOrNull();

  Stream<List<Mother>> watchHighRisk() => (select(mothers)
        ..where((m) => m.riskLevel.isIn(['red', 'amber']))
        ..orderBy([(m) => OrderingTerm(expression: m.riskLevel)]))
      .watch();

  Future<void> setRiskLevel(String motherId, String level) =>
      (update(mothers)..where((m) => m.id.equals(motherId)))
          .write(MothersCompanion(riskLevel: Value(level)));

  // -------------------------------------------------------------- visits

  /// Latest first. Superseded rows (those corrected by a later row) are
  /// filtered out by [effectiveVisits].
  Stream<List<AncVisit>> watchVisits(String motherId) => (select(ancVisits)
        ..where((v) => v.motherId.equals(motherId))
        ..orderBy([
          (v) => OrderingTerm(expression: v.visitDate, mode: OrderingMode.desc),
        ]))
      .watch();

  Future<List<AncVisit>> visitsFor(String motherId) => (select(ancVisits)
        ..where((v) => v.motherId.equals(motherId))
        ..orderBy([(v) => OrderingTerm(expression: v.visitDate)]))
      .get();

  Future<AncVisit?> lastVisit(String motherId) async {
    final rows = await (select(ancVisits)
          ..where((v) => v.motherId.equals(motherId))
          ..orderBy([
            (v) =>
                OrderingTerm(expression: v.visitDate, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  // --------------------------------------------------------------- tasks

  Stream<List<Task>> watchTasks(String status) => (select(tasks)
        ..where((t) => t.status.equals(status))
        ..orderBy([
          // Doctor-assigned work sorts first — it is the point of the product.
          (t) => OrderingTerm(expression: t.origin),
          (t) => OrderingTerm(expression: t.dueDate),
        ]))
      .watch();

  Future<List<Task>> openTasksFor(String motherId) => (select(tasks)
        ..where((t) => t.motherId.equals(motherId) & t.status.equals('open')))
      .get();

  // -------------------------------------------------------------- alerts

  Stream<List<Alert>> watchAlerts(String motherId) => (select(alerts)
        ..where((a) => a.motherId.equals(motherId))
        ..orderBy([
          (a) => OrderingTerm(expression: a.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();

  // -------------------------------------------------------------- outbox

  Stream<List<OutboxData>> watchOutbox() => (select(outbox)
        ..orderBy([
          (o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();

  Stream<int> watchPendingCount() {
    final count = outbox.id.count();
    final query = selectOnly(outbox)
      ..addColumns([count])
      ..where(outbox.status.isIn(['pending', 'failed']));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Future<List<OutboxData>> pendingOutbox() => (select(outbox)
        ..where((o) => o.status.isIn(['pending', 'failed']))
        ..orderBy([(o) => OrderingTerm(expression: o.createdAt)]))
      .get();

  /// Re-queues every mother and visit held on this phone.
  ///
  /// Needed because a row can be marked synced without ever having reached the
  /// server: the sync service used to be a stub that slept and returned
  /// success, so the worker duly marked those rows done. They are invisible to
  /// [pendingOutbox] forever after, and nothing reports a failure because
  /// nothing failed — the record is simply stranded on the handset.
  ///
  /// Safe to run at any time. Every push is an upsert keyed on a uuid derived
  /// from the local id, so re-sending a row that is already up there writes the
  /// same values to the same row rather than duplicating her.
  /// A row this handset's worker actually created, rather than one the app
  /// seeded itself with at first run.
  ///
  /// The seeded caseload uses short ids (`m-001`), and the demo dataset on the
  /// server uses exactly the same ones — so pushing a seeded row writes it over
  /// a different, real woman with the same id. That is how a set of flat
  /// practice readings ended up interleaved with Lakshmi's rising blood
  /// pressure. Anything the worker enters is stamped with microseconds
  /// (`m-1755400000000000`), which is what tells the two apart.
  @visibleForTesting
  static bool isWorkerCreatedForTest(String id) => _isWorkerCreated(id);

  static bool _isWorkerCreated(String id) {
    final digits = id.split('-').last;
    return digits.length > 8 && int.tryParse(digits) != null;
  }

  Future<int> requeueEverything() async {
    // Re-sending is for rows this handset owns. It used to ask
    // _isWorkerCreated, which reads the last '-' group of an id: that is right
    // for 'm-001' versus 'm-1755400000000000' and wrong for everything else —
    // roughly one server uuid in 300 ends in twelve digits and would be pushed
    // back over the server's own copy, and a visit against practice mother
    // m-003 ('v-m-003-<micros>') read as worker-made and was re-sent.
    final allMothers =
        (await select(mothers).get()).where((m) => m.workerCreated).toList();
    final allVisits =
        (await select(ancVisits).get()).where((v) => v.workerCreated).toList();

    for (final m in allMothers) {
      await requeue(
        entityTable: 'mothers',
        recordId: m.id,
        operation: 'insert',
        payload: {
          'id': m.id,
          'name': m.name,
          'age': m.age,
          'village': m.village,
          'sub_centre': m.subCentre,
          'email': m.email,
          'email_verified': m.emailVerified,
          'phone': m.phone,
          'husband_name': m.husbandName,
          'abha_id': m.abhaId,
          'home_lat': m.homeLat,
          'home_lng': m.homeLng,
          'home_note': m.homeNote,
          'home_located_at': m.homeLocatedAt?.toIso8601String(),
          'lmp': m.lmp.toIso8601String(),
          'gravida': m.gravida,
          'para': m.para,
          'blood_group': m.bloodGroup,
          'height_cm': m.heightCm,
          'is_bpl': m.isBpl,
          'risk_level': m.riskLevel,
          'prev_complications': _decodeIds(m.prevComplications),
          'created_at': m.createdAt.toIso8601String(),
        },
      );
    }

    for (final v in allVisits) {
      await requeue(
        entityTable: 'anc_visits',
        recordId: v.id,
        operation: 'insert',
        payload: {
          'id': v.id,
          'mother_id': v.motherId,
          'visit_no': v.visitNo,
          'visit_date': v.visitDate.toIso8601String(),
          'bp_sys': v.bpSys,
          'bp_dia': v.bpDia,
          'weight_kg': v.weightKg,
          'hb': v.hb,
          'danger_signs': _decodeIds(v.dangerSigns),
          'fundal_height_cm': v.fundalHeightCm,
          'fetal_hr': v.fetalHr,
          'fetal_movement': v.fetalMovement,
          'urine_albumin': v.urineAlbumin,
          'ifa_taken': v.ifaTaken,
          'calcium_taken': v.calciumTaken,
          'tt_dose_given': v.ttDoseGiven,
          'notes': v.notes,
          'gps_lat': v.gpsLat,
          'gps_lng': v.gpsLng,
          'photo_paths': _decodeIds(v.photoPaths),
          'recorded_by': v.recordedBy,
          'corrects_id': v.correctsId,
          // The key _pushVisit reads is client_created_at, and the column is
          // NOT NULL. Queuing it as 'created_at' meant the push found nothing,
          // sent an explicit null, and every re-sent visit was refused with
          // 23502 — so "Send everything again", the one button whose whole job
          // is to rescue stranded rows, could never rescue a visit.
          'client_created_at': v.clientCreatedAt.toIso8601String(),
        },
      );
    }

    return allMothers.length + allVisits.length;
  }

  /// prevComplications is stored as a JSON string locally and is a text[] on
  /// the server, so the queued payload has to carry a real list.
  static List<String> _decodeIds(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      // A row written before the column held JSON. Nothing to send.
    }
    return const [];
  }

  /// Record ids with something still queued for them.
  ///
  /// A pull must leave these alone: what is queued here has by definition not
  /// reached the server, so the server's copy is the older one and writing it
  /// over the local row would silently discard what the worker just entered.
  Future<Set<String>> unsentRecordIds() async {
    final rows = await (select(outbox)
          ..where((o) => o.status.equals('synced').not()))
        .get();
    return rows.map((o) => o.recordId).toSet();
  }

  /// A row from the invented practice caseload this app used to write into
  /// every handset the first time it ran.
  ///
  /// The seed mints exactly three id shapes: mothers `m-001`..`m-020`, visits
  /// `m-001-v1`, and tasks `task-001`..`task-007`. It never wrote alerts,
  /// referrals or outbox rows — those only ever appear when a worker does
  /// something, including doing it to a practice mother.
  static final _seededMother = RegExp(r'^m-\d{3}$');
  static final _seededTask = RegExp(r'^task-\d{3}$');

  /// Deletes the practice caseload, and only it.
  ///
  /// Every predicate here keys on the MOTHER a row belongs to, never on the
  /// row's own id. _isWorkerCreated reads the last '-' group and is wrong in
  /// both directions for the child tables: an alert id ends in its index
  /// (`a-<mother>-<micros>-0`), so a real red alert reads as seeded and would
  /// be thrown away; and a visit recorded against practice mother m-003 is
  /// `v-m-003-<micros>`, which reads as worker-made and would be pushed —
  /// landing four flat practice readings in the middle of whichever real woman
  /// holds that id on the server. That has already happened to this project
  /// once, to Lakshmi's blood pressure trend.
  ///
  /// Anything the worker entered against a real mother survives untouched.
  Future<int> purgePracticeCaseload() async {
    return transaction(() async {
      final seededMothers = (await select(mothers).get())
          .map((m) => m.id)
          .where(_seededMother.hasMatch)
          .toSet();
      final seededTasks = (await select(tasks).get())
          .where((t) => _seededTask.hasMatch(t.id))
          .map((t) => t.id)
          .toSet();
      if (seededMothers.isEmpty && seededTasks.isEmpty) return 0;

      final deadVisits = (await select(ancVisits).get())
          .where((v) => seededMothers.contains(v.motherId))
          .map((v) => v.id)
          .toSet();
      final deadAlerts = (await select(alerts).get())
          .where((a) => seededMothers.contains(a.motherId))
          .map((a) => a.id)
          .toSet();
      final deadReferrals = (await select(referrals).get())
          .where((r) => seededMothers.contains(r.motherId))
          .map((r) => r.id)
          .toSet();
      final deadTasks = (await select(tasks).get())
          .where((t) =>
              _seededTask.hasMatch(t.id) || seededMothers.contains(t.motherId))
          .map((t) => t.id)
          .toSet();

      // Children first: the foreign keys point at mothers, and a handset that
      // later turns enforcement on would otherwise be holding orphans.
      await (delete(ancVisits)..where((v) => v.id.isIn(deadVisits.toList())))
          .go();
      await (delete(alerts)..where((a) => a.id.isIn(deadAlerts.toList()))).go();
      await (delete(referrals)
            ..where((r) => r.id.isIn(deadReferrals.toList())))
          .go();
      await (delete(tasks)..where((t) => t.id.isIn(deadTasks.toList()))).go();
      await (delete(mothers)
            ..where((m) => m.id.isIn(seededMothers.toList())))
          .go();

      // Anything queued for a row that no longer exists would be pushed to the
      // server on the next drain, which is the whole thing this is preventing.
      final orphaned = <String>{
        ...seededMothers,
        ...deadVisits,
        ...deadAlerts,
        ...deadReferrals,
        ...deadTasks,
      };
      await (delete(outbox)..where((o) => o.recordId.isIn(orphaned.toList())))
          .go();

      // Backfill the provenance flag for rows that predate it.
      //
      // Scoped to ids that are not server uuids, and NOT written blanket over
      // the table: this runs on every start, and a blanket write would relabel
      // every mother pulled down from the server as this handset's own the
      // next morning — and requeueEverything would then push all of them back
      // over the server's copies. Only three id shapes reach this point:
      // 'm-001' (just deleted), 'm-<microseconds>' (entered here), and a uuid
      // (pulled). A uuid is the only one with four hyphens.
      await (update(mothers)..where((m) => m.id.like('%-%-%-%-%').not()))
          .write(const MothersCompanion(workerCreated: Value(true)));
      await (update(ancVisits)..where((v) => v.motherId.like('%-%-%-%-%').not()))
          .write(const AncVisitsCompanion(workerCreated: Value(true)));

      return seededMothers.length;
    });
  }

  /// Queues a record again without leaving a second entry for it behind.
  ///
  /// [enqueue] mints a fresh outbox id on every call
  /// (`ob-<recordId>-<microseconds>`). That is right for a genuinely new
  /// change and wrong for a re-send: "Send everything again" called it for
  /// every mother and visit on the phone, so each press appended another
  /// identical row, and the Sync Status screen grew a whole extra copy of the
  /// caseload each time. Nothing was duplicated on the server — every push is
  /// an upsert keyed on a uuid derived from the local id — but the one screen
  /// whose job is to tell her what has not been sent became unreadable, which
  /// looks from the outside exactly like the data itself being duplicated.
  ///
  /// Collapsing to one row is also what the payload means: it carries the
  /// whole of what this handset holds for the record, not a delta, so any
  /// entry still queued for it is already superseded.
  Future<void> requeue({
    required String entityTable,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await transaction(() async {
      // A row mid-flight is left alone: the worker is holding its id and will
      // write a result against it.
      final existing = await (select(outbox)
            ..where((o) =>
                o.entityTable.equals(entityTable) &
                o.recordId.equals(recordId) &
                o.status.equals('syncing').not())
            ..orderBy([(o) => OrderingTerm(expression: o.createdAt)]))
          .get();

      if (existing.isEmpty) {
        await enqueue(
          entityTable: entityTable,
          recordId: recordId,
          operation: operation,
          payload: payload,
        );
        return;
      }

      // Keep the oldest so its place in the queue is kept, and clear out the
      // copies earlier presses left behind.
      if (existing.length > 1) {
        final stale = existing.skip(1).map((e) => e.id).toList();
        await (delete(outbox)..where((o) => o.id.isIn(stale))).go();
      }

      await (update(outbox)..where((o) => o.id.equals(existing.first.id)))
          .write(
        OutboxCompanion(
          operation: Value(operation),
          payload: Value(jsonEncode(payload)),
          status: const Value('pending'),
          retryCount: const Value(0),
          lastError: const Value(null),
          syncedAt: const Value(null),
        ),
      );
    });
  }

  /// The only way anything gets written. Local row and outbox entry go in one
  /// transaction, so a queued change can never be lost or half-written.
  Future<void> enqueue({
    required String entityTable,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) {
    return into(outbox).insert(
      OutboxCompanion.insert(
        id: 'ob-$recordId-${DateTime.now().microsecondsSinceEpoch}',
        entityTable: entityTable,
        recordId: recordId,
        operation: operation,
        payload: jsonEncode(payload),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> markOutbox(String id, String status, {String? error}) =>
      (update(outbox)..where((o) => o.id.equals(id))).write(
        OutboxCompanion(
          status: Value(status),
          lastError: Value(error),
          syncedAt: Value(status == 'synced' ? DateTime.now() : null),
        ),
      );

  Future<void> bumpRetry(String id, String error) async {
    final row =
        await (select(outbox)..where((o) => o.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (update(outbox)..where((o) => o.id.equals(id))).write(
      OutboxCompanion(
        status: const Value('failed'),
        retryCount: Value(row.retryCount + 1),
        lastError: Value(error),
      ),
    );
  }
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'setu_asha.sqlite'));
    // Needed on older Android for a working, up-to-date SQLite.
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    return NativeDatabase.createInBackground(file);
  });
}
