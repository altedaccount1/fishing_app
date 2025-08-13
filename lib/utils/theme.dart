// utils/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Colors.blue;
  static const Color primaryGreen = Colors.green;
  static const Color primaryOrange = Colors.orange;
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color cardWhite = Colors.white;

  // Status Colors
  static const Color liveColor = Colors.green;
  static const Color upcomingColor = Colors.orange;
  static const Color completedColor = Colors.blue;
  static const Color verifiedColor = Colors.green;
  static const Color pendingColor = Colors.orange;

  // Rank Colors
  static const Color goldColor = Colors.amber;
  static const Color silverColor = Colors.grey;
  static const Color bronzeColor = Colors.brown;

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: cardWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundGrey,
    );
  }
}

// Extension for status colors
extension StatusColors on String {
  Color get statusColor {
    switch (toLowerCase()) {
      case 'live':
        return AppTheme.liveColor;
      case 'upcoming':
        return AppTheme.upcomingColor;
      case 'completed':
        return AppTheme.completedColor;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (toLowerCase()) {
      case 'live':
        return Icons.live_tv;
      case 'upcoming':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}

// Extension for rank colors
extension RankColors on int {
  Color get rankColor {
    switch (this) {
      case 0:
        return AppTheme.goldColor;
      case 1:
        return AppTheme.silverColor;
      case 2:
        return AppTheme.bronzeColor;
      default:
        return AppTheme.primaryBlue;
    }
  }
}
