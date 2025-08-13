// screens/leaderboard/enhanced_leaderboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/team.dart';
import '../../models/individual_registration.dart';
import '../../services/data_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/theme.dart';
import '../../widgets/status_badge.dart';
import 'tournament_leaderboard_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool showSeasonLeaderboard = true;
  String selectedCategory = 'teams'; // 'teams', 'individuals', 'kids'

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle between Season and Tournament view
        Container(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                  value: true,
                  label: Text('Season'),
                  icon: Icon(Icons.emoji_events)),
              ButtonSegment(
                  value: false,
                  label: Text('Tournaments'),
                  icon: Icon(Icons.event)),
            ],
            selected: {showSeasonLeaderboard},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() => showSeasonLeaderboard = newSelection.first);
            },
          ),
        ),

        if (showSeasonLeaderboard) ...[
          // Category selection for season view
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Category: '),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['teams', 'individuals', 'kids']
                          .map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label:
                                      Text(_getCategoryDisplayName(category)),
                                  selected: selectedCategory == category,
                                  onSelected: (selected) {
                                    if (selected)
                                      setState(
                                          () => selectedCategory = category);
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildSeasonLeaderboard()),
        ] else ...[
          Expanded(child: _buildTournamentSelector()),
        ],
      ],
    );
  }

  Widget _buildSeasonLeaderboard() {
    switch (selectedCategory) {
      case 'teams':
        return _buildTeamLeaderboard();
      case 'individuals':
        return _buildIndividualLeaderboard();
      case 'kids':
        return _buildKidsLeaderboard();
      default:
        return _buildTeamLeaderboard();
    }
  }

  Widget _buildTeamLeaderboard() {
    final teams = DataService.getSeasonLeaderboard();
    if (teams.isEmpty) return _buildEmptyState('No teams yet');

    return RefreshIndicator(
      onRefresh: () => DataService.refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          final rank = index + 1;
          return _buildTeamLeaderboardCard(team, rank);
        },
      ),
    );
  }

  Widget _buildIndividualLeaderboard() {
    // Combine all individual registrations across tournaments
    final allTournaments = DataService.getAllTournaments();
    final allIndividuals = <IndividualRegistration>[];

    for (final tournament in allTournaments) {
      final individuals = DataService.getIndividualLeaderboard(tournament.id);
      allIndividuals.addAll(individuals);
    }

    // Sort by total points
    allIndividuals.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    if (allIndividuals.isEmpty)
      return _buildEmptyState('No individual participants yet');

    return RefreshIndicator(
      onRefresh: () => DataService.refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allIndividuals.length,
        itemBuilder: (context, index) {
          final individual = allIndividuals[index];
          final rank = index + 1;
          return _buildIndividualLeaderboardCard(individual, rank);
        },
      ),
    );
  }

  Widget _buildKidsLeaderboard() {
    // Similar to individual but filter for kids only
    final allTournaments = DataService.getAllTournaments();
    final allKids = <IndividualRegistration>[];

    for (final tournament in allTournaments) {
      final kids = DataService.getKidsLeaderboard(tournament.id);
      allKids.addAll(kids);
    }

    allKids.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    if (allKids.isEmpty) return _buildEmptyState('No kids participants yet');

    return RefreshIndicator(
      onRefresh: () => DataService.refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allKids.length,
        itemBuilder: (context, index) {
          final kid = allKids[index];
          final rank = index + 1;
          return _buildKidLeaderboardCard(kid, rank);
        },
      ),
    );
  }

  Widget _buildTournamentSelector() {
    final tournaments = DataService.getAllTournaments();

    if (tournaments.isEmpty) {
      return _buildEmptyState('No tournaments available');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: tournament.status.statusColor,
              child: Icon(
                tournament.status.statusIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              tournament.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormatter.formatShortDate(tournament.date)} • ${tournament.location}',
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${tournament.teams.length} teams',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      status: tournament.status,
                      showIcon: false,
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _navigateToTournamentLeaderboard(tournament),
          ),
        );
      },
    );
  }

  Widget _buildTeamLeaderboardCard(Team team, int rank) {
    final isTopThree = rank <= 3;

    return Card(
      color: isTopThree ? _getTopThreeColor(rank) : null,
      elevation: isTopThree ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: RankBadge(rank: rank),
        title: Text(
          team.name,
          style: TextStyle(
            fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
            fontSize: isTopThree ? 16 : 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.club,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Members: ${team.membersDisplay}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${team.totalPoints}',
              style: TextStyle(
                fontSize: isTopThree ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: rank.rankColor,
              ),
            ),
            Text(
              'points',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualLeaderboardCard(
      IndividualRegistration individual, int rank) {
    final isTopThree = rank <= 3;

    return Card(
      color: isTopThree ? _getTopThreeColor(rank) : null,
      elevation: isTopThree ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: RankBadge(rank: rank),
        title: Text(
          individual.displayName,
          style: TextStyle(
            fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
            fontSize: isTopThree ? 16 : 14,
          ),
        ),
        subtitle: Text(
          '${individual.catches.length} fish caught',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${individual.totalPoints}',
              style: TextStyle(
                fontSize: isTopThree ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: rank.rankColor,
              ),
            ),
            Text(
              'points',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKidLeaderboardCard(IndividualRegistration kid, int rank) {
    final isTopThree = rank <= 3;

    return Card(
      color: isTopThree ? _getTopThreeColor(rank) : null,
      elevation: isTopThree ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: RankBadge(rank: rank),
        title: Row(
          children: [
            Expanded(
              child: Text(
                kid.displayName,
                style: TextStyle(
                  fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
                  fontSize: isTopThree ? 16 : 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Age ${kid.age}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parent: ${kid.parentName}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${kid.catches.length} fish caught',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${kid.totalPoints}',
              style: TextStyle(
                fontSize: isTopThree ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: rank.rankColor,
              ),
            ),
            Text(
              'points',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Participate in tournaments to see rankings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color? _getTopThreeColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade50;
      case 2:
        return Colors.grey.shade50;
      case 3:
        return Colors.brown.shade50;
      default:
        return null;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'teams':
        return 'Teams';
      case 'individuals':
        return 'Adults';
      case 'kids':
        return 'Kids';
      default:
        return category;
    }
  }

  void _navigateToTournamentLeaderboard(Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TournamentLeaderboardScreen(tournament: tournament),
      ),
    );
  }
}
