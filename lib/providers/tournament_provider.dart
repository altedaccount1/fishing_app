// providers/tournament_provider.dart
import 'package:flutter/foundation.dart';
import '../models/tournament.dart';
import '../models/team.dart';
import '../models/fish.dart';
import '../services/data_service.dart';

class TournamentProvider extends ChangeNotifier {
  List<Tournament> _tournaments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Tournament> get tournaments => List.unmodifiable(_tournaments);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Tournament> get liveTournaments =>
      _tournaments.where((t) => t.status == 'live').toList();

  List<Tournament> get upcomingTournaments =>
      _tournaments.where((t) => t.status == 'upcoming').toList();

  List<Tournament> get completedTournaments =>
      _tournaments.where((t) => t.status == 'completed').toList();

  // Initialize provider
  TournamentProvider() {
    loadTournaments();
  }

  // Load tournaments from data service
  Future<void> loadTournaments() async {
    _setLoading(true);
    _clearError();

    try {
      _tournaments = DataService.getAllTournaments();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tournaments: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get tournament by ID
  Tournament? getTournamentById(String id) {
    try {
      return _tournaments.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get tournaments by status
  List<Tournament> getTournamentsByStatus(String status) {
    return _tournaments.where((t) => t.status == status).toList();
  }

  // Get tournaments by host club
  List<Tournament> getTournamentsByHostClub(String hostClub) {
    return _tournaments.where((t) => t.hostClub == hostClub).toList();
  }

  // Create new tournament
  Future<bool> createTournament({
    required String name,
    required DateTime date,
    required String location,
    required String hostClub,
    String status = 'upcoming',
  }) async {
    _setLoading(true);
    _clearError();

    try {
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

      // TODO: Implement in DataService
      // For now, add to local list
      _tournaments.add(newTournament);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create tournament: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update tournament
  Future<bool> updateTournament(Tournament tournament) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _tournaments.indexWhere((t) => t.id == tournament.id);
      if (index != -1) {
        _tournaments[index] = tournament;
        notifyListeners();
        return true;
      }
      throw Exception('Tournament not found');
    } catch (e) {
      _setError('Failed to update tournament: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update tournament status
  Future<bool> updateTournamentStatus(
      String tournamentId, String newStatus) async {
    _setLoading(true);
    _clearError();

    try {
      DataService.updateTournamentStatus(tournamentId, newStatus);
      await loadTournaments(); // Reload to get updated data
      return true;
    } catch (e) {
      _setError('Failed to update tournament status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete tournament
  Future<bool> deleteTournament(String tournamentId) async {
    _setLoading(true);
    _clearError();

    try {
      _tournaments.removeWhere((t) => t.id == tournamentId);
      // TODO: Implement actual deletion in DataService
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete tournament: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register team for tournament
  Future<bool> registerTeamForTournament(String tournamentId, Team team) async {
    _setLoading(true);
    _clearError();

    try {
      final tournamentIndex =
          _tournaments.indexWhere((t) => t.id == tournamentId);
      if (tournamentIndex != -1) {
        final tournament = _tournaments[tournamentIndex];
        final updatedTeams = List<Team>.from(tournament.teams)..add(team);
        _tournaments[tournamentIndex] =
            tournament.copyWith(teams: updatedTeams);
        notifyListeners();
        return true;
      }
      throw Exception('Tournament not found');
    } catch (e) {
      _setError('Failed to register team: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Unregister team from tournament
  Future<bool> unregisterTeamFromTournament(
      String tournamentId, String teamId) async {
    _setLoading(true);
    _clearError();

    try {
      final tournamentIndex =
          _tournaments.indexWhere((t) => t.id == tournamentId);
      if (tournamentIndex != -1) {
        final tournament = _tournaments[tournamentIndex];
        final updatedTeams =
            tournament.teams.where((t) => t.id != teamId).toList();
        _tournaments[tournamentIndex] =
            tournament.copyWith(teams: updatedTeams);
        notifyListeners();
        return true;
      }
      throw Exception('Tournament not found');
    } catch (e) {
      _setError('Failed to unregister team: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add fish catch to tournament
  Future<bool> addFishCatch(String tournamentId, Fish fish) async {
    _setLoading(true);
    _clearError();

    try {
      DataService.addFishCatch(fish);
      await loadTournaments(); // Reload to get updated data
      return true;
    } catch (e) {
      _setError('Failed to add fish catch: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get tournament leaderboard
  List<Team> getTournamentLeaderboard(String tournamentId) {
    final tournament = getTournamentById(tournamentId);
    if (tournament == null) return [];

    final teams = List<Team>.from(tournament.teams);
    teams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return teams;
  }

  // Get tournament catches
  List<Fish> getTournamentCatches(String tournamentId) {
    return DataService.getCatchesForTournament(tournamentId);
  }

  // Search tournaments
  List<Tournament> searchTournaments(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _tournaments.where((tournament) {
      return tournament.name.toLowerCase().contains(lowercaseQuery) ||
          tournament.location.toLowerCase().contains(lowercaseQuery) ||
          tournament.hostClub.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter tournaments by date range
  List<Tournament> filterTournamentsByDateRange(DateTime start, DateTime end) {
    return _tournaments.where((tournament) {
      return tournament.date.isAfter(start.subtract(const Duration(days: 1))) &&
          tournament.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadTournaments();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Tournament statistics
  Map<String, dynamic> getTournamentStats() {
    final total = _tournaments.length;
    final live = liveTournaments.length;
    final upcoming = upcomingTournaments.length;
    final completed = completedTournaments.length;

    final totalTeams = _tournaments.fold<int>(
        0, (sum, tournament) => sum + tournament.teams.length);

    final totalCatches = _tournaments.fold<int>(
        0, (sum, tournament) => sum + tournament.catches.length);

    return {
      'totalTournaments': total,
      'liveTournaments': live,
      'upcomingTournaments': upcoming,
      'completedTournaments': completed,
      'totalTeams': totalTeams,
      'totalCatches': totalCatches,
    };
  }

  // Get tournaments by club
  List<Tournament> getTournamentsHostedByClub(String club) {
    return _tournaments.where((t) => t.hostClub == club).toList();
  }

  // Check if tournament can be edited
  bool canEditTournament(Tournament tournament) {
    return tournament.status == 'upcoming' || tournament.status == 'live';
  }

  // Check if tournament can be deleted
  bool canDeleteTournament(Tournament tournament) {
    return tournament.teams.isEmpty && tournament.catches.isEmpty;
  }

  // Get next tournament
  Tournament? getNextTournament() {
    final upcoming = upcomingTournaments;
    if (upcoming.isEmpty) return null;

    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming.first;
  }

  // Get current live tournament
  Tournament? getCurrentLiveTournament() {
    final live = liveTournaments;
    return live.isNotEmpty ? live.first : null;
  }
}
