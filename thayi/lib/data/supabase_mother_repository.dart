import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';
import 'mother_repository.dart';

/// The real implementation, sitting behind the same interface the UI has
/// always used. Nothing above the repository layer changed to add this.
///
/// Every query is scoped by Row Level Security to the signed-in mother — the
/// client never passes a mother id it chose itself.
class SupabaseMotherRepository implements MotherRepository {
  SupabaseMotherRepository(this._client);

  final SupabaseClient _client;

  /// Cached for the lifetime of the repository so the child queries do not
  /// each re-fetch the parent row.
  String? _motherId;

  Future<String> _requireMotherId() async {
    final cached = _motherId;
    if (cached != null) return cached;
    final mother = await getMother();
    return _motherId = mother.id;
  }

  @override
  Future<Mother> getMother() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const RepositoryException('Not signed in');
    }

    // The foreign key is named explicitly. `mothers` carries two references to
    // `asha_workers` — the canonical `asha_worker_id` and a legacy `asha_id` —
    // and with both present PostgREST refuses the embed as ambiguous
    // (PGRST201) rather than picking one. That error surfaced as an empty app:
    // every screen depends on this row, so the failure looked like missing
    // data rather than a broken query.
    final row = await _client
        .from('mothers')
        .select('*, asha:asha_workers!mothers_asha_worker_fk(*), '
            'phc:health_centres(*)')
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (row == null) {
      // RLS returns nothing rather than an error when the record is not
      // linked to this user yet, so say what actually happened.
      throw const RepositoryException(
        'No Thayi Card record is linked to this account',
      );
    }

    _motherId = row['id'] as String;
    return _mother(row);
  }

  @override
  Future<List<Checkup>> getCheckups() async {
    final rows = await _client
        .from('checkups')
        .select()
        .eq('mother_id', await _requireMotherId())
        .order('visit_number');
    return rows.map(_checkup).toList();
  }

  @override
  Future<HealthRecord> getHealthRecord() async {
    final motherId = await _requireMotherId();
    final weights = await _client
        .from('weight_entries')
        .select()
        .eq('mother_id', motherId)
        .order('week');
    final bp = await _client
        .from('bp_entries')
        .select()
        .eq('mother_id', motherId)
        .order('week');
    final tt = await _client
        .from('tt_doses')
        .select()
        .eq('mother_id', motherId)
        .order('dose_number');

    return HealthRecord(
      weights: weights
          .map((r) => WeightEntry(
                week: r['week'] as int,
                kg: _toDouble(r['kg']),
              ))
          .toList(),
      bloodPressure: bp
          .map((r) => BpEntry(
                week: r['week'] as int,
                systolic: r['systolic'] as int,
                diastolic: r['diastolic'] as int,
              ))
          .toList(),
      ttDoses: tt
          .map((r) => TtDose(
                number: r['dose_number'] as int,
                given: r['given'] as bool? ?? false,
                givenOn: _toDate(r['given_on']),
              ))
          .toList(),
    );
  }

  @override
  Future<List<Scheme>> getSchemes() async {
    final mother = await getMother();
    final rows = await _client.from('schemes').select().order('sort_order');
    final centres = await _client.from('health_centres').select();
    final byId = {
      for (final c in centres) c['id'] as String: _centre(c),
    };

    return rows.map((r) {
      final id = _schemeId(r['id'] as String);
      final hospitalIds =
          (r['hospital_ids'] as List?)?.cast<String>() ?? const <String>[];
      return Scheme(
        id: id,
        // Eligibility stays a client-side rule over her profile fields, so it
        // is auditable and does not need a round trip.
        eligible: _isEligible(id, mother),
        documentIds:
            (r['document_ids'] as List?)?.cast<String>() ?? const <String>[],
        hospitals: [
          for (final h in hospitalIds)
            if (byId[h] != null) byId[h]!,
        ],
      );
    }).toList();
  }

  @override
  Future<BabyRecord> getBabyRecord() async {
    final motherId = await _requireMotherId();
    final vaccines = await _client
        .from('baby_vaccines')
        .select()
        .eq('mother_id', motherId)
        .order('sort_order');
    final growth = await _client
        .from('baby_growth')
        .select()
        .eq('mother_id', motherId)
        .order('week');

    return BabyRecord(
      vaccines: vaccines
          .map((r) => BabyVaccine(
                vaccineId: r['vaccine_id'] as String,
                ageId: r['age_id'] as String,
                given: r['given'] as bool? ?? false,
              ))
          .toList(),
      growth: growth
          .map((r) => WeightEntry(
                week: r['week'] as int,
                kg: _toDouble(r['kg']),
              ))
          .toList(),
    );
  }

  // ------------------------------------------------------------- mapping

  Mother _mother(Map<String, dynamic> r) {
    final asha = r['asha'] as Map<String, dynamic>?;
    final phc = r['phc'] as Map<String, dynamic>?;

    return Mother(
      id: r['id'] as String,
      qrToken: r['qr_token'] as String? ?? '',
      thayiCardNumber: r['thayi_card_number'] as String? ?? '',
      nameKn: r['name_kn'] as String? ?? '',
      nameEn: r['name_en'] as String? ?? '',
      age: r['age'] as int? ?? 0,
      guardianKn: r['guardian_kn'] as String? ?? '',
      guardianEn: r['guardian_en'] as String? ?? '',
      villageKn: r['village_kn'] as String? ?? '',
      villageEn: r['village_en'] as String? ?? '',
      districtKn: r['district_kn'] as String? ?? '',
      districtEn: r['district_en'] as String? ?? '',
      bloodGroup: r['blood_group'] as String? ?? '',
      lmp: _toDate(r['lmp']) ?? DateTime.now(),
      riskFlagIds: (r['risk_flag_ids'] as List?)?.cast<String>() ?? const [],
      allergyIds: (r['allergy_ids'] as List?)?.cast<String>() ?? const [],
      isBpl: r['is_bpl'] as bool? ?? false,
      deliveryNumber: r['delivery_number'] as int? ?? 1,
      plansInstitutionalDelivery:
          r['plans_institutional_delivery'] as bool? ?? true,
      hasBankAccount: r['has_bank_account'] as bool? ?? false,
      asha: asha == null
          ? const AshaWorker(
              nameKn: '',
              nameEn: '',
              phone: '',
              subCentreKn: '',
              subCentreEn: '')
          : AshaWorker(
              nameKn: asha['name_kn'] as String? ?? '',
              nameEn: asha['name_en'] as String? ?? '',
              phone: asha['phone'] as String? ?? '',
              subCentreKn: asha['sub_centre_kn'] as String? ?? '',
              subCentreEn: asha['sub_centre_en'] as String? ?? '',
            ),
      phc: phc == null
          ? const HealthCentre(nameKn: '', nameEn: '', phone: '', distanceKm: 0)
          : _centre(phc),
    );
  }

  Checkup _checkup(Map<String, dynamic> r) => Checkup(
        visitNumber: r['visit_number'] as int,
        date: _toDate(r['scheduled_on']) ?? DateTime.now(),
        locationKn: r['location_kn'] as String? ?? '',
        locationEn: r['location_en'] as String? ?? '',
        activityIds:
            (r['activity_ids'] as List?)?.cast<String>() ?? const <String>[],
        completed: r['completed'] as bool? ?? false,
        weightKg: r['weight_kg'] == null ? null : _toDouble(r['weight_kg']),
        systolic: r['systolic'] as int?,
        diastolic: r['diastolic'] as int?,
        recordedByKn: r['recorded_by_kn'] as String?,
        recordedByEn: r['recorded_by_en'] as String?,
      );

  HealthCentre _centre(Map<String, dynamic> r) => HealthCentre(
        nameKn: r['name_kn'] as String? ?? '',
        nameEn: r['name_en'] as String? ?? '',
        phone: r['phone'] as String? ?? '',
        // Distance is a device-side calculation once location is available;
        // until then the record carries no distance.
        distanceKm: 0,
        latitude: r['latitude'] == null ? null : _toDouble(r['latitude']),
        longitude: r['longitude'] == null ? null : _toDouble(r['longitude']),
      );

  static SchemeId _schemeId(String id) => switch (id) {
        'thayiBhagya' => SchemeId.thayiBhagya,
        'pmmvy' => SchemeId.pmmvy,
        'jsy' => SchemeId.jsy,
        'prasootiAraike' => SchemeId.prasootiAraike,
        'madilu' => SchemeId.madilu,
        _ => SchemeId.jssk,
      };

  static bool _isEligible(SchemeId id, Mother m) => switch (id) {
        SchemeId.thayiBhagya => m.isBpl && m.plansInstitutionalDelivery,
        SchemeId.pmmvy => m.deliveryNumber == 1 && m.hasBankAccount,
        SchemeId.jsy => m.isBpl && m.plansInstitutionalDelivery,
        SchemeId.prasootiAraike => m.isBpl && m.deliveryNumber <= 2,
        SchemeId.madilu => m.isBpl && m.plansInstitutionalDelivery,
        SchemeId.jssk => m.plansInstitutionalDelivery,
      };

  static double _toDouble(Object? v) => switch (v) {
        num n => n.toDouble(),
        String s => double.tryParse(s) ?? 0,
        _ => 0,
      };

  static DateTime? _toDate(Object? v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}

class RepositoryException implements Exception {
  const RepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
