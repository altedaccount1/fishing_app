// screens/leaderboard/tournament_leaderboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/team.dart';
import '../../widgets/status_badge.dart';
import '../../utils/theme.dart';

class TournamentLeaderboardScreen extends StatelessWidget {
  final Tournament tournament;

  const TournamentLeaderboardScreen({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final teams = List<Team>.from(tournament.teams);
    teams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return Scaffold(
      appBar: AppBar(
        title: Text('${tournament.name} - Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareLeaderboard(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tournament Info Header
          _buildTournamentHeader(),

          // Leaderboard
          Expanded(
            child: teams.isEmpty
                ? _buildEmptyLeaderboard()
                : _buildLeaderboardList(teams),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentHeader() {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.location,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Host: ${tournament.hostClub}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: tournament.status,
                isLive: tournament.status == 'live',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.group, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${tournament.teams.length} teams competing',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<Team> teams) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        final rank = index + 1;
        final isTopThree = rank <= 3;

        return Card(
          color: isTopThree ? _getTopThreeColor(rank) : null,
          elevation: isTopThree ? 4 : 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: rank.rankColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isTopThree
                        ? Icon(
                            _getMedalIcon(rank),
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '#$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Team Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: TextStyle(
                          fontWeight: isTopThree
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: isTopThree ? 16 : 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        team.club,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Members: ${team.membersDisplay}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${team.totalPoints}',
                      style: TextStyle(
                        fontSize: isTopThree ? 24 : 20,
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
              ],
            ),
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
          Icon(Icons.emoji_events, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Teams Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Teams will appear here once they join the tournament',
            style: TextStyle(color: Colors.grey.shade600),
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

  IconData _getMedalIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
      case 3:
        return Icons.workspace_premium; // Medal
      default:
        return Icons.emoji_events;
    }
  }

  void _shareLeaderboard(BuildContext context) {
    // Placeholder for sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing feature coming soon!')),
    );
  }
}
