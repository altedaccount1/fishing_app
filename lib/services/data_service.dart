// services/data_service.dart
import 'dart:math';
import '../models/tournament.dart';
import '../models/team.dart';
import '../models/fish.dart';
import '../models/individual_registration.dart';
import '../models/tournament_code.dart';

class DataService {
  // Storage
  static List<Tournament> _tournaments = [];
  static List<Team> _teams = [];
  static List<Fish> _allCatches = [];
  static List<IndividualRegistration> _individualRegistrations = [];
  static List<TournamentCode> _tournamentCodes = [];
  static bool _isInitialized = false;

  // Data change listeners
  static final List<Function()> _listeners = [];

  static void initialize() {
    if (_isInitialized) return;
    _loadSampleData();
    _isInitialized = true;
  }

  static void _loadSampleData() {
    // Load existing sample data (tournaments, teams, etc.)
    _loadSampleTournaments();
    _loadSampleTeams();
    _loadSampleCatches();
    _generateSampleTournamentCodes();
    _notifyListeners();
  }

  static void _loadSampleTournaments() {
    _tournaments = [
      Tournament(
        id: '1',
        name: 'Spring Slam 2024',
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'Cape Henlopen State Park',
        status: 'upcoming',
        hostClub: 'Cape May Fishing Club',
        teams: [],
        catches: [],
      ),
      Tournament(
        id: '2',
        name: 'Summer Classic',
        date: DateTime.now().add(const Duration(hours: 2)),
        location: 'Island Beach State Park',
        status: 'live',
        hostClub: 'Ocean City Fishing Club',
        teams: [],
        catches: [],
      ),
      Tournament(
        id: '3',
        name: 'Fall Championship',
        date: DateTime.now().subtract(const Duration(days: 30)),
        location: 'Assateague Island',
        status: 'completed',
        hostClub: 'Atlantic City Salt Water Anglers',
        teams: [],
        catches: [],
      ),
    ];
  }

  static void _loadSampleTeams() {
    _teams = [
      Team(
        id: '1',
        name: 'Ocean City Legends',
        club: 'Ocean City Fishing Club',
        members: ['Drew Furst', 'Mike Johnson', 'Tom Wilson'],
        totalPoints: 450,
      ),
      Team(
        id: '2',
        name: 'Cape May Warriors',
        club: 'Cape May Fishing Club',
        members: ['Sarah Davis', 'Chris Brown', 'Alex Miller'],
        totalPoints: 380,
      ),
    ];

    // Add teams to tournaments
    _tournaments[0] = _tournaments[0].copyWith(teams: [_teams[0], _teams[1]]);
    _tournaments[1] = _tournaments[1].copyWith(teams: [_teams[0]]);
  }

  static void _loadSampleCatches() {
    _allCatches = [
      Fish(
        id: '1',
        teamId: '1',
        tournamentId: '2',
        species: 'Striped Bass',
        length: 28.5,
        weight: 8.2,
        caughtTime: DateTime.now().subtract(const Duration(hours: 1)),
        points: 132,
        judgeId: 'judge_ocean_city',
        verified: true,
      ),
      Fish(
        id: '2',
        teamId: '2',
        tournamentId: '2',
        species: 'Bluefish',
        length: 24.0,
        weight: 4.5,
        caughtTime: DateTime.now().subtract(const Duration(minutes: 30)),
        points: 90,
        judgeId: 'judge_cape_may',
        verified: false,
      ),
    ];
  }

  static void _generateSampleTournamentCodes() {
    // Generate codes for live and upcoming tournaments
    for (final tournament in _tournaments) {
      if (tournament.status == 'live' || tournament.status == 'upcoming') {
        final code = _generateTournamentCode(tournament.id);
        _tournamentCodes.add(code);
      }
    }
  }

