import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// White rounded card with a soft shadow. The base of everything.
class SetuCard extends StatelessWidget {
  const SetuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(S.md),
    this.onTap,
    this.color = C.card,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(S.radius),
        boxShadow: kCardShadow,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(S.radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    return content;
  }
}

/// Small caps label above a group of cards.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: S.sm, top: S.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(text.toUpperCase(), style: T.label),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Quiet two-column row used on the Thayi Card and the detail screens.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: S.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(label, style: T.label),
          ),
          const SizedBox(width: S.sm),
          Expanded(
            child: Text(value, style: T.body),
          ),
        ],
      ),
    );
  }
}
