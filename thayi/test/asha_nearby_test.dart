import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_thayi/data/asha_directory.dart';
import 'package:setu_thayi/l10n/app_localizations.dart';
import 'package:setu_thayi/providers.dart';
import 'package:setu_thayi/screens/onboarding/asha_nearby_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The first screen a pregnant woman sees, and the only one whose job is to
/// give her a real person to phone.
///
/// Two things must hold however the data comes back. She is never shown an
/// empty list while a worker exists anywhere — a radius is a badge, not a
/// filter. And a distance is never worded as more precise than it is: a PHC
/// centroid inherited from her health centre is not a surveyed position.
class _FakeDirectory implements AshaDirectory {
  const _FakeDirectory(this._rows);
  final List<DirectoryAsha> _rows;

  @override
  Future<List<DirectoryAsha>> nearby({double? lat, double? lng}) async => _rows;
}

DirectoryAsha _asha({
  required String name,
  String accuracy = 'gps',
  double? distanceKm,
  bool onDuty = false,
  bool nearby = false,
  String? band,
}) =>
    DirectoryAsha(
      id: name,
      nameKn: name,
      nameEn: name,
      phone: '+91 99000 00000',
      subCentreKn: '$name Sub-Centre',
      subCentreEn: '$name Sub-Centre',
      village: name,
      accuracy: accuracy,
      distanceKm: distanceKm,
      onDuty: onDuty,
      nearby: nearby,
      proximityBand: band,
    );

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget harness(List<DirectoryAsha> rows) => ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          ashaDirectoryProvider.overrideWithValue(_FakeDirectory(rows)),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AshaNearbyScreen(),
        ),
      );

  testWidgets('a worker far away is still offered, never an empty screen',
      (tester) async {
    await tester.pumpWidget(harness([
      _asha(name: 'Nagamma', accuracy: 'phc', distanceKm: 48.2),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Nagamma'), findsOneWidget);
    // The "nobody yet" state is for when there is genuinely nobody.
    expect(find.text('No ASHA worker listed yet'), findsNothing);
  });

  testWidgets('a worker with no coordinate at all is still offered',
      (tester) async {
    await tester.pumpWidget(harness([
      _asha(name: 'Sunita', accuracy: 'none'),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Sunita'), findsOneWidget);
    expect(find.textContaining('km'), findsNothing);
  });

  testWidgets('an inherited PHC distance is worded as approximate',
      (tester) async {
    await tester.pumpWidget(harness([
      _asha(name: 'Akhila', accuracy: 'phc', distanceKm: 4.2),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('about 4.2 km away'), findsOneWidget);
    expect(find.text('4.2 km away'), findsNothing);
  });

  testWidgets('a sub-centre she pinned herself is given exactly',
      (tester) async {
    await tester.pumpWidget(harness([
      _asha(name: 'Akhila', accuracy: 'gps', distanceKm: 4.2),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('4.2 km away'), findsOneWidget);
  });

  testWidgets('an on-duty worker nearby is badged, and by band not by metres',
      (tester) async {
    await tester.pumpWidget(harness([
      _asha(
        name: 'Akhila',
        accuracy: 'gps',
        distanceKm: 3.6,
        onDuty: true,
        nearby: true,
        band: 'under_1km',
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Available now'), findsOneWidget);
    expect(find.text('Less than 1 km from you'), findsOneWidget);
    // Her live position is never expressed as a number.
    expect(find.textContaining('km away'), findsNothing);
  });

  testWidgets('a worker who is off duty carries no availability badge',
      (tester) async {
    await tester.pumpWidget(harness([
      _asha(name: 'Nagamma', accuracy: 'gps', distanceKm: 1.2),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Available now'), findsNothing);
    expect(find.text('1.2 km away'), findsOneWidget);
  });
}
