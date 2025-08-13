// screens/leaderboard/leaderboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';
import '../../widgets/status_badge.dart';
import '../../utils/date_formatter.dart';
import '../../utils/theme.dart';
import 'tournament_leaderboard_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool showSeasonLeaderboard = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle Buttons
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('Season Rankings'),
                icon: Icon(Icons.emoji_events),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('Tournaments'),
                icon: Icon(Icons.event),
              ),
            ],
            selected: {showSeasonLeaderboard},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                showSeasonLeaderboard = newSelection.first;
              });
            },
          ),
        ),

        // Content
        Expanded(
          child: showSeasonLeaderboard
              ? _buildSeasonLeaderboard()
              : _buildTournamentSelector(),
        ),
      ],
    );
  }

  Widget _buildSeasonLeaderboard() {
    final teams = DataService.getSeasonLeaderboard();

    if (teams.isEmpty) {
      return _buildEmptyLeaderboard();
    }

    return RefreshIndicator(
      onRefresh: () => DataService.refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          final rank = index + 1;
          final isTopThree = rank <= 3;

          return Card(
            color: isTopThree ? Colors.amber.shade50 : null,
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
        },
      ),
    );
  }

  Widget _buildTournamentSelector() {
    final tournaments = DataService.getAllTournaments();

    if (tournaments.isEmpty) {
      return _buildEmptyTournaments();
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

  Widget _buildEmptyLeaderboard() {
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
            'No Rankings Yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete tournaments to see season rankings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTournaments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Tournaments',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tournaments will appear here once created',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
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
