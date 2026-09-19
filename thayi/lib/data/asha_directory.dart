import 'package:supabase_flutter/supabase_flutter.dart';

/// One ASHA worker as shown before she has an account.
class DirectoryAsha {
  const DirectoryAsha({
    required this.id,
    required this.nameKn,
    required this.nameEn,
    required this.phone,
    required this.subCentreKn,
    required this.subCentreEn,
    required this.village,
    this.accuracy = 'none',
    this.distanceKm,
    this.onDuty = false,
    this.nearby = false,
    this.proximityBand,
  });

  final String id;
  final String nameKn;
  final String nameEn;
  final String phone;
  final String subCentreKn;
  final String subCentreEn;
  final String village;

  /// Where her coordinate came from: 'gps' when she pinned her own sub-centre,
  /// 'phc' when it was inherited from her health centre, 'seed', or 'none'.
  /// Anything but 'gps' is a centroid, so the distance is worded as
  /// approximate rather than claiming a precision it does not have.
  final String accuracy;

  /// Straight-line distance to her sub-centre. Null when she declined location
  /// or the worker has no coordinate at all. The list still shows, unsorted.
  final double? distanceKm;

  /// She has said she is working right now, and her phone has been heard from
  /// recently enough to believe it.
  final bool onDuty;

  /// On duty and within 2 km of where this woman is standing.
  final bool nearby;

  /// 'under_1km' or '1_to_2km' — only ever set when [nearby]. Her live
  /// distance is never given as a number, because an exact distance to a
  /// moving person, asked three times, is a position.
  final String? proximityBand;

  bool get isApproximate => accuracy != 'gps';
}

/// Finds ASHA workers for a woman who has no account yet.
///
/// Reads the public `asha_nearby` function, which carries only what is already
/// displayed on a sub-centre noticeboard: a name, a number, a sub-centre. It
/// orders on-duty workers within 2 km first, then everyone else nearest-first,
/// and it never filters anyone out — a woman far from the only ASHA in her
/// taluk must still be given that ASHA.
abstract class AshaDirectory {
  Future<List<DirectoryAsha>> nearby({double? lat, double? lng});
}

class SupabaseAshaDirectory implements AshaDirectory {
  const SupabaseAshaDirectory(this._client);

  final SupabaseClient? _client;

  /// Throws [AshaDirectoryUnavailable] when the list could not be fetched.
  ///
  /// It used to fall back to a bundled list of four workers with invented phone
  /// numbers. On a screen whose entire purpose is a pregnant woman calling
  /// someone, that is the worst possible failure mode: +919845012345 belongs to
  /// nobody, or to a stranger, and she would dial it in an emergency believing
  /// it was her ASHA. Showing nothing and saying why is safe; showing a number
  /// that does not answer is not.
  ///
  /// An empty result is also returned as empty rather than papered over. Before
  /// any worker has been registered the honest answer is "none yet", not four
  /// people who do not exist.
  @override
  Future<List<DirectoryAsha>> nearby({double? lat, double? lng}) async {
    final client = _client;
    if (client == null) throw const AshaDirectoryUnavailable();

    try {
      // Ordering, the 2 km test and the limit all live in the database: it is
      // the one place that can see where the workers are, and it keeps this to
      // ten rows on a connection that may be 2G.
      final rows = await client.rpc('asha_nearby', params: {
        'p_lat': lat,
        'p_lng': lng,
        'p_limit': 10,
      }).timeout(const Duration(seconds: 6));

      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(_map)
          .toList(growable: false);
    } catch (_) {
      throw const AshaDirectoryUnavailable();
    }
  }

  static DirectoryAsha _map(Map<String, dynamic> r) => DirectoryAsha(
        id: r['id'] as String,
        nameKn: r['name_kn'] as String? ?? '',
        nameEn: r['name_en'] as String? ?? '',
        phone: r['phone'] as String? ?? '',
        subCentreKn: r['sub_centre_kn'] as String? ?? '',
        subCentreEn: r['sub_centre_en'] as String? ?? '',
        village: r['village'] as String? ?? '',
        accuracy: r['accuracy'] as String? ?? 'none',
        distanceKm: (r['distance_km'] as num?)?.toDouble(),
        onDuty: r['on_duty'] as bool? ?? false,
        nearby: r['nearby'] as bool? ?? false,
        proximityBand: r['proximity_band'] as String?,
      );
}

/// The list could not be fetched. The screen says so and offers a retry rather
/// than inventing someone for her to call.
class AshaDirectoryUnavailable implements Exception {
  const AshaDirectoryUnavailable();
  @override
  String toString() => 'AshaDirectoryUnavailable';
}
