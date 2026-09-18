import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/tokens.dart';

/// White card, subtle shadow, 12px radius. Shadow OR border, never both.
class CareCard extends StatelessWidget {
  const CareCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(S.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(S.radius),
        boxShadow: kShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Uppercase label above a group. The brief's --fs-label.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: S.sm),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: T.label)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Big number, small label. Used for the four dashboard tiles.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.tone,
    this.onTap,
  });

  final String value;
  final String label;

  /// Only ever a clinical tone. Null means neutral ink.
  final RiskLevel? tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colour = switch (tone) {
      RiskLevel.red => C.red,
      RiskLevel.amber => C.amber,
      RiskLevel.green => C.green,
      null => C.ink,
    };
    return CareCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: T.display.copyWith(color: colour, fontSize: 30)),
          const SizedBox(height: S.xs),
          Text(label.toUpperCase(), style: T.label),
        ],
      ),
    );
  }
}

/// Small coloured pill. The only place colour carries meaning in a table.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.level, this.compact = false});

  final RiskLevel level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, text) = switch (level) {
      RiskLevel.red => (C.red, C.redSoft, 'High risk'),
      RiskLevel.amber => (C.amber, C.amberSoft, 'Watch'),
      RiskLevel.green => (C.green, C.greenSoft, 'Normal'),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? S.sm : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: T.label.copyWith(color: fg, letterSpacing: 0.4),
      ),
    );
  }
}

/// A pill spelling out *why* she is flagged. Reason, not decoration.
class ReasonChip extends StatelessWidget {
  const ReasonChip({super.key, required this.text, required this.level});

  final String text;
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (level) {
      RiskLevel.red => (C.red, C.redSoft),
      RiskLevel.amber => (C.amber, C.amberSoft),
      RiskLevel.green => (C.green, C.greenSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(S.sm),
      ),
      child: Text(text, style: T.small.copyWith(color: fg)),
    );
  }
}

/// Tight two-column row for the identity panel.
class KeyValue extends StatelessWidget {
  const KeyValue({
    super.key,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 116, child: Text(label, style: T.small)),
          Expanded(child: Text(value, style: valueStyle ?? T.body)),
        ],
      ),
    );
  }
}

/// Who recorded an entry, with a role icon. ASHA or doctor.
class RoleTag extends StatelessWidget {
  const RoleTag({super.key, required this.name, required this.source});

  final String name;
  final VisitSource source;

  @override
  Widget build(BuildContext context) {
    final isDoctor = source == VisitSource.doctor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDoctor ? Icons.medical_services_outlined : Icons.hiking_outlined,
          size: 14,
          color: C.textSoft,
        ),
        const SizedBox(width: S.xs),
        Text(
          '$name · ${isDoctor ? 'Doctor' : 'ASHA'}',
          style: T.small,
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.inbox_outlined, size: 28, color: C.textSoft),
            const SizedBox(height: S.sm),
            Text(message, style: T.small, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Never a blank screen while loading.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.height = 72});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(S.radius),
        boxShadow: kShadow,
      ),
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(90, 9),
          const SizedBox(height: S.sm),
          _bar(150, 13),
        ],
      ),
    );
  }

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: C.bg,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(S.screen),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: S.sm),
      itemBuilder: (_, i) => SkeletonBlock(height: i.isEven ? 78 : 64),
    );
  }
}
