// services/data_service.dart
import 'dart:convert';
import 'dart:math';
import '../models/tournament.dart';
import '../models/team.dart';
import '../models/fish.dart';

class DataService {
  // In-memory data storage (replace with API calls in production)
  static List<Tournament> _tournaments = [];
  static List<Fish> _allCatches = [];
  static List<Team> _allTeams = [];

  // Data change listeners
  static final List<Function()> _listeners = [];

  // Initialize with sample data
  static void initialize() {
    _loadSampleData();
  }

  static void _loadSampleData() {
    // Create sample teams first
    _allTeams = [
      Team(
        id: '1',
        name: 'Ocean City Anglers',
        club: 'Ocean City Fishing Club',
        members: ['Drew Furst', 'John Smith'],
        totalPoints: 245,
      ),
      Team(
        id: '2',
        name: 'Cape May Crushers',
        club: 'Delaware Valley Surf Anglers',
        members: ['Mike Johnson', 'Sarah Wilson'],
        totalPoints: 198,
      ),
      Team(
        id: '3',
        name: 'Atlantic Aces',
        club: 'Atlantic City Salt Water Anglers',
        members: ['Tom Brown', 'Lisa Davis'],
        totalPoints: 156,
      ),
      Team(
        id: '4',
        name: 'Wildwood Warriors',
        club: 'Anglesea Surf Anglers',
        members: ['Bob Miller', 'Kate Jones'],
        totalPoints: 89,
      ),
      Team(
        id: '5',
        name: 'Seaside Slayers',
        club: 'Seaside Heights Fishing Club',
        members: ['Dave Wilson', 'Amy Clark'],
        totalPoints: 134,
      ),
      Team(
        id: '6',
        name: 'LBI Legends',
        club: 'Long Beach Island Fishing Club',
        members: ['Chris Taylor', 'Emma White'],
        totalPoints: 167,
      ),
    ];

    // Create sample tournaments with the teams
    _tournaments = [
      Tournament(
        id: '1',
        name: 'Spring Kickoff Classic',
        date: DateTime(2024, 4, 14),
        location: 'Cape Henlopen State Park',
        status: 'completed',
        hostClub: 'Delaware Valley Surf Anglers',
        teams: [_allTeams[0], _allTeams[1], _allTeams[2]],
        catches: [], // Initialize with empty catches
      ),
      Tournament(
        id: '2',
        name: 'Summer Slam Tournament',
        date: DateTime(2024, 6, 10),
        location: 'Island Beach State Park',
        status: 'live',
        hostClub: 'Ocean City Fishing Club',
        teams: [_allTeams[1], _allTeams[3], _allTeams[4]],
        catches: [], // Initialize with empty catches
      ),
      Tournament(
        id: '3',
        name: 'Fall Championship',
        date: DateTime(2024, 10, 1),
        location: 'Assateague Island',
        status: 'upcoming',
        hostClub: 'Atlantic City Salt Water Anglers',
        teams: [_allTeams[0], _allTeams[2], _allTeams[5]],
        catches: [], // Initialize with empty catches
      ),
    ];

    // Create sample fish catches
    _allCatches = [
      Fish(
        id: '1',
        teamId: '1',
        tournamentId: '2',
        species: 'Striped Bass',
        length: 28.5,
        weight: 8.2,
        caughtTime: DateTime.now().subtract(const Duration(hours: 2)),
        points: 51, // (28.5 * 1.5 + 8.2 * 3.0) * 1.2
        judgeId: 'judge_ocean_city',
        verified: true,
      ),
      Fish(
        id: '2',
        teamId: '3',
        tournamentId: '2',
        species: 'Red Drum',
        length: 24.0,
        weight: 6.1,
        caughtTime: DateTime.now().subtract(const Duration(hours: 1)),
        points: 46, // (24.0 * 1.5 + 6.1 * 3.0) * 1.1
        judgeId: 'judge_ocean_city',
        verified: true,
      ),
      Fish(
        id: '3',
        teamId: '4',
        tournamentId: '2',
        species: 'Bluefish',
        length: 22.0,
        weight: 4.5,
        caughtTime: DateTime.now().subtract(const Duration(minutes: 30)),
        points: 47, // 22.0 * 1.5 + 4.5 * 3.0
        judgeId: 'judge_ocean_city',
        verified: false,
      ),
    ];

    _notifyListeners();
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

  // Tournament CRUD operations
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
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    final tournament = Tournament(
      id: _generateId(),
      name: name,
      date: date,
      location: location,
      status: status,
      hostClub: hostClub,
      teams: [],
      catches: [],
    );

    _tournaments.add(tournament);
    _notifyListeners();
    return tournament.id;
  }

