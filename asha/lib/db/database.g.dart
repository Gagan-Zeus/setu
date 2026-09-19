// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MothersTable extends Mothers with TableInfo<$MothersTable, Mother> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MothersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _husbandNameMeta =
      const VerificationMeta('husbandName');
  @override
  late final GeneratedColumn<String> husbandName = GeneratedColumn<String>(
      'husband_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailVerifiedMeta =
      const VerificationMeta('emailVerified');
  @override
  late final GeneratedColumn<bool> emailVerified = GeneratedColumn<bool>(
      'email_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("email_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _homeLatMeta =
      const VerificationMeta('homeLat');
  @override
  late final GeneratedColumn<double> homeLat = GeneratedColumn<double>(
      'home_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _homeLngMeta =
      const VerificationMeta('homeLng');
  @override
  late final GeneratedColumn<double> homeLng = GeneratedColumn<double>(
      'home_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _homeNoteMeta =
      const VerificationMeta('homeNote');
  @override
  late final GeneratedColumn<String> homeNote = GeneratedColumn<String>(
      'home_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _homeLocatedAtMeta =
      const VerificationMeta('homeLocatedAt');
  @override
  late final GeneratedColumn<DateTime> homeLocatedAt =
      GeneratedColumn<DateTime>('home_located_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _villageMeta =
      const VerificationMeta('village');
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
      'village', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subCentreMeta =
      const VerificationMeta('subCentre');
  @override
  late final GeneratedColumn<String> subCentre = GeneratedColumn<String>(
      'sub_centre', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _abhaIdMeta = const VerificationMeta('abhaId');
  @override
  late final GeneratedColumn<String> abhaId = GeneratedColumn<String>(
      'abha_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lmpMeta = const VerificationMeta('lmp');
  @override
  late final GeneratedColumn<DateTime> lmp = GeneratedColumn<DateTime>(
      'lmp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _gravidaMeta =
      const VerificationMeta('gravida');
  @override
  late final GeneratedColumn<int> gravida = GeneratedColumn<int>(
      'gravida', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _paraMeta = const VerificationMeta('para');
  @override
  late final GeneratedColumn<int> para = GeneratedColumn<int>(
      'para', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bloodGroupMeta =
      const VerificationMeta('bloodGroup');
  @override
  late final GeneratedColumn<String> bloodGroup = GeneratedColumn<String>(
      'blood_group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isBplMeta = const VerificationMeta('isBpl');
  @override
  late final GeneratedColumn<bool> isBpl = GeneratedColumn<bool>(
      'is_bpl', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_bpl" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _prevComplicationsMeta =
      const VerificationMeta('prevComplications');
  @override
  late final GeneratedColumn<String> prevComplications =
      GeneratedColumn<String>('prev_complications', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _riskLevelMeta =
      const VerificationMeta('riskLevel');
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
      'risk_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('green'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _workerCreatedMeta =
      const VerificationMeta('workerCreated');
  @override
  late final GeneratedColumn<bool> workerCreated = GeneratedColumn<bool>(
      'worker_created', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("worker_created" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        age,
        husbandName,
        phone,
        email,
        emailVerified,
        homeLat,
        homeLng,
        homeNote,
        homeLocatedAt,
        village,
        subCentre,
        abhaId,
        lmp,
        gravida,
        para,
        bloodGroup,
        heightCm,
        isBpl,
        prevComplications,
        riskLevel,
        createdAt,
        synced,
        workerCreated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mothers';
  @override
  VerificationContext validateIntegrity(Insertable<Mother> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('husband_name')) {
      context.handle(
          _husbandNameMeta,
          husbandName.isAcceptableOrUnknown(
              data['husband_name']!, _husbandNameMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('email_verified')) {
      context.handle(
          _emailVerifiedMeta,
          emailVerified.isAcceptableOrUnknown(
              data['email_verified']!, _emailVerifiedMeta));
    }
    if (data.containsKey('home_lat')) {
      context.handle(_homeLatMeta,
          homeLat.isAcceptableOrUnknown(data['home_lat']!, _homeLatMeta));
    }
    if (data.containsKey('home_lng')) {
      context.handle(_homeLngMeta,
          homeLng.isAcceptableOrUnknown(data['home_lng']!, _homeLngMeta));
    }
    if (data.containsKey('home_note')) {
      context.handle(_homeNoteMeta,
          homeNote.isAcceptableOrUnknown(data['home_note']!, _homeNoteMeta));
    }
    if (data.containsKey('home_located_at')) {
      context.handle(
          _homeLocatedAtMeta,
          homeLocatedAt.isAcceptableOrUnknown(
              data['home_located_at']!, _homeLocatedAtMeta));
    }
    if (data.containsKey('village')) {
      context.handle(_villageMeta,
          village.isAcceptableOrUnknown(data['village']!, _villageMeta));
    } else if (isInserting) {
      context.missing(_villageMeta);
    }
    if (data.containsKey('sub_centre')) {
      context.handle(_subCentreMeta,
          subCentre.isAcceptableOrUnknown(data['sub_centre']!, _subCentreMeta));
    }
    if (data.containsKey('abha_id')) {
      context.handle(_abhaIdMeta,
          abhaId.isAcceptableOrUnknown(data['abha_id']!, _abhaIdMeta));
    }
    if (data.containsKey('lmp')) {
      context.handle(
          _lmpMeta, lmp.isAcceptableOrUnknown(data['lmp']!, _lmpMeta));
    } else if (isInserting) {
      context.missing(_lmpMeta);
    }
    if (data.containsKey('gravida')) {
      context.handle(_gravidaMeta,
          gravida.isAcceptableOrUnknown(data['gravida']!, _gravidaMeta));
    }
    if (data.containsKey('para')) {
      context.handle(
          _paraMeta, para.isAcceptableOrUnknown(data['para']!, _paraMeta));
    }
    if (data.containsKey('blood_group')) {
      context.handle(
          _bloodGroupMeta,
          bloodGroup.isAcceptableOrUnknown(
              data['blood_group']!, _bloodGroupMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('is_bpl')) {
      context.handle(
          _isBplMeta, isBpl.isAcceptableOrUnknown(data['is_bpl']!, _isBplMeta));
    }
    if (data.containsKey('prev_complications')) {
      context.handle(
          _prevComplicationsMeta,
          prevComplications.isAcceptableOrUnknown(
              data['prev_complications']!, _prevComplicationsMeta));
    }
    if (data.containsKey('risk_level')) {
      context.handle(_riskLevelMeta,
          riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('worker_created')) {
      context.handle(
          _workerCreatedMeta,
          workerCreated.isAcceptableOrUnknown(
              data['worker_created']!, _workerCreatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mother map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mother(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age'])!,
      husbandName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}husband_name']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      emailVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}email_verified'])!,
      homeLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}home_lat']),
      homeLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}home_lng']),
      homeNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}home_note']),
      homeLocatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}home_located_at']),
      village: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}village'])!,
      subCentre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_centre']),
      abhaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}abha_id']),
      lmp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}lmp'])!,
      gravida: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gravida'])!,
      para: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}para'])!,
      bloodGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}blood_group']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      isBpl: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_bpl'])!,
      prevComplications: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}prev_complications'])!,
      riskLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}risk_level'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      workerCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}worker_created'])!,
    );
  }

  @override
  $MothersTable createAlias(String alias) {
    return $MothersTable(attachedDatabase, alias);
  }
}

class Mother extends DataClass implements Insertable<Mother> {
  final String id;
  final String name;
  final int age;
  final String? husbandName;
  final String? phone;

  /// How she signs in to Thayi Setu. Entered by the ASHA at registration;
  /// without it she cannot open her own record.
  final String? email;

  /// Proved to reach her, by sending the login code and having her read it
  /// back. An address typed at a doorstep and never tested is the quietest way
  /// for a mother to lose access to her own record.
  final bool emailVerified;

  /// Where she lives, pinned on the first home visit so the next visit —
  /// by anyone covering the sub-centre — can navigate straight there.
  final double? homeLat;
  final double? homeLng;
  final String? homeNote;
  final DateTime? homeLocatedAt;
  final String village;
  final String? subCentre;
  final String? abhaId;
  final DateTime lmp;
  final int gravida;
  final int para;
  final String? bloodGroup;
  final double? heightCm;
  final bool isBpl;

  /// JSON list of ids: cSection, stillbirth, pph, hypertension, gdm, anaemia.
  final String prevComplications;

  /// green | amber | red — the worst level currently known for her.
  final String riskLevel;
  final DateTime createdAt;
  final bool synced;

  /// True when a worker entered her on this handset, false when she arrived in
  /// a pull from the server.
  ///
  /// This used to be inferred from the shape of the id by _isWorkerCreated,
  /// which reads the last '-' group and is wrong in both directions once
  /// pulled rows exist: a server uuid ending in twelve digits reads as
  /// worker-made, and every mother pulled down would be pushed straight back
  /// up, overwriting her name and posting with this phone's copy.
  final bool workerCreated;
  const Mother(
      {required this.id,
      required this.name,
      required this.age,
      this.husbandName,
      this.phone,
      this.email,
      required this.emailVerified,
      this.homeLat,
      this.homeLng,
      this.homeNote,
      this.homeLocatedAt,
      required this.village,
      this.subCentre,
      this.abhaId,
      required this.lmp,
      required this.gravida,
      required this.para,
      this.bloodGroup,
      this.heightCm,
      required this.isBpl,
      required this.prevComplications,
      required this.riskLevel,
      required this.createdAt,
      required this.synced,
      required this.workerCreated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    if (!nullToAbsent || husbandName != null) {
      map['husband_name'] = Variable<String>(husbandName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['email_verified'] = Variable<bool>(emailVerified);
    if (!nullToAbsent || homeLat != null) {
      map['home_lat'] = Variable<double>(homeLat);
    }
    if (!nullToAbsent || homeLng != null) {
      map['home_lng'] = Variable<double>(homeLng);
    }
    if (!nullToAbsent || homeNote != null) {
      map['home_note'] = Variable<String>(homeNote);
    }
    if (!nullToAbsent || homeLocatedAt != null) {
      map['home_located_at'] = Variable<DateTime>(homeLocatedAt);
    }
    map['village'] = Variable<String>(village);
    if (!nullToAbsent || subCentre != null) {
      map['sub_centre'] = Variable<String>(subCentre);
    }
    if (!nullToAbsent || abhaId != null) {
      map['abha_id'] = Variable<String>(abhaId);
    }
    map['lmp'] = Variable<DateTime>(lmp);
    map['gravida'] = Variable<int>(gravida);
    map['para'] = Variable<int>(para);
    if (!nullToAbsent || bloodGroup != null) {
      map['blood_group'] = Variable<String>(bloodGroup);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    map['is_bpl'] = Variable<bool>(isBpl);
    map['prev_complications'] = Variable<String>(prevComplications);
    map['risk_level'] = Variable<String>(riskLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    map['worker_created'] = Variable<bool>(workerCreated);
    return map;
  }

  MothersCompanion toCompanion(bool nullToAbsent) {
    return MothersCompanion(
      id: Value(id),
      name: Value(name),
      age: Value(age),
      husbandName: husbandName == null && nullToAbsent
          ? const Value.absent()
          : Value(husbandName),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      emailVerified: Value(emailVerified),
      homeLat: homeLat == null && nullToAbsent
          ? const Value.absent()
          : Value(homeLat),
      homeLng: homeLng == null && nullToAbsent
          ? const Value.absent()
          : Value(homeLng),
      homeNote: homeNote == null && nullToAbsent
          ? const Value.absent()
          : Value(homeNote),
      homeLocatedAt: homeLocatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(homeLocatedAt),
      village: Value(village),
      subCentre: subCentre == null && nullToAbsent
          ? const Value.absent()
          : Value(subCentre),
      abhaId:
          abhaId == null && nullToAbsent ? const Value.absent() : Value(abhaId),
      lmp: Value(lmp),
      gravida: Value(gravida),
      para: Value(para),
      bloodGroup: bloodGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodGroup),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      isBpl: Value(isBpl),
      prevComplications: Value(prevComplications),
      riskLevel: Value(riskLevel),
      createdAt: Value(createdAt),
      synced: Value(synced),
      workerCreated: Value(workerCreated),
    );
  }

  factory Mother.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mother(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      husbandName: serializer.fromJson<String?>(json['husbandName']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      emailVerified: serializer.fromJson<bool>(json['emailVerified']),
      homeLat: serializer.fromJson<double?>(json['homeLat']),
      homeLng: serializer.fromJson<double?>(json['homeLng']),
      homeNote: serializer.fromJson<String?>(json['homeNote']),
      homeLocatedAt: serializer.fromJson<DateTime?>(json['homeLocatedAt']),
      village: serializer.fromJson<String>(json['village']),
      subCentre: serializer.fromJson<String?>(json['subCentre']),
      abhaId: serializer.fromJson<String?>(json['abhaId']),
      lmp: serializer.fromJson<DateTime>(json['lmp']),
      gravida: serializer.fromJson<int>(json['gravida']),
      para: serializer.fromJson<int>(json['para']),
      bloodGroup: serializer.fromJson<String?>(json['bloodGroup']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      isBpl: serializer.fromJson<bool>(json['isBpl']),
      prevComplications: serializer.fromJson<String>(json['prevComplications']),
      riskLevel: serializer.fromJson<String>(json['riskLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      workerCreated: serializer.fromJson<bool>(json['workerCreated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'husbandName': serializer.toJson<String?>(husbandName),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'emailVerified': serializer.toJson<bool>(emailVerified),
      'homeLat': serializer.toJson<double?>(homeLat),
      'homeLng': serializer.toJson<double?>(homeLng),
      'homeNote': serializer.toJson<String?>(homeNote),
      'homeLocatedAt': serializer.toJson<DateTime?>(homeLocatedAt),
      'village': serializer.toJson<String>(village),
      'subCentre': serializer.toJson<String?>(subCentre),
      'abhaId': serializer.toJson<String?>(abhaId),
      'lmp': serializer.toJson<DateTime>(lmp),
      'gravida': serializer.toJson<int>(gravida),
      'para': serializer.toJson<int>(para),
      'bloodGroup': serializer.toJson<String?>(bloodGroup),
      'heightCm': serializer.toJson<double?>(heightCm),
      'isBpl': serializer.toJson<bool>(isBpl),
      'prevComplications': serializer.toJson<String>(prevComplications),
      'riskLevel': serializer.toJson<String>(riskLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
      'workerCreated': serializer.toJson<bool>(workerCreated),
    };
  }

  Mother copyWith(
          {String? id,
          String? name,
          int? age,
          Value<String?> husbandName = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          bool? emailVerified,
          Value<double?> homeLat = const Value.absent(),
          Value<double?> homeLng = const Value.absent(),
          Value<String?> homeNote = const Value.absent(),
          Value<DateTime?> homeLocatedAt = const Value.absent(),
          String? village,
          Value<String?> subCentre = const Value.absent(),
          Value<String?> abhaId = const Value.absent(),
          DateTime? lmp,
          int? gravida,
          int? para,
          Value<String?> bloodGroup = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          bool? isBpl,
          String? prevComplications,
          String? riskLevel,
          DateTime? createdAt,
          bool? synced,
          bool? workerCreated}) =>
      Mother(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        husbandName: husbandName.present ? husbandName.value : this.husbandName,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        emailVerified: emailVerified ?? this.emailVerified,
        homeLat: homeLat.present ? homeLat.value : this.homeLat,
        homeLng: homeLng.present ? homeLng.value : this.homeLng,
        homeNote: homeNote.present ? homeNote.value : this.homeNote,
        homeLocatedAt:
            homeLocatedAt.present ? homeLocatedAt.value : this.homeLocatedAt,
        village: village ?? this.village,
        subCentre: subCentre.present ? subCentre.value : this.subCentre,
        abhaId: abhaId.present ? abhaId.value : this.abhaId,
        lmp: lmp ?? this.lmp,
        gravida: gravida ?? this.gravida,
        para: para ?? this.para,
        bloodGroup: bloodGroup.present ? bloodGroup.value : this.bloodGroup,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        isBpl: isBpl ?? this.isBpl,
        prevComplications: prevComplications ?? this.prevComplications,
        riskLevel: riskLevel ?? this.riskLevel,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
        workerCreated: workerCreated ?? this.workerCreated,
      );
  Mother copyWithCompanion(MothersCompanion data) {
    return Mother(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      husbandName:
          data.husbandName.present ? data.husbandName.value : this.husbandName,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      emailVerified: data.emailVerified.present
          ? data.emailVerified.value
          : this.emailVerified,
      homeLat: data.homeLat.present ? data.homeLat.value : this.homeLat,
      homeLng: data.homeLng.present ? data.homeLng.value : this.homeLng,
      homeNote: data.homeNote.present ? data.homeNote.value : this.homeNote,
      homeLocatedAt: data.homeLocatedAt.present
          ? data.homeLocatedAt.value
          : this.homeLocatedAt,
      village: data.village.present ? data.village.value : this.village,
      subCentre: data.subCentre.present ? data.subCentre.value : this.subCentre,
      abhaId: data.abhaId.present ? data.abhaId.value : this.abhaId,
      lmp: data.lmp.present ? data.lmp.value : this.lmp,
      gravida: data.gravida.present ? data.gravida.value : this.gravida,
      para: data.para.present ? data.para.value : this.para,
      bloodGroup:
          data.bloodGroup.present ? data.bloodGroup.value : this.bloodGroup,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      isBpl: data.isBpl.present ? data.isBpl.value : this.isBpl,
      prevComplications: data.prevComplications.present
          ? data.prevComplications.value
          : this.prevComplications,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      workerCreated: data.workerCreated.present
          ? data.workerCreated.value
          : this.workerCreated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mother(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('husbandName: $husbandName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('emailVerified: $emailVerified, ')
          ..write('homeLat: $homeLat, ')
          ..write('homeLng: $homeLng, ')
          ..write('homeNote: $homeNote, ')
          ..write('homeLocatedAt: $homeLocatedAt, ')
          ..write('village: $village, ')
          ..write('subCentre: $subCentre, ')
          ..write('abhaId: $abhaId, ')
          ..write('lmp: $lmp, ')
          ..write('gravida: $gravida, ')
          ..write('para: $para, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('heightCm: $heightCm, ')
          ..write('isBpl: $isBpl, ')
          ..write('prevComplications: $prevComplications, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('workerCreated: $workerCreated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        age,
        husbandName,
        phone,
        email,
        emailVerified,
        homeLat,
        homeLng,
        homeNote,
        homeLocatedAt,
        village,
        subCentre,
        abhaId,
        lmp,
        gravida,
        para,
        bloodGroup,
        heightCm,
        isBpl,
        prevComplications,
        riskLevel,
        createdAt,
        synced,
        workerCreated
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mother &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.husbandName == this.husbandName &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.emailVerified == this.emailVerified &&
          other.homeLat == this.homeLat &&
          other.homeLng == this.homeLng &&
          other.homeNote == this.homeNote &&
          other.homeLocatedAt == this.homeLocatedAt &&
          other.village == this.village &&
          other.subCentre == this.subCentre &&
          other.abhaId == this.abhaId &&
          other.lmp == this.lmp &&
          other.gravida == this.gravida &&
          other.para == this.para &&
          other.bloodGroup == this.bloodGroup &&
          other.heightCm == this.heightCm &&
          other.isBpl == this.isBpl &&
          other.prevComplications == this.prevComplications &&
          other.riskLevel == this.riskLevel &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced &&
          other.workerCreated == this.workerCreated);
}

class MothersCompanion extends UpdateCompanion<Mother> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> age;
  final Value<String?> husbandName;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<bool> emailVerified;
  final Value<double?> homeLat;
  final Value<double?> homeLng;
  final Value<String?> homeNote;
  final Value<DateTime?> homeLocatedAt;
  final Value<String> village;
  final Value<String?> subCentre;
  final Value<String?> abhaId;
  final Value<DateTime> lmp;
  final Value<int> gravida;
  final Value<int> para;
  final Value<String?> bloodGroup;
  final Value<double?> heightCm;
  final Value<bool> isBpl;
  final Value<String> prevComplications;
  final Value<String> riskLevel;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<bool> workerCreated;
  final Value<int> rowid;
  const MothersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.husbandName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.emailVerified = const Value.absent(),
    this.homeLat = const Value.absent(),
    this.homeLng = const Value.absent(),
    this.homeNote = const Value.absent(),
    this.homeLocatedAt = const Value.absent(),
    this.village = const Value.absent(),
    this.subCentre = const Value.absent(),
    this.abhaId = const Value.absent(),
    this.lmp = const Value.absent(),
    this.gravida = const Value.absent(),
    this.para = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.isBpl = const Value.absent(),
    this.prevComplications = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.workerCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MothersCompanion.insert({
    required String id,
    required String name,
    required int age,
    this.husbandName = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.emailVerified = const Value.absent(),
    this.homeLat = const Value.absent(),
    this.homeLng = const Value.absent(),
    this.homeNote = const Value.absent(),
    this.homeLocatedAt = const Value.absent(),
    required String village,
    this.subCentre = const Value.absent(),
    this.abhaId = const Value.absent(),
    required DateTime lmp,
    this.gravida = const Value.absent(),
    this.para = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.isBpl = const Value.absent(),
    this.prevComplications = const Value.absent(),
    this.riskLevel = const Value.absent(),
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.workerCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        age = Value(age),
        village = Value(village),
        lmp = Value(lmp),
        createdAt = Value(createdAt);
  static Insertable<Mother> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? husbandName,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<bool>? emailVerified,
    Expression<double>? homeLat,
    Expression<double>? homeLng,
    Expression<String>? homeNote,
    Expression<DateTime>? homeLocatedAt,
    Expression<String>? village,
    Expression<String>? subCentre,
    Expression<String>? abhaId,
    Expression<DateTime>? lmp,
    Expression<int>? gravida,
    Expression<int>? para,
    Expression<String>? bloodGroup,
    Expression<double>? heightCm,
    Expression<bool>? isBpl,
    Expression<String>? prevComplications,
    Expression<String>? riskLevel,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<bool>? workerCreated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (husbandName != null) 'husband_name': husbandName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (emailVerified != null) 'email_verified': emailVerified,
      if (homeLat != null) 'home_lat': homeLat,
      if (homeLng != null) 'home_lng': homeLng,
      if (homeNote != null) 'home_note': homeNote,
      if (homeLocatedAt != null) 'home_located_at': homeLocatedAt,
      if (village != null) 'village': village,
      if (subCentre != null) 'sub_centre': subCentre,
      if (abhaId != null) 'abha_id': abhaId,
      if (lmp != null) 'lmp': lmp,
      if (gravida != null) 'gravida': gravida,
      if (para != null) 'para': para,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (heightCm != null) 'height_cm': heightCm,
      if (isBpl != null) 'is_bpl': isBpl,
      if (prevComplications != null) 'prev_complications': prevComplications,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (workerCreated != null) 'worker_created': workerCreated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MothersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? age,
      Value<String?>? husbandName,
      Value<String?>? phone,
      Value<String?>? email,
      Value<bool>? emailVerified,
      Value<double?>? homeLat,
      Value<double?>? homeLng,
      Value<String?>? homeNote,
      Value<DateTime?>? homeLocatedAt,
      Value<String>? village,
      Value<String?>? subCentre,
      Value<String?>? abhaId,
      Value<DateTime>? lmp,
      Value<int>? gravida,
      Value<int>? para,
      Value<String?>? bloodGroup,
      Value<double?>? heightCm,
      Value<bool>? isBpl,
      Value<String>? prevComplications,
      Value<String>? riskLevel,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<bool>? workerCreated,
      Value<int>? rowid}) {
    return MothersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      husbandName: husbandName ?? this.husbandName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      homeLat: homeLat ?? this.homeLat,
      homeLng: homeLng ?? this.homeLng,
      homeNote: homeNote ?? this.homeNote,
      homeLocatedAt: homeLocatedAt ?? this.homeLocatedAt,
      village: village ?? this.village,
      subCentre: subCentre ?? this.subCentre,
      abhaId: abhaId ?? this.abhaId,
      lmp: lmp ?? this.lmp,
      gravida: gravida ?? this.gravida,
      para: para ?? this.para,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      heightCm: heightCm ?? this.heightCm,
      isBpl: isBpl ?? this.isBpl,
      prevComplications: prevComplications ?? this.prevComplications,
      riskLevel: riskLevel ?? this.riskLevel,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      workerCreated: workerCreated ?? this.workerCreated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (husbandName.present) {
      map['husband_name'] = Variable<String>(husbandName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (emailVerified.present) {
      map['email_verified'] = Variable<bool>(emailVerified.value);
    }
    if (homeLat.present) {
      map['home_lat'] = Variable<double>(homeLat.value);
    }
    if (homeLng.present) {
      map['home_lng'] = Variable<double>(homeLng.value);
    }
    if (homeNote.present) {
      map['home_note'] = Variable<String>(homeNote.value);
    }
    if (homeLocatedAt.present) {
      map['home_located_at'] = Variable<DateTime>(homeLocatedAt.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (subCentre.present) {
      map['sub_centre'] = Variable<String>(subCentre.value);
    }
    if (abhaId.present) {
      map['abha_id'] = Variable<String>(abhaId.value);
    }
    if (lmp.present) {
      map['lmp'] = Variable<DateTime>(lmp.value);
    }
    if (gravida.present) {
      map['gravida'] = Variable<int>(gravida.value);
    }
    if (para.present) {
      map['para'] = Variable<int>(para.value);
    }
    if (bloodGroup.present) {
      map['blood_group'] = Variable<String>(bloodGroup.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (isBpl.present) {
      map['is_bpl'] = Variable<bool>(isBpl.value);
    }
    if (prevComplications.present) {
      map['prev_complications'] = Variable<String>(prevComplications.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (workerCreated.present) {
      map['worker_created'] = Variable<bool>(workerCreated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MothersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('husbandName: $husbandName, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('emailVerified: $emailVerified, ')
          ..write('homeLat: $homeLat, ')
          ..write('homeLng: $homeLng, ')
          ..write('homeNote: $homeNote, ')
          ..write('homeLocatedAt: $homeLocatedAt, ')
          ..write('village: $village, ')
          ..write('subCentre: $subCentre, ')
          ..write('abhaId: $abhaId, ')
          ..write('lmp: $lmp, ')
          ..write('gravida: $gravida, ')
          ..write('para: $para, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('heightCm: $heightCm, ')
          ..write('isBpl: $isBpl, ')
          ..write('prevComplications: $prevComplications, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('workerCreated: $workerCreated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AncVisitsTable extends AncVisits
    with TableInfo<$AncVisitsTable, AncVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AncVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _motherIdMeta =
      const VerificationMeta('motherId');
  @override
  late final GeneratedColumn<String> motherId = GeneratedColumn<String>(
      'mother_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES mothers (id)'));
  static const VerificationMeta _visitNoMeta =
      const VerificationMeta('visitNo');
  @override
  late final GeneratedColumn<int> visitNo = GeneratedColumn<int>(
      'visit_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _visitDateMeta =
      const VerificationMeta('visitDate');
  @override
  late final GeneratedColumn<DateTime> visitDate = GeneratedColumn<DateTime>(
      'visit_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _bpSysMeta = const VerificationMeta('bpSys');
  @override
  late final GeneratedColumn<int> bpSys = GeneratedColumn<int>(
      'bp_sys', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bpDiaMeta = const VerificationMeta('bpDia');
  @override
  late final GeneratedColumn<int> bpDia = GeneratedColumn<int>(
      'bp_dia', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fundalHeightCmMeta =
      const VerificationMeta('fundalHeightCm');
  @override
  late final GeneratedColumn<double> fundalHeightCm = GeneratedColumn<double>(
      'fundal_height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _hbMeta = const VerificationMeta('hb');
  @override
  late final GeneratedColumn<double> hb = GeneratedColumn<double>(
      'hb', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _urineAlbuminMeta =
      const VerificationMeta('urineAlbumin');
  @override
  late final GeneratedColumn<String> urineAlbumin = GeneratedColumn<String>(
      'urine_albumin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fetalHrMeta =
      const VerificationMeta('fetalHr');
  @override
  late final GeneratedColumn<int> fetalHr = GeneratedColumn<int>(
      'fetal_hr', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fetalMovementMeta =
      const VerificationMeta('fetalMovement');
  @override
  late final GeneratedColumn<bool> fetalMovement = GeneratedColumn<bool>(
      'fetal_movement', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("fetal_movement" IN (0, 1))'));
  static const VerificationMeta _dangerSignsMeta =
      const VerificationMeta('dangerSigns');
  @override
  late final GeneratedColumn<String> dangerSigns = GeneratedColumn<String>(
      'danger_signs', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _ifaTakenMeta =
      const VerificationMeta('ifaTaken');
  @override
  late final GeneratedColumn<bool> ifaTaken = GeneratedColumn<bool>(
      'ifa_taken', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ifa_taken" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _calciumTakenMeta =
      const VerificationMeta('calciumTaken');
  @override
  late final GeneratedColumn<bool> calciumTaken = GeneratedColumn<bool>(
      'calcium_taken', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("calcium_taken" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _ttDoseGivenMeta =
      const VerificationMeta('ttDoseGiven');
  @override
  late final GeneratedColumn<int> ttDoseGiven = GeneratedColumn<int>(
      'tt_dose_given', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gpsLatMeta = const VerificationMeta('gpsLat');
  @override
  late final GeneratedColumn<double> gpsLat = GeneratedColumn<double>(
      'gps_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _gpsLngMeta = const VerificationMeta('gpsLng');
  @override
  late final GeneratedColumn<double> gpsLng = GeneratedColumn<double>(
      'gps_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _photoPathsMeta =
      const VerificationMeta('photoPaths');
  @override
  late final GeneratedColumn<String> photoPaths = GeneratedColumn<String>(
      'photo_paths', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _recordedByMeta =
      const VerificationMeta('recordedBy');
  @override
  late final GeneratedColumn<String> recordedBy = GeneratedColumn<String>(
      'recorded_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientCreatedAtMeta =
      const VerificationMeta('clientCreatedAt');
  @override
  late final GeneratedColumn<DateTime> clientCreatedAt =
      GeneratedColumn<DateTime>('client_created_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _correctsIdMeta =
      const VerificationMeta('correctsId');
  @override
  late final GeneratedColumn<String> correctsId = GeneratedColumn<String>(
      'corrects_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _workerCreatedMeta =
      const VerificationMeta('workerCreated');
  @override
  late final GeneratedColumn<bool> workerCreated = GeneratedColumn<bool>(
      'worker_created', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("worker_created" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        motherId,
        visitNo,
        visitDate,
        bpSys,
        bpDia,
        weightKg,
        fundalHeightCm,
        hb,
        urineAlbumin,
        fetalHr,
        fetalMovement,
        dangerSigns,
        ifaTaken,
        calciumTaken,
        ttDoseGiven,
        notes,
        gpsLat,
        gpsLng,
        photoPaths,
        recordedBy,
        clientCreatedAt,
        correctsId,
        synced,
        workerCreated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anc_visits';
  @override
  VerificationContext validateIntegrity(Insertable<AncVisit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mother_id')) {
      context.handle(_motherIdMeta,
          motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta));
    } else if (isInserting) {
      context.missing(_motherIdMeta);
    }
    if (data.containsKey('visit_no')) {
      context.handle(_visitNoMeta,
          visitNo.isAcceptableOrUnknown(data['visit_no']!, _visitNoMeta));
    } else if (isInserting) {
      context.missing(_visitNoMeta);
    }
    if (data.containsKey('visit_date')) {
      context.handle(_visitDateMeta,
          visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta));
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('bp_sys')) {
      context.handle(
          _bpSysMeta, bpSys.isAcceptableOrUnknown(data['bp_sys']!, _bpSysMeta));
    }
    if (data.containsKey('bp_dia')) {
      context.handle(
          _bpDiaMeta, bpDia.isAcceptableOrUnknown(data['bp_dia']!, _bpDiaMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('fundal_height_cm')) {
      context.handle(
          _fundalHeightCmMeta,
          fundalHeightCm.isAcceptableOrUnknown(
              data['fundal_height_cm']!, _fundalHeightCmMeta));
    }
    if (data.containsKey('hb')) {
      context.handle(_hbMeta, hb.isAcceptableOrUnknown(data['hb']!, _hbMeta));
    }
    if (data.containsKey('urine_albumin')) {
      context.handle(
          _urineAlbuminMeta,
          urineAlbumin.isAcceptableOrUnknown(
              data['urine_albumin']!, _urineAlbuminMeta));
    }
    if (data.containsKey('fetal_hr')) {
      context.handle(_fetalHrMeta,
          fetalHr.isAcceptableOrUnknown(data['fetal_hr']!, _fetalHrMeta));
    }
    if (data.containsKey('fetal_movement')) {
      context.handle(
          _fetalMovementMeta,
          fetalMovement.isAcceptableOrUnknown(
              data['fetal_movement']!, _fetalMovementMeta));
    }
    if (data.containsKey('danger_signs')) {
      context.handle(
          _dangerSignsMeta,
          dangerSigns.isAcceptableOrUnknown(
              data['danger_signs']!, _dangerSignsMeta));
    }
    if (data.containsKey('ifa_taken')) {
      context.handle(_ifaTakenMeta,
          ifaTaken.isAcceptableOrUnknown(data['ifa_taken']!, _ifaTakenMeta));
    }
    if (data.containsKey('calcium_taken')) {
      context.handle(
          _calciumTakenMeta,
          calciumTaken.isAcceptableOrUnknown(
              data['calcium_taken']!, _calciumTakenMeta));
    }
    if (data.containsKey('tt_dose_given')) {
      context.handle(
          _ttDoseGivenMeta,
          ttDoseGiven.isAcceptableOrUnknown(
              data['tt_dose_given']!, _ttDoseGivenMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('gps_lat')) {
      context.handle(_gpsLatMeta,
          gpsLat.isAcceptableOrUnknown(data['gps_lat']!, _gpsLatMeta));
    }
    if (data.containsKey('gps_lng')) {
      context.handle(_gpsLngMeta,
          gpsLng.isAcceptableOrUnknown(data['gps_lng']!, _gpsLngMeta));
    }
    if (data.containsKey('photo_paths')) {
      context.handle(
          _photoPathsMeta,
          photoPaths.isAcceptableOrUnknown(
              data['photo_paths']!, _photoPathsMeta));
    }
    if (data.containsKey('recorded_by')) {
      context.handle(
          _recordedByMeta,
          recordedBy.isAcceptableOrUnknown(
              data['recorded_by']!, _recordedByMeta));
    } else if (isInserting) {
      context.missing(_recordedByMeta);
    }
    if (data.containsKey('client_created_at')) {
      context.handle(
          _clientCreatedAtMeta,
          clientCreatedAt.isAcceptableOrUnknown(
              data['client_created_at']!, _clientCreatedAtMeta));
    } else if (isInserting) {
      context.missing(_clientCreatedAtMeta);
    }
    if (data.containsKey('corrects_id')) {
      context.handle(
          _correctsIdMeta,
          correctsId.isAcceptableOrUnknown(
              data['corrects_id']!, _correctsIdMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('worker_created')) {
      context.handle(
          _workerCreatedMeta,
          workerCreated.isAcceptableOrUnknown(
              data['worker_created']!, _workerCreatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AncVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AncVisit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      motherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mother_id'])!,
      visitNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}visit_no'])!,
      visitDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}visit_date'])!,
      bpSys: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bp_sys']),
      bpDia: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bp_dia']),
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      fundalHeightCm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}fundal_height_cm']),
      hb: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hb']),
      urineAlbumin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}urine_albumin']),
      fetalHr: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fetal_hr']),
      fetalMovement: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}fetal_movement']),
      dangerSigns: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}danger_signs'])!,
      ifaTaken: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ifa_taken'])!,
      calciumTaken: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}calcium_taken'])!,
      ttDoseGiven: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tt_dose_given']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      gpsLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_lat']),
      gpsLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_lng']),
      photoPaths: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_paths'])!,
      recordedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recorded_by'])!,
      clientCreatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}client_created_at'])!,
      correctsId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}corrects_id']),
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      workerCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}worker_created'])!,
    );
  }

  @override
  $AncVisitsTable createAlias(String alias) {
    return $AncVisitsTable(attachedDatabase, alias);
  }
}

class AncVisit extends DataClass implements Insertable<AncVisit> {
  final String id;
  final String motherId;
  final int visitNo;
  final DateTime visitDate;
  final int? bpSys;
  final int? bpDia;
  final double? weightKg;
  final double? fundalHeightCm;
  final double? hb;
  final String? urineAlbumin;
  final int? fetalHr;
  final bool? fetalMovement;

  /// JSON list of danger sign ids.
  final String dangerSigns;
  final bool ifaTaken;
  final bool calciumTaken;
  final int? ttDoseGiven;
  final String? notes;
  final double? gpsLat;
  final double? gpsLng;
  final String photoPaths;
  final String recordedBy;
  final DateTime clientCreatedAt;
  final String? correctsId;
  final bool synced;

  /// Recorded on this handset rather than pulled down. See Mothers.
  final bool workerCreated;
  const AncVisit(
      {required this.id,
      required this.motherId,
      required this.visitNo,
      required this.visitDate,
      this.bpSys,
      this.bpDia,
      this.weightKg,
      this.fundalHeightCm,
      this.hb,
      this.urineAlbumin,
      this.fetalHr,
      this.fetalMovement,
      required this.dangerSigns,
      required this.ifaTaken,
      required this.calciumTaken,
      this.ttDoseGiven,
      this.notes,
      this.gpsLat,
      this.gpsLng,
      required this.photoPaths,
      required this.recordedBy,
      required this.clientCreatedAt,
      this.correctsId,
      required this.synced,
      required this.workerCreated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mother_id'] = Variable<String>(motherId);
    map['visit_no'] = Variable<int>(visitNo);
    map['visit_date'] = Variable<DateTime>(visitDate);
    if (!nullToAbsent || bpSys != null) {
      map['bp_sys'] = Variable<int>(bpSys);
    }
    if (!nullToAbsent || bpDia != null) {
      map['bp_dia'] = Variable<int>(bpDia);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || fundalHeightCm != null) {
      map['fundal_height_cm'] = Variable<double>(fundalHeightCm);
    }
    if (!nullToAbsent || hb != null) {
      map['hb'] = Variable<double>(hb);
    }
    if (!nullToAbsent || urineAlbumin != null) {
      map['urine_albumin'] = Variable<String>(urineAlbumin);
    }
    if (!nullToAbsent || fetalHr != null) {
      map['fetal_hr'] = Variable<int>(fetalHr);
    }
    if (!nullToAbsent || fetalMovement != null) {
      map['fetal_movement'] = Variable<bool>(fetalMovement);
    }
    map['danger_signs'] = Variable<String>(dangerSigns);
    map['ifa_taken'] = Variable<bool>(ifaTaken);
    map['calcium_taken'] = Variable<bool>(calciumTaken);
    if (!nullToAbsent || ttDoseGiven != null) {
      map['tt_dose_given'] = Variable<int>(ttDoseGiven);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || gpsLat != null) {
      map['gps_lat'] = Variable<double>(gpsLat);
    }
    if (!nullToAbsent || gpsLng != null) {
      map['gps_lng'] = Variable<double>(gpsLng);
    }
    map['photo_paths'] = Variable<String>(photoPaths);
    map['recorded_by'] = Variable<String>(recordedBy);
    map['client_created_at'] = Variable<DateTime>(clientCreatedAt);
    if (!nullToAbsent || correctsId != null) {
      map['corrects_id'] = Variable<String>(correctsId);
    }
    map['synced'] = Variable<bool>(synced);
    map['worker_created'] = Variable<bool>(workerCreated);
    return map;
  }

  AncVisitsCompanion toCompanion(bool nullToAbsent) {
    return AncVisitsCompanion(
      id: Value(id),
      motherId: Value(motherId),
      visitNo: Value(visitNo),
      visitDate: Value(visitDate),
      bpSys:
          bpSys == null && nullToAbsent ? const Value.absent() : Value(bpSys),
      bpDia:
          bpDia == null && nullToAbsent ? const Value.absent() : Value(bpDia),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      fundalHeightCm: fundalHeightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(fundalHeightCm),
      hb: hb == null && nullToAbsent ? const Value.absent() : Value(hb),
      urineAlbumin: urineAlbumin == null && nullToAbsent
          ? const Value.absent()
          : Value(urineAlbumin),
      fetalHr: fetalHr == null && nullToAbsent
          ? const Value.absent()
          : Value(fetalHr),
      fetalMovement: fetalMovement == null && nullToAbsent
          ? const Value.absent()
          : Value(fetalMovement),
      dangerSigns: Value(dangerSigns),
      ifaTaken: Value(ifaTaken),
      calciumTaken: Value(calciumTaken),
      ttDoseGiven: ttDoseGiven == null && nullToAbsent
          ? const Value.absent()
          : Value(ttDoseGiven),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      gpsLat:
          gpsLat == null && nullToAbsent ? const Value.absent() : Value(gpsLat),
      gpsLng:
          gpsLng == null && nullToAbsent ? const Value.absent() : Value(gpsLng),
      photoPaths: Value(photoPaths),
      recordedBy: Value(recordedBy),
      clientCreatedAt: Value(clientCreatedAt),
      correctsId: correctsId == null && nullToAbsent
          ? const Value.absent()
          : Value(correctsId),
      synced: Value(synced),
      workerCreated: Value(workerCreated),
    );
  }

  factory AncVisit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AncVisit(
      id: serializer.fromJson<String>(json['id']),
      motherId: serializer.fromJson<String>(json['motherId']),
      visitNo: serializer.fromJson<int>(json['visitNo']),
      visitDate: serializer.fromJson<DateTime>(json['visitDate']),
      bpSys: serializer.fromJson<int?>(json['bpSys']),
      bpDia: serializer.fromJson<int?>(json['bpDia']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      fundalHeightCm: serializer.fromJson<double?>(json['fundalHeightCm']),
      hb: serializer.fromJson<double?>(json['hb']),
      urineAlbumin: serializer.fromJson<String?>(json['urineAlbumin']),
      fetalHr: serializer.fromJson<int?>(json['fetalHr']),
      fetalMovement: serializer.fromJson<bool?>(json['fetalMovement']),
      dangerSigns: serializer.fromJson<String>(json['dangerSigns']),
      ifaTaken: serializer.fromJson<bool>(json['ifaTaken']),
      calciumTaken: serializer.fromJson<bool>(json['calciumTaken']),
      ttDoseGiven: serializer.fromJson<int?>(json['ttDoseGiven']),
      notes: serializer.fromJson<String?>(json['notes']),
      gpsLat: serializer.fromJson<double?>(json['gpsLat']),
      gpsLng: serializer.fromJson<double?>(json['gpsLng']),
      photoPaths: serializer.fromJson<String>(json['photoPaths']),
      recordedBy: serializer.fromJson<String>(json['recordedBy']),
      clientCreatedAt: serializer.fromJson<DateTime>(json['clientCreatedAt']),
      correctsId: serializer.fromJson<String?>(json['correctsId']),
      synced: serializer.fromJson<bool>(json['synced']),
      workerCreated: serializer.fromJson<bool>(json['workerCreated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'motherId': serializer.toJson<String>(motherId),
      'visitNo': serializer.toJson<int>(visitNo),
      'visitDate': serializer.toJson<DateTime>(visitDate),
      'bpSys': serializer.toJson<int?>(bpSys),
      'bpDia': serializer.toJson<int?>(bpDia),
      'weightKg': serializer.toJson<double?>(weightKg),
      'fundalHeightCm': serializer.toJson<double?>(fundalHeightCm),
      'hb': serializer.toJson<double?>(hb),
      'urineAlbumin': serializer.toJson<String?>(urineAlbumin),
      'fetalHr': serializer.toJson<int?>(fetalHr),
      'fetalMovement': serializer.toJson<bool?>(fetalMovement),
      'dangerSigns': serializer.toJson<String>(dangerSigns),
      'ifaTaken': serializer.toJson<bool>(ifaTaken),
      'calciumTaken': serializer.toJson<bool>(calciumTaken),
      'ttDoseGiven': serializer.toJson<int?>(ttDoseGiven),
      'notes': serializer.toJson<String?>(notes),
      'gpsLat': serializer.toJson<double?>(gpsLat),
      'gpsLng': serializer.toJson<double?>(gpsLng),
      'photoPaths': serializer.toJson<String>(photoPaths),
      'recordedBy': serializer.toJson<String>(recordedBy),
      'clientCreatedAt': serializer.toJson<DateTime>(clientCreatedAt),
      'correctsId': serializer.toJson<String?>(correctsId),
      'synced': serializer.toJson<bool>(synced),
      'workerCreated': serializer.toJson<bool>(workerCreated),
    };
  }

  AncVisit copyWith(
          {String? id,
          String? motherId,
          int? visitNo,
          DateTime? visitDate,
          Value<int?> bpSys = const Value.absent(),
          Value<int?> bpDia = const Value.absent(),
          Value<double?> weightKg = const Value.absent(),
          Value<double?> fundalHeightCm = const Value.absent(),
          Value<double?> hb = const Value.absent(),
          Value<String?> urineAlbumin = const Value.absent(),
          Value<int?> fetalHr = const Value.absent(),
          Value<bool?> fetalMovement = const Value.absent(),
          String? dangerSigns,
          bool? ifaTaken,
          bool? calciumTaken,
          Value<int?> ttDoseGiven = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<double?> gpsLat = const Value.absent(),
          Value<double?> gpsLng = const Value.absent(),
          String? photoPaths,
          String? recordedBy,
          DateTime? clientCreatedAt,
          Value<String?> correctsId = const Value.absent(),
          bool? synced,
          bool? workerCreated}) =>
      AncVisit(
        id: id ?? this.id,
        motherId: motherId ?? this.motherId,
        visitNo: visitNo ?? this.visitNo,
        visitDate: visitDate ?? this.visitDate,
        bpSys: bpSys.present ? bpSys.value : this.bpSys,
        bpDia: bpDia.present ? bpDia.value : this.bpDia,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        fundalHeightCm:
            fundalHeightCm.present ? fundalHeightCm.value : this.fundalHeightCm,
        hb: hb.present ? hb.value : this.hb,
        urineAlbumin:
            urineAlbumin.present ? urineAlbumin.value : this.urineAlbumin,
        fetalHr: fetalHr.present ? fetalHr.value : this.fetalHr,
        fetalMovement:
            fetalMovement.present ? fetalMovement.value : this.fetalMovement,
        dangerSigns: dangerSigns ?? this.dangerSigns,
        ifaTaken: ifaTaken ?? this.ifaTaken,
        calciumTaken: calciumTaken ?? this.calciumTaken,
        ttDoseGiven: ttDoseGiven.present ? ttDoseGiven.value : this.ttDoseGiven,
        notes: notes.present ? notes.value : this.notes,
        gpsLat: gpsLat.present ? gpsLat.value : this.gpsLat,
        gpsLng: gpsLng.present ? gpsLng.value : this.gpsLng,
        photoPaths: photoPaths ?? this.photoPaths,
        recordedBy: recordedBy ?? this.recordedBy,
        clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
        correctsId: correctsId.present ? correctsId.value : this.correctsId,
        synced: synced ?? this.synced,
        workerCreated: workerCreated ?? this.workerCreated,
      );
  AncVisit copyWithCompanion(AncVisitsCompanion data) {
    return AncVisit(
      id: data.id.present ? data.id.value : this.id,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      visitNo: data.visitNo.present ? data.visitNo.value : this.visitNo,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      bpSys: data.bpSys.present ? data.bpSys.value : this.bpSys,
      bpDia: data.bpDia.present ? data.bpDia.value : this.bpDia,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      fundalHeightCm: data.fundalHeightCm.present
          ? data.fundalHeightCm.value
          : this.fundalHeightCm,
      hb: data.hb.present ? data.hb.value : this.hb,
      urineAlbumin: data.urineAlbumin.present
          ? data.urineAlbumin.value
          : this.urineAlbumin,
      fetalHr: data.fetalHr.present ? data.fetalHr.value : this.fetalHr,
      fetalMovement: data.fetalMovement.present
          ? data.fetalMovement.value
          : this.fetalMovement,
      dangerSigns:
          data.dangerSigns.present ? data.dangerSigns.value : this.dangerSigns,
      ifaTaken: data.ifaTaken.present ? data.ifaTaken.value : this.ifaTaken,
      calciumTaken: data.calciumTaken.present
          ? data.calciumTaken.value
          : this.calciumTaken,
      ttDoseGiven:
          data.ttDoseGiven.present ? data.ttDoseGiven.value : this.ttDoseGiven,
      notes: data.notes.present ? data.notes.value : this.notes,
      gpsLat: data.gpsLat.present ? data.gpsLat.value : this.gpsLat,
      gpsLng: data.gpsLng.present ? data.gpsLng.value : this.gpsLng,
      photoPaths:
          data.photoPaths.present ? data.photoPaths.value : this.photoPaths,
      recordedBy:
          data.recordedBy.present ? data.recordedBy.value : this.recordedBy,
      clientCreatedAt: data.clientCreatedAt.present
          ? data.clientCreatedAt.value
          : this.clientCreatedAt,
      correctsId:
          data.correctsId.present ? data.correctsId.value : this.correctsId,
      synced: data.synced.present ? data.synced.value : this.synced,
      workerCreated: data.workerCreated.present
          ? data.workerCreated.value
          : this.workerCreated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AncVisit(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('visitNo: $visitNo, ')
          ..write('visitDate: $visitDate, ')
          ..write('bpSys: $bpSys, ')
          ..write('bpDia: $bpDia, ')
          ..write('weightKg: $weightKg, ')
          ..write('fundalHeightCm: $fundalHeightCm, ')
          ..write('hb: $hb, ')
          ..write('urineAlbumin: $urineAlbumin, ')
          ..write('fetalHr: $fetalHr, ')
          ..write('fetalMovement: $fetalMovement, ')
          ..write('dangerSigns: $dangerSigns, ')
          ..write('ifaTaken: $ifaTaken, ')
          ..write('calciumTaken: $calciumTaken, ')
          ..write('ttDoseGiven: $ttDoseGiven, ')
          ..write('notes: $notes, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('photoPaths: $photoPaths, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('correctsId: $correctsId, ')
          ..write('synced: $synced, ')
          ..write('workerCreated: $workerCreated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        motherId,
        visitNo,
        visitDate,
        bpSys,
        bpDia,
        weightKg,
        fundalHeightCm,
        hb,
        urineAlbumin,
        fetalHr,
        fetalMovement,
        dangerSigns,
        ifaTaken,
        calciumTaken,
        ttDoseGiven,
        notes,
        gpsLat,
        gpsLng,
        photoPaths,
        recordedBy,
        clientCreatedAt,
        correctsId,
        synced,
        workerCreated
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AncVisit &&
          other.id == this.id &&
          other.motherId == this.motherId &&
          other.visitNo == this.visitNo &&
          other.visitDate == this.visitDate &&
          other.bpSys == this.bpSys &&
          other.bpDia == this.bpDia &&
          other.weightKg == this.weightKg &&
          other.fundalHeightCm == this.fundalHeightCm &&
          other.hb == this.hb &&
          other.urineAlbumin == this.urineAlbumin &&
          other.fetalHr == this.fetalHr &&
          other.fetalMovement == this.fetalMovement &&
          other.dangerSigns == this.dangerSigns &&
          other.ifaTaken == this.ifaTaken &&
          other.calciumTaken == this.calciumTaken &&
          other.ttDoseGiven == this.ttDoseGiven &&
          other.notes == this.notes &&
          other.gpsLat == this.gpsLat &&
          other.gpsLng == this.gpsLng &&
          other.photoPaths == this.photoPaths &&
          other.recordedBy == this.recordedBy &&
          other.clientCreatedAt == this.clientCreatedAt &&
          other.correctsId == this.correctsId &&
          other.synced == this.synced &&
          other.workerCreated == this.workerCreated);
}

class AncVisitsCompanion extends UpdateCompanion<AncVisit> {
  final Value<String> id;
  final Value<String> motherId;
  final Value<int> visitNo;
  final Value<DateTime> visitDate;
  final Value<int?> bpSys;
  final Value<int?> bpDia;
  final Value<double?> weightKg;
  final Value<double?> fundalHeightCm;
  final Value<double?> hb;
  final Value<String?> urineAlbumin;
  final Value<int?> fetalHr;
  final Value<bool?> fetalMovement;
  final Value<String> dangerSigns;
  final Value<bool> ifaTaken;
  final Value<bool> calciumTaken;
  final Value<int?> ttDoseGiven;
  final Value<String?> notes;
  final Value<double?> gpsLat;
  final Value<double?> gpsLng;
  final Value<String> photoPaths;
  final Value<String> recordedBy;
  final Value<DateTime> clientCreatedAt;
  final Value<String?> correctsId;
  final Value<bool> synced;
  final Value<bool> workerCreated;
  final Value<int> rowid;
  const AncVisitsCompanion({
    this.id = const Value.absent(),
    this.motherId = const Value.absent(),
    this.visitNo = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.bpSys = const Value.absent(),
    this.bpDia = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.fundalHeightCm = const Value.absent(),
    this.hb = const Value.absent(),
    this.urineAlbumin = const Value.absent(),
    this.fetalHr = const Value.absent(),
    this.fetalMovement = const Value.absent(),
    this.dangerSigns = const Value.absent(),
    this.ifaTaken = const Value.absent(),
    this.calciumTaken = const Value.absent(),
    this.ttDoseGiven = const Value.absent(),
    this.notes = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.photoPaths = const Value.absent(),
    this.recordedBy = const Value.absent(),
    this.clientCreatedAt = const Value.absent(),
    this.correctsId = const Value.absent(),
    this.synced = const Value.absent(),
    this.workerCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AncVisitsCompanion.insert({
    required String id,
    required String motherId,
    required int visitNo,
    required DateTime visitDate,
    this.bpSys = const Value.absent(),
    this.bpDia = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.fundalHeightCm = const Value.absent(),
    this.hb = const Value.absent(),
    this.urineAlbumin = const Value.absent(),
    this.fetalHr = const Value.absent(),
    this.fetalMovement = const Value.absent(),
    this.dangerSigns = const Value.absent(),
    this.ifaTaken = const Value.absent(),
    this.calciumTaken = const Value.absent(),
    this.ttDoseGiven = const Value.absent(),
    this.notes = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.photoPaths = const Value.absent(),
    required String recordedBy,
    required DateTime clientCreatedAt,
    this.correctsId = const Value.absent(),
    this.synced = const Value.absent(),
    this.workerCreated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        motherId = Value(motherId),
        visitNo = Value(visitNo),
        visitDate = Value(visitDate),
        recordedBy = Value(recordedBy),
        clientCreatedAt = Value(clientCreatedAt);
  static Insertable<AncVisit> custom({
    Expression<String>? id,
    Expression<String>? motherId,
    Expression<int>? visitNo,
    Expression<DateTime>? visitDate,
    Expression<int>? bpSys,
    Expression<int>? bpDia,
    Expression<double>? weightKg,
    Expression<double>? fundalHeightCm,
    Expression<double>? hb,
    Expression<String>? urineAlbumin,
    Expression<int>? fetalHr,
    Expression<bool>? fetalMovement,
    Expression<String>? dangerSigns,
    Expression<bool>? ifaTaken,
    Expression<bool>? calciumTaken,
    Expression<int>? ttDoseGiven,
    Expression<String>? notes,
    Expression<double>? gpsLat,
    Expression<double>? gpsLng,
    Expression<String>? photoPaths,
    Expression<String>? recordedBy,
    Expression<DateTime>? clientCreatedAt,
    Expression<String>? correctsId,
    Expression<bool>? synced,
    Expression<bool>? workerCreated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motherId != null) 'mother_id': motherId,
      if (visitNo != null) 'visit_no': visitNo,
      if (visitDate != null) 'visit_date': visitDate,
      if (bpSys != null) 'bp_sys': bpSys,
      if (bpDia != null) 'bp_dia': bpDia,
      if (weightKg != null) 'weight_kg': weightKg,
      if (fundalHeightCm != null) 'fundal_height_cm': fundalHeightCm,
      if (hb != null) 'hb': hb,
      if (urineAlbumin != null) 'urine_albumin': urineAlbumin,
      if (fetalHr != null) 'fetal_hr': fetalHr,
      if (fetalMovement != null) 'fetal_movement': fetalMovement,
      if (dangerSigns != null) 'danger_signs': dangerSigns,
      if (ifaTaken != null) 'ifa_taken': ifaTaken,
      if (calciumTaken != null) 'calcium_taken': calciumTaken,
      if (ttDoseGiven != null) 'tt_dose_given': ttDoseGiven,
      if (notes != null) 'notes': notes,
      if (gpsLat != null) 'gps_lat': gpsLat,
      if (gpsLng != null) 'gps_lng': gpsLng,
      if (photoPaths != null) 'photo_paths': photoPaths,
      if (recordedBy != null) 'recorded_by': recordedBy,
      if (clientCreatedAt != null) 'client_created_at': clientCreatedAt,
      if (correctsId != null) 'corrects_id': correctsId,
      if (synced != null) 'synced': synced,
      if (workerCreated != null) 'worker_created': workerCreated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AncVisitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? motherId,
      Value<int>? visitNo,
      Value<DateTime>? visitDate,
      Value<int?>? bpSys,
      Value<int?>? bpDia,
      Value<double?>? weightKg,
      Value<double?>? fundalHeightCm,
      Value<double?>? hb,
      Value<String?>? urineAlbumin,
      Value<int?>? fetalHr,
      Value<bool?>? fetalMovement,
      Value<String>? dangerSigns,
      Value<bool>? ifaTaken,
      Value<bool>? calciumTaken,
      Value<int?>? ttDoseGiven,
      Value<String?>? notes,
      Value<double?>? gpsLat,
      Value<double?>? gpsLng,
      Value<String>? photoPaths,
      Value<String>? recordedBy,
      Value<DateTime>? clientCreatedAt,
      Value<String?>? correctsId,
      Value<bool>? synced,
      Value<bool>? workerCreated,
      Value<int>? rowid}) {
    return AncVisitsCompanion(
      id: id ?? this.id,
      motherId: motherId ?? this.motherId,
      visitNo: visitNo ?? this.visitNo,
      visitDate: visitDate ?? this.visitDate,
      bpSys: bpSys ?? this.bpSys,
      bpDia: bpDia ?? this.bpDia,
      weightKg: weightKg ?? this.weightKg,
      fundalHeightCm: fundalHeightCm ?? this.fundalHeightCm,
      hb: hb ?? this.hb,
      urineAlbumin: urineAlbumin ?? this.urineAlbumin,
      fetalHr: fetalHr ?? this.fetalHr,
      fetalMovement: fetalMovement ?? this.fetalMovement,
      dangerSigns: dangerSigns ?? this.dangerSigns,
      ifaTaken: ifaTaken ?? this.ifaTaken,
      calciumTaken: calciumTaken ?? this.calciumTaken,
      ttDoseGiven: ttDoseGiven ?? this.ttDoseGiven,
      notes: notes ?? this.notes,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      photoPaths: photoPaths ?? this.photoPaths,
      recordedBy: recordedBy ?? this.recordedBy,
      clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
      correctsId: correctsId ?? this.correctsId,
      synced: synced ?? this.synced,
      workerCreated: workerCreated ?? this.workerCreated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<String>(motherId.value);
    }
    if (visitNo.present) {
      map['visit_no'] = Variable<int>(visitNo.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<DateTime>(visitDate.value);
    }
    if (bpSys.present) {
      map['bp_sys'] = Variable<int>(bpSys.value);
    }
    if (bpDia.present) {
      map['bp_dia'] = Variable<int>(bpDia.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (fundalHeightCm.present) {
      map['fundal_height_cm'] = Variable<double>(fundalHeightCm.value);
    }
    if (hb.present) {
      map['hb'] = Variable<double>(hb.value);
    }
    if (urineAlbumin.present) {
      map['urine_albumin'] = Variable<String>(urineAlbumin.value);
    }
    if (fetalHr.present) {
      map['fetal_hr'] = Variable<int>(fetalHr.value);
    }
    if (fetalMovement.present) {
      map['fetal_movement'] = Variable<bool>(fetalMovement.value);
    }
    if (dangerSigns.present) {
      map['danger_signs'] = Variable<String>(dangerSigns.value);
    }
    if (ifaTaken.present) {
      map['ifa_taken'] = Variable<bool>(ifaTaken.value);
    }
    if (calciumTaken.present) {
      map['calcium_taken'] = Variable<bool>(calciumTaken.value);
    }
    if (ttDoseGiven.present) {
      map['tt_dose_given'] = Variable<int>(ttDoseGiven.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (gpsLat.present) {
      map['gps_lat'] = Variable<double>(gpsLat.value);
    }
    if (gpsLng.present) {
      map['gps_lng'] = Variable<double>(gpsLng.value);
    }
    if (photoPaths.present) {
      map['photo_paths'] = Variable<String>(photoPaths.value);
    }
    if (recordedBy.present) {
      map['recorded_by'] = Variable<String>(recordedBy.value);
    }
    if (clientCreatedAt.present) {
      map['client_created_at'] = Variable<DateTime>(clientCreatedAt.value);
    }
    if (correctsId.present) {
      map['corrects_id'] = Variable<String>(correctsId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (workerCreated.present) {
      map['worker_created'] = Variable<bool>(workerCreated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AncVisitsCompanion(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('visitNo: $visitNo, ')
          ..write('visitDate: $visitDate, ')
          ..write('bpSys: $bpSys, ')
          ..write('bpDia: $bpDia, ')
          ..write('weightKg: $weightKg, ')
          ..write('fundalHeightCm: $fundalHeightCm, ')
          ..write('hb: $hb, ')
          ..write('urineAlbumin: $urineAlbumin, ')
          ..write('fetalHr: $fetalHr, ')
          ..write('fetalMovement: $fetalMovement, ')
          ..write('dangerSigns: $dangerSigns, ')
          ..write('ifaTaken: $ifaTaken, ')
          ..write('calciumTaken: $calciumTaken, ')
          ..write('ttDoseGiven: $ttDoseGiven, ')
          ..write('notes: $notes, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('photoPaths: $photoPaths, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('correctsId: $correctsId, ')
          ..write('synced: $synced, ')
          ..write('workerCreated: $workerCreated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _motherIdMeta =
      const VerificationMeta('motherId');
  @override
  late final GeneratedColumn<String> motherId = GeneratedColumn<String>(
      'mother_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES mothers (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionKnMeta =
      const VerificationMeta('instructionKn');
  @override
  late final GeneratedColumn<String> instructionKn = GeneratedColumn<String>(
      'instruction_kn', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _instructionEnMeta =
      const VerificationMeta('instructionEn');
  @override
  late final GeneratedColumn<String> instructionEn = GeneratedColumn<String>(
      'instruction_en', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normal'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('open'));
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
      'origin', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('self'));
  static const VerificationMeta _closedByVisitIdMeta =
      const VerificationMeta('closedByVisitId');
  @override
  late final GeneratedColumn<String> closedByVisitId = GeneratedColumn<String>(
      'closed_by_visit_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _closedAtMeta =
      const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
      'closed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        motherId,
        type,
        instructionKn,
        instructionEn,
        dueDate,
        priority,
        status,
        origin,
        closedByVisitId,
        createdAt,
        closedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mother_id')) {
      context.handle(_motherIdMeta,
          motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta));
    } else if (isInserting) {
      context.missing(_motherIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('instruction_kn')) {
      context.handle(
          _instructionKnMeta,
          instructionKn.isAcceptableOrUnknown(
              data['instruction_kn']!, _instructionKnMeta));
    }
    if (data.containsKey('instruction_en')) {
      context.handle(
          _instructionEnMeta,
          instructionEn.isAcceptableOrUnknown(
              data['instruction_en']!, _instructionEnMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    }
    if (data.containsKey('closed_by_visit_id')) {
      context.handle(
          _closedByVisitIdMeta,
          closedByVisitId.isAcceptableOrUnknown(
              data['closed_by_visit_id']!, _closedByVisitIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta,
          closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      motherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mother_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      instructionKn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instruction_kn']),
      instructionEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instruction_en']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin'])!,
      closedByVisitId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}closed_by_visit_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      closedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String motherId;

  /// ancVisit | followUp | referralFollowUp | labResult | counselling
  final String type;
  final String? instructionKn;
  final String? instructionEn;
  final DateTime dueDate;

  /// high | normal
  final String priority;

  /// open | done | missed
  final String status;

  /// doctor | system | self — doctor-assigned work is the point of the product.
  final String origin;
  final String? closedByVisitId;
  final DateTime createdAt;
  final DateTime? closedAt;
  const Task(
      {required this.id,
      required this.motherId,
      required this.type,
      this.instructionKn,
      this.instructionEn,
      required this.dueDate,
      required this.priority,
      required this.status,
      required this.origin,
      this.closedByVisitId,
      required this.createdAt,
      this.closedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mother_id'] = Variable<String>(motherId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || instructionKn != null) {
      map['instruction_kn'] = Variable<String>(instructionKn);
    }
    if (!nullToAbsent || instructionEn != null) {
      map['instruction_en'] = Variable<String>(instructionEn);
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || closedByVisitId != null) {
      map['closed_by_visit_id'] = Variable<String>(closedByVisitId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      motherId: Value(motherId),
      type: Value(type),
      instructionKn: instructionKn == null && nullToAbsent
          ? const Value.absent()
          : Value(instructionKn),
      instructionEn: instructionEn == null && nullToAbsent
          ? const Value.absent()
          : Value(instructionEn),
      dueDate: Value(dueDate),
      priority: Value(priority),
      status: Value(status),
      origin: Value(origin),
      closedByVisitId: closedByVisitId == null && nullToAbsent
          ? const Value.absent()
          : Value(closedByVisitId),
      createdAt: Value(createdAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      motherId: serializer.fromJson<String>(json['motherId']),
      type: serializer.fromJson<String>(json['type']),
      instructionKn: serializer.fromJson<String?>(json['instructionKn']),
      instructionEn: serializer.fromJson<String?>(json['instructionEn']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      origin: serializer.fromJson<String>(json['origin']),
      closedByVisitId: serializer.fromJson<String?>(json['closedByVisitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'motherId': serializer.toJson<String>(motherId),
      'type': serializer.toJson<String>(type),
      'instructionKn': serializer.toJson<String?>(instructionKn),
      'instructionEn': serializer.toJson<String?>(instructionEn),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'origin': serializer.toJson<String>(origin),
      'closedByVisitId': serializer.toJson<String?>(closedByVisitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
    };
  }

  Task copyWith(
          {String? id,
          String? motherId,
          String? type,
          Value<String?> instructionKn = const Value.absent(),
          Value<String?> instructionEn = const Value.absent(),
          DateTime? dueDate,
          String? priority,
          String? status,
          String? origin,
          Value<String?> closedByVisitId = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> closedAt = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        motherId: motherId ?? this.motherId,
        type: type ?? this.type,
        instructionKn:
            instructionKn.present ? instructionKn.value : this.instructionKn,
        instructionEn:
            instructionEn.present ? instructionEn.value : this.instructionEn,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        origin: origin ?? this.origin,
        closedByVisitId: closedByVisitId.present
            ? closedByVisitId.value
            : this.closedByVisitId,
        createdAt: createdAt ?? this.createdAt,
        closedAt: closedAt.present ? closedAt.value : this.closedAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      type: data.type.present ? data.type.value : this.type,
      instructionKn: data.instructionKn.present
          ? data.instructionKn.value
          : this.instructionKn,
      instructionEn: data.instructionEn.present
          ? data.instructionEn.value
          : this.instructionEn,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      closedByVisitId: data.closedByVisitId.present
          ? data.closedByVisitId.value
          : this.closedByVisitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('type: $type, ')
          ..write('instructionKn: $instructionKn, ')
          ..write('instructionEn: $instructionEn, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('closedByVisitId: $closedByVisitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      motherId,
      type,
      instructionKn,
      instructionEn,
      dueDate,
      priority,
      status,
      origin,
      closedByVisitId,
      createdAt,
      closedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.motherId == this.motherId &&
          other.type == this.type &&
          other.instructionKn == this.instructionKn &&
          other.instructionEn == this.instructionEn &&
          other.dueDate == this.dueDate &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.closedByVisitId == this.closedByVisitId &&
          other.createdAt == this.createdAt &&
          other.closedAt == this.closedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> motherId;
  final Value<String> type;
  final Value<String?> instructionKn;
  final Value<String?> instructionEn;
  final Value<DateTime> dueDate;
  final Value<String> priority;
  final Value<String> status;
  final Value<String> origin;
  final Value<String?> closedByVisitId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> closedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.motherId = const Value.absent(),
    this.type = const Value.absent(),
    this.instructionKn = const Value.absent(),
    this.instructionEn = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.closedByVisitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String motherId,
    required String type,
    this.instructionKn = const Value.absent(),
    this.instructionEn = const Value.absent(),
    required DateTime dueDate,
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.closedByVisitId = const Value.absent(),
    required DateTime createdAt,
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        motherId = Value(motherId),
        type = Value(type),
        dueDate = Value(dueDate),
        createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? motherId,
    Expression<String>? type,
    Expression<String>? instructionKn,
    Expression<String>? instructionEn,
    Expression<DateTime>? dueDate,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<String>? origin,
    Expression<String>? closedByVisitId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motherId != null) 'mother_id': motherId,
      if (type != null) 'type': type,
      if (instructionKn != null) 'instruction_kn': instructionKn,
      if (instructionEn != null) 'instruction_en': instructionEn,
      if (dueDate != null) 'due_date': dueDate,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (closedByVisitId != null) 'closed_by_visit_id': closedByVisitId,
      if (createdAt != null) 'created_at': createdAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? motherId,
      Value<String>? type,
      Value<String?>? instructionKn,
      Value<String?>? instructionEn,
      Value<DateTime>? dueDate,
      Value<String>? priority,
      Value<String>? status,
      Value<String>? origin,
      Value<String?>? closedByVisitId,
      Value<DateTime>? createdAt,
      Value<DateTime?>? closedAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      motherId: motherId ?? this.motherId,
      type: type ?? this.type,
      instructionKn: instructionKn ?? this.instructionKn,
      instructionEn: instructionEn ?? this.instructionEn,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      closedByVisitId: closedByVisitId ?? this.closedByVisitId,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<String>(motherId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (instructionKn.present) {
      map['instruction_kn'] = Variable<String>(instructionKn.value);
    }
    if (instructionEn.present) {
      map['instruction_en'] = Variable<String>(instructionEn.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (closedByVisitId.present) {
      map['closed_by_visit_id'] = Variable<String>(closedByVisitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('type: $type, ')
          ..write('instructionKn: $instructionKn, ')
          ..write('instructionEn: $instructionEn, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('closedByVisitId: $closedByVisitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, Alert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _motherIdMeta =
      const VerificationMeta('motherId');
  @override
  late final GeneratedColumn<String> motherId = GeneratedColumn<String>(
      'mother_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES mothers (id)'));
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
      'rule_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageKnMeta =
      const VerificationMeta('messageKn');
  @override
  late final GeneratedColumn<String> messageKn = GeneratedColumn<String>(
      'message_kn', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageEnMeta =
      const VerificationMeta('messageEn');
  @override
  late final GeneratedColumn<String> messageEn = GeneratedColumn<String>(
      'message_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _visitIdMeta =
      const VerificationMeta('visitId');
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
      'visit_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _acknowledgedMeta =
      const VerificationMeta('acknowledged');
  @override
  late final GeneratedColumn<bool> acknowledged = GeneratedColumn<bool>(
      'acknowledged', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("acknowledged" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        motherId,
        ruleId,
        severity,
        messageKn,
        messageEn,
        visitId,
        createdAt,
        acknowledged
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(Insertable<Alert> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mother_id')) {
      context.handle(_motherIdMeta,
          motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta));
    } else if (isInserting) {
      context.missing(_motherIdMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(_ruleIdMeta,
          ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta));
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('message_kn')) {
      context.handle(_messageKnMeta,
          messageKn.isAcceptableOrUnknown(data['message_kn']!, _messageKnMeta));
    } else if (isInserting) {
      context.missing(_messageKnMeta);
    }
    if (data.containsKey('message_en')) {
      context.handle(_messageEnMeta,
          messageEn.isAcceptableOrUnknown(data['message_en']!, _messageEnMeta));
    } else if (isInserting) {
      context.missing(_messageEnMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(_visitIdMeta,
          visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('acknowledged')) {
      context.handle(
          _acknowledgedMeta,
          acknowledged.isAcceptableOrUnknown(
              data['acknowledged']!, _acknowledgedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alert(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      motherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mother_id'])!,
      ruleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_id'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      messageKn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_kn'])!,
      messageEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_en'])!,
      visitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visit_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      acknowledged: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}acknowledged'])!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }
}

class Alert extends DataClass implements Insertable<Alert> {
  final String id;
  final String motherId;
  final String ruleId;

  /// red | amber
  final String severity;
  final String messageKn;
  final String messageEn;
  final String? visitId;
  final DateTime createdAt;
  final bool acknowledged;
  const Alert(
      {required this.id,
      required this.motherId,
      required this.ruleId,
      required this.severity,
      required this.messageKn,
      required this.messageEn,
      this.visitId,
      required this.createdAt,
      required this.acknowledged});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mother_id'] = Variable<String>(motherId);
    map['rule_id'] = Variable<String>(ruleId);
    map['severity'] = Variable<String>(severity);
    map['message_kn'] = Variable<String>(messageKn);
    map['message_en'] = Variable<String>(messageEn);
    if (!nullToAbsent || visitId != null) {
      map['visit_id'] = Variable<String>(visitId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['acknowledged'] = Variable<bool>(acknowledged);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      motherId: Value(motherId),
      ruleId: Value(ruleId),
      severity: Value(severity),
      messageKn: Value(messageKn),
      messageEn: Value(messageEn),
      visitId: visitId == null && nullToAbsent
          ? const Value.absent()
          : Value(visitId),
      createdAt: Value(createdAt),
      acknowledged: Value(acknowledged),
    );
  }

  factory Alert.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alert(
      id: serializer.fromJson<String>(json['id']),
      motherId: serializer.fromJson<String>(json['motherId']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      severity: serializer.fromJson<String>(json['severity']),
      messageKn: serializer.fromJson<String>(json['messageKn']),
      messageEn: serializer.fromJson<String>(json['messageEn']),
      visitId: serializer.fromJson<String?>(json['visitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      acknowledged: serializer.fromJson<bool>(json['acknowledged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'motherId': serializer.toJson<String>(motherId),
      'ruleId': serializer.toJson<String>(ruleId),
      'severity': serializer.toJson<String>(severity),
      'messageKn': serializer.toJson<String>(messageKn),
      'messageEn': serializer.toJson<String>(messageEn),
      'visitId': serializer.toJson<String?>(visitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'acknowledged': serializer.toJson<bool>(acknowledged),
    };
  }

  Alert copyWith(
          {String? id,
          String? motherId,
          String? ruleId,
          String? severity,
          String? messageKn,
          String? messageEn,
          Value<String?> visitId = const Value.absent(),
          DateTime? createdAt,
          bool? acknowledged}) =>
      Alert(
        id: id ?? this.id,
        motherId: motherId ?? this.motherId,
        ruleId: ruleId ?? this.ruleId,
        severity: severity ?? this.severity,
        messageKn: messageKn ?? this.messageKn,
        messageEn: messageEn ?? this.messageEn,
        visitId: visitId.present ? visitId.value : this.visitId,
        createdAt: createdAt ?? this.createdAt,
        acknowledged: acknowledged ?? this.acknowledged,
      );
  Alert copyWithCompanion(AlertsCompanion data) {
    return Alert(
      id: data.id.present ? data.id.value : this.id,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      severity: data.severity.present ? data.severity.value : this.severity,
      messageKn: data.messageKn.present ? data.messageKn.value : this.messageKn,
      messageEn: data.messageEn.present ? data.messageEn.value : this.messageEn,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      acknowledged: data.acknowledged.present
          ? data.acknowledged.value
          : this.acknowledged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Alert(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('ruleId: $ruleId, ')
          ..write('severity: $severity, ')
          ..write('messageKn: $messageKn, ')
          ..write('messageEn: $messageEn, ')
          ..write('visitId: $visitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('acknowledged: $acknowledged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, motherId, ruleId, severity, messageKn,
      messageEn, visitId, createdAt, acknowledged);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alert &&
          other.id == this.id &&
          other.motherId == this.motherId &&
          other.ruleId == this.ruleId &&
          other.severity == this.severity &&
          other.messageKn == this.messageKn &&
          other.messageEn == this.messageEn &&
          other.visitId == this.visitId &&
          other.createdAt == this.createdAt &&
          other.acknowledged == this.acknowledged);
}

class AlertsCompanion extends UpdateCompanion<Alert> {
  final Value<String> id;
  final Value<String> motherId;
  final Value<String> ruleId;
  final Value<String> severity;
  final Value<String> messageKn;
  final Value<String> messageEn;
  final Value<String?> visitId;
  final Value<DateTime> createdAt;
  final Value<bool> acknowledged;
  final Value<int> rowid;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.motherId = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.severity = const Value.absent(),
    this.messageKn = const Value.absent(),
    this.messageEn = const Value.absent(),
    this.visitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.acknowledged = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertsCompanion.insert({
    required String id,
    required String motherId,
    required String ruleId,
    required String severity,
    required String messageKn,
    required String messageEn,
    this.visitId = const Value.absent(),
    required DateTime createdAt,
    this.acknowledged = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        motherId = Value(motherId),
        ruleId = Value(ruleId),
        severity = Value(severity),
        messageKn = Value(messageKn),
        messageEn = Value(messageEn),
        createdAt = Value(createdAt);
  static Insertable<Alert> custom({
    Expression<String>? id,
    Expression<String>? motherId,
    Expression<String>? ruleId,
    Expression<String>? severity,
    Expression<String>? messageKn,
    Expression<String>? messageEn,
    Expression<String>? visitId,
    Expression<DateTime>? createdAt,
    Expression<bool>? acknowledged,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motherId != null) 'mother_id': motherId,
      if (ruleId != null) 'rule_id': ruleId,
      if (severity != null) 'severity': severity,
      if (messageKn != null) 'message_kn': messageKn,
      if (messageEn != null) 'message_en': messageEn,
      if (visitId != null) 'visit_id': visitId,
      if (createdAt != null) 'created_at': createdAt,
      if (acknowledged != null) 'acknowledged': acknowledged,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertsCompanion copyWith(
      {Value<String>? id,
      Value<String>? motherId,
      Value<String>? ruleId,
      Value<String>? severity,
      Value<String>? messageKn,
      Value<String>? messageEn,
      Value<String?>? visitId,
      Value<DateTime>? createdAt,
      Value<bool>? acknowledged,
      Value<int>? rowid}) {
    return AlertsCompanion(
      id: id ?? this.id,
      motherId: motherId ?? this.motherId,
      ruleId: ruleId ?? this.ruleId,
      severity: severity ?? this.severity,
      messageKn: messageKn ?? this.messageKn,
      messageEn: messageEn ?? this.messageEn,
      visitId: visitId ?? this.visitId,
      createdAt: createdAt ?? this.createdAt,
      acknowledged: acknowledged ?? this.acknowledged,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<String>(motherId.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (messageKn.present) {
      map['message_kn'] = Variable<String>(messageKn.value);
    }
    if (messageEn.present) {
      map['message_en'] = Variable<String>(messageEn.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (acknowledged.present) {
      map['acknowledged'] = Variable<bool>(acknowledged.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('ruleId: $ruleId, ')
          ..write('severity: $severity, ')
          ..write('messageKn: $messageKn, ')
          ..write('messageEn: $messageEn, ')
          ..write('visitId: $visitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('acknowledged: $acknowledged, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferralsTable extends Referrals
    with TableInfo<$ReferralsTable, Referral> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferralsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _motherIdMeta =
      const VerificationMeta('motherId');
  @override
  late final GeneratedColumn<String> motherId = GeneratedColumn<String>(
      'mother_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES mothers (id)'));
  static const VerificationMeta _toFacilityMeta =
      const VerificationMeta('toFacility');
  @override
  late final GeneratedColumn<String> toFacility = GeneratedColumn<String>(
      'to_facility', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonKnMeta =
      const VerificationMeta('reasonKn');
  @override
  late final GeneratedColumn<String> reasonKn = GeneratedColumn<String>(
      'reason_kn', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonEnMeta =
      const VerificationMeta('reasonEn');
  @override
  late final GeneratedColumn<String> reasonEn = GeneratedColumn<String>(
      'reason_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _visitIdMeta =
      const VerificationMeta('visitId');
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
      'visit_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        motherId,
        toFacility,
        reasonKn,
        reasonEn,
        status,
        visitId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'referrals';
  @override
  VerificationContext validateIntegrity(Insertable<Referral> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mother_id')) {
      context.handle(_motherIdMeta,
          motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta));
    } else if (isInserting) {
      context.missing(_motherIdMeta);
    }
    if (data.containsKey('to_facility')) {
      context.handle(
          _toFacilityMeta,
          toFacility.isAcceptableOrUnknown(
              data['to_facility']!, _toFacilityMeta));
    } else if (isInserting) {
      context.missing(_toFacilityMeta);
    }
    if (data.containsKey('reason_kn')) {
      context.handle(_reasonKnMeta,
          reasonKn.isAcceptableOrUnknown(data['reason_kn']!, _reasonKnMeta));
    } else if (isInserting) {
      context.missing(_reasonKnMeta);
    }
    if (data.containsKey('reason_en')) {
      context.handle(_reasonEnMeta,
          reasonEn.isAcceptableOrUnknown(data['reason_en']!, _reasonEnMeta));
    } else if (isInserting) {
      context.missing(_reasonEnMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('visit_id')) {
      context.handle(_visitIdMeta,
          visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Referral map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Referral(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      motherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mother_id'])!,
      toFacility: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_facility'])!,
      reasonKn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason_kn'])!,
      reasonEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason_en'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      visitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visit_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ReferralsTable createAlias(String alias) {
    return $ReferralsTable(attachedDatabase, alias);
  }
}

class Referral extends DataClass implements Insertable<Referral> {
  final String id;
  final String motherId;
  final String toFacility;
  final String reasonKn;
  final String reasonEn;

  /// pending | accepted | completed
  final String status;
  final String? visitId;
  final DateTime createdAt;
  const Referral(
      {required this.id,
      required this.motherId,
      required this.toFacility,
      required this.reasonKn,
      required this.reasonEn,
      required this.status,
      this.visitId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mother_id'] = Variable<String>(motherId);
    map['to_facility'] = Variable<String>(toFacility);
    map['reason_kn'] = Variable<String>(reasonKn);
    map['reason_en'] = Variable<String>(reasonEn);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || visitId != null) {
      map['visit_id'] = Variable<String>(visitId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReferralsCompanion toCompanion(bool nullToAbsent) {
    return ReferralsCompanion(
      id: Value(id),
      motherId: Value(motherId),
      toFacility: Value(toFacility),
      reasonKn: Value(reasonKn),
      reasonEn: Value(reasonEn),
      status: Value(status),
      visitId: visitId == null && nullToAbsent
          ? const Value.absent()
          : Value(visitId),
      createdAt: Value(createdAt),
    );
  }

  factory Referral.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Referral(
      id: serializer.fromJson<String>(json['id']),
      motherId: serializer.fromJson<String>(json['motherId']),
      toFacility: serializer.fromJson<String>(json['toFacility']),
      reasonKn: serializer.fromJson<String>(json['reasonKn']),
      reasonEn: serializer.fromJson<String>(json['reasonEn']),
      status: serializer.fromJson<String>(json['status']),
      visitId: serializer.fromJson<String?>(json['visitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'motherId': serializer.toJson<String>(motherId),
      'toFacility': serializer.toJson<String>(toFacility),
      'reasonKn': serializer.toJson<String>(reasonKn),
      'reasonEn': serializer.toJson<String>(reasonEn),
      'status': serializer.toJson<String>(status),
      'visitId': serializer.toJson<String?>(visitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Referral copyWith(
          {String? id,
          String? motherId,
          String? toFacility,
          String? reasonKn,
          String? reasonEn,
          String? status,
          Value<String?> visitId = const Value.absent(),
          DateTime? createdAt}) =>
      Referral(
        id: id ?? this.id,
        motherId: motherId ?? this.motherId,
        toFacility: toFacility ?? this.toFacility,
        reasonKn: reasonKn ?? this.reasonKn,
        reasonEn: reasonEn ?? this.reasonEn,
        status: status ?? this.status,
        visitId: visitId.present ? visitId.value : this.visitId,
        createdAt: createdAt ?? this.createdAt,
      );
  Referral copyWithCompanion(ReferralsCompanion data) {
    return Referral(
      id: data.id.present ? data.id.value : this.id,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      toFacility:
          data.toFacility.present ? data.toFacility.value : this.toFacility,
      reasonKn: data.reasonKn.present ? data.reasonKn.value : this.reasonKn,
      reasonEn: data.reasonEn.present ? data.reasonEn.value : this.reasonEn,
      status: data.status.present ? data.status.value : this.status,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Referral(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('toFacility: $toFacility, ')
          ..write('reasonKn: $reasonKn, ')
          ..write('reasonEn: $reasonEn, ')
          ..write('status: $status, ')
          ..write('visitId: $visitId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, motherId, toFacility, reasonKn, reasonEn, status, visitId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Referral &&
          other.id == this.id &&
          other.motherId == this.motherId &&
          other.toFacility == this.toFacility &&
          other.reasonKn == this.reasonKn &&
          other.reasonEn == this.reasonEn &&
          other.status == this.status &&
          other.visitId == this.visitId &&
          other.createdAt == this.createdAt);
}

class ReferralsCompanion extends UpdateCompanion<Referral> {
  final Value<String> id;
  final Value<String> motherId;
  final Value<String> toFacility;
  final Value<String> reasonKn;
  final Value<String> reasonEn;
  final Value<String> status;
  final Value<String?> visitId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReferralsCompanion({
    this.id = const Value.absent(),
    this.motherId = const Value.absent(),
    this.toFacility = const Value.absent(),
    this.reasonKn = const Value.absent(),
    this.reasonEn = const Value.absent(),
    this.status = const Value.absent(),
    this.visitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferralsCompanion.insert({
    required String id,
    required String motherId,
    required String toFacility,
    required String reasonKn,
    required String reasonEn,
    this.status = const Value.absent(),
    this.visitId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        motherId = Value(motherId),
        toFacility = Value(toFacility),
        reasonKn = Value(reasonKn),
        reasonEn = Value(reasonEn),
        createdAt = Value(createdAt);
  static Insertable<Referral> custom({
    Expression<String>? id,
    Expression<String>? motherId,
    Expression<String>? toFacility,
    Expression<String>? reasonKn,
    Expression<String>? reasonEn,
    Expression<String>? status,
    Expression<String>? visitId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motherId != null) 'mother_id': motherId,
      if (toFacility != null) 'to_facility': toFacility,
      if (reasonKn != null) 'reason_kn': reasonKn,
      if (reasonEn != null) 'reason_en': reasonEn,
      if (status != null) 'status': status,
      if (visitId != null) 'visit_id': visitId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferralsCompanion copyWith(
      {Value<String>? id,
      Value<String>? motherId,
      Value<String>? toFacility,
      Value<String>? reasonKn,
      Value<String>? reasonEn,
      Value<String>? status,
      Value<String?>? visitId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ReferralsCompanion(
      id: id ?? this.id,
      motherId: motherId ?? this.motherId,
      toFacility: toFacility ?? this.toFacility,
      reasonKn: reasonKn ?? this.reasonKn,
      reasonEn: reasonEn ?? this.reasonEn,
      status: status ?? this.status,
      visitId: visitId ?? this.visitId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<String>(motherId.value);
    }
    if (toFacility.present) {
      map['to_facility'] = Variable<String>(toFacility.value);
    }
    if (reasonKn.present) {
      map['reason_kn'] = Variable<String>(reasonKn.value);
    }
    if (reasonEn.present) {
      map['reason_en'] = Variable<String>(reasonEn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferralsCompanion(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('toFacility: $toFacility, ')
          ..write('reasonKn: $reasonKn, ')
          ..write('reasonEn: $reasonEn, ')
          ..write('status: $status, ')
          ..write('visitId: $visitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTableMeta =
      const VerificationMeta('entityTable');
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
      'table_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
      'record_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityTable,
        recordId,
        operation,
        payload,
        status,
        retryCount,
        lastError,
        createdAt,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
          _entityTableMeta,
          entityTable.isAcceptableOrUnknown(
              data['table_name']!, _entityTableMeta));
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityTable: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}table_name'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final String id;
  final String entityTable;
  final String recordId;

  /// insert | update
  final String operation;
  final String payload;

  /// pending | syncing | synced | failed
  final String status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const OutboxData(
      {required this.id,
      required this.entityTable,
      required this.recordId,
      required this.operation,
      required this.payload,
      required this.status,
      required this.retryCount,
      this.lastError,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(entityTable);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      recordId: Value(recordId),
      operation: Value(operation),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory OutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<String>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  OutboxData copyWith(
          {String? id,
          String? entityTable,
          String? recordId,
          String? operation,
          String? payload,
          String? status,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      OutboxData(
        id: id ?? this.id,
        entityTable: entityTable ?? this.entityTable,
        recordId: recordId ?? this.recordId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      entityTable:
          data.entityTable.present ? data.entityTable.value : this.entityTable,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityTable, recordId, operation, payload,
      status, retryCount, lastError, createdAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<String> id;
  final Value<String> entityTable;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String id,
    required String entityTable,
    required String recordId,
    required String operation,
    required String payload,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityTable = Value(entityTable),
        recordId = Value(recordId),
        operation = Value(operation),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<String>? id,
    Expression<String>? entityTable,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'table_name': entityTable,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityTable,
      Value<String>? recordId,
      Value<String>? operation,
      Value<String>? payload,
      Value<String>? status,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt,
      Value<int>? rowid}) {
    return OutboxCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityTable.present) {
      map['table_name'] = Variable<String>(entityTable.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MothersTable mothers = $MothersTable(this);
  late final $AncVisitsTable ancVisits = $AncVisitsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $ReferralsTable referrals = $ReferralsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [mothers, ancVisits, tasks, alerts, referrals, outbox];
}

typedef $$MothersTableCreateCompanionBuilder = MothersCompanion Function({
  required String id,
  required String name,
  required int age,
  Value<String?> husbandName,
  Value<String?> phone,
  Value<String?> email,
  Value<bool> emailVerified,
  Value<double?> homeLat,
  Value<double?> homeLng,
  Value<String?> homeNote,
  Value<DateTime?> homeLocatedAt,
  required String village,
  Value<String?> subCentre,
  Value<String?> abhaId,
  required DateTime lmp,
  Value<int> gravida,
  Value<int> para,
  Value<String?> bloodGroup,
  Value<double?> heightCm,
  Value<bool> isBpl,
  Value<String> prevComplications,
  Value<String> riskLevel,
  required DateTime createdAt,
  Value<bool> synced,
  Value<bool> workerCreated,
  Value<int> rowid,
});
typedef $$MothersTableUpdateCompanionBuilder = MothersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> age,
  Value<String?> husbandName,
  Value<String?> phone,
  Value<String?> email,
  Value<bool> emailVerified,
  Value<double?> homeLat,
  Value<double?> homeLng,
  Value<String?> homeNote,
  Value<DateTime?> homeLocatedAt,
  Value<String> village,
  Value<String?> subCentre,
  Value<String?> abhaId,
  Value<DateTime> lmp,
  Value<int> gravida,
  Value<int> para,
  Value<String?> bloodGroup,
  Value<double?> heightCm,
  Value<bool> isBpl,
  Value<String> prevComplications,
  Value<String> riskLevel,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<bool> workerCreated,
  Value<int> rowid,
});

final class $$MothersTableReferences
    extends BaseReferences<_$AppDatabase, $MothersTable, Mother> {
  $$MothersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AncVisitsTable, List<AncVisit>>
      _ancVisitsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.ancVisits,
              aliasName: 'mothers__id__anc_visits__mother_id');

  $$AncVisitsTableProcessedTableManager get ancVisitsRefs {
    final manager = $$AncVisitsTableTableManager($_db, $_db.ancVisits)
        .filter((f) => f.motherId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ancVisitsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: 'mothers__id__tasks__mother_id');

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.motherId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AlertsTable, List<Alert>> _alertsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.alerts,
          aliasName: 'mothers__id__alerts__mother_id');

  $$AlertsTableProcessedTableManager get alertsRefs {
    final manager = $$AlertsTableTableManager($_db, $_db.alerts)
        .filter((f) => f.motherId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_alertsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReferralsTable, List<Referral>>
      _referralsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.referrals,
              aliasName: 'mothers__id__referrals__mother_id');

  $$ReferralsTableProcessedTableManager get referralsRefs {
    final manager = $$ReferralsTableTableManager($_db, $_db.referrals)
        .filter((f) => f.motherId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_referralsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MothersTableFilterComposer
    extends Composer<_$AppDatabase, $MothersTable> {
  $$MothersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get husbandName => $composableBuilder(
      column: $table.husbandName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get emailVerified => $composableBuilder(
      column: $table.emailVerified, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get homeLat => $composableBuilder(
      column: $table.homeLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get homeLng => $composableBuilder(
      column: $table.homeLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homeNote => $composableBuilder(
      column: $table.homeNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get homeLocatedAt => $composableBuilder(
      column: $table.homeLocatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get village => $composableBuilder(
      column: $table.village, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCentre => $composableBuilder(
      column: $table.subCentre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get abhaId => $composableBuilder(
      column: $table.abhaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lmp => $composableBuilder(
      column: $table.lmp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gravida => $composableBuilder(
      column: $table.gravida, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get para => $composableBuilder(
      column: $table.para, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bloodGroup => $composableBuilder(
      column: $table.bloodGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBpl => $composableBuilder(
      column: $table.isBpl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevComplications => $composableBuilder(
      column: $table.prevComplications,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get riskLevel => $composableBuilder(
      column: $table.riskLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get workerCreated => $composableBuilder(
      column: $table.workerCreated, builder: (column) => ColumnFilters(column));

  Expression<bool> ancVisitsRefs(
      Expression<bool> Function($$AncVisitsTableFilterComposer f) f) {
    final $$AncVisitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ancVisits,
        getReferencedColumn: (t) => t.motherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AncVisitsTableFilterComposer(
              $db: $db,
              $table: $db.ancVisits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.motherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> alertsRefs(
      Expression<bool> Function($$AlertsTableFilterComposer f) f) {
    final $$AlertsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.alerts,
        getReferencedColumn: (t) => t.motherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlertsTableFilterComposer(
              $db: $db,
              $table: $db.alerts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> referralsRefs(
      Expression<bool> Function($$ReferralsTableFilterComposer f) f) {
    final $$ReferralsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.referrals,
        getReferencedColumn: (t) => t.motherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReferralsTableFilterComposer(
              $db: $db,
              $table: $db.referrals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MothersTableOrderingComposer
    extends Composer<_$AppDatabase, $MothersTable> {
  $$MothersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get husbandName => $composableBuilder(
      column: $table.husbandName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get emailVerified => $composableBuilder(
      column: $table.emailVerified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get homeLat => $composableBuilder(
      column: $table.homeLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get homeLng => $composableBuilder(
      column: $table.homeLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homeNote => $composableBuilder(
      column: $table.homeNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get homeLocatedAt => $composableBuilder(
      column: $table.homeLocatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get village => $composableBuilder(
      column: $table.village, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCentre => $composableBuilder(
      column: $table.subCentre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get abhaId => $composableBuilder(
      column: $table.abhaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lmp => $composableBuilder(
      column: $table.lmp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gravida => $composableBuilder(
      column: $table.gravida, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get para => $composableBuilder(
      column: $table.para, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bloodGroup => $composableBuilder(
      column: $table.bloodGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBpl => $composableBuilder(
      column: $table.isBpl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevComplications => $composableBuilder(
      column: $table.prevComplications,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get riskLevel => $composableBuilder(
      column: $table.riskLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get workerCreated => $composableBuilder(
      column: $table.workerCreated,
      builder: (column) => ColumnOrderings(column));
}

class $$MothersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MothersTable> {
  $$MothersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get husbandName => $composableBuilder(
      column: $table.husbandName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get emailVerified => $composableBuilder(
      column: $table.emailVerified, builder: (column) => column);

  GeneratedColumn<double> get homeLat =>
      $composableBuilder(column: $table.homeLat, builder: (column) => column);

  GeneratedColumn<double> get homeLng =>
      $composableBuilder(column: $table.homeLng, builder: (column) => column);

  GeneratedColumn<String> get homeNote =>
      $composableBuilder(column: $table.homeNote, builder: (column) => column);

  GeneratedColumn<DateTime> get homeLocatedAt => $composableBuilder(
      column: $table.homeLocatedAt, builder: (column) => column);

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get subCentre =>
      $composableBuilder(column: $table.subCentre, builder: (column) => column);

  GeneratedColumn<String> get abhaId =>
      $composableBuilder(column: $table.abhaId, builder: (column) => column);

  GeneratedColumn<DateTime> get lmp =>
      $composableBuilder(column: $table.lmp, builder: (column) => column);

  GeneratedColumn<int> get gravida =>
      $composableBuilder(column: $table.gravida, builder: (column) => column);

  GeneratedColumn<int> get para =>
      $composableBuilder(column: $table.para, builder: (column) => column);

  GeneratedColumn<String> get bloodGroup => $composableBuilder(
      column: $table.bloodGroup, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<bool> get isBpl =>
      $composableBuilder(column: $table.isBpl, builder: (column) => column);

  GeneratedColumn<String> get prevComplications => $composableBuilder(
      column: $table.prevComplications, builder: (column) => column);

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get workerCreated => $composableBuilder(
      column: $table.workerCreated, builder: (column) => column);

  Expression<T> ancVisitsRefs<T extends Object>(
      Expression<T> Function($$AncVisitsTableAnnotationComposer a) f) {
    final $$AncVisitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.ancVisits,
        getReferencedColumn: (t) => t.motherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AncVisitsTableAnnotationComposer(
              $db: $db,
              $table: $db.ancVisits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.motherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> alertsRefs<T extends Object>(
      Expression<T> Function($$AlertsTableAnnotationComposer a) f) {
    final $$AlertsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.alerts,
        getReferencedColumn: (t) => t.motherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AlertsTableAnnotationComposer(
              $db: $db,
              $table: $db.alerts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> referralsRefs<T extends Object>(
      Expression<T> Function($$ReferralsTableAnnotationComposer a) f) {
    final $$ReferralsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.referrals,
        getReferencedColumn: (t) => t.motherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReferralsTableAnnotationComposer(
              $db: $db,
              $table: $db.referrals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MothersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MothersTable,
    Mother,
    $$MothersTableFilterComposer,
    $$MothersTableOrderingComposer,
    $$MothersTableAnnotationComposer,
    $$MothersTableCreateCompanionBuilder,
    $$MothersTableUpdateCompanionBuilder,
    (Mother, $$MothersTableReferences),
    Mother,
    PrefetchHooks Function(
        {bool ancVisitsRefs,
        bool tasksRefs,
        bool alertsRefs,
        bool referralsRefs})> {
  $$MothersTableTableManager(_$AppDatabase db, $MothersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MothersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MothersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MothersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> age = const Value.absent(),
            Value<String?> husbandName = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<bool> emailVerified = const Value.absent(),
            Value<double?> homeLat = const Value.absent(),
            Value<double?> homeLng = const Value.absent(),
            Value<String?> homeNote = const Value.absent(),
            Value<DateTime?> homeLocatedAt = const Value.absent(),
            Value<String> village = const Value.absent(),
            Value<String?> subCentre = const Value.absent(),
            Value<String?> abhaId = const Value.absent(),
            Value<DateTime> lmp = const Value.absent(),
            Value<int> gravida = const Value.absent(),
            Value<int> para = const Value.absent(),
            Value<String?> bloodGroup = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<bool> isBpl = const Value.absent(),
            Value<String> prevComplications = const Value.absent(),
            Value<String> riskLevel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<bool> workerCreated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MothersCompanion(
            id: id,
            name: name,
            age: age,
            husbandName: husbandName,
            phone: phone,
            email: email,
            emailVerified: emailVerified,
            homeLat: homeLat,
            homeLng: homeLng,
            homeNote: homeNote,
            homeLocatedAt: homeLocatedAt,
            village: village,
            subCentre: subCentre,
            abhaId: abhaId,
            lmp: lmp,
            gravida: gravida,
            para: para,
            bloodGroup: bloodGroup,
            heightCm: heightCm,
            isBpl: isBpl,
            prevComplications: prevComplications,
            riskLevel: riskLevel,
            createdAt: createdAt,
            synced: synced,
            workerCreated: workerCreated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int age,
            Value<String?> husbandName = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<bool> emailVerified = const Value.absent(),
            Value<double?> homeLat = const Value.absent(),
            Value<double?> homeLng = const Value.absent(),
            Value<String?> homeNote = const Value.absent(),
            Value<DateTime?> homeLocatedAt = const Value.absent(),
            required String village,
            Value<String?> subCentre = const Value.absent(),
            Value<String?> abhaId = const Value.absent(),
            required DateTime lmp,
            Value<int> gravida = const Value.absent(),
            Value<int> para = const Value.absent(),
            Value<String?> bloodGroup = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<bool> isBpl = const Value.absent(),
            Value<String> prevComplications = const Value.absent(),
            Value<String> riskLevel = const Value.absent(),
            required DateTime createdAt,
            Value<bool> synced = const Value.absent(),
            Value<bool> workerCreated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MothersCompanion.insert(
            id: id,
            name: name,
            age: age,
            husbandName: husbandName,
            phone: phone,
            email: email,
            emailVerified: emailVerified,
            homeLat: homeLat,
            homeLng: homeLng,
            homeNote: homeNote,
            homeLocatedAt: homeLocatedAt,
            village: village,
            subCentre: subCentre,
            abhaId: abhaId,
            lmp: lmp,
            gravida: gravida,
            para: para,
            bloodGroup: bloodGroup,
            heightCm: heightCm,
            isBpl: isBpl,
            prevComplications: prevComplications,
            riskLevel: riskLevel,
            createdAt: createdAt,
            synced: synced,
            workerCreated: workerCreated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MothersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {ancVisitsRefs = false,
              tasksRefs = false,
              alertsRefs = false,
              referralsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ancVisitsRefs) db.ancVisits,
                if (tasksRefs) db.tasks,
                if (alertsRefs) db.alerts,
                if (referralsRefs) db.referrals
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ancVisitsRefs)
                    await $_getPrefetchedData<Mother, $MothersTable, AncVisit>(
                        currentTable: table,
                        referencedTable:
                            $$MothersTableReferences._ancVisitsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MothersTableReferences(db, table, p0)
                                .ancVisitsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.motherId == item.id),
                        typedResults: items),
                  if (tasksRefs)
                    await $_getPrefetchedData<Mother, $MothersTable, Task>(
                        currentTable: table,
                        referencedTable:
                            $$MothersTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MothersTableReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.motherId == item.id),
                        typedResults: items),
                  if (alertsRefs)
                    await $_getPrefetchedData<Mother, $MothersTable, Alert>(
                        currentTable: table,
                        referencedTable:
                            $$MothersTableReferences._alertsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MothersTableReferences(db, table, p0).alertsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.motherId == item.id),
                        typedResults: items),
                  if (referralsRefs)
                    await $_getPrefetchedData<Mother, $MothersTable, Referral>(
                        currentTable: table,
                        referencedTable:
                            $$MothersTableReferences._referralsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MothersTableReferences(db, table, p0)
                                .referralsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.motherId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MothersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MothersTable,
    Mother,
    $$MothersTableFilterComposer,
    $$MothersTableOrderingComposer,
    $$MothersTableAnnotationComposer,
    $$MothersTableCreateCompanionBuilder,
    $$MothersTableUpdateCompanionBuilder,
    (Mother, $$MothersTableReferences),
    Mother,
    PrefetchHooks Function(
        {bool ancVisitsRefs,
        bool tasksRefs,
        bool alertsRefs,
        bool referralsRefs})>;
typedef $$AncVisitsTableCreateCompanionBuilder = AncVisitsCompanion Function({
  required String id,
  required String motherId,
  required int visitNo,
  required DateTime visitDate,
  Value<int?> bpSys,
  Value<int?> bpDia,
  Value<double?> weightKg,
  Value<double?> fundalHeightCm,
  Value<double?> hb,
  Value<String?> urineAlbumin,
  Value<int?> fetalHr,
  Value<bool?> fetalMovement,
  Value<String> dangerSigns,
  Value<bool> ifaTaken,
  Value<bool> calciumTaken,
  Value<int?> ttDoseGiven,
  Value<String?> notes,
  Value<double?> gpsLat,
  Value<double?> gpsLng,
  Value<String> photoPaths,
  required String recordedBy,
  required DateTime clientCreatedAt,
  Value<String?> correctsId,
  Value<bool> synced,
  Value<bool> workerCreated,
  Value<int> rowid,
});
typedef $$AncVisitsTableUpdateCompanionBuilder = AncVisitsCompanion Function({
  Value<String> id,
  Value<String> motherId,
  Value<int> visitNo,
  Value<DateTime> visitDate,
  Value<int?> bpSys,
  Value<int?> bpDia,
  Value<double?> weightKg,
  Value<double?> fundalHeightCm,
  Value<double?> hb,
  Value<String?> urineAlbumin,
  Value<int?> fetalHr,
  Value<bool?> fetalMovement,
  Value<String> dangerSigns,
  Value<bool> ifaTaken,
  Value<bool> calciumTaken,
  Value<int?> ttDoseGiven,
  Value<String?> notes,
  Value<double?> gpsLat,
  Value<double?> gpsLng,
  Value<String> photoPaths,
  Value<String> recordedBy,
  Value<DateTime> clientCreatedAt,
  Value<String?> correctsId,
  Value<bool> synced,
  Value<bool> workerCreated,
  Value<int> rowid,
});

final class $$AncVisitsTableReferences
    extends BaseReferences<_$AppDatabase, $AncVisitsTable, AncVisit> {
  $$AncVisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MothersTable _motherIdTable(_$AppDatabase db) =>
      db.mothers.createAlias('anc_visits__mother_id__mothers__id');

  $$MothersTableProcessedTableManager get motherId {
    final $_column = $_itemColumn<String>('mother_id')!;

    final manager = $$MothersTableTableManager($_db, $_db.mothers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AncVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $AncVisitsTable> {
  $$AncVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get visitNo => $composableBuilder(
      column: $table.visitNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get visitDate => $composableBuilder(
      column: $table.visitDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bpSys => $composableBuilder(
      column: $table.bpSys, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bpDia => $composableBuilder(
      column: $table.bpDia, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fundalHeightCm => $composableBuilder(
      column: $table.fundalHeightCm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hb => $composableBuilder(
      column: $table.hb, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get urineAlbumin => $composableBuilder(
      column: $table.urineAlbumin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fetalHr => $composableBuilder(
      column: $table.fetalHr, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get fetalMovement => $composableBuilder(
      column: $table.fetalMovement, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dangerSigns => $composableBuilder(
      column: $table.dangerSigns, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ifaTaken => $composableBuilder(
      column: $table.ifaTaken, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get calciumTaken => $composableBuilder(
      column: $table.calciumTaken, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ttDoseGiven => $composableBuilder(
      column: $table.ttDoseGiven, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsLat => $composableBuilder(
      column: $table.gpsLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsLng => $composableBuilder(
      column: $table.gpsLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPaths => $composableBuilder(
      column: $table.photoPaths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordedBy => $composableBuilder(
      column: $table.recordedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get clientCreatedAt => $composableBuilder(
      column: $table.clientCreatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctsId => $composableBuilder(
      column: $table.correctsId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get workerCreated => $composableBuilder(
      column: $table.workerCreated, builder: (column) => ColumnFilters(column));

  $$MothersTableFilterComposer get motherId {
    final $$MothersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableFilterComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AncVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $AncVisitsTable> {
  $$AncVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get visitNo => $composableBuilder(
      column: $table.visitNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get visitDate => $composableBuilder(
      column: $table.visitDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bpSys => $composableBuilder(
      column: $table.bpSys, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bpDia => $composableBuilder(
      column: $table.bpDia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fundalHeightCm => $composableBuilder(
      column: $table.fundalHeightCm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hb => $composableBuilder(
      column: $table.hb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get urineAlbumin => $composableBuilder(
      column: $table.urineAlbumin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fetalHr => $composableBuilder(
      column: $table.fetalHr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get fetalMovement => $composableBuilder(
      column: $table.fetalMovement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dangerSigns => $composableBuilder(
      column: $table.dangerSigns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ifaTaken => $composableBuilder(
      column: $table.ifaTaken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get calciumTaken => $composableBuilder(
      column: $table.calciumTaken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ttDoseGiven => $composableBuilder(
      column: $table.ttDoseGiven, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsLat => $composableBuilder(
      column: $table.gpsLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsLng => $composableBuilder(
      column: $table.gpsLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPaths => $composableBuilder(
      column: $table.photoPaths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordedBy => $composableBuilder(
      column: $table.recordedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get clientCreatedAt => $composableBuilder(
      column: $table.clientCreatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctsId => $composableBuilder(
      column: $table.correctsId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get workerCreated => $composableBuilder(
      column: $table.workerCreated,
      builder: (column) => ColumnOrderings(column));

  $$MothersTableOrderingComposer get motherId {
    final $$MothersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableOrderingComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AncVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AncVisitsTable> {
  $$AncVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get visitNo =>
      $composableBuilder(column: $table.visitNo, builder: (column) => column);

  GeneratedColumn<DateTime> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<int> get bpSys =>
      $composableBuilder(column: $table.bpSys, builder: (column) => column);

  GeneratedColumn<int> get bpDia =>
      $composableBuilder(column: $table.bpDia, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get fundalHeightCm => $composableBuilder(
      column: $table.fundalHeightCm, builder: (column) => column);

  GeneratedColumn<double> get hb =>
      $composableBuilder(column: $table.hb, builder: (column) => column);

  GeneratedColumn<String> get urineAlbumin => $composableBuilder(
      column: $table.urineAlbumin, builder: (column) => column);

  GeneratedColumn<int> get fetalHr =>
      $composableBuilder(column: $table.fetalHr, builder: (column) => column);

  GeneratedColumn<bool> get fetalMovement => $composableBuilder(
      column: $table.fetalMovement, builder: (column) => column);

  GeneratedColumn<String> get dangerSigns => $composableBuilder(
      column: $table.dangerSigns, builder: (column) => column);

  GeneratedColumn<bool> get ifaTaken =>
      $composableBuilder(column: $table.ifaTaken, builder: (column) => column);

  GeneratedColumn<bool> get calciumTaken => $composableBuilder(
      column: $table.calciumTaken, builder: (column) => column);

  GeneratedColumn<int> get ttDoseGiven => $composableBuilder(
      column: $table.ttDoseGiven, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get gpsLat =>
      $composableBuilder(column: $table.gpsLat, builder: (column) => column);

  GeneratedColumn<double> get gpsLng =>
      $composableBuilder(column: $table.gpsLng, builder: (column) => column);

  GeneratedColumn<String> get photoPaths => $composableBuilder(
      column: $table.photoPaths, builder: (column) => column);

  GeneratedColumn<String> get recordedBy => $composableBuilder(
      column: $table.recordedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get clientCreatedAt => $composableBuilder(
      column: $table.clientCreatedAt, builder: (column) => column);

  GeneratedColumn<String> get correctsId => $composableBuilder(
      column: $table.correctsId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get workerCreated => $composableBuilder(
      column: $table.workerCreated, builder: (column) => column);

  $$MothersTableAnnotationComposer get motherId {
    final $$MothersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableAnnotationComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AncVisitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AncVisitsTable,
    AncVisit,
    $$AncVisitsTableFilterComposer,
    $$AncVisitsTableOrderingComposer,
    $$AncVisitsTableAnnotationComposer,
    $$AncVisitsTableCreateCompanionBuilder,
    $$AncVisitsTableUpdateCompanionBuilder,
    (AncVisit, $$AncVisitsTableReferences),
    AncVisit,
    PrefetchHooks Function({bool motherId})> {
  $$AncVisitsTableTableManager(_$AppDatabase db, $AncVisitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AncVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AncVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AncVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> motherId = const Value.absent(),
            Value<int> visitNo = const Value.absent(),
            Value<DateTime> visitDate = const Value.absent(),
            Value<int?> bpSys = const Value.absent(),
            Value<int?> bpDia = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> fundalHeightCm = const Value.absent(),
            Value<double?> hb = const Value.absent(),
            Value<String?> urineAlbumin = const Value.absent(),
            Value<int?> fetalHr = const Value.absent(),
            Value<bool?> fetalMovement = const Value.absent(),
            Value<String> dangerSigns = const Value.absent(),
            Value<bool> ifaTaken = const Value.absent(),
            Value<bool> calciumTaken = const Value.absent(),
            Value<int?> ttDoseGiven = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<double?> gpsLat = const Value.absent(),
            Value<double?> gpsLng = const Value.absent(),
            Value<String> photoPaths = const Value.absent(),
            Value<String> recordedBy = const Value.absent(),
            Value<DateTime> clientCreatedAt = const Value.absent(),
            Value<String?> correctsId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<bool> workerCreated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AncVisitsCompanion(
            id: id,
            motherId: motherId,
            visitNo: visitNo,
            visitDate: visitDate,
            bpSys: bpSys,
            bpDia: bpDia,
            weightKg: weightKg,
            fundalHeightCm: fundalHeightCm,
            hb: hb,
            urineAlbumin: urineAlbumin,
            fetalHr: fetalHr,
            fetalMovement: fetalMovement,
            dangerSigns: dangerSigns,
            ifaTaken: ifaTaken,
            calciumTaken: calciumTaken,
            ttDoseGiven: ttDoseGiven,
            notes: notes,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            photoPaths: photoPaths,
            recordedBy: recordedBy,
            clientCreatedAt: clientCreatedAt,
            correctsId: correctsId,
            synced: synced,
            workerCreated: workerCreated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String motherId,
            required int visitNo,
            required DateTime visitDate,
            Value<int?> bpSys = const Value.absent(),
            Value<int?> bpDia = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> fundalHeightCm = const Value.absent(),
            Value<double?> hb = const Value.absent(),
            Value<String?> urineAlbumin = const Value.absent(),
            Value<int?> fetalHr = const Value.absent(),
            Value<bool?> fetalMovement = const Value.absent(),
            Value<String> dangerSigns = const Value.absent(),
            Value<bool> ifaTaken = const Value.absent(),
            Value<bool> calciumTaken = const Value.absent(),
            Value<int?> ttDoseGiven = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<double?> gpsLat = const Value.absent(),
            Value<double?> gpsLng = const Value.absent(),
            Value<String> photoPaths = const Value.absent(),
            required String recordedBy,
            required DateTime clientCreatedAt,
            Value<String?> correctsId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<bool> workerCreated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AncVisitsCompanion.insert(
            id: id,
            motherId: motherId,
            visitNo: visitNo,
            visitDate: visitDate,
            bpSys: bpSys,
            bpDia: bpDia,
            weightKg: weightKg,
            fundalHeightCm: fundalHeightCm,
            hb: hb,
            urineAlbumin: urineAlbumin,
            fetalHr: fetalHr,
            fetalMovement: fetalMovement,
            dangerSigns: dangerSigns,
            ifaTaken: ifaTaken,
            calciumTaken: calciumTaken,
            ttDoseGiven: ttDoseGiven,
            notes: notes,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            photoPaths: photoPaths,
            recordedBy: recordedBy,
            clientCreatedAt: clientCreatedAt,
            correctsId: correctsId,
            synced: synced,
            workerCreated: workerCreated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AncVisitsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({motherId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (motherId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.motherId,
                    referencedTable:
                        $$AncVisitsTableReferences._motherIdTable(db),
                    referencedColumn:
                        $$AncVisitsTableReferences._motherIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AncVisitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AncVisitsTable,
    AncVisit,
    $$AncVisitsTableFilterComposer,
    $$AncVisitsTableOrderingComposer,
    $$AncVisitsTableAnnotationComposer,
    $$AncVisitsTableCreateCompanionBuilder,
    $$AncVisitsTableUpdateCompanionBuilder,
    (AncVisit, $$AncVisitsTableReferences),
    AncVisit,
    PrefetchHooks Function({bool motherId})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String motherId,
  required String type,
  Value<String?> instructionKn,
  Value<String?> instructionEn,
  required DateTime dueDate,
  Value<String> priority,
  Value<String> status,
  Value<String> origin,
  Value<String?> closedByVisitId,
  required DateTime createdAt,
  Value<DateTime?> closedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> motherId,
  Value<String> type,
  Value<String?> instructionKn,
  Value<String?> instructionEn,
  Value<DateTime> dueDate,
  Value<String> priority,
  Value<String> status,
  Value<String> origin,
  Value<String?> closedByVisitId,
  Value<DateTime> createdAt,
  Value<DateTime?> closedAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MothersTable _motherIdTable(_$AppDatabase db) =>
      db.mothers.createAlias('tasks__mother_id__mothers__id');

  $$MothersTableProcessedTableManager get motherId {
    final $_column = $_itemColumn<String>('mother_id')!;

    final manager = $$MothersTableTableManager($_db, $_db.mothers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructionKn => $composableBuilder(
      column: $table.instructionKn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructionEn => $composableBuilder(
      column: $table.instructionEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get closedByVisitId => $composableBuilder(
      column: $table.closedByVisitId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnFilters(column));

  $$MothersTableFilterComposer get motherId {
    final $$MothersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableFilterComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructionKn => $composableBuilder(
      column: $table.instructionKn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructionEn => $composableBuilder(
      column: $table.instructionEn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get closedByVisitId => $composableBuilder(
      column: $table.closedByVisitId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  $$MothersTableOrderingComposer get motherId {
    final $$MothersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableOrderingComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get instructionKn => $composableBuilder(
      column: $table.instructionKn, builder: (column) => column);

  GeneratedColumn<String> get instructionEn => $composableBuilder(
      column: $table.instructionEn, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get closedByVisitId => $composableBuilder(
      column: $table.closedByVisitId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  $$MothersTableAnnotationComposer get motherId {
    final $$MothersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableAnnotationComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool motherId})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> motherId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> instructionKn = const Value.absent(),
            Value<String?> instructionEn = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> origin = const Value.absent(),
            Value<String?> closedByVisitId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            motherId: motherId,
            type: type,
            instructionKn: instructionKn,
            instructionEn: instructionEn,
            dueDate: dueDate,
            priority: priority,
            status: status,
            origin: origin,
            closedByVisitId: closedByVisitId,
            createdAt: createdAt,
            closedAt: closedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String motherId,
            required String type,
            Value<String?> instructionKn = const Value.absent(),
            Value<String?> instructionEn = const Value.absent(),
            required DateTime dueDate,
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> origin = const Value.absent(),
            Value<String?> closedByVisitId = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> closedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            motherId: motherId,
            type: type,
            instructionKn: instructionKn,
            instructionEn: instructionEn,
            dueDate: dueDate,
            priority: priority,
            status: status,
            origin: origin,
            closedByVisitId: closedByVisitId,
            createdAt: createdAt,
            closedAt: closedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({motherId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (motherId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.motherId,
                    referencedTable: $$TasksTableReferences._motherIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._motherIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool motherId})>;
typedef $$AlertsTableCreateCompanionBuilder = AlertsCompanion Function({
  required String id,
  required String motherId,
  required String ruleId,
  required String severity,
  required String messageKn,
  required String messageEn,
  Value<String?> visitId,
  required DateTime createdAt,
  Value<bool> acknowledged,
  Value<int> rowid,
});
typedef $$AlertsTableUpdateCompanionBuilder = AlertsCompanion Function({
  Value<String> id,
  Value<String> motherId,
  Value<String> ruleId,
  Value<String> severity,
  Value<String> messageKn,
  Value<String> messageEn,
  Value<String?> visitId,
  Value<DateTime> createdAt,
  Value<bool> acknowledged,
  Value<int> rowid,
});

final class $$AlertsTableReferences
    extends BaseReferences<_$AppDatabase, $AlertsTable, Alert> {
  $$AlertsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MothersTable _motherIdTable(_$AppDatabase db) =>
      db.mothers.createAlias('alerts__mother_id__mothers__id');

  $$MothersTableProcessedTableManager get motherId {
    final $_column = $_itemColumn<String>('mother_id')!;

    final manager = $$MothersTableTableManager($_db, $_db.mothers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleId => $composableBuilder(
      column: $table.ruleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageKn => $composableBuilder(
      column: $table.messageKn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageEn => $composableBuilder(
      column: $table.messageEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitId => $composableBuilder(
      column: $table.visitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get acknowledged => $composableBuilder(
      column: $table.acknowledged, builder: (column) => ColumnFilters(column));

  $$MothersTableFilterComposer get motherId {
    final $$MothersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableFilterComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleId => $composableBuilder(
      column: $table.ruleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageKn => $composableBuilder(
      column: $table.messageKn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageEn => $composableBuilder(
      column: $table.messageEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitId => $composableBuilder(
      column: $table.visitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get acknowledged => $composableBuilder(
      column: $table.acknowledged,
      builder: (column) => ColumnOrderings(column));

  $$MothersTableOrderingComposer get motherId {
    final $$MothersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableOrderingComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get messageKn =>
      $composableBuilder(column: $table.messageKn, builder: (column) => column);

  GeneratedColumn<String> get messageEn =>
      $composableBuilder(column: $table.messageEn, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get acknowledged => $composableBuilder(
      column: $table.acknowledged, builder: (column) => column);

  $$MothersTableAnnotationComposer get motherId {
    final $$MothersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableAnnotationComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AlertsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlertsTable,
    Alert,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableAnnotationComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder,
    (Alert, $$AlertsTableReferences),
    Alert,
    PrefetchHooks Function({bool motherId})> {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> motherId = const Value.absent(),
            Value<String> ruleId = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> messageKn = const Value.absent(),
            Value<String> messageEn = const Value.absent(),
            Value<String?> visitId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> acknowledged = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion(
            id: id,
            motherId: motherId,
            ruleId: ruleId,
            severity: severity,
            messageKn: messageKn,
            messageEn: messageEn,
            visitId: visitId,
            createdAt: createdAt,
            acknowledged: acknowledged,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String motherId,
            required String ruleId,
            required String severity,
            required String messageKn,
            required String messageEn,
            Value<String?> visitId = const Value.absent(),
            required DateTime createdAt,
            Value<bool> acknowledged = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion.insert(
            id: id,
            motherId: motherId,
            ruleId: ruleId,
            severity: severity,
            messageKn: messageKn,
            messageEn: messageEn,
            visitId: visitId,
            createdAt: createdAt,
            acknowledged: acknowledged,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AlertsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({motherId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (motherId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.motherId,
                    referencedTable: $$AlertsTableReferences._motherIdTable(db),
                    referencedColumn:
                        $$AlertsTableReferences._motherIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AlertsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlertsTable,
    Alert,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableAnnotationComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder,
    (Alert, $$AlertsTableReferences),
    Alert,
    PrefetchHooks Function({bool motherId})>;
typedef $$ReferralsTableCreateCompanionBuilder = ReferralsCompanion Function({
  required String id,
  required String motherId,
  required String toFacility,
  required String reasonKn,
  required String reasonEn,
  Value<String> status,
  Value<String?> visitId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ReferralsTableUpdateCompanionBuilder = ReferralsCompanion Function({
  Value<String> id,
  Value<String> motherId,
  Value<String> toFacility,
  Value<String> reasonKn,
  Value<String> reasonEn,
  Value<String> status,
  Value<String?> visitId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ReferralsTableReferences
    extends BaseReferences<_$AppDatabase, $ReferralsTable, Referral> {
  $$ReferralsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MothersTable _motherIdTable(_$AppDatabase db) =>
      db.mothers.createAlias('referrals__mother_id__mothers__id');

  $$MothersTableProcessedTableManager get motherId {
    final $_column = $_itemColumn<String>('mother_id')!;

    final manager = $$MothersTableTableManager($_db, $_db.mothers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReferralsTableFilterComposer
    extends Composer<_$AppDatabase, $ReferralsTable> {
  $$ReferralsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toFacility => $composableBuilder(
      column: $table.toFacility, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reasonKn => $composableBuilder(
      column: $table.reasonKn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reasonEn => $composableBuilder(
      column: $table.reasonEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitId => $composableBuilder(
      column: $table.visitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$MothersTableFilterComposer get motherId {
    final $$MothersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableFilterComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReferralsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReferralsTable> {
  $$ReferralsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toFacility => $composableBuilder(
      column: $table.toFacility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reasonKn => $composableBuilder(
      column: $table.reasonKn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reasonEn => $composableBuilder(
      column: $table.reasonEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitId => $composableBuilder(
      column: $table.visitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$MothersTableOrderingComposer get motherId {
    final $$MothersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableOrderingComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReferralsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReferralsTable> {
  $$ReferralsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get toFacility => $composableBuilder(
      column: $table.toFacility, builder: (column) => column);

  GeneratedColumn<String> get reasonKn =>
      $composableBuilder(column: $table.reasonKn, builder: (column) => column);

  GeneratedColumn<String> get reasonEn =>
      $composableBuilder(column: $table.reasonEn, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get visitId =>
      $composableBuilder(column: $table.visitId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MothersTableAnnotationComposer get motherId {
    final $$MothersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.motherId,
        referencedTable: $db.mothers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MothersTableAnnotationComposer(
              $db: $db,
              $table: $db.mothers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReferralsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReferralsTable,
    Referral,
    $$ReferralsTableFilterComposer,
    $$ReferralsTableOrderingComposer,
    $$ReferralsTableAnnotationComposer,
    $$ReferralsTableCreateCompanionBuilder,
    $$ReferralsTableUpdateCompanionBuilder,
    (Referral, $$ReferralsTableReferences),
    Referral,
    PrefetchHooks Function({bool motherId})> {
  $$ReferralsTableTableManager(_$AppDatabase db, $ReferralsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferralsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferralsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferralsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> motherId = const Value.absent(),
            Value<String> toFacility = const Value.absent(),
            Value<String> reasonKn = const Value.absent(),
            Value<String> reasonEn = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> visitId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferralsCompanion(
            id: id,
            motherId: motherId,
            toFacility: toFacility,
            reasonKn: reasonKn,
            reasonEn: reasonEn,
            status: status,
            visitId: visitId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String motherId,
            required String toFacility,
            required String reasonKn,
            required String reasonEn,
            Value<String> status = const Value.absent(),
            Value<String?> visitId = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReferralsCompanion.insert(
            id: id,
            motherId: motherId,
            toFacility: toFacility,
            reasonKn: reasonKn,
            reasonEn: reasonEn,
            status: status,
            visitId: visitId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReferralsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({motherId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (motherId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.motherId,
                    referencedTable:
                        $$ReferralsTableReferences._motherIdTable(db),
                    referencedColumn:
                        $$ReferralsTableReferences._motherIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReferralsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReferralsTable,
    Referral,
    $$ReferralsTableFilterComposer,
    $$ReferralsTableOrderingComposer,
    $$ReferralsTableAnnotationComposer,
    $$ReferralsTableCreateCompanionBuilder,
    $$ReferralsTableUpdateCompanionBuilder,
    (Referral, $$ReferralsTableReferences),
    Referral,
    PrefetchHooks Function({bool motherId})>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required String id,
  required String entityTable,
  required String recordId,
  required String operation,
  required String payload,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> lastError,
  required DateTime createdAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<String> id,
  Value<String> entityTable,
  Value<String> recordId,
  Value<String> operation,
  Value<String> payload,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityTable = const Value.absent(),
            Value<String> recordId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxCompanion(
            id: id,
            entityTable: entityTable,
            recordId: recordId,
            operation: operation,
            payload: payload,
            status: status,
            retryCount: retryCount,
            lastError: lastError,
            createdAt: createdAt,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityTable,
            required String recordId,
            required String operation,
            required String payload,
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxCompanion.insert(
            id: id,
            entityTable: entityTable,
            recordId: recordId,
            operation: operation,
            payload: payload,
            status: status,
            retryCount: retryCount,
            lastError: lastError,
            createdAt: createdAt,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MothersTableTableManager get mothers =>
      $$MothersTableTableManager(_db, _db.mothers);
  $$AncVisitsTableTableManager get ancVisits =>
      $$AncVisitsTableTableManager(_db, _db.ancVisits);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$ReferralsTableTableManager get referrals =>
      $$ReferralsTableTableManager(_db, _db.referrals);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
}
