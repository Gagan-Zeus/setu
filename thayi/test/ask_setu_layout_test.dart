import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:setu_thayi/data/chat_service.dart';
import 'package:setu_thayi/data/mother_repository.dart';
import 'package:setu_thayi/l10n/app_localizations.dart';
import 'package:setu_thayi/providers.dart';
import 'package:setu_thayi/screens/ask_setu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The composer used to carry the openers and the disclaimer permanently, which
/// came to roughly 250 logical pixels. With the keyboard open on a real phone
/// there was then no height left for the message list at all: the body
/// collapsed to nothing and the composer rendered at the top of the screen with
/// the conversation gone. These tests pin the two things that caused it.
void main() {
  // The screen restores its saved transcript on open, so the store has to be
  // present or every test dies in initState.
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget harness({Size size = const Size(400, 800)}) {
    return ProviderScope(
      overrides: [
        // No network in a widget test, and none needed: the layout is what is
        // under test, not the assistant. Zero delays so nothing is left
        // pending when the tree is torn down.
        chatServiceProvider.overrideWithValue(
          const MockChatService(
              delay: Duration.zero, reply: 'Yes, that is fine.'),
        ),
        motherRepositoryProvider.overrideWithValue(
          const MockMotherRepository(delay: Duration.zero),
        ),
        prefsProvider.overrideWithValue(prefs),
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
        home: const AskSetuScreen(),
      ),
    );
  }

  testWidgets('the openers are offered before she has said anything',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    expect(find.text('What should I eat every day?'), findsOneWidget);
  });

  testWidgets('the disclaimer is stated once, not pinned above the keyboard',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    expect(find.text("Advice only — not a doctor's opinion"), findsOneWidget);
  });

  testWidgets('the composer leaves the conversation room on a short screen',
      (tester) async {
    // Roughly what is left of a phone once the keyboard is up.
    tester.view.physicalSize = const Size(400, 420);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // The welcome message must still be on screen. If the composer takes the
    // whole height this is the first thing to disappear.
    expect(find.textContaining('Namaskara'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the keyboard does not cover the box she types into',
      (tester) async {
    // Scaffold insets its body for the keyboard but leaves
    // bottomNavigationBar alone, so the composer has to lift itself.
    const keyboard = 300.0;
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    final field = tester.getRect(find.byType(TextField));
    expect(
      field.bottom,
      lessThanOrEqualTo(800.0 - keyboard),
      reason: 'the text field is underneath the keyboard',
    );
  });
}
