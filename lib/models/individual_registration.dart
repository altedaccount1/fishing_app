// models/individual_registration.dart
import 'fish.dart';

class IndividualRegistration {
  final String id;
  final String tournamentId;
  final String name;
  final String? phoneNumber;
  final int? age; // null for adults
  final DateTime registrationTime;
  final bool isPaid;
  final String? parentName; // for kids
  final String? parentPhone; // for kids
  final List<Fish> catches;
  final int totalPoints;

  IndividualRegistration({
    required this.id,
    required this.tournamentId,
    required this.name,
    this.phoneNumber,
    this.age,
    required this.registrationTime,
    this.isPaid = false,
    this.parentName,
    this.parentPhone,
    this.catches = const [],
    this.totalPoints = 0,
  });

  bool get isChild => age != null && age! < 18;
  bool get needsParentInfo =>
      isChild && (parentName == null || parentPhone == null);

  String get displayName => isChild ? '$name (Age $age)' : name;
  String get contactInfo =>
      isChild ? parentPhone ?? 'No contact' : phoneNumber ?? 'No contact';

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'name': name,
      'phoneNumber': phoneNumber,
      'age': age,
      'registrationTime': registrationTime.toIso8601String(),
      'isPaid': isPaid,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'catches': catches.map((c) => c.toJson()).toList(),
      'totalPoints': totalPoints,
    };
  }

  factory IndividualRegistration.fromJson(Map<String, dynamic> json) {
    return IndividualRegistration(
      id: json['id'],
      tournamentId: json['tournamentId'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      age: json['age'],
      registrationTime: DateTime.parse(json['registrationTime']),
      isPaid: json['isPaid'] ?? false,
      parentName: json['parentName'],
      parentPhone: json['parentPhone'],
      catches:
          (json['catches'] as List?)?.map((c) => Fish.fromJson(c)).toList() ??
              [],
      totalPoints: json['totalPoints'] ?? 0,
    );
  }

  IndividualRegistration copyWith({
    String? id,
    String? tournamentId,
    String? name,
    String? phoneNumber,
    int? age,
    DateTime? registrationTime,
    bool? isPaid,
    String? parentName,
    String? parentPhone,
    List<Fish>? catches,
    int? totalPoints,
  }) {
    return IndividualRegistration(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      registrationTime: registrationTime ?? this.registrationTime,
      isPaid: isPaid ?? this.isPaid,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      catches: catches ?? this.catches,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
