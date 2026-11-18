import 'package:flutter/material.dart';

enum AppThemeMode { light, warmCoffee, pitchBlack, vintageSepia }

class AppTheme {
  static ThemeData getThemeData(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.warmCoffee:
        const scaffoldBg = Color(0xFF1E1815);
        const cardBg = Color(0xFF2B211E);
        const textColor = Color(0xFFE8DCC4);
        const subTextColor = Color(0xFFB8A995);

        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: scaffoldBg,
          primaryColor: textColor,
          cardColor: cardBg,
          dialogBackgroundColor: cardBg,
          dividerColor: Colors.white12,
          colorScheme: const ColorScheme.dark(
            primary: textColor,
            secondary: Color(0xFFD4B886),
            surface: cardBg,
            background: scaffoldBg,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: cardBg,
            elevation: 0.5,
            iconTheme: IconThemeData(color: textColor),
            titleTextStyle: TextStyle(
              fontFamily: 'Essays1743',
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: cardBg,
            selectedItemColor: textColor,
            unselectedItemColor: subTextColor,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: textColor, fontFamily: 'Essays1743'),
            bodyMedium: TextStyle(color: textColor, fontFamily: 'Essays1743'),
            titleMedium: TextStyle(color: textColor, fontFamily: 'Essays1743'),
          ),
          fontFamily: 'Essays1743',
        );

      case AppThemeMode.pitchBlack:
        const scaffoldBg = Color(0xFF121212);
        const cardBg = Color(0xFF1E1E1E);
        const textColor = Color(0xFFE0E0E0);
        const subTextColor = Color(0xFF9E9E9E);

        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: scaffoldBg,
          primaryColor: Colors.white,
          cardColor: cardBg,
          dialogBackgroundColor: cardBg,
          dividerColor: Colors.white10,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.white70,
            surface: cardBg,
            background: scaffoldBg,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: cardBg,
            elevation: 0.5,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              fontFamily: 'Essays1743',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: cardBg,
            selectedItemColor: Colors.white,
            unselectedItemColor: subTextColor,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: textColor, fontFamily: 'Essays1743'),
            bodyMedium: TextStyle(color: textColor, fontFamily: 'Essays1743'),
            titleMedium: TextStyle(color: textColor, fontFamily: 'Essays1743'),
          ),
          fontFamily: 'Essays1743',
        );

      case AppThemeMode.vintageSepia:
        const scaffoldBg = Color(0xFFF4ECD8);
        const cardBg = Color(0xFFEFE4CD);
        const textColor = Color(0xFF433422);
        const subTextColor = Color(0xFF7A654C);

        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: scaffoldBg,
          primaryColor: textColor,
          cardColor: cardBg,
          dialogBackgroundColor: cardBg,
          dividerColor: Colors.black12,
          colorScheme: const ColorScheme.light(
            primary: textColor,
            secondary: subTextColor,
            surface: cardBg,
            background: scaffoldBg,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: cardBg,
            elevation: 0.5,
            iconTheme: IconThemeData(color: textColor),
            titleTextStyle: TextStyle(
              fontFamily: 'Essays1743',
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: cardBg,
            selectedItemColor: textColor,
            unselectedItemColor: subTextColor,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: textColor, fontFamily: 'Essays1743'),
            bodyMedium: TextStyle(color: textColor, fontFamily: 'Essays1743'),
            titleMedium: TextStyle(color: textColor, fontFamily: 'Essays1743'),
          ),
          fontFamily: 'Essays1743',
        );

      case AppThemeMode.light:
      default:
        const scaffoldBg = Color(0xFFFAF9F6);
        const cardBg = Colors.white;
        const textColor = Color(0xFF2D2319);
        const subTextColor = Colors.black54;

        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: scaffoldBg,
          primaryColor: Colors.black,
          cardColor: cardBg,
          dialogBackgroundColor: cardBg,
          dividerColor: Colors.black12,
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            secondary: Colors.black87,
            surface: cardBg,
            background: scaffoldBg,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: cardBg,
            elevation: 0.5,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              fontFamily: 'Essays1743',
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: cardBg,
            selectedItemColor: Colors.black,
            unselectedItemColor: subTextColor,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: textColor, fontFamily: 'Essays1743'),
            bodyMedium: TextStyle(color: textColor, fontFamily: 'Essays1743'),
            titleMedium: TextStyle(color: textColor, fontFamily: 'Essays1743'),
          ),
          fontFamily: 'Essays1743',
        );
    }
  }
}
