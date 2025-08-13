// models/fish.dart

class Fish {
  final String id;
  final String teamId;
  final String tournamentId;
  final String species;
  final double length; // inches
  final double weight; // pounds
  final DateTime caughtTime;
  final int points;
  final String judgeId;
  final bool verified;
  final String? photoUrl;
  final String? notes;

  Fish({
    required this.id,
    required this.teamId,
    required this.tournamentId,
    required this.species,
    required this.length,
    required this.weight,
    required this.caughtTime,
    required this.points,
    required this.judgeId,
    this.verified = false,
    this.photoUrl,
    this.notes,
  });

  // Helper methods
  String get lengthDisplay => '${length.toStringAsFixed(1)}"';
  String get weightDisplay => '${weight.toStringAsFixed(1)} lbs';
  String get measurementDisplay => '$lengthDisplay • $weightDisplay';
  String get pointsDisplay => '$points pts';

  bool get isPending => !verified;

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'tournamentId': tournamentId,
      'species': species,
      'length': length,
      'weight': weight,
      'caughtTime': caughtTime.toIso8601String(),
      'points': points,
      'judgeId': judgeId,
      'verified': verified,
      'photoUrl': photoUrl,
      'notes': notes,
    };
  }

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      id: json['id'],
      teamId: json['teamId'],
      tournamentId: json['tournamentId'],
      species: json['species'],
      length: (json['length'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      caughtTime: DateTime.parse(json['caughtTime']),
      points: json['points'],
      judgeId: json['judgeId'],
      verified: json['verified'] ?? false,
      photoUrl: json['photoUrl'],
      notes: json['notes'],
    );
  }

  // Copy with method for immutable updates
  Fish copyWith({
    String? id,
    String? teamId,
    String? tournamentId,
    String? species,
    double? length,
    double? weight,
    DateTime? caughtTime,
    int? points,
    String? judgeId,
    bool? verified,
    String? photoUrl,
    String? notes,
  }) {
    return Fish(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      tournamentId: tournamentId ?? this.tournamentId,
      species: species ?? this.species,
      length: length ?? this.length,
      weight: weight ?? this.weight,
      caughtTime: caughtTime ?? this.caughtTime,
      points: points ?? this.points,
      judgeId: judgeId ?? this.judgeId,
      verified: verified ?? this.verified,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fish && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Fish(id: $id, species: $species, length: $length, weight: $weight, points: $points, verified: $verified)';
  }
}
