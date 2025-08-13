// models/team.dart

class Team {
  final String id;
  final String name;
  final String club;
  final List<String> members;
  int totalPoints;

  Team({
    required this.id,
    required this.name,
    required this.club,
    required this.members,
    this.totalPoints = 0,
  });

  // Helper methods
  String get membersDisplay => members.join(', ');
  int get memberCount => members.length;

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'club': club,
      'members': members,
      'totalPoints': totalPoints,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      club: json['club'],
      members: List<String>.from(json['members'] ?? []),
      totalPoints: json['totalPoints'] ?? 0,
    );
  }

  // Copy with method
  Team copyWith({
    String? id,
    String? name,
    String? club,
    List<String>? members,
    int? totalPoints,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      club: club ?? this.club,
      members: members ?? this.members,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  // Add points to team
  void addPoints(int points) {
    totalPoints += points;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
