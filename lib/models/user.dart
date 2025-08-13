// models/user.dart

enum UserRole {
  admin, // ASAC Officials
  teamCaptain, // Team Captains
  judge, // Tournament Judges
  user, // Regular Users
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'ASAC Official';
      case UserRole.teamCaptain:
        return 'Team Captain';
      case UserRole.judge:
        return 'Judge';
      case UserRole.user:
        return 'Member';
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.teamCaptain:
        return 'team_captain';
      case UserRole.judge:
        return 'judge';
      case UserRole.user:
        return 'user';
    }
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? club;
  final String? teamId;
  final DateTime createdAt;
  final bool isActive;
  final String? phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.club,
    this.teamId,
    required this.createdAt,
    this.isActive = true,
    this.phoneNumber,
  });

  String get fullName => '$firstName $lastName';
  String get displayRole => role.displayName;

  bool get isAdmin => role == UserRole.admin;
  bool get isTeamCaptain => role == UserRole.teamCaptain;
  bool get isJudge => role == UserRole.judge;
  bool get canManageTournaments => isAdmin;
  bool get canManageTeams => isAdmin || isTeamCaptain;
  bool get canScore => isAdmin || isJudge;

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.value,
      'club': club,
      'teamId': teamId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'phoneNumber': phoneNumber,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: UserRole.values.firstWhere((r) => r.value == json['role']),
      club: json['club'],
      teamId: json['teamId'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      phoneNumber: json['phoneNumber'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? club,
    String? teamId,
    DateTime? createdAt,
    bool? isActive,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      club: club ?? this.club,
      teamId: teamId ?? this.teamId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
