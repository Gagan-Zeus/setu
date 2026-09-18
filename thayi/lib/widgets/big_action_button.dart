import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Full width, 56dp minimum, icon plus label. Never an icon on its own.
class BigActionButton extends StatelessWidget {
  const BigActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.background = C.teal,
    this.foreground = C.onDark,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 26, color: background),
        label: Text(label, textAlign: TextAlign.center),
        style: OutlinedButton.styleFrom(
          foregroundColor: background,
          side: BorderSide(color: background, width: 1.5),
          minimumSize: const Size.fromHeight(S.tapMin),
          textStyle: T.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 26),
      label: Text(label, textAlign: TextAlign.center),
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size.fromHeight(S.tapMin),
        textStyle: T.button,
        padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// Large square tile with an icon over a label. Used in the Home grid.
class TileButton extends StatelessWidget {
  const TileButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.accent = C.teal,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.card,
      borderRadius: BorderRadius.circular(S.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(S.radius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 124),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(S.radius),
            boxShadow: kCardShadow,
            color: C.card,
          ),
          padding: const EdgeInsets.all(S.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: C.tealSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: accent),
              ),
              const SizedBox(height: S.sm),
              Text(
                label,
                style: T.body.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
