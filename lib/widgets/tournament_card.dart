// widgets/tournament_card.dart
import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../utils/date_formatter.dart';
import '../utils/theme.dart';
import 'status_badge.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;
  final bool showHostClub;
  final bool isLiveHighlighted;

  const TournamentCard({
    super.key,
    required this.tournament,
    this.onTap,
    this.showHostClub = true,
    this.isLiveHighlighted = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = tournament.status == 'live';

    return Card(
      color: isLive && isLiveHighlighted ? Colors.green.shade50 : null,
      elevation: isLive && isLiveHighlighted ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormatter.getTournamentDateDisplay(
                            tournament.date,
                            tournament.status,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: tournament.status, isLive: isLive),
                ],
              ),

              const SizedBox(height: 12),

              // Location and details
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tournament.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              if (showHostClub) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Host: ${tournament.hostClub}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // Teams count and action button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${tournament.teams.length} teams',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (onTap != null) _buildActionButton(context, isLive),
                ],
              ),

              // Live tournament additional info
              if (isLive) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.live_tv, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Tournament in progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isLive) {
    if (isLive) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: const Text('View Live'),
      );
    } else {
      return TextButton(
        onPressed: onTap,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('View Details'),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 16),
          ],
        ),
      );
    }
  }
}

// Compact version for lists
class TournamentListTile extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;

  const TournamentListTile({super.key, required this.tournament, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tournament.status.statusColor,
          child: Icon(tournament.status.statusIcon, color: Colors.white),
        ),
        title: Text(tournament.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormatter.formatShortDate(tournament.date)} • ${tournament.location}',
            ),
            Text(
              '${tournament.teams.length} teams • ${tournament.status.toUpperCase()} • Host: ${tournament.hostClub}',
              style: TextStyle(
                color: tournament.status.statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
