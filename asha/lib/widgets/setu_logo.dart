import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The ASHA mark: a health worker attending a mother and her newborn.
///
/// The artwork ships as an asset rather than being drawn, so the app icon and
/// every in-app logo are the same image. It is clipped to a rounded square to
/// match the launcher icon's shape.
class SetuLogo extends StatelessWidget {
  const SetuLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: kCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Image.asset(
        'assets/brand/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        // If the asset is ever missing, fall back to the wordmark's initial
        // rather than a broken-image box on the splash screen.
        errorBuilder: (context, _, __) => Container(
          color: C.teal,
          alignment: Alignment.center,
          child: Text(
            'ಆ',
            style: TextStyle(
              color: C.onDark,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
