// Add to services/data_service.dart

// Individual Registration Storage
static List<IndividualRegistration> _individualRegistrations = [];
static List<TournamentCode> _tournamentCodes = [];

// Tournament Code Management
static TournamentCode generateTournamentCode(String tournamentId) {
  final tournament = getTournamentById(tournamentId);
  if (tournament == null) {
    throw Exception('Tournament not found');
  }

  // Generate a readable 6-character code
  final codeChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  String code;
  
  // Ensure unique code
  do {
    code = List.generate(6, (index) => 
      codeChars[random.nextInt(codeChars.length)]).join();
  } while (_tournamentCodes.any((tc) => tc.code == code));

  final tournamentCode = TournamentCode(
    tournamentId: tournamentId,
    code: code,
    createdAt: DateTime.now(),
    expiresAt: tournament.date.add(const Duration(hours: 12)), // Expires 12 hours after tournament
    maxRegistrations: 200, // Adjust as needed
  );

  _tournamentCodes.add(tournamentCode);
  _notifyListeners();
  return tournamentCode;
}

static TournamentCode? getTournamentCode(String tournamentId) {
  try {
    return _tournamentCodes.firstWhere((tc) => tc.tournamentId == tournamentId);
  } catch (e) {
    return null;
  }
}

static Future<Tournament?> getTournamentByCode(String code) async {
  await Future.delayed(const Duration(milliseconds: 300));
  
  try {
    final tournamentCode = _tournamentCodes.firstWhere((tc) => tc.code == code);
    
    if (!tournamentCode.isValid) {
      throw Exception('Tournament code is expired or invalid');
    }
    
    return getTournamentById(tournamentCode.tournamentId);
  } catch (e) {
    throw Exception('Invalid tournament code');
  }
}

// Individual Registration Management
static List<IndividualRegistration> getIndividualRegistrations(String tournamentId) {
  return _individualRegistrations
      .where((reg) => reg.tournamentId == tournamentId)
      .toList()
    ..sort((a, b) => b.registrationTime.compareTo(a.registrationTime));
}

static Future<String> submitIndividualRegistration(IndividualRegistration registration) async {
  await Future.delayed(const Duration(milliseconds: 500));

  // Validate tournament exists and is accepting registrations
  final tournament = getTournamentById(registration.tournamentId);
  if (tournament == null) {
    throw Exception('Tournament not found');
  }

  if (tournament.status == 'completed') {
    throw Exception('Tournament registration is closed');
  }

  // Check for duplicate registration
  final existingReg = _individualRegistrations.where((reg) => 
    reg.tournamentId == registration.tournamentId && 
    reg.name.toLowerCase() == registration.name.toLowerCase()
  ).firstOrNull;

  if (existingReg != null) {
    throw Exception('A registration already exists for this name');
  }

  // Validate tournament code capacity
  final tournamentCode = getTournamentCode(registration.tournamentId);
  if (tournamentCode != null && tournamentCode.isFull) {
    throw Exception('Tournament registration is full');
  }

  _individualRegistrations.add(registration);
  
  // Update tournament code registration count
  if (tournamentCode != null) {
    final index = _tournamentCodes.indexWhere((tc) => tc.code == tournamentCode.code);
    if (index != -1) {
      _tournamentCodes[index] = TournamentCode(
        tournamentId: tournamentCode.tournamentId,
        code: tournamentCode.code,
        createdAt: tournamentCode.createdAt,
        expiresAt: tournamentCode.expiresAt,
        isActive: tournamentCode.isActive,
        maxRegistrations: tournamentCode.maxRegistrations,
        currentRegistrations: tournamentCode.currentRegistrations + 1,
      );
    }
  }

  _notifyListeners();
  return registration.id;
}

static Future<bool> markRegistrationAsPaid(String registrationId) async {
  await Future.delayed(const Duration(milliseconds: 300));

  final index = _individualRegistrations.indexWhere((reg) => reg.id == registrationId);
  if (index != -1) {
    _individualRegistrations[index] = _individualRegistrations[index].copyWith(isPaid: true);
    _notifyListeners();
    return true;
  }
  return false;
}

static Future<bool> removeIndividualRegistration(String registrationId) async {
  await Future.delayed(const Duration(milliseconds: 300));

  final registration = _individualRegistrations.where((reg) => reg.id == registrationId).firstOrNull;
  if (registration == null) {
    return false;
  }

  // Remove any fish catches associated with this registration
  _allCatches.removeWhere((fish) => fish.teamId == registrationId);

  // Remove the registration
  final countRemoved = _individualRegistrations.where((reg) => reg.id == registrationId).length;
  _individualRegistrations.removeWhere((reg) => reg.id == registrationId);

  // Update tournament code registration count
  final tournamentCode = getTournamentCode(registration.tournamentId);
  if (tournamentCode != null) {
    final index = _tournamentCodes.indexWhere((tc) => tc.code == tournamentCode.code);
    if (index != -1) {
      _tournamentCodes[index] = TournamentCode(
        tournamentId: tournamentCode.tournamentId,
        code: tournamentCode.code,
        createdAt: tournamentCode.createdAt,
        expiresAt: tournamentCode.expiresAt,
        isActive: tournamentCode.isActive,
        maxRegistrations: tournamentCode.maxRegistrations,
        currentRegistrations: (tournamentCode.currentRegistrations - 1).clamp(0, double.infinity).toInt(),
      );
    }
  }

  if (countRemoved > 0) {
    _notifyListeners();
    return true;
  }
  return false;
}

