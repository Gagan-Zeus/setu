import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../routes.dart';
import '../../theme/tokens.dart';
import '../../widgets/big_action_button.dart';

/// Location is only used to put the closest ASHA worker at the top of the
/// next screen. Declining is a first-class path: she still sees every worker,
/// just unsorted. Rural GPS fails often, so this never blocks her.
class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  bool _busy = false;

  Future<void> _allow() async {
    setState(() => _busy = true);
    ({double lat, double lng})? at;

    try {
      if (await Geolocator.isLocationServiceEnabled()) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 8),
            ),
          );
          at = (lat: pos.latitude, lng: pos.longitude);
        }
      }
    } catch (_) {
      // No fix, no service, timed out — carry on without it.
    }

    ref.read(coordsProvider.notifier).state = at;
    await ref.read(onboardingProvider.notifier).markLocationAsked();
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.pushReplacementNamed(context, Routes.onboardingAshaNearby);
  }

  Future<void> _skip() async {
    ref.read(coordsProvider.notifier).state = null;
    await ref.read(onboardingProvider.notifier).markLocationAsked();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.onboardingAshaNearby);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(S.screen),
                child: Column(
                  children: [
                    const SizedBox(height: S.lg),
                    Container(
                      width: 116,
                      height: 116,
                      decoration: const BoxDecoration(
                        color: C.tealSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.place_outlined,
                          size: 60, color: C.teal),
                    ),
                    const SizedBox(height: S.lg),
                    Text(l.locationTitle,
                        style: T.h1, textAlign: TextAlign.center),
                    const SizedBox(height: S.md),
                    Text(l.locationWhy,
                        style: T.body, textAlign: TextAlign.center),
                    const SizedBox(height: S.md),
                    Container(
                      padding: const EdgeInsets.all(S.md),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(S.radius),
                        boxShadow: kCardShadow,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_outline,
                              size: 22, color: C.green),
                          const SizedBox(width: S.sm),
                          Expanded(
                            child: Text(l.locationPrivacy,
                                style: T.bodySoft.copyWith(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(S.screen),
              child: Column(
                children: [
                  BigActionButton(
                    label: l.locationAllow,
                    icon: Icons.my_location,
                    onPressed: _busy ? null : _allow,
                  ),
                  const SizedBox(height: S.sm),
                  TextButton(
                    onPressed: _busy ? null : _skip,
                    child: Text(l.locationSkip),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
