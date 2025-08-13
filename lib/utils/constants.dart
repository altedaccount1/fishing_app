// utils/constants.dart

class AppConstants {
  // App Info
  static const String appName = 'ASAC Fishing';
  static const String appVersion = '1.0.0';

  // Tournament Status
  static const String statusLive = 'live';
  static const String statusUpcoming = 'upcoming';
  static const String statusCompleted = 'completed';

  // Common Fish Species
  static const List<String> commonSpecies = [
    'Striped Bass',
    'Bluefish',
    'Fluke/Summer Flounder',
    'Weakfish',
    'Red Drum',
    'Black Drum',
    'Tautog',
    'Sea Bass',
    'Scup',
    'Kingfish',
  ];

  // Species Multipliers for scoring
  static const Map<String, double> speciesMultipliers = {
    'Striped Bass': 1.2,
    'Red Drum': 1.1,
    'Tautog': 1.3,
    'Black Drum': 1.1,
    'Weakfish': 1.0,
    'Bluefish': 1.0,
    'Fluke/Summer Flounder': 1.0,
    'Sea Bass': 1.0,
    'Scup': 1.0,
    'Kingfish': 1.0,
  };

  // Scoring Constants
  static const double lengthMultiplier = 1.5;
  static const double weightMultiplier = 3.0;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 8.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.asacfishing.com';
  static const String tournamentsEndpoint = '/tournaments';
  static const String teamsEndpoint = '/teams';
  static const String fishEndpoint = '/fish';

  // Validation
  static const double minFishLength = 6.0; // inches
  static const double maxFishLength = 60.0; // inches
  static const double minFishWeight = 0.1; // pounds
  static const double maxFishWeight = 100.0; // pounds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Error Messages
  static const String networkError =
      'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String validationError =
      'Please check your input and try again.';
  static const String notFoundError = 'The requested item was not found.';

  // Success Messages
  static const String fishSubmittedSuccess = 'Fish submitted successfully!';
  static const String dataRefreshedSuccess = 'Data refreshed successfully!';
  static const String tournamentUpdatedSuccess =
      'Tournament updated successfully!';
}

// Enums for better type safety
enum TournamentStatus {
  upcoming,
  live,
  completed;

  String get displayName {
    switch (this) {
      case TournamentStatus.upcoming:
        return 'Upcoming';
      case TournamentStatus.live:
        return 'Live';
      case TournamentStatus.completed:
        return 'Completed';
    }
  }
}

enum UserRole {
  participant,
  judge,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.participant:
        return 'Participant';
      case UserRole.judge:
        return 'Judge';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}
