// widgets/fish_submission_card.dart
import 'package:flutter/material.dart';
import '../models/fish.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../services/data_service.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';

class FishSubmissionCard extends StatelessWidget {
  final Fish fish;
  final VoidCallback? onTap;
  final bool showTournament;
  final bool showTeam;
  final bool isCompact;

  const FishSubmissionCard({
    super.key,
    required this.fish,
    this.onTap,
    this.showTournament = true,
    this.showTeam = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final team = DataService.getTeamById(fish.teamId);
    final tournament = DataService.getTournamentById(fish.tournamentId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
          child: isCompact
              ? _buildCompactLayout(team, tournament)
              : _buildFullLayout(team, tournament),
        ),
      ),
    );
  }

  Widget _buildFullLayout(Team? team, Tournament? tournament) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          children: [
            // Species Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.set_meal, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),

            // Fish Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fish.species,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    fish.measurementDisplay,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // Points and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fish.pointsDisplay,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                VerificationBadge(
                  verified: fish.verified,
                  pending: !fish.verified,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Team and Tournament Info
        Row(
          children: [
            if (showTeam && team != null) ...[
              Icon(Icons.group, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                team.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              if (showTournament) ...[
                const SizedBox(width: 12),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 12),
              ],
            ],
            if (showTournament && tournament != null) ...[
              Icon(Icons.event, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  tournament.name,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // Time and Judge Info
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              DateFormatter.getRelativeTime(fish.caughtTime),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const Spacer(),
            Text(
              'Judge: ${_getJudgeName(fish.judgeId)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),

        // Notes if available
        if (fish.notes != null && fish.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fish.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLayout(Team? team, Tournament? tournament) {
    return Row(
      children: [
        // Status Indicator
        CircleAvatar(
          radius: 12,
          backgroundColor: fish.verified ? Colors.green : Colors.orange,
          child: Icon(
            fish.verified ? Icons.check : Icons.pending,
            color: Colors.white,
            size: 14,
          ),
        ),

        const SizedBox(width: 12),

        // Fish Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fish.species,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    fish.pointsDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    fish.measurementDisplay,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (showTeam && team != null) ...[
                    const Text(
                      ' • ',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Expanded(
                      child: Text(
                        team.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                DateFormatter.getRelativeTime(fish.caughtTime),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getJudgeName(String judgeId) {
    // Extract judge name from ID (simplified)
    if (judgeId.contains('cape_may')) {
      return 'Cape May FC';
    } else if (judgeId.contains('wildwood')) {
      return 'Wildwood AC';
    } else {
      return judgeId.replaceAll('judge_', '').replaceAll('_', ' ');
    }
  }
}

// Specialized card for live feed
class LiveFeedFishCard extends StatelessWidget {
  final Fish fish;
  final String teamName;
  final VoidCallback? onTap;

  const LiveFeedFishCard({
    super.key,
    required this.fish,
    required this.teamName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Live indicator or verification status
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: fish.verified
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  fish.verified ? Icons.verified : Icons.pending,
                  color: fish.verified ? Colors.green : Colors.orange,
                  size: 16,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: teamName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ' caught '),
                          TextSpan(
                            text: fish.species,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${fish.measurementDisplay} • ${fish.pointsDisplay}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      DateFormatter.getRelativeTime(fish.caughtTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              if (!fish.verified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
