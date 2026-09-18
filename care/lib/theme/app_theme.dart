import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: C.teal,
      onPrimary: C.onDark,
      // Terracotta is reserved for the single most important action on a
      // screen, not used as a general accent.
      secondary: C.terra,
      onSecondary: C.onDark,
      surface: C.card,
      onSurface: C.text,
      error: C.red,
      onError: C.onDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: T.h2,
      iconTheme: IconThemeData(color: C.ink, size: 22),
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
          borderRadius: BorderRadius.circular(S.sm),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.teal,
        minimumSize: const Size.fromHeight(S.tapMin),
        textStyle: T.button,
        side: const BorderSide(color: C.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.sm),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: C.teal,
        textStyle: T.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.card,
      hintStyle: T.small,
      labelStyle: T.small,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: S.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.sm),
        borderSide: const BorderSide(color: C.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.sm),
        borderSide: const BorderSide(color: C.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(S.sm),
        borderSide: const BorderSide(color: C.teal, width: 2),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: C.teal,
      unselectedLabelColor: C.textSoft,
      labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      indicatorColor: C.teal,
      dividerColor: C.divider,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.card,
      indicatorColor: C.tealSoft,
      elevation: 0,
      height: 66,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: C.ink,
      contentTextStyle: TextStyle(color: C.onDark, fontSize: 15),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
