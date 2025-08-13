// models/tournament_code.dart
class TournamentCode {
  final String tournamentId;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final int maxRegistrations;
  final int currentRegistrations;

  TournamentCode({
    required this.tournamentId,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
    this.maxRegistrations = 100,
    this.currentRegistrations = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isFull => currentRegistrations >= maxRegistrations;
  bool get isValid => isActive && !isExpired && !isFull;

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'code': code,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      'maxRegistrations': maxRegistrations,
      'currentRegistrations': currentRegistrations,
    };
  }

  factory TournamentCode.fromJson(Map<String, dynamic> json) {
    return TournamentCode(
      tournamentId: json['tournamentId'],
      code: json['code'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      isActive: json['isActive'] ?? true,
      maxRegistrations: json['maxRegistrations'] ?? 100,
      currentRegistrations: json['currentRegistrations'] ?? 0,
    );
  }
}
