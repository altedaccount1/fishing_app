// widgets/team_card.dart
import 'package:flutter/material.dart';
import '../models/team.dart';
import '../utils/theme.dart';

class TeamCard extends StatelessWidget {
  final Team team;
  final int? rank;
  final VoidCallback? onTap;
  final bool showRank;
  final bool showClub;
  final bool showMembers;
  final bool isCompact;

  const TeamCard({
    super.key,
    required this.team,
    this.rank,
    this.onTap,
    this.showRank = true,
    this.showClub = true,
    this.showMembers = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank != null && rank! <= 3;

    return Card(
      color: isTopThree ? _getTopThreeColor(rank!) : null,
      elevation: isTopThree ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
          child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
        ),
      ),
    );
  }

  Widget _buildFullLayout() {
    return Row(
      children: [
        // Rank or Avatar
        if (showRank && rank != null)
          CircleAvatar(
            radius: 20,
            backgroundColor: rank!.rankColor,
            child: rank! <= 3
                ? Icon(_getMedalIcon(rank!), color: Colors.white, size: 20)
                : Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          )
        else
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            child: Text(
              team.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
                  fontWeight: rank != null && rank! <= 3
                      ? FontWeight.bold
                      : FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (showClub) ...[
                const SizedBox(height: 2),
                Text(
                  team.club,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (showMembers) ...[
                const SizedBox(height: 4),
                Text(
                  'Members: ${team.membersDisplay}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
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
                fontSize: rank != null && rank! <= 3 ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: rank?.rankColor ?? Colors.blue,
              ),
            ),
            Text(
              'points',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      children: [
        // Small rank indicator
        if (showRank && rank != null)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank!.rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          )
        else
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                team.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),

        const SizedBox(width: 12),

        // Team name and club
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (showClub)
                Text(
                  team.club,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),

        // Points
        Text(
          '${team.totalPoints} pts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: rank?.rankColor ?? Colors.blue,
          ),
        ),
      ],
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
}

// Simple team list tile for minimal displays
class TeamListTile extends StatelessWidget {
  final Team team;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TeamListTile({
    super.key,
    required this.team,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          team.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        team.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(team.club),
          Text(
            '${team.totalPoints} points',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}
