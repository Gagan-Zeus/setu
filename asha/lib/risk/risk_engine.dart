/// The risk engine.
///
/// A pure function over a visit and a mother's profile. It runs on the device,
/// synchronously, with no network and no model call — which is exactly why it
/// still fires in a village in airplane mode.
///
/// Thresholds live in assets/rules/risk_rules.json so they can be tuned
/// without a rebuild; the evaluation for each rule id lives here.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

enum Severity { amber, red }

class RiskAlert {
  const RiskAlert({
    required this.ruleId,
    required this.severity,
    required this.titleKn,
    required this.titleEn,
    required this.messageKn,
    required this.messageEn,
  });

  final String ruleId;
  final Severity severity;
  final String titleKn;
  final String titleEn;
  final String messageKn;
  final String messageEn;

  bool get isRed => severity == Severity.red;
}

class RuleSpec {
  const RuleSpec({
    required this.id,
    required this.severity,
    required this.enabled,
    required this.params,
    required this.titleKn,
    required this.titleEn,
    required this.messageKn,
    required this.messageEn,
  });

  factory RuleSpec.fromJson(Map<String, dynamic> json) => RuleSpec(
        id: json['id'] as String,
        severity: (json['severity'] as String) == 'red'
            ? Severity.red
            : Severity.amber,
        enabled: json['enabled'] as bool? ?? true,
        params: Map<String, dynamic>.from(json['params'] as Map? ?? {}),
        titleKn: json['title_kn'] as String? ?? '',
        titleEn: json['title_en'] as String? ?? '',
        messageKn: json['message_kn'] as String? ?? '',
        messageEn: json['message_en'] as String? ?? '',
      );

  final String id;
  final Severity severity;
  final bool enabled;
  final Map<String, dynamic> params;
  final String titleKn;
  final String titleEn;
  final String messageKn;
  final String messageEn;

  double num_(String key, double fallback) {
    final v = params[key];
    return v is num ? v.toDouble() : fallback;
  }
}

/// What the engine needs to know about the mother. Kept separate from the
/// Drift row so the engine stays testable with no database.
class RiskProfile {
  const RiskProfile({
    required this.age,
    required this.gravida,
    required this.prevComplications,
    required this.lmp,
    this.lastVisitDate,
    this.weightAt4WeeksAgo,
  });

  final int age;
  final int gravida;
  final List<String> prevComplications;
  final DateTime lmp;
  final DateTime? lastVisitDate;
  final double? weightAt4WeeksAgo;

  int gestationWeeksOn(DateTime now) =>
      (now.difference(lmp).inDays / 7).floor().clamp(0, 45);
}

/// What the engine needs from the visit being entered. All nullable, because
/// she may be part-way through typing.
class RiskInput {
  const RiskInput({
    this.bpSys,
    this.bpDia,
    this.hb,
    this.weightKg,
    this.temperatureC,
    this.dangerSigns = const [],
  });

  final int? bpSys;
  final int? bpDia;
  final double? hb;
  final double? weightKg;
  final double? temperatureC;
  final List<String> dangerSigns;
}

class RiskEngine {
  RiskEngine(this.rules);

  final List<RuleSpec> rules;

  static const assetPath = 'assets/rules/risk_rules.json';

  static Future<RiskEngine> load() async {
    final raw = await rootBundle.loadString(assetPath);
    return RiskEngine.fromJson(raw);
  }