  static Future<bool> updateTournament(Tournament tournament) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _tournaments.indexWhere((t) => t.id == tournament.id);
    if (index != -1) {
      _tournaments[index] = tournament;
      _notifyListeners();
      return true;
    }
    return false;
  }

  static Future<bool> deleteTournament(String tournamentId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if tournament has teams or catches
    final tournament = getTournamentById(tournamentId);
    if (tournament != null &&
        (tournament.teams.isNotEmpty || tournament.catches.isNotEmpty)) {
      throw Exception(
          'Cannot delete tournament with registered teams or catches');
    }

    final removed = _tournaments.removeWhere((t) => t.id == tournamentId);
    if (removed > 0) {
      _notifyListeners();
    }
    return removed > 0;
  }

  static void updateTournamentStatus(String tournamentId, String newStatus) {
    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index != -1) {
      _tournaments[index] = _tournaments[index].copyWith(status: newStatus);
      _notifyListeners();
    }
  }

  // Team CRUD operations
  static List<Team> getAllTeams() => List.unmodifiable(_allTeams);

  static Team? getTeamById(String teamId) {
    try {
      return _allTeams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  static Future<String> createTeam({
    required String name,
    required String club,
    required List<String> members,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Validate team name is unique
    if (_allTeams
        .any((team) => team.name.toLowerCase() == name.toLowerCase())) {
      throw Exception('Team name already exists');
    }

    final team = Team(
      id: _generateId(),
      name: name,
      club: club,
      members: members,
      totalPoints: 0,
    );

    _allTeams.add(team);
    _notifyListeners();
    return team.id;
  }

  static Future<bool> updateTeam(Team team) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate team name is unique (excluding current team)
    if (_allTeams.any((t) =>
        t.id != team.id && t.name.toLowerCase() == team.name.toLowerCase())) {
      throw Exception('Team name already exists');
    }

    final index = _allTeams.indexWhere((t) => t.id == team.id);
    if (index != -1) {
      _allTeams[index] = team;

      // Update team in tournaments
      for (int i = 0; i < _tournaments.length; i++) {
        final tournament = _tournaments[i];
        final teamIndex = tournament.teams.indexWhere((t) => t.id == team.id);
        if (teamIndex != -1) {
          final updatedTeams = List<Team>.from(tournament.teams);
          updatedTeams[teamIndex] = team;
          _tournaments[i] = tournament.copyWith(teams: updatedTeams);
        }
      }

      _notifyListeners();
      return true;
    }
    return false;
  }

  static Future<bool> deleteTeam(String teamId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if team has fish catches
    final teamCatches = getCatchesForTeam(teamId);
    if (teamCatches.isNotEmpty) {
      throw Exception('Cannot delete team with existing fish catches');
    }

    // Remove team from tournaments
    for (int i = 0; i < _tournaments.length; i++) {
      final tournament = _tournaments[i];
      final updatedTeams =
          tournament.teams.where((t) => t.id != teamId).toList();
      if (updatedTeams.length != tournament.teams.length) {
        _tournaments[i] = tournament.copyWith(teams: updatedTeams);
      }
    }

    final removed = _allTeams.removeWhere((t) => t.id == teamId);
    if (removed > 0) {
      _notifyListeners();
    }
    return removed;
  }

  // Tournament team registration
  static Future<bool> registerTeamForTournament(
      String tournamentId, String teamId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final tournament = getTournamentById(tournamentId);
    final team = getTeamById(teamId);

    if (tournament == null || team == null) {
      throw Exception('Tournament or team not found');
    }

    if (tournament.status == 'completed') {
      throw Exception('Cannot register for completed tournament');
    }

    // Check if team is already registered
    if (tournament.teams.any((t) => t.id == teamId)) {
      throw Exception('Team is already registered for this tournament');
    }

    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index != -1) {
      final updatedTeams = List<Team>.from(tournament.teams)..add(team);
      _tournaments[index] = tournament.copyWith(teams: updatedTeams);
      _notifyListeners();
      return true;
    }
    return false;
  }

  static Future<bool> unregisterTeamFromTournament(
      String tournamentId, String teamId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final tournament = getTournamentById(tournamentId);
    if (tournament == null) {
      throw Exception('Tournament not found');
    }

    if (tournament.status == 'live' || tournament.status == 'completed') {
      throw Exception('Cannot unregister from active or completed tournament');
    }

    // Check if team has catches in this tournament
    final teamCatches = getCatchesForTeam(teamId)
        .where((fish) => fish.tournamentId == tournamentId)
        .toList();
    if (teamCatches.isNotEmpty) {
      throw Exception('Cannot unregister team with existing catches');
    }

    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index != -1) {
      final updatedTeams =
          tournament.teams.where((t) => t.id != teamId).toList();
      _tournaments[index] = tournament.copyWith(teams: updatedTeams);
      _notifyListeners();
      return true;
    }
    return false;
  }

  static List<Team> getTeamsForTournament(String tournamentId) {
    final tournament = getTournamentById(tournamentId);
    return tournament?.teams ?? [];
  }

  static List<Team> getCompetingTeamsForTournament(
    String tournamentId,
    String excludeClub,
  ) {
    final tournament = getTournamentById(tournamentId);
    if (tournament == null) return [];
    return tournament.teams.where((team) => team.club != excludeClub).toList();
  }

  // Fish/Catch CRUD operations
  static List<Fish> getAllCatches() => List.unmodifiable(_allCatches);

  static List<Fish> getCatchesForTournament(String tournamentId) {
    return _allCatches
        .where((fish) => fish.tournamentId == tournamentId)
        .toList();
  }

  static List<Fish> getCatchesForTeam(String teamId) {
    return _allCatches.where((fish) => fish.teamId == teamId).toList();
  }

  static List<Fish> getRecentCatches({int limit = 10}) {
    var catches = List<Fish>.from(_allCatches);
    catches.sort((a, b) => b.caughtTime.compareTo(a.caughtTime));
    return catches.take(limit).toList();
  }

  static Future<String> addFishCatch(Fish fish) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Validate tournament exists and is active
    final tournament = getTournamentById(fish.tournamentId);
    if (tournament == null) {
      throw Exception('Tournament not found');
    }

    if (tournament.status != 'live') {
      throw Exception('Can only add catches to live tournaments');
    }

    // Validate team is registered for tournament
    if (!tournament.teams.any((team) => team.id == fish.teamId)) {
      throw Exception('Team is not registered for this tournament');
    }

    _allCatches.add(fish);

    // Update team points if fish is verified
    if (fish.verified) {
      _updateTeamPoints(fish.teamId, fish.points);
    }

    _notifyListeners();
    return fish.id;
  }

  static Future<bool> updateFishCatch(Fish fish) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _allCatches.indexWhere((f) => f.id == fish.id);
    if (index != -1) {
      final oldFish = _allCatches[index];
      _allCatches[index] = fish;

      // Update team points if verification status changed
      if (oldFish.verified != fish.verified) {
        if (fish.verified) {
          _updateTeamPoints(fish.teamId, fish.points);
        } else {
          _updateTeamPoints(fish.teamId, -fish.points);
        }
      } else if (fish.verified && oldFish.points != fish.points) {
        // Points changed for verified fish
        _updateTeamPoints(fish.teamId, fish.points - oldFish.points);
      }

      _notifyListeners();
      return true;
    }
    return false;
  }

  static Future<bool> deleteFishCatch(String fishId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final fishIndex = _allCatches.indexWhere((f) => f.id == fishId);
    if (fishIndex != -1) {
      final fish = _allCatches[fishIndex];

      // Remove points from team if fish was verified
      if (fish.verified) {
        _updateTeamPoints(fish.teamId, -fish.points);
      }

      _allCatches.removeAt(fishIndex);
      _notifyListeners();
      return true;
    }
    return false;
  }

  static void verifyFishCatch(String fishId) {
    final fishIndex = _allCatches.indexWhere((f) => f.id == fishId);
    if (fishIndex != -1) {
      final fish = _allCatches[fishIndex];
      if (!fish.verified) {
        _allCatches[fishIndex] = fish.copyWith(verified: true);
        _updateTeamPoints(fish.teamId, fish.points);
        _notifyListeners();
      }
    }
  }

  static void _updateTeamPoints(String teamId, int pointsChange) {
    // Update in main teams list
    final teamIndex = _allTeams.indexWhere((team) => team.id == teamId);
    if (teamIndex != -1) {
      final team = _allTeams[teamIndex];
      _allTeams[teamIndex] = team.copyWith(
          totalPoints: (team.totalPoints + pointsChange)
              .clamp(0, double.infinity)
              .toInt());
    }

    // Update in tournament teams
    for (int i = 0; i < _tournaments.length; i++) {
      final tournament = _tournaments[i];
      final tournamentTeamIndex =
          tournament.teams.indexWhere((t) => t.id == teamId);
      if (tournamentTeamIndex != -1) {
        final updatedTeams = List<Team>.from(tournament.teams);
        final team = updatedTeams[tournamentTeamIndex];
        updatedTeams[tournamentTeamIndex] = team.copyWith(
            totalPoints: (team.totalPoints + pointsChange)
                .clamp(0, double.infinity)
                .toInt());
        _tournaments[i] = tournament.copyWith(teams: updatedTeams);
      }
    }
  }

  // Season leaderboard
  static List<Team> getSeasonLeaderboard() {
    final teams = List<Team>.from(_allTeams);
    teams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return teams;
  }

  // Statistics
  static int getTotalPointsAwarded() {
    return _allCatches
        .where((fish) => fish.verified)
        .fold(0, (sum, fish) => sum + fish.points);
  }

  static int getTotalVerifiedCatches() {
    return _allCatches.where((fish) => fish.verified).length;
  }

  static Map<String, int> getSpeciesCount() {
    Map<String, int> speciesCount = {};
    for (var fish in _allCatches) {
      speciesCount[fish.species] = (speciesCount[fish.species] ?? 0) + 1;
    }
    return speciesCount;
  }

  // Search and filter methods
  static List<Tournament> searchTournaments(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _tournaments.where((tournament) {
      return tournament.name.toLowerCase().contains(lowercaseQuery) ||
          tournament.location.toLowerCase().contains(lowercaseQuery) ||
          tournament.hostClub.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static List<Team> searchTeams(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _allTeams.where((team) {
      return team.name.toLowerCase().contains(lowercaseQuery) ||
          team.club.toLowerCase().contains(lowercaseQuery) ||
          team.members
              .any((member) => member.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Data management
  static void clearAllData() {
    _tournaments.clear();
    _allCatches.clear();
    _allTeams.clear();
    _notifyListeners();
  }

  static Future<void> refreshData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would reload from API
    _notifyListeners();
  }

  // Export data for backup/sharing
  static Map<String, dynamic> exportData() {
    return {
      'tournaments': _tournaments.map((t) => t.toJson()).toList(),
      'teams': _allTeams.map((t) => t.toJson()).toList(),
      'catches': _allCatches.map((f) => f.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // Import data from backup
  static Future<bool> importData(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      final tournaments = (data['tournaments'] as List?)
              ?.map((json) => Tournament.fromJson(json))
              .toList() ??
          [];

      final teams = (data['teams'] as List?)
              ?.map((json) => Team.fromJson(json))
              .toList() ??
          [];

      final catches = (data['catches'] as List?)
              ?.map((json) => Fish.fromJson(json))
              .toList() ??
          [];

      _tournaments = tournaments;
      _allTeams = teams;
      _allCatches = catches;

      _notifyListeners();
      return true;
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // Helper methods
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return '${timestamp}_$random';
  }

  // Advanced analytics
  static Map<String, dynamic> getAdvancedStats() {
    final totalTournaments = _tournaments.length;
    final liveTournaments = getTournamentsByStatus('live').length;
    final upcomingTournaments = getTournamentsByStatus('upcoming').length;
    final completedTournaments = getTournamentsByStatus('completed').length;

    final totalTeams = _allTeams.length;
    final activeTeams = _allTeams.where((t) => t.totalPoints > 0).length;

    final totalCatches = _allCatches.length;
    final verifiedCatches = getTotalVerifiedCatches();
    final pendingCatches = totalCatches - verifiedCatches;

    final avgPointsPerTeam =
        totalTeams > 0 ? getTotalPointsAwarded() / totalTeams : 0.0;

    return {
      'tournaments': {
        'total': totalTournaments,
        'live': liveTournaments,
        'upcoming': upcomingTournaments,
        'completed': completedTournaments,
      },
      'teams': {
        'total': totalTeams,
        'active': activeTeams,
        'inactive': totalTeams - activeTeams,
        'avgPoints': avgPointsPerTeam.round(),
      },
      'catches': {
        'total': totalCatches,
        'verified': verifiedCatches,
        'pending': pendingCatches,
        'totalPoints': getTotalPointsAwarded(),
      },
      'species': getSpeciesCount(),
    };
  }

  // Performance metrics
  static Map<String, dynamic> getPerformanceMetrics() {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));

    final recentCatches =
        _allCatches.where((fish) => fish.caughtTime.isAfter(last30Days)).length;

    final recentTournaments =
        _tournaments.where((t) => t.date.isAfter(last30Days)).length;

    return {
      'catchesLast30Days': recentCatches,
      'tournamentsLast30Days': recentTournaments,
      'avgCatchesPerTournament': _tournaments.isNotEmpty
          ? _allCatches.length / _tournaments.length
          : 0.0,
      'verificationRate': _allCatches.isNotEmpty
          ? (getTotalVerifiedCatches() / _allCatches.length) * 100
          : 0.0,
    };
  }
}
