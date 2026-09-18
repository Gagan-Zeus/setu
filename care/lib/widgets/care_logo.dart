import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The Setu Care mark: a stethoscope framing a mother and the child she is
/// carrying. Ships as an asset so the launcher icon and the in-app mark are
/// the same image.
class CareLogo extends StatelessWidget {
  const CareLogo({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/brand/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Never a broken-image box on the login screen.
        errorBuilder: (context, _, __) => Container(
          color: C.teal,
          alignment: Alignment.center,
          child: Text(
            'S',
            style: TextStyle(
              color: C.onDark,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.53,
            ),
          ),
        ),
      ),
    );
  }
}