  factory RiskEngine.fromJson(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['rules'] as List)
        .map((e) => RuleSpec.fromJson(e as Map<String, dynamic>))
        .toList();
    return RiskEngine(list);
  }

  RuleSpec? _rule(String id) {
    for (final r in rules) {
      if (r.id == id && r.enabled) return r;
    }
    return null;
  }

  RiskAlert _alert(RuleSpec spec) => RiskAlert(
        ruleId: spec.id,
        severity: spec.severity,
        titleKn: spec.titleKn,
        titleEn: spec.titleEn,
        messageKn: spec.messageKn,
        messageEn: spec.messageEn,
      );

  /// Runs every rule that applies to a visit in progress. Ordered red first,
  /// because the UI shows the worst one.
  List<RiskAlert> evaluateVisit(RiskInput input, RiskProfile profile) {
    final out = <RiskAlert>[];

    // R5 — any hard danger sign, or a high fever. Checked first: it is the
    // one that means "stop and refer now".
    final r5 = _rule('R5');
    if (r5 != null) {
      const hard = {
        'bleeding',
        'convulsions',
        'noMovement',
      };
      final feverThreshold = r5.num_('fever', 38.5);
      final hasHardSign = input.dangerSigns.any(hard.contains);
      final hasFever = input.dangerSigns.contains('fever') ||
          (input.temperatureC != null && input.temperatureC! >= feverThreshold);
      if (hasHardSign || hasFever) out.add(_alert(r5));
    }

    // R2 — severe hypertension, or raised BP together with a pre-eclampsia
    // sign. This is the rule the whole demo turns on.
    final r2 = _rule('R2');
    if (r2 != null && input.bpSys != null && input.bpDia != null) {
      final severe = input.bpSys! >= r2.num_('sys', 160) ||
          input.bpDia! >= r2.num_('dia', 110);
      final raised = input.bpSys! >= r2.num_('warn_sys', 140) ||
          input.bpDia! >= r2.num_('warn_dia', 90);
      const preEclampsiaSigns = {'headache', 'vision', 'swelling'};
      final withSign = input.dangerSigns.any(preEclampsiaSigns.contains);
      if (severe || (raised && withSign)) out.add(_alert(r2));
    }

    // R1 — raised BP on its own. Suppressed when R2 already fired, so she is
    // not told the same thing twice at two different severities.
    final r1 = _rule('R1');
    if (r1 != null &&
        input.bpSys != null &&
        input.bpDia != null &&
        !out.any((a) => a.ruleId == 'R2')) {
      if (input.bpSys! >= r1.num_('sys', 140) ||
          input.bpDia! >= r1.num_('dia', 90)) {
        out.add(_alert(r1));
      }
    }

    // R3 / R4 — anaemia.
    final hb = input.hb;
    if (hb != null) {
      final r3 = _rule('R3');
      final r4 = _rule('R4');
      if (r3 != null && hb < r3.num_('hb', 7.0)) {
        out.add(_alert(r3));
      } else if (r4 != null &&
          hb >= r4.num_('low', 7.0) &&
          hb <= r4.num_('high', 9.9)) {
        out.add(_alert(r4));
      }
    }

    // R8 — poor weight gain after 20 weeks.
    final r8 = _rule('R8');
    if (r8 != null &&
        input.weightKg != null &&
        profile.weightAt4WeeksAgo != null &&
        profile.gestationWeeksOn(DateTime.now()) >= r8.num_('after_week', 20)) {
      final gain = input.weightKg! - profile.weightAt4WeeksAgo!;
      if (gain < r8.num_('min_gain_kg', 1.0)) out.add(_alert(r8));
    }

    out.addAll(evaluateProfile(profile));
    out.sort((a, b) => a.isRed == b.isRed ? 0 : (a.isRed ? -1 : 1));
    return out;
  }

  /// R6 — standing risk from who she is, not from today's readings. Runs at
  /// registration too, which is why it is separate.
  List<RiskAlert> evaluateProfile(RiskProfile profile) {
    final out = <RiskAlert>[];
    final r6 = _rule('R6');
    if (r6 != null) {
      const risky = {'cSection', 'stillbirth', 'pph'};
      final byAge = profile.age < r6.num_('min_age', 18) ||
          profile.age > r6.num_('max_age', 35);
      final byGravida = profile.gravida >= r6.num_('gravida', 5);
      final byHistory = profile.prevComplications.any(risky.contains);
      if (byAge || byGravida || byHistory) out.add(_alert(r6));
    }
    return out;
  }

  /// R7 — no visit in N days. Runs as a periodic local check that creates
  /// Task rows; it does not depend on a visit being entered.
  RiskAlert? evaluateOverdue(RiskProfile profile, DateTime now) {
    final r7 = _rule('R7');
    if (r7 == null) return null;
    final last = profile.lastVisitDate;
    final days = r7.num_('days', 30).toInt();
    if (last == null) {
      // Registered but never visited: only overdue once she has been on the
      // books longer than the window.
      return now.difference(profile.lmp).inDays > days ? _alert(r7) : null;
    }
    return now.difference(last).inDays >= days ? _alert(r7) : null;
  }

  /// The worst severity in a list, as the string stored on the mother row.
  static String levelOf(List<RiskAlert> alerts) {
    if (alerts.any((a) => a.isRed)) return 'red';
    if (alerts.isNotEmpty) return 'amber';
    return 'green';
  }
}

/// Plausible ranges. Outside these, she is asked to confirm rather than the
/// value being silently accepted — a typo in a BP reading is dangerous.
class PlausibleRange {
  static bool bpSys(int v) => v >= 70 && v <= 200;
  static bool bpDia(int v) => v >= 40 && v <= 130;
  static bool weight(double v) => v >= 30 && v <= 120;
  static bool hb(double v) => v >= 3 && v <= 18;
  static bool fundalHeight(double v) => v >= 10 && v <= 45;
  static bool fetalHr(int v) => v >= 100 && v <= 180;
}
