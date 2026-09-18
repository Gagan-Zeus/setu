import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/data/seed_data.dart';
import 'package:setu_asha/db/database.dart';
import 'package:setu_asha/l10n/app_localizations.dart';
import 'package:setu_asha/providers.dart';
import 'package:setu_asha/screens/home_screen.dart';

/// Regression test. TaskCard used a bare CrossAxisAlignment.stretch, which
/// gives the Row an unbounded height inside a ListView — the first card
/// rendered without its surface and every card after it silently vanished.
void main() {
  late AppDatabase db;
  late List<Task> tasks;
  late List<Mother> mothers;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await SeedData.seedIfEmpty(db);
    tasks = await db.watchTasks('open').first;
    mothers = await db.allMothers();
  });

  tearDown(() => db.close());

  Mother motherFor(String id) => mothers.firstWhere((m) => m.id == id);

  Widget harness(Widget child) => MaterialApp(
        locale: const Locale('kn'),
        supportedLocales: kSupportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: child),
      );

  testWidgets('every open task renders in a scrolling list', (tester) async {
    await tester.pumpWidget(
      harness(
        ListView(
          children: [
            for (final t in tasks)
              TaskCard(task: t, mother: motherFor(t.motherId)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tasks.length, 5);
    // A ListView only builds what fits, so the count is "more than one" —
    // the bug rendered exactly one and dropped the rest.
    expect(find.byType(TaskCard), findsAtLeastNWidgets(2));
    expect(tester.takeException(), isNull);

    // The last task must be reachable by scrolling.
    await tester.dragUntilVisible(
      find.text(motherFor(tasks.last.motherId).name),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text(motherFor(tasks.last.motherId).name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a task card lays out without overflowing', (tester) async {
    await tester.pumpWidget(
      harness(
        ListView(
          children: [
            TaskCard(
                task: tasks.first, mother: motherFor(tasks.first.motherId)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
