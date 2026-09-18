import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum RiskLevel { normal, caution, danger, neutral }

/// Small pill with a semantic colour. Green normal, amber caution, red danger.
class RiskChip extends StatelessWidget {
  const RiskChip({
    super.key,
    required this.label,
    this.level = RiskLevel.caution,
    this.icon,
  });

  final String label;
  final RiskLevel level;
  final IconData? icon;

  Color get _fg => switch (level) {
        RiskLevel.normal => C.green,
        RiskLevel.caution => C.amber,
        RiskLevel.danger => C.red,
        RiskLevel.neutral => C.teal,
      };

  Color get _bg => switch (level) {
        RiskLevel.normal => C.greenSoft,
        RiskLevel.caution => C.amberSoft,
        RiskLevel.danger => C.redSoft,
        RiskLevel.neutral => C.tealSoft,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: _fg),
            const SizedBox(width: S.xs),
          ],
          Text(
            label,
            style: T.label.copyWith(color: _fg, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
