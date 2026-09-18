import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/l10n/app_localizations.dart';
import 'package:setu_asha/providers.dart';
import 'package:setu_asha/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The six code boxes were a fixed 46pt each — 276pt of hard minimum inside a
/// card that offers about 232pt on a 320pt phone, so the row overflowed there.
/// They are Expanded now, which divides whatever width exists and cannot
/// overflow. This pins the narrow case, which no simulator default catches.
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget harness() => ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      );

  testWidgets('the six code boxes fit the narrowest phone', (tester) async {
    // 320pt wide is the point. The height is generous on purpose: a short
    // viewport pushes the button off screen, the tap misses, and the test
    // passes against a layout it never rendered.
    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // With no Supabase configured the controller falls back to local sign-in,
    // so any address reaches the code step without sending anything.
    await tester.enterText(find.byType(TextField).first, 'asha@example.com');
    // "Sign in" is both the heading and the button label, so take the button.
    final button = find.text('Sign in').last;
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget,
        reason: 'the code step should have replaced the email step');

    // A RenderFlex overflow is thrown during layout and surfaces here.
    expect(tester.takeException(), isNull);
  });
}
