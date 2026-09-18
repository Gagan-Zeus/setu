import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pinning a mother's house, and getting back to it.
///
/// Rural GPS fails constantly — indoors, under trees, on a cheap handset — so
/// every call here is best-effort and returns null rather than throwing. A
/// registration or a visit must never be blocked because there was no fix.
class HomeLocation {
  HomeLocation._();

  /// Best-effort fix. Null when the service is off, permission is refused, or
  /// it simply times out.
  static Future<({double lat, double lng})?> capture({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Turn-by-turn navigation to her house. Tries Google Maps' navigation
  /// intent first, then a plain maps URL, then the generic geo: scheme, so it
  /// still works on a handset without Google Maps installed.
  static Future<bool> navigateTo(double lat, double lng,
      {String? label}) async {
    final name = Uri.encodeComponent(label ?? '');
    final candidates = <Uri>[
      Uri.parse('google.navigation:q=$lat,$lng&mode=d'),
      Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving'),
      Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)'),
    ];
    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          return true;
        }
      } catch (_) {
        // Try the next one.
      }
    }
    return false;
  }

  /// Street View at the pin.
  ///
  /// Worth knowing before relying on this: Street View coverage in rural
  /// Karnataka villages is close to nonexistent, so this will usually open to
  /// no imagery. It is offered as a nice-to-have next to navigation, never as
  /// the way to find a house.
  static Future<bool> streetView(double lat, double lng) async {
    final candidates = <Uri>[
      Uri.parse('google.streetview:cbll=$lat,$lng'),
      Uri.parse(
          'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$lat,$lng'),
    ];
    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          return true;
        }
      } catch (_) {
        // Try the next one.
      }
    }
    return false;
  }

  static String format(double lat, double lng) =>
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}

/// A small status line shown while a fix is being taken, so she can see it
/// working rather than wondering whether the screen has frozen.
class LocationChip extends StatelessWidget {
  const LocationChip({
    super.key,
    required this.busy,
    required this.hasFix,
    required this.busyLabel,
    required this.foundLabel,
    required this.missingLabel,
    required this.colorFound,
    required this.colorMissing,
  });

  final bool busy;
  final bool hasFix;
  final String busyLabel;
  final String foundLabel;
  final String missingLabel;
  final Color colorFound;
  final Color colorMissing;

  @override
  Widget build(BuildContext context) {
    final colour = hasFix ? colorFound : colorMissing;
    return Row(
      children: [
        if (busy)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: colour),
          )
        else
          Icon(hasFix ? Icons.place : Icons.location_off_outlined,
              size: 18, color: colour),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            busy ? busyLabel : (hasFix ? foundLabel : missingLabel),
            style: TextStyle(fontSize: 14, color: colour),
          ),
        ),
      ],
    );
  }
}
