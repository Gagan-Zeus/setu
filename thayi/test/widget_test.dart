import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_thayi/main.dart';
import 'package:setu_thayi/providers.dart';
import 'package:setu_thayi/screens/login_screen.dart';
import 'package:setu_thayi/screens/onboarding/welcome_screen.dart';
import 'package:setu_thayi/screens/onboarding/waiting_screen.dart';
import 'package:setu_thayi/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The first-open flow has to resume exactly where she left it. Waiting for an
/// ASHA to visit can take days, and restarting her at the welcome screen every
/// time she reopens the app would be worse than useless.
void main() {
  Future<void> boot(WidgetTester tester, Map<String, Object> prefsValues,
      {bool settle = true}) async {
    SharedPreferences.setMockInitialValues(prefsValues);
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: const SetuThayiApp(),
      ),
    );
    if (settle) {
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();
    }
  }

  testWidgets('opens on the splash screen in Kannada by default',
      (tester) async {
    await boot(tester, {}, settle: false);
    await tester.pump();

    // Kannada is the default locale, not English.
    expect(find.text('ತಾಯಿ ಸೇತು'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    // Let the splash timer fire so the test does not end with it pending.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
  });

  testWidgets('a first open lands on the welcome screen, not login',
      (tester) async {
    await boot(tester, {});

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    // Congratulations first — before anything is asked of her.
    expect(find.text('ಅಭಿನಂದನೆಗಳು'), findsOneWidget);
    // Language can be changed before an account exists.
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('having given her name, she resumes at the location step',
      (tester) async {
    await boot(tester, {'onboarding_name': 'ಲಕ್ಷ್ಮಿ'});

    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.text('ನೀವು ಎಲ್ಲಿದ್ದೀರಿ?'), findsOneWidget);
  });

  testWidgets('having called an ASHA, she resumes at the waiting screen',
      (tester) async {
    await boot(tester, {
      'onboarding_name': 'ಲಕ್ಷ್ಮಿ',
      'onboarding_location_asked': true,
      'onboarding_called_asha': true,
    });

    expect(find.byType(WaitingScreen), findsOneWidget);
    // Greeted by name while she waits.
    expect(find.textContaining('ಲಕ್ಷ್ಮಿ'), findsWidgets);
  });

  testWidgets('once onboarding is finished she goes to login', (tester) async {
    await boot(tester, {
      'onboarding_name': 'ಲಕ್ಷ್ಮಿ',
      'onboarding_location_asked': true,
      'onboarding_called_asha': true,
      'onboarding_finished': true,
    });

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('ನಿಮ್ಮ ಇಮೇಲ್ ವಿಳಾಸ ಹಾಕಿ'), findsOneWidget);
  });

  testWidgets('a signed-in mother skips the whole flow', (tester) async {
    await boot(tester, {
      'auth_token': 'mock-token',
      'auth_email': 'lakshmi@example.com',
      'consent_at': DateTime.now().toIso8601String(),
    });

    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);

    // Home loads her record, so let the repository's delay drain rather than
    // ending the test with a timer still pending.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
  });
}
