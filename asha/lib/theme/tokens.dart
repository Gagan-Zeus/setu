import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour tokens. Never use raw `Colors.*` anywhere else in the app.
class C {
  // Brand
  static const ink = Color(0xFF10312B); // deep teal-green, headings
  static const teal = Color(0xFF0F5257); // primary
  static const tealSoft = Color(0xFFE4EFEC); // teal tint, chips/fills
  static const terra = Color(0xFFD2603F); // accent, CTAs
  static const terraSoft = Color(0xFFFBEAE3);

  // Surfaces
  static const bg = Color(0xFFF7F2EA); // warm off-white
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE6DED2);

  // Text
  static const text = Color(0xFF10312B);
  static const textSoft = Color(0xFF5E6E6A);
  static const onDark = Color(0xFFFFFFFF);

  // Clinical status - these three are semantic, never decorative
  static const red = Color(0xFFB23A32); // danger, emergency
  static const redSoft = Color(0xFFF7E4E2);
  static const amber = Color(0xFFC98A2B); // caution, overdue
  static const amberSoft = Color(0xFFFBF0DC);
  static const green = Color(0xFF3E7C59); // normal, done
  static const greenSoft = Color(0xFFE3F0E8);
}

/// Type scale. Everything is one size up from a normal app -
/// the user may be reading in sunlight with poor eyesight.
class T {
  static TextStyle get display => GoogleFonts.notoSansKannada(
      fontSize: 44, fontWeight: FontWeight.w700, color: C.ink, height: 1.15);
  static TextStyle get h1 => GoogleFonts.notoSansKannada(
      fontSize: 28, fontWeight: FontWeight.w700, color: C.ink, height: 1.25);
  static TextStyle get h2 => GoogleFonts.notoSansKannada(
      fontSize: 22, fontWeight: FontWeight.w600, color: C.ink, height: 1.3);
  static TextStyle get body => GoogleFonts.notoSansKannada(
      fontSize: 18, fontWeight: FontWeight.w400, color: C.text, height: 1.5);
  static TextStyle get bodySoft => GoogleFonts.notoSansKannada(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: C.textSoft,
      height: 1.5);
  static TextStyle get label => GoogleFonts.notoSansKannada(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: C.textSoft,
      letterSpacing: 0.4);
  static TextStyle get button => GoogleFonts.notoSansKannada(
      fontSize: 19, fontWeight: FontWeight.w600, height: 1.2);
}

/// Spacing - only these values. No magic numbers anywhere.
class S {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const screen = 20.0; // screen edge padding
  static const radius = 18.0; // all cards
  static const tapMin = 56.0; // minimum height of anything tappable
}

/// The one shadow used on every card.
const kCardShadow = <BoxShadow>[
  BoxShadow(color: Color(0x0F10312B), blurRadius: 18, offset: Offset(0, 6)),
];
