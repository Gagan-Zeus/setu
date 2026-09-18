import 'package:flutter/material.dart';
import 'tokens.dart';

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: C.teal,
      onPrimary: C.onDark,
      secondary: C.terra,
      onSecondary: C.onDark,
      surface: C.card,
      onSurface: C.text,
      error: C.red,
      onError: C.onDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: T.h2,
      iconTheme: const IconThemeData(color: C.ink, size: 28),
    ),
    cardTheme: CardThemeData(
      color: C.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(S.radius),
      ),
    ),
    dividerTheme: const DividerThemeData(color: C.divider, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.teal,
        foregroundColor: C.onDark,
        minimumSize: const Size.fromHeight(S.tapMin),
        textStyle: T.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.teal,
        minimumSize: const Size.fromHeight(S.tapMin),
        textStyle: T.button,
        side: const BorderSide(color: C.teal, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: C.teal,
        textStyle: T.button,
        minimumSize: const Size(S.tapMin, S.tapMin),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.card,
      hintStyle: T.bodySoft,
      labelStyle: T.label,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: S.md, vertical: S.md),
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
    tabBarTheme: TabBarThemeData(
      labelColor: C.teal,
      unselectedLabelColor: C.textSoft,
      labelStyle: T.h2,
      unselectedLabelStyle: T.h2,
      indicatorColor: C.teal,
      dividerColor: C.divider,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: C.teal,
      linearTrackColor: C.tealSoft,
    ),
  );
}
