// screens/admin/tournament_management_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';
import 'create_tournament_screen.dart';
import 'edit_tournament_screen.dart';

class TournamentManagementScreen extends StatefulWidget {
  const TournamentManagementScreen({super.key});

  @override
  State<TournamentManagementScreen> createState() =>
      _TournamentManagementScreenState();
}

class _TournamentManagementScreenState
    extends State<TournamentManagementScreen> {
  String _selectedFilter = 'all';

  final List<String> _filterOptions = [
    'all',
    'upcoming',
    'live',
    'completed',
  ];

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('Admin access required'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateTournament(),
            tooltip: 'Create Tournament',
          ),
        ],
      ),
      body: Column(
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
            child: _buildTournamentList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTournament(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTournamentList() {
    List<Tournament> tournaments = _getFilteredTournaments();
    final sortableTournaments = List<Tournament>.from(tournaments);
    sortableTournaments.sort((a, b) => a.date.compareTo(b.date));

    if (sortableTournaments.isEmpty) {
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
              'No ${_selectedFilter == 'all' ? '' : _selectedFilter} tournaments',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateTournament(),
              icon: const Icon(Icons.add),
              label: const Text('Create Tournament'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortableTournaments.length,
      itemBuilder: (context, index) {
        final tournament = sortableTournaments[index];
        return _buildTournamentCard(tournament);
      },
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tournament.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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

            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatLongDate(tournament.date),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.business, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Host: ${tournament.hostClub}',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.group, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${tournament.teams.length} teams registered',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToEditTournament(tournament),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStatusChangeDialog(tournament),
                    icon: const Icon(Icons.update, size: 16),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusActionColor(tournament.status),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(tournament),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Tournament',
                ),
              ],
            ),
          ],
        ),
      ),
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

  Color _getStatusActionColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.green; // Can start
      case 'live':
        return Colors.orange; // Can end
      case 'completed':
        return Colors.grey; // Can reopen
      default:
        return Colors.blue;
    }
  }

  void _navigateToCreateTournament() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTournamentScreen(),
      ),
    ).then((created) {
      if (created == true) {
        setState(() {}); // Refresh list
      }
    });
  }

  void _navigateToEditTournament(Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTournamentScreen(tournament: tournament),
      ),
    ).then((updated) {
      if (updated == true) {
        setState(() {}); // Refresh list
      }
    });
  }

  void _showStatusChangeDialog(Tournament tournament) {
    List<String> availableStatuses = [];

    switch (tournament.status) {
      case 'upcoming':
        availableStatuses = ['live'];
        break;
      case 'live':
        availableStatuses = ['completed'];
        break;
      case 'completed':
        availableStatuses = ['live']; // Reopen if needed
        break;
    }

    if (availableStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No status changes available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${tournament.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current status: ${tournament.status.toUpperCase()}'),
            const SizedBox(height: 16),
            const Text('Change to:'),
            ...availableStatuses.map((status) => ListTile(
                  title: Text(status.toUpperCase()),
                  onTap: () {
                    Navigator.of(context).pop();
                    _updateTournamentStatus(tournament, status);
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateTournamentStatus(Tournament tournament, String newStatus) {
    DataService.updateTournamentStatus(tournament.id, newStatus);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${tournament.name} status updated to ${newStatus.toUpperCase()}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteConfirmation(Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: Text(
            'Are you sure you want to delete "${tournament.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTournament(tournament);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTournament(Tournament tournament) {
    // TODO: Implement delete in DataService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delete functionality will be implemented soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
