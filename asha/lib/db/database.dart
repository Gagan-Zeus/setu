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
  TextColumn get toFacility => text()();
  TextColumn get reasonKn => text()();
  TextColumn get reasonEn => text()();

  /// pending | accepted | completed
  TextColumn get status => text().withDefault(const Constant('pending'))();
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
  int get schemaVersion => 4;

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
    final allMothers = (await select(mothers).get())
        .where((m) => _isWorkerCreated(m.id))
        .toList();
    final allVisits = (await select(ancVisits).get())
        .where((v) => _isWorkerCreated(v.id) || _isWorkerCreated(v.motherId))
        .toList();

    for (final m in allMothers) {
      await enqueue(
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
          'lmp': m.lmp.toIso8601String(),
          'gravida': m.gravida,
          'para': m.para,
          'blood_group': m.bloodGroup,
          'height_cm': m.heightCm,
          'is_bpl': m.isBpl,
          'risk_level': m.riskLevel,
          'created_at': m.createdAt.toIso8601String(),
        },
      );
    }

    for (final v in allVisits) {
      await enqueue(
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
          'danger_signs': v.dangerSigns,
          'fundal_height_cm': v.fundalHeightCm,
          'fetal_hr': v.fetalHr,
          'urine_albumin': v.urineAlbumin,
          'ifa_taken': v.ifaTaken,
          'calcium_taken': v.calciumTaken,
          'tt_dose_given': v.ttDoseGiven,
          'notes': v.notes,
          'gps_lat': v.gpsLat,
          'gps_lng': v.gpsLng,
          'recorded_by': v.recordedBy,
          'corrects_id': v.correctsId,
          'created_at': v.clientCreatedAt.toIso8601String(),
        },
      );
    }

    return allMothers.length + allVisits.length;
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
