import 'dart:math' as math;

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
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final String id;
  final String nameKn;
  final String nameEn;
  final String phone;
  final String subCentreKn;
  final String subCentreEn;
  final String village;
  final double? latitude;
  final double? longitude;

  /// Null when she declined location. The list still shows, unsorted.
  final double? distanceKm;

  DirectoryAsha withDistance(double? km) => DirectoryAsha(
        id: id,
        nameKn: nameKn,
        nameEn: nameEn,
        phone: phone,
        subCentreKn: subCentreKn,
        subCentreEn: subCentreEn,
        village: village,
        latitude: latitude,
        longitude: longitude,
        distanceKm: km,
      );
}

/// Finds ASHA workers for a woman who has no account yet.
///
/// Reads the public `asha_directory` view, which carries only what is already
/// displayed on a sub-centre noticeboard. If there is no signal — the common
/// case in a village — it falls back to a bundled list so she is never left
/// with an empty screen and no way to reach anyone.
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

    List<DirectoryAsha> list;
    try {
      final rows = await client
          .from('asha_directory')
          .select()
          .timeout(const Duration(seconds: 6));
      list = rows.map(_map).toList();
    } catch (_) {
      throw const AshaDirectoryUnavailable();
    }

    if (lat == null || lng == null) return list;

    final withDistance = [
      for (final a in list)
        a.withDistance(
          a.latitude == null || a.longitude == null
              ? null
              : _haversineKm(lat, lng, a.latitude!, a.longitude!),
        ),
    ]..sort((x, y) {
        final a = x.distanceKm ?? double.maxFinite;
        final b = y.distanceKm ?? double.maxFinite;
        return a.compareTo(b);
      });
    return withDistance;
  }

  static DirectoryAsha _map(Map<String, dynamic> r) => DirectoryAsha(
        id: r['id'] as String,
        nameKn: r['name_kn'] as String? ?? '',
        nameEn: r['name_en'] as String? ?? '',
        phone: r['phone'] as String? ?? '',
        subCentreKn: r['sub_centre_kn'] as String? ?? '',
        subCentreEn: r['sub_centre_en'] as String? ?? '',
        village: r['village'] as String? ?? '',
        latitude: (r['latitude'] as num?)?.toDouble(),
        longitude: (r['longitude'] as num?)?.toDouble(),
      );

  /// Straight-line distance. Good enough to order four sub-centres.
  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;

}

/// The list could not be fetched. The screen says so and offers a retry rather
/// than inventing someone for her to call.
class AshaDirectoryUnavailable implements Exception {
  const AshaDirectoryUnavailable();
  @override
  String toString() => 'AshaDirectoryUnavailable';
}
