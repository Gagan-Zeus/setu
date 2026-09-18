import 'package:flutter/material.dart';

/// Tokens from the Setu Care brief (src/styles/tokens.css), ported to Dart.
///
/// This is a clinical tool, not a consumer app: dense, calm, information
/// first. Red and amber are semantic ONLY — risk badges, alert rows, overdue
/// markers. Never a button, never an accent. If red loses its meaning the
/// whole interface stops working.
class C {
  // Brand
  static const ink = Color(0xFF10312B);
  static const teal = Color(0xFF0F5257);
  static const tealSoft = Color(0xFFE4EFEC);
  static const terra = Color(0xFFD2603F);
  static const terraSoft = Color(0xFFFBEAE3);

  // Surfaces
  static const bg = Color(0xFFF7F2EA);
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE6DED2);

  // Text
  static const text = Color(0xFF10312B);
  static const textSoft = Color(0xFF5E6E6A);
  static const onDark = Color(0xFFFFFFFF);

  // Clinical status — semantic only, never decorative
  static const red = Color(0xFFB23A32);
  static const redSoft = Color(0xFFFBEAE8);
  static const amber = Color(0xFFC98A2B);
  static const amberSoft = Color(0xFFFBF2E2);
  static const green = Color(0xFF3E7C59);
  static const greenSoft = Color(0xFFE8F1EB);
}

/// Exactly the brief's scale — 15px body, 13px small, 11px label. This is a
/// clinical tool for someone scanning 200 records, not the mother app, which
/// is oversized and warm because she reads it in sunlight. If this comes out
/// looking like a consumer app it is wrong, so the density is not softened for
/// touch.
///
/// No fontFamily is set on purpose: the brief's stack is Inter with a
/// system-ui fallback, Inter is not bundled, and the platform sans-serif is
/// what would render anyway. Naming a font we do not ship would be a lie.
class T {
  static const display = TextStyle(
      fontSize: 34, fontWeight: FontWeight.w700, color: C.ink, height: 1.1);
  static const h1 = TextStyle(
      fontSize: 24, fontWeight: FontWeight.w700, color: C.ink, height: 1.2);
  static const h2 = TextStyle(
      fontSize: 19, fontWeight: FontWeight.w600, color: C.ink, height: 1.3);
  static const body = TextStyle(
      fontSize: 15, fontWeight: FontWeight.w400, color: C.text, height: 1.45);
  static const bodySoft = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: C.textSoft,
      height: 1.45);
  static const small = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: C.textSoft,
      height: 1.4);

  /// Uppercase, letter-spacing 0.06em, per the brief.
  static const label = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: C.textSoft,
      letterSpacing: 0.66);
  static const button = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

  /// Tabular figures, so columns of numbers line up.
  static const mono = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: C.ink,
      fontFeatures: [FontFeature.tabularFigures()]);
}

/// Spacing — only these values.
class S {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 40.0;
  static const radius = 12.0;
  static const screen = 16.0;

  /// Minimum height of anything tappable on a touch screen.
  static const tapMin = 48.0;
}

/// Cards get a shadow OR a border, never both.
const kShadow = <BoxShadow>[
  BoxShadow(color: Color(0x0F10312B), blurRadius: 3, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0A10312B), blurRadius: 12, offset: Offset(0, 4)),
];
