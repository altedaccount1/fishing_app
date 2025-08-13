// screens/schedule/schedule_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/theme.dart';
import '../tournament/tournament_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedFilter = 'all';

  final List<String> _filterOptions = [
    'all',
    'upcoming',
    'live',
    'completed',
  ];

  @override
  Widget build(BuildContext context) {
    List<Tournament> tournaments = _getFilteredTournaments();
    // Create a mutable copy before sorting
    final sortableTournaments = List<Tournament>.from(tournaments);
    sortableTournaments.sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Filter: '),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions
                        .map((filter) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(_getFilterDisplayName(filter)),
                                selected: _selectedFilter == filter,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  }
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

        // Tournament List
        Expanded(
          child: sortableTournaments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => DataService.refreshData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: sortableTournaments.length,
                    itemBuilder: (context, index) {
                      final tournament = sortableTournaments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: _buildTournamentListItem(tournament),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  List<Tournament> _getFilteredTournaments() {
    final allTournaments = DataService.getAllTournaments();

    if (_selectedFilter == 'all') {
      return allTournaments;
    } else {
      return DataService.getTournamentsByStatus(_selectedFilter);
    }
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'upcoming':
        return 'Upcoming';
      case 'live':
        return 'Live';
      case 'completed':
        return 'Completed';
      default:
        return filter;
    }
  }

  Widget _buildTournamentListItem(Tournament tournament) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tournament.status.statusColor,
          child: Icon(
            tournament.status.statusIcon,
            color: Colors.white,
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
                const Text(' • ', style: TextStyle(fontSize: 12)),
                Text(
                  tournament.status.toUpperCase(),
                  style: TextStyle(
                    color: tournament.status.statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const Text(' • ', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Text(
                    'Host: ${tournament.hostClub}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward),
            if (tournament.status == 'live')
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () => _navigateToTournamentDetail(tournament),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'upcoming':
        message = 'No upcoming tournaments';
        icon = Icons.schedule;
        break;
      case 'live':
        message = 'No live tournaments';
        icon = Icons.live_tv;
        break;
      case 'completed':
        message = 'No completed tournaments';
        icon = Icons.check_circle;
        break;
      default:
        message = 'No tournaments available';
        icon = Icons.event_busy;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
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
            'Check back later for new tournaments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToTournamentDetail(Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailScreen(tournament: tournament),
      ),
    );
  }
}
