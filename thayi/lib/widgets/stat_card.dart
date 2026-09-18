import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'setu_card.dart';

/// Big number, small label beneath. Weeks pregnant, EDD, next checkup.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueStyle,
    this.caption,
    this.icon,
    this.accent = C.teal,
    this.badge,
    this.progress,
    this.onTap,
    this.background = C.card,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final String? caption;
  final IconData? icon;
  final Color accent;
  final Widget? badge;

  /// 0..1, draws a slim bar under the value.
  final double? progress;
  final VoidCallback? onTap;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SetuCard(
      onTap: onTap,
      color: background,
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24, color: accent),
                const SizedBox(width: S.sm),
              ],
              Expanded(child: Text(label, style: T.label)),
              if (badge != null) badge!,
            ],
          ),
          const SizedBox(height: S.sm),
          Text(
            value,
            style: (valueStyle ?? T.h1).copyWith(color: accent),
          ),
          if (progress != null) ...[
            const SizedBox(height: S.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: C.tealSoft,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
          if (caption != null) ...[
            const SizedBox(height: S.sm),
            Text(caption!, style: T.bodySoft),
          ],
        ],
      ),
    );
  }
}