  // Listener management
  static void addListener(Function() listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // Tournament Management
  static List<Tournament> getAllTournaments() =>
      List.unmodifiable(_tournaments);

  static Tournament? getTournamentById(String id) {
    try {
      return _tournaments.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Tournament> getTournamentsByStatus(String status) {
    return _tournaments.where((t) => t.status == status).toList();
  }

  static List<Tournament> getTournamentsByHostClub(String hostClub) {
    return _tournaments.where((t) => t.hostClub == hostClub).toList();
  }

  static Future<String> createTournament({
    required String name,
    required DateTime date,
    required String location,
    required String hostClub,
    String status = 'upcoming',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newTournament = Tournament(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      date: date,
      location: location,
      status: status,
      hostClub: hostClub,
      teams: [],
      catches: [],
    );

    _tournaments.add(newTournament);
    _notifyListeners();
    return newTournament.id;
  }

  static Future<bool> updateTournament(Tournament tournament) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _tournaments.indexWhere((t) => t.id == tournament.id);
    if (index != -1) {
      _tournaments[index] = tournament;
      _notifyListeners();
      return true;
    }
    return false;
  }

  static void updateTournamentStatus(String tournamentId, String newStatus) {
    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index != -1) {
      _tournaments[index] = _tournaments[index].copyWith(status: newStatus);
      _notifyListeners();
    }
  }

  static Future<bool> deleteTournament(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final countRemoved = _tournaments.where((t) => t.id == tournamentId).length;
    _tournaments.removeWhere((t) => t.id == tournamentId);

    // Also remove related data
    _allCatches.removeWhere((fish) => fish.tournamentId == tournamentId);
    _individualRegistrations
        .removeWhere((reg) => reg.tournamentId == tournamentId);
    _tournamentCodes.removeWhere((code) => code.tournamentId == tournamentId);

    if (countRemoved > 0) {
      _notifyListeners();
      return true;
    }
    return false;
  }

  // Tournament Code Management
  static TournamentCode _generateTournamentCode(String tournamentId) {
    final codeChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code;

    // Ensure unique code
    do {
      code = List.generate(
          6, (index) => codeChars[random.nextInt(codeChars.length)]).join();
    } while (_tournamentCodes.any((tc) => tc.code == code));

    final tournament = getTournamentById(tournamentId)!;
    return TournamentCode(
      tournamentId: tournamentId,
      code: code,
      createdAt: DateTime.now(),
      expiresAt: tournament.date.add(const Duration(hours: 12)),
      maxRegistrations: 200,
    );
  }

  static TournamentCode generateTournamentCode(String tournamentId) {
    final tournamentCode = _generateTournamentCode(tournamentId);
    _tournamentCodes.add(tournamentCode);
    _notifyListeners();
    return tournamentCode;
  }

  static TournamentCode? getTournamentCode(String tournamentId) {
    try {
      return _tournamentCodes
          .firstWhere((tc) => tc.tournamentId == tournamentId);
    } catch (e) {
      return null;
    }
  }

  static Future<Tournament?> getTournamentByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final tournamentCode =
          _tournamentCodes.firstWhere((tc) => tc.code == code);

      if (!tournamentCode.isValid) {
        throw Exception('Tournament code is expired or invalid');
      }

      return getTournamentById(tournamentCode.tournamentId);
    } catch (e) {
      throw Exception('Invalid tournament code');
    }
  }

  // Individual Registration Management
  static List<IndividualRegistration> getIndividualRegistrations(
      String tournamentId) {
    return _individualRegistrations
        .where((reg) => reg.tournamentId == tournamentId)
        .toList()
      ..sort((a, b) => b.registrationTime.compareTo(a.registrationTime));
  }

  static Future<String> submitIndividualRegistration(
      IndividualRegistration registration) async {
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
    final existingReg = _individualRegistrations
        .where((reg) =>
            reg.tournamentId == registration.tournamentId &&
            reg.name.toLowerCase() == registration.name.toLowerCase())
        .firstOrNull;

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
      _updateTournamentCodeCount(tournamentCode.code, 1);
    }

