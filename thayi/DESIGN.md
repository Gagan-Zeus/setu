# Setu Thayi — design system

Two files. Paste both into Claude Code and tell it: **"Use this theme everywhere.
Never use raw Colors.* or hardcoded sizes. Build every screen from these tokens
and components."**

That instruction is the whole point — without it you get default Material blue and
a dozen inconsistent paddings.

---

## 1. `lib/theme/tokens.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  // Brand
  static const ink       = Color(0xFF10312B); // deep teal-green, headings
  static const teal      = Color(0xFF0F5257); // primary
  static const tealSoft  = Color(0xFFE4EFEC); // teal tint, chips/fills
  static const terra     = Color(0xFFD2603F); // accent, CTAs
  static const terraSoft = Color(0xFFFBEAE3);

  // Surfaces
  static const bg      = Color(0xFFF7F2EA); // warm off-white
  static const card    = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE6DED2);

  // Text
  static const text     = Color(0xFF10312B);
  static const textSoft = Color(0xFF5E6E6A);

  // Clinical status — these three are semantic, never decorative
  static const red   = Color(0xFFB23A32); // danger, emergency
  static const amber = Color(0xFFC98A2B); // caution, overdue
  static const green = Color(0xFF3E7C59); // normal, done
}

/// Type scale. Everything is one size up from a normal app —
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
      fontSize: 18, fontWeight: FontWeight.w400, color: C.textSoft, height: 1.5);
  static TextStyle get label => GoogleFonts.notoSansKannada(
      fontSize: 15, fontWeight: FontWeight.w600, color: C.textSoft,
      letterSpacing: 0.4);
  static TextStyle get button => GoogleFonts.notoSansKannada(
      fontSize: 19, fontWeight: FontWeight.w600, height: 1.2);
}

/// Spacing — only these values. No magic numbers anywhere.
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
```

---

## 2. `lib/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'tokens.dart';

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: C.teal,
      secondary: C.terra,
      surface: C.card,
      error: C.red,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: T.h2,
      iconTheme: const IconThemeData(color: C.ink, size: 28),
    ),
    cardTheme: CardTheme(
      color: C.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(S.radius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(S.tapMin),
        textStyle: T.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.card,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: S.md, vertical: S.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.teal, width: 2),
      ),
    ),
  );
}
```

---

## 3. Components to build once and reuse

Tell Claude Code to create these in `lib/widgets/` **before** any screen. Every
screen then composes from them, which is what makes the app look designed rather
than assembled.

| Widget | What it is |
|---|---|
| `SetuCard` | White rounded card, soft shadow, `S.md` internal padding. The base of everything. |
| `StatCard` | Big number + small label beneath. Used for weeks pregnant, EDD, next checkup. |
| `RiskChip` | Small pill, semantic colour + label. Green normal, amber caution, red danger. |
| `BigActionButton` | Full-width, 56dp min, icon + Kannada label. All primary actions. |
| `CallButton` | Terracotta, phone icon, name + number. Used on Emergency, ASHA, Danger Signs. |
| `EmergencyFab` | Red circular FAB, bottom-right, wraps every post-login screen. |
| `SectionHeader` | `T.label` in caps above a group of cards. |
| `EmptyState` | Icon + one Kannada line. Prevents blank screens during the demo. |

---

## 4. Visual direction for the four demo screens

Spend your polish budget here and nowhere else.

**HOME** — vertical scroll of `SetuCard`s. The "weeks pregnant" card is visually
dominant: number at `T.display` in teal, thin progress bar across 40 weeks
beneath. Everything else is quieter. Ends with a 2×2 grid of large icon tiles.

**MY THAYI CARD** — the QR fills roughly 60% of the screen width, centred, on
white with generous margin. Kannada caption directly beneath. Her details in a
quiet two-column list below. Nothing competes with the QR — this is the screen
someone else will be pointing a scanner at.

**EMERGENCY** — breaks the calm palette on purpose. Red header band, her critical
info in `T.h1` so a stranger holding her phone can read it at arm's length, then
three full-width `CallButton`s stacked. No decoration, no cards-within-cards.

**ASK SETU** — standard chat bubbles: her messages terracotta-tinted and
right-aligned, replies white and left-aligned. Suggestion chips sit in a
horizontal scroll directly above the input. The advisory line is small, muted,
and permanently pinned under the text field.

---

## 5. The rule that saves you at hour 20

**Never leave a screen blank while loading.** Every screen gets a skeleton or an
`EmptyState`. A demo that flashes white and then pops content looks broken on a
projector; a demo with a soft placeholder looks finished.

Same for errors — mock repository failures should return an `EmptyState` with a
Kannada line, not a red Flutter exception box.
