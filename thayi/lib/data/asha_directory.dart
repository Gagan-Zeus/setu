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

  @override
  Future<List<DirectoryAsha>> nearby({double? lat, double? lng}) async {
    var list = _fallback;
    final client = _client;
    if (client != null) {
      try {
        final rows = await client
            .from('asha_directory')
            .select()
            .timeout(const Duration(seconds: 6));
        if (rows.isNotEmpty) list = rows.map(_map).toList();
      } catch (_) {
        // Keep the bundled list rather than showing nothing.
      }
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

  /// Bundled so the screen works with no signal at all.
  static const _fallback = <DirectoryAsha>[
    DirectoryAsha(
      id: 'local-1',
      nameKn: 'ಸರೋಜಮ್ಮ',
      nameEn: 'Sarojamma',
      phone: '+919845012345',
      subCentreKn: 'ಹೊಸಳ್ಳಿ ಉಪ ಕೇಂದ್ರ',
      subCentreEn: 'Hosahalli Sub-centre',
      village: 'Hosahalli',
      latitude: 12.2958,
      longitude: 76.6394,
    ),
    DirectoryAsha(
      id: 'local-2',
      nameKn: 'ಗೀತಮ್ಮ',
      nameEn: 'Geethamma',
      phone: '+919845067123',
      subCentreKn: 'ಕೆಂಪನಹಳ್ಳಿ ಉಪ ಕೇಂದ್ರ',
      subCentreEn: 'Kempanahalli Sub-centre',
      village: 'Kempanahalli',
      latitude: 12.2731,
      longitude: 76.6802,
    ),
    DirectoryAsha(
      id: 'local-3',
      nameKn: 'ಶಾರದಮ್ಮ',
      nameEn: 'Sharadamma',
      phone: '+919845098456',
      subCentreKn: 'ಮಾದಾಪುರ ಉಪ ಕೇಂದ್ರ',
      subCentreEn: 'Madapura Sub-centre',
      village: 'Madapura',
      latitude: 12.1904,
      longitude: 76.6115,
    ),
    DirectoryAsha(
      id: 'local-4',
      nameKn: 'ನಾಗರತ್ನ',
      nameEn: 'Nagarathna',
      phone: '+919845033210',
      subCentreKn: 'ಬೀಡನಹಳ್ಳಿ ಉಪ ಕೇಂದ್ರ',
      subCentreEn: 'Beedanahalli Sub-centre',
      village: 'Beedanahalli',
      latitude: 12.2405,
      longitude: 76.7218,
    ),
  ];
}