    _notifyListeners();
    return registration.id;
  }

  static Future<bool> markRegistrationAsPaid(String registrationId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index =
        _individualRegistrations.indexWhere((reg) => reg.id == registrationId);
    if (index != -1) {
      _individualRegistrations[index] =
          _individualRegistrations[index].copyWith(isPaid: true);
      _notifyListeners();
      return true;
    }
    return false;
  }

  static Future<bool> removeIndividualRegistration(
      String registrationId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final registration = _individualRegistrations
        .where((reg) => reg.id == registrationId)
        .firstOrNull;
    if (registration == null) {
      return false;
    }

    // Remove any fish catches associated with this registration
    _allCatches.removeWhere((fish) => fish.teamId == registrationId);

    // Remove the registration
    final countRemoved = _individualRegistrations
        .where((reg) => reg.id == registrationId)
        .length;
    _individualRegistrations.removeWhere((reg) => reg.id == registrationId);

    // Update tournament code registration count
    final tournamentCode = getTournamentCode(registration.tournamentId);
    if (tournamentCode != null) {
      _updateTournamentCodeCount(tournamentCode.code, -1);
    }

    if (countRemoved > 0) {
      _notifyListeners();
      return true;
    }
    return false;
  }

  static void _updateTournamentCodeCount(String code, int change) {
    final index = _tournamentCodes.indexWhere((tc) => tc.code == code);
    if (index != -1) {
      final current = _tournamentCodes[index];
      _tournamentCodes[index] = TournamentCode(
        tournamentId: current.tournamentId,
        code: current.code,
        createdAt: current.createdAt,
        expiresAt: current.expiresAt,
        isActive: current.isActive,
        maxRegistrations: current.maxRegistrations,
        currentRegistrations: (current.currentRegistrations + change)
            .clamp(0, double.infinity)
            .toInt(),
      );
    }
  }

  // Team Management
  static List<Team> getAllTeams() => List.unmodifiable(_teams);

  static Team? getTeamById(String id) {
    try {
      return _teams.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<String> createTeam({
    required String name,
    required String club,
    required List<String> members,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newTeam = Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      club: club,
      members: members,
      totalPoints: 0,
    );

    _teams.add(newTeam);
    _notifyListeners();
    return newTeam.id;
  }

  static Future<bool> updateTeam(Team team) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _teams.indexWhere((t) => t.id == team.id);
    if (index != -1) {
      _teams[index] = team;
      _notifyListeners();
      return true;
    }
    return false;
  }

  static Future<bool> deleteTeam(String teamId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final countRemoved = _teams.where((t) => t.id == teamId).length;
    _teams.removeWhere((t) => t.id == teamId);

    // Remove from tournaments
    for (int i = 0; i < _tournaments.length; i++) {
      final updatedTeams =
          _tournaments[i].teams.where((t) => t.id != teamId).toList();
      _tournaments[i] = _tournaments[i].copyWith(teams: updatedTeams);
    }

    // Remove fish catches
    _allCatches.removeWhere((fish) => fish.teamId == teamId);

    if (countRemoved > 0) {
      _notifyListeners();
      return true;
    }
    return false;
  }

  // Fish Management
  static List<Fish> getAllCatches() => List.unmodifiable(_allCatches);

  static List<Fish> getCatchesForTournament(String tournamentId) {
    return _allCatches
        .where((fish) => fish.tournamentId == tournamentId)
        .toList()
      ..sort((a, b) => b.caughtTime.compareTo(a.caughtTime));
  }

  static List<Fish> getCatchesForTeam(String teamId) {
    return _allCatches.where((fish) => fish.teamId == teamId).toList()
      ..sort((a, b) => b.caughtTime.compareTo(a.caughtTime));
  }

  static List<Fish> getRecentCatches({int limit = 10}) {
    final sorted = List<Fish>.from(_allCatches)
      ..sort((a, b) => b.caughtTime.compareTo(a.caughtTime));
    return sorted.take(limit).toList();
  }

  static void addFishCatch(Fish fish) {
    _allCatches.add(fish);

    // Update team/individual points if verified
    if (fish.verified) {
      _updatePoints(fish.teamId, fish.points);
    }

    _notifyListeners();
  }

  static void _updatePoints(String teamId, int pointsChange) {
    // Check if it's a team
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex != -1) {
      _teams[teamIndex].addPoints(pointsChange);
      return;
    }

    // Check if it's an individual registration
    final regIndex =
        _individualRegistrations.indexWhere((reg) => reg.id == teamId);
    if (regIndex != -1) {
      final registration = _individualRegistrations[regIndex];
      final catches = getCatchesForTeam(teamId);
      final newTotalPoints = catches
          .where((fish) => fish.verified)
          .fold(0, (sum, fish) => sum + fish.points);

      _individualRegistrations[regIndex] = registration.copyWith(
        totalPoints: newTotalPoints,
        catches: catches,
      );
    }
  }

  // Leaderboards
  static List<Team> getSeasonLeaderboard() {
    final teams = List<Team>.from(_teams);
    teams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return teams;
  }

  static List<IndividualRegistration> getIndividualLeaderboard(
      String tournamentId) {
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

  static List<IndividualRegistration> getKidsLeaderboard(String tournamentId) {
    return getIndividualLeaderboard(tournamentId)
        .where((reg) => reg.isChild)
        .toList();
  }

  // Statistics
  static int getTotalPointsAwarded() {
    return _allCatches
        .where((fish) => fish.verified)
        .fold(0, (sum, fish) => sum + fish.points);
  }

  static List<Team> getCompetingTeamsForTournament(
      String tournamentId, String judgeClub) {
    final tournament = getTournamentById(tournamentId);
    if (tournament == null) return [];

    // Return teams that are different from the judge's club to avoid conflicts
    return tournament.teams.where((team) => team.club != judgeClub).toList();
  }

  // Utility
  static Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    _notifyListeners();
  }

  // Statistics for individuals
  static Map<String, dynamic> getIndividualStats(String tournamentId) {
    final registrations = getIndividualRegistrations(tournamentId);
    final paidRegistrations = registrations.where((reg) => reg.isPaid).toList();
    final kidsRegistrations =
        registrations.where((reg) => reg.isChild).toList();

    final totalCatches =
        paidRegistrations.fold(0, (sum, reg) => sum + reg.catches.length);
    final totalPoints =
        paidRegistrations.fold(0, (sum, reg) => sum + reg.totalPoints);

    return {
      'totalRegistrations': registrations.length,
      'paidRegistrations': paidRegistrations.length,
      'pendingRegistrations': registrations.length - paidRegistrations.length,
      'kidsRegistrations': kidsRegistrations.length,
      'adultRegistrations': registrations.length - kidsRegistrations.length,
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

    return (tournamentCode.maxRegistrations -
            tournamentCode.currentRegistrations)
        .clamp(0, double.infinity)
        .toInt();
  }
}
