// models/tournament.dart
import 'team.dart';
import 'fish.dart';

class Tournament {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String status; // upcoming, live, completed
  final String hostClub; // Club hosting the tournament
  final List<Team> teams;
  final List<Fish> catches;

  Tournament({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.status,
    required this.hostClub,
    this.teams = const [],
    this.catches = const [],
  });

  // Helper methods
  bool get isLive => status == 'live';
  bool get isUpcoming => status == 'upcoming';
  bool get isCompleted => status == 'completed';

  int get teamCount => teams.length;

  // Convert to/from JSON for future API integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'status': status,
      'hostClub': hostClub,
      'teams': teams.map((team) => team.toJson()).toList(),
      'catches': catches.map((fish) => fish.toJson()).toList(),
    };
  }

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      status: json['status'],
      hostClub: json['hostClub'],
      teams:
          (json['teams'] as List?)
              ?.map((team) => Team.fromJson(team))
              .toList() ??
          [],
      catches:
          (json['catches'] as List?)
              ?.map((fish) => Fish.fromJson(fish))
              .toList() ??
          [],
    );
  }

  // Copy with method for immutable updates
  Tournament copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? location,
    String? status,
    String? hostClub,
    List<Team>? teams,
    List<Fish>? catches,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      status: status ?? this.status,
      hostClub: hostClub ?? this.hostClub,
      teams: teams ?? this.teams,
      catches: catches ?? this.catches,
    );
  }
}