static Future<bool> updateIndividualRegistration(IndividualRegistration registration) async {
  await Future.delayed(const Duration(milliseconds: 300));

  final index = _individualRegistrations.indexWhere((reg) => reg.id == registration.id);
  if (index != -1) {
    _individualRegistrations[index] = registration;
    _notifyListeners();
    return true;
  }
  return false;
}

// Individual Fish Scoring (modify existing addFishCatch to handle individuals)
static Future<String> addIndividualFishCatch(Fish fish, String registrationId) async {
  await Future.delayed(const Duration(milliseconds: 300));

  // Validate registration exists and is paid
  final registration = _individualRegistrations.where((reg) => reg.id == registrationId).firstOrNull;
  if (registration == null) {
    throw Exception('Registration not found');
  }

  if (!registration.isPaid) {
    throw Exception('Registration payment must be confirmed before submitting catches');
  }

  // Validate tournament exists and is active
  final tournament = getTournamentById(fish.tournamentId);
  if (tournament == null) {
    throw Exception('Tournament not found');
  }

  if (tournament.status != 'live') {
    throw Exception('Can only add catches to live tournaments');
  }

  // Use registrationId as teamId for individual participants
  final individualFish = fish.copyWith(teamId: registrationId);
  _allCatches.add(individualFish);

  // Update individual registration points if fish is verified
  if (individualFish.verified) {
    _updateIndividualPoints(registrationId, individualFish.points);
  }

  _notifyListeners();
  return individualFish.id;
}

static void _updateIndividualPoints(String registrationId, int pointsChange) {
  final index = _individualRegistrations.indexWhere((reg) => reg.id == registrationId);
  if (index != -1) {
    final registration = _individualRegistrations[index];
    final updatedCatches = getCatchesForTeam(registrationId); // teamId is registrationId for individuals
    final newTotalPoints = updatedCatches
        .where((fish) => fish.verified)
        .fold(0, (sum, fish) => sum + fish.points);

    _individualRegistrations[index] = registration.copyWith(
      totalPoints: newTotalPoints,
      catches: updatedCatches,
    );
  }
}

// Leaderboard methods for individuals
static List<IndividualRegistration> getIndividualLeaderboard(String tournamentId) {
  final registrations = getIndividualRegistrations(tournamentId)
      .where((reg) => reg.isPaid)
      .toList();
  
  // Update points for each registration
  for (int i = 0; i < registrations.length; i++) {
    final catches = getCatchesForTeam(registrations[i].id);
    final totalPoints = catches
        .where((fish) => fish.verified)
        .fold(0, (sum, fish) => sum + fish.points);
    
    registrations[i] = registrations[i].copyWith(
      totalPoints: totalPoints,
      catches: catches,
    );
  }
  
  registrations.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
  return registrations;
}

// Age category leaderboards
static List<IndividualRegistration> getKidsLeaderboard(String tournamentId) {
  return getIndividualLeaderboard(tournamentId)
      .where((reg) => reg.isChild)
      .toList();
}

static List<IndividualRegistration> getAdultLeaderboard(String tournamentId) {
  return getIndividualLeaderboard(tournamentId)
      .where((reg) => !reg.isChild)
      .toList();
}

// Statistics for individuals
static Map<String, dynamic> getIndividualStats(String tournamentId) {
  final registrations = getIndividualRegistrations(tournamentId);
  final paidRegistrations = registrations.where((reg) => reg.isPaid).toList();
  final kidsRegistrations = registrations.where((reg) => reg.isChild).toList();
  final adultRegistrations = registrations.where((reg) => !reg.isChild).toList();

  final totalCatches = paidRegistrations.fold(0, (sum, reg) => sum + reg.catches.length);
  final totalPoints = paidRegistrations.fold(0, (sum, reg) => sum + reg.totalPoints);

  return {
    'totalRegistrations': registrations.length,
    'paidRegistrations': paidRegistrations.length,
    'pendingRegistrations': registrations.length - paidRegistrations.length,
    'kidsRegistrations': kidsRegistrations.length,
    'adultRegistrations': adultRegistrations.length,
    'totalCatches': totalCatches,
    'totalPoints': totalPoints,
    'averagePointsPerPerson': paidRegistrations.isNotEmpty 
        ? (totalPoints / paidRegistrations.length).round() 
        : 0,
  };
}

// Tournament capacity management
static bool canAcceptMoreRegistrations(String tournamentId) {
  final tournamentCode = getTournamentCode(tournamentId);
  if (tournamentCode == null) return false;
  
  return tournamentCode.isValid && !tournamentCode.isFull;
}

static int getRemainingCapacity(String tournamentId) {
  final tournamentCode = getTournamentCode(tournamentId);
  if (tournamentCode == null) return 0;
  
  return (tournamentCode.maxRegistrations - tournamentCode.currentRegistrations)
      .clamp(0, double.infinity)
      .toInt();
}

// Export individual registration data
static Map<String, dynamic> exportIndividualRegistrations(String tournamentId) {
  final registrations = getIndividualRegistrations(tournamentId);
  final leaderboard = getIndividualLeaderboard(tournamentId);
  final stats = getIndividualStats(tournamentId);

  return {
    'tournamentId': tournamentId,
    'exportDate': DateTime.now().toIso8601String(),
    'registrations': registrations.map((r) => r.toJson()).toList(),
    'leaderboard': leaderboard.map((r) => {
      'rank': leaderboard.indexOf(r) + 1,
      'name': r.displayName,
      'totalPoints': r.totalPoints,
      'fishCount': r.catches.length,
      'isPaid': r.isPaid,
      'isChild': r.isChild,
    }).toList(),
    'statistics': stats,
  };
}