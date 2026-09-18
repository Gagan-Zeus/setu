import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_thayi/l10n/app_localizations.dart';
import 'package:setu_thayi/providers.dart';
import 'package:setu_thayi/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The six code boxes were a fixed 48pt each. Six of them plus the gaps needed
/// 288pt, inside a card that offers about 232pt on a 320pt phone — so the row
/// overflowed on small screens and sat with roughly 3pt of air between boxes on
/// a normal one. They are now Expanded, which divides whatever width exists and
/// cannot overflow.
///
/// This pins the narrow case, because the failure is invisible on the
/// simulator sizes people usually check.
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
    // An iPhone SE is 320pt wide. Anything that assumes more is broken for a
    // share of the handsets this is actually used on.
    // 320pt wide is the point of the test. The height is generous on purpose:
    // a short viewport pushes the button off screen and the tap silently
    // misses, which looks like a pass.
    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // The boxes live on the second step, so the test has to get there or it
    // passes against a layout it never rendered. With no Supabase configured
    // the controller is in mock mode: any address is accepted and no code is
    // actually sent.
    await tester.enterText(
        find.byType(TextField).first, 'lakshmi@example.com');
    await tester.ensureVisible(find.text('Send code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    // The email field is replaced by the code field, not added to.
    expect(find.byType(TextField), findsOneWidget,
        reason: 'the code step should be on screen');

    // A RenderFlex overflow is thrown during layout, and this is where it
    // surfaces.
    expect(tester.takeException(), isNull);
  });

  testWidgets('the send button and errors talk about email, never SMS',
      (tester) async {
    // This screen began life as a phone/SMS flow and the wording outlived it:
    // the failure message asked her to "check your number" and the wrong-code
    // message pointed her at "the SMS", on a screen with no phone number on
    // it at all.
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
        tester.element(find.byType(LoginScreen)));

    for (final copy in [l.otpSendFailed, l.otpWrongCode, l.emailInvalid]) {
      expect(copy.toLowerCase(), isNot(contains('sms')));
      expect(copy.toLowerCase(), isNot(contains('number')));
    }
  });
}
