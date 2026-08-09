import 'package:flutter/material.dart';

abstract final class WalkaColors {
  static const Color navy = Color(0xFF003366);
  static const Color navyDark = Color(0xFF00264D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color ivory = Color(0xFFFAF9F6);
  static const Color surface = Color(0xFFF3F5F7);
  static const Color text = Color(0xFF111827);
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE2E8F0);
  static const Color white = Colors.white;
}

abstract final class WalkaSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class WalkaRadius {
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double pill = 999;
}

abstract final class WalkaType {
  static const TextStyle eyebrow = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
    color: WalkaColors.gold,
  );

  static const TextStyle display = TextStyle(
    fontFamily: 'serif',
    fontSize: 38,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.7,
    color: WalkaColors.white,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'serif',
    fontSize: 28,
    height: 1.1,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: WalkaColors.navy,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.55,
    color: WalkaColors.muted,
  );
}

ThemeData buildWalkaTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: WalkaColors.navy,
    brightness: Brightness.light,
  ).copyWith(
    primary: WalkaColors.navy,
    secondary: WalkaColors.gold,
    surface: WalkaColors.ivory,
    onPrimary: WalkaColors.white,
    onSecondary: WalkaColors.navyDark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: WalkaColors.ivory,
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: WalkaColors.text,
      displayColor: WalkaColors.text,
    ),
    dividerColor: WalkaColors.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: WalkaColors.ivory,
      foregroundColor: WalkaColors.navy,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: WalkaColors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: WalkaColors.gold.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        final bool selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? WalkaColors.navy : WalkaColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        final bool selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? WalkaColors.navy : WalkaColors.muted,
          size: 23,
        );
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: WalkaColors.gold,
        foregroundColor: WalkaColors.navyDark,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WalkaRadius.pill),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}
