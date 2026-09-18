import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:setu_asha/risk/risk_engine.dart';

/// The risk engine is the clinical heart of this app and it runs offline, so
/// it is tested directly rather than through the UI. R2 in particular is the
/// rule the whole demo turns on.
void main() {
  late RiskEngine engine;

  setUpAll(() {
    final raw = File('assets/rules/risk_rules.json').readAsStringSync();
    engine = RiskEngine.fromJson(raw);
  });

  RiskProfile normal() => RiskProfile(
        age: 24,
        gravida: 1,
        prevComplications: const [],
        lmp: DateTime.now().subtract(const Duration(days: 224)),
      );

  group('blood pressure', () {
    test('R2 fires red on 165/110', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(bpSys: 165, bpDia: 110),
        normal(),
      );
      expect(alerts.any((a) => a.ruleId == 'R2' && a.isRed), isTrue);
    });

    test('R2 fires on 145/95 with headache — the demo case', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(bpSys: 145, bpDia: 95, dangerSigns: ['headache']),
        normal(),
      );
      expect(alerts.any((a) => a.ruleId == 'R2' && a.isRed), isTrue);
    });

    test('R1 fires amber on 145/95 with no other sign', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(bpSys: 145, bpDia: 95),
        normal(),
      );
      expect(alerts.any((a) => a.ruleId == 'R1'), isTrue);
      expect(alerts.any((a) => a.ruleId == 'R2'), isFalse);
    });

    test('R1 is suppressed when R2 already fired', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(bpSys: 170, bpDia: 115),
        normal(),
      );
      expect(alerts.where((a) => a.ruleId == 'R1'), isEmpty);
    });

    test('normal BP raises nothing', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(bpSys: 118, bpDia: 76),
        normal(),
      );
      expect(alerts, isEmpty);
    });
  });

  group('anaemia', () {
    test('R3 fires red below 7', () {
      final alerts = engine.evaluateVisit(const RiskInput(hb: 6.4), normal());
      expect(alerts.any((a) => a.ruleId == 'R3' && a.isRed), isTrue);
    });

    test('R4 fires amber between 7 and 9.9', () {
      final alerts = engine.evaluateVisit(const RiskInput(hb: 8.2), normal());
      expect(alerts.any((a) => a.ruleId == 'R4'), isTrue);
      expect(alerts.any((a) => a.ruleId == 'R3'), isFalse);
    });

    test('normal haemoglobin raises nothing', () {
      final alerts = engine.evaluateVisit(const RiskInput(hb: 11.5), normal());
      expect(alerts, isEmpty);
    });
  });

  group('danger signs', () {
    test('R5 fires red on bleeding', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(dangerSigns: ['bleeding']),
        normal(),
      );
      expect(alerts.any((a) => a.ruleId == 'R5' && a.isRed), isTrue);
    });

    test('R5 fires red on absent fetal movement', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(dangerSigns: ['noMovement']),
        normal(),
      );
      expect(alerts.any((a) => a.ruleId == 'R5' && a.isRed), isTrue);
    });

    test('a headache alone is not a red flag without raised BP', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(dangerSigns: ['headache']),
        normal(),
      );
      expect(alerts.any((a) => a.isRed), isFalse);
    });
  });

  group('R6 standing risk at registration', () {
    test('fires for a mother under 18', () {
      final alerts = engine.evaluateProfile(
        RiskProfile(
          age: 17,
          gravida: 1,
          prevComplications: const [],
          lmp: DateTime.now(),
        ),
      );
      expect(alerts.any((a) => a.ruleId == 'R6'), isTrue);
    });

    test('fires on a previous caesarean', () {
      final alerts = engine.evaluateProfile(
        RiskProfile(
          age: 26,
          gravida: 2,
          prevComplications: const ['cSection'],
          lmp: DateTime.now(),
        ),
      );
      expect(alerts.any((a) => a.ruleId == 'R6'), isTrue);
    });

    test('does not fire for a low-risk first pregnancy', () {
      expect(engine.evaluateProfile(normal()), isEmpty);
    });
  });

  group('severity roll-up', () {
    test('red beats amber', () {
      final alerts = engine.evaluateVisit(
        const RiskInput(bpSys: 165, bpDia: 112, hb: 8.0),
        normal(),
      );
      expect(RiskEngine.levelOf(alerts), 'red');
      // The worst alert must sort first — the banner shows only one.
      expect(alerts.first.isRed, isTrue);
    });

    test('no alerts means green', () {
      expect(RiskEngine.levelOf(const []), 'green');
    });
  });

  group('plausible ranges', () {
    test('flags an impossible BP typo', () {
      expect(PlausibleRange.bpSys(1650), isFalse);
      expect(PlausibleRange.bpSys(165), isTrue);
    });

    test('flags an impossible weight', () {
      expect(PlausibleRange.weight(4.5), isFalse);
      expect(PlausibleRange.weight(54.5), isTrue);
    });
  });
}
