// screens/admin/team_management_screen.dart
import 'package:flutter/material.dart';
import '../../models/team.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/team_card.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = [
    'all',
    'active',
    'no_points',
    'high_performers',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: const Text('Team Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search teams by name or club...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Filter Chips
                Row(
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
                                      label:
                                          Text(_getFilterDisplayName(filter)),
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
              ],
            ),
          ),

          // Team Stats Bar
          _buildTeamStatsBar(),

          // Team List
          Expanded(
            child: _buildTeamList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTeamDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.group_add, color: Colors.white),
        tooltip: 'Add Team',
      ),
    );
  }

  Widget _buildTeamStatsBar() {
    final allTeams = DataService.getAllTeams();
    final activeTeams = allTeams.where((t) => t.totalPoints > 0).length;
    final totalPoints = allTeams.fold(0, (sum, team) => sum + team.totalPoints);

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          _buildStatChip('Total', allTeams.length.toString(), Colors.blue),
          const SizedBox(width: 8),
          _buildStatChip('Active', activeTeams.toString(), Colors.green),
          const SizedBox(width: 8),
          _buildStatChip('Points', totalPoints.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamList() {
    final filteredTeams = _getFilteredTeams();

    if (filteredTeams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No teams found matching "$_searchQuery"'
                  : 'No ${_selectedFilter == 'all' ? '' : _getFilterDisplayName(_selectedFilter)} teams',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateTeamDialog(),
              icon: const Icon(Icons.group_add),
              label: const Text('Add Team'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredTeams.length,
      itemBuilder: (context, index) {
        final team = filteredTeams[index];
        return _buildTeamCard(team);
      },
    );
  }

  Widget _buildTeamCard(Team team) {
    final teamCatches = DataService.getCatchesForTeam(team.id);
    final tournaments = DataService.getAllTournaments()
        .where((t) =>
            t.teams.any((tournamentTeam) => tournamentTeam.id == team.id))
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    team.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        team.club,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${team.totalPoints} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Team Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Members (${team.memberCount}):',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    team.membersDisplay,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tournaments',
                    tournaments.length.toString(),
                    Icons.event,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Fish Caught',
                    teamCatches.length.toString(),
                    Icons.set_meal,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Points',
                    tournaments.isNotEmpty
                        ? (team.totalPoints / tournaments.length)
                            .toStringAsFixed(1)
                        : '0',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tournament Participation
            if (tournaments.isNotEmpty) ...[
              const Text(
                'Tournament Participation:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = tournaments[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tournament.status == 'live'
                            ? Colors.green.shade100
                            : tournament.status == 'upcoming'
                                ? Colors.orange.shade100
                                : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tournament.status == 'live'
                              ? Colors.green.shade300
                              : tournament.status == 'upcoming'
                                  ? Colors.orange.shade300
                                  : Colors.blue.shade300,
                        ),
                      ),
                      child: Text(
                        tournament.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: tournament.status == 'live'
                              ? Colors.green.shade700
                              : tournament.status == 'upcoming'
                                  ? Colors.orange.shade700
                                  : Colors.blue.shade700,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditTeamDialog(team),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTeamDetails(team),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteTeamDialog(team),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Team',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Team> _getFilteredTeams() {
    final allTeams = DataService.getAllTeams();

    List<Team> filtered = allTeams;

    // Apply filter
    switch (_selectedFilter) {
      case 'active':
        filtered = filtered.where((team) => team.totalPoints > 0).toList();
        break;
      case 'no_points':
        filtered = filtered.where((team) => team.totalPoints == 0).toList();
        break;
      case 'high_performers':
        filtered = filtered.where((team) => team.totalPoints >= 100).toList();
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((team) {
        return team.name.toLowerCase().contains(_searchQuery) ||
            team.club.toLowerCase().contains(_searchQuery) ||
            team.members
                .any((member) => member.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    // Sort by points (descending)
    filtered.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return filtered;
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Teams';
      case 'active':
        return 'Active (>0 pts)';
      case 'no_points':
        return 'No Points';
      case 'high_performers':
        return 'High Performers (100+ pts)';
      default:
        return filter;
    }
  }

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateTeamDialog(
        onTeamCreated: () => setState(() {}),
      ),
    );
  }

  void _showEditTeamDialog(Team team) {
    showDialog(
      context: context,
      builder: (context) => _EditTeamDialog(
        team: team,
        onTeamUpdated: () => setState(() {}),
      ),
    );
  }

  void _showTeamDetails(Team team) {
    final teamCatches = DataService.getCatchesForTeam(team.id);
    final tournaments = DataService.getAllTournaments()
        .where((t) =>
            t.teams.any((tournamentTeam) => tournamentTeam.id == team.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(team.name),
        content: SizedBox(
          width: 400,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Club', team.club),
                _buildDetailRow('Total Points', '${team.totalPoints}'),
                _buildDetailRow('Members', '${team.memberCount}'),
                _buildDetailRow('Fish Caught', '${teamCatches.length}'),
                _buildDetailRow('Tournaments', '${tournaments.length}'),
                const SizedBox(height: 16),
                const Text(
                  'Team Members:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...team.members.map((member) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.person,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(member),
                        ],
                      ),
                    )),
                if (tournaments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Tournament History:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...tournaments.map((tournament) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              tournament.status == 'live'
                                  ? Icons.live_tv
                                  : tournament.status == 'upcoming'
                                      ? Icons.schedule
                                      : Icons.check_circle,
                              size: 16,
                              color: tournament.status == 'live'
                                  ? Colors.green
                                  : tournament.status == 'upcoming'
                                      ? Colors.orange
                                      : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(tournament.name)),
                            Text(
                              tournament.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: tournament.status == 'live'
                                    ? Colors.green
                                    : tournament.status == 'upcoming'
                                        ? Colors.orange
                                        : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditTeamDialog(team);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteTeamDialog(Team team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text(
          'Are you sure you want to delete "${team.name}"? This action cannot be undone and will remove all associated data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTeam(team);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeam(Team team) async {
    try {
      final success = await DataService.deleteTeam(team.id);

      if (mounted) {
        setState(() {}); // Refresh the list

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Team "${team.name}" deleted successfully'
                : 'Failed to delete team'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Create Team Dialog
class _CreateTeamDialog extends StatefulWidget {
  final VoidCallback onTeamCreated;

  const _CreateTeamDialog({required this.onTeamCreated});

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clubController = TextEditingController();
  final List<TextEditingController> _memberControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _isLoading = false;

  final List<String> _asacClubs = [
    'American Angler',
    'Anglesea Surf Anglers',
    'Atlantic City Salt Water Anglers',
    'Barrington Rod & Reel',
    'Creek Keepers Surf Fishing Team',
    'Delaware Valley Surf Anglers',
    'Fishin Fuzz',
    'Frann\'s Fans in the Sand',
    'Long Beach Island Fishing Club',
    'Merchantville Fishing Club',
    'New Jersey Beach Buggy Assoc.',
    'Ocean City Fishing Club',
    'Pennsauken Fishing Club',
    'Seaside Heights Fishing Club',
    'Surf n\'Land Sportsmen\'s Club',
    'Surf City Sea Anglers',
    'Team Top Notch',
    'Women\'s Surf Fishing Club of NJ',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _clubController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Team'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Team name is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _clubController.text.isEmpty
                      ? null
                      : _clubController.text,
                  decoration: const InputDecoration(
                    labelText: 'Club',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: _asacClubs.map((club) {
                    return DropdownMenuItem(
                      value: club,
                      child: Text(club),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _clubController.text = value;
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Club is required' : null,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Team Members:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                ..._memberControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Member ${index + 1}',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: index < 2
                                ? (value) =>
                                    value?.isEmpty == true ? 'Required' : null
                                : null,
                          ),
                        ),
                        if (index >= 2)
                          IconButton(
                            onPressed: () => _removeMember(index),
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            tooltip: 'Remove Member',
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                if (_memberControllers.length < 6)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addMember,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Member'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTeam,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create Team'),
        ),
      ],
    );
  }

  void _addMember() {
    if (_memberControllers.length < 6) {
      setState(() {
        _memberControllers.add(TextEditingController());
      });
    }
  }

  void _removeMember(int index) {
    if (index >= 2 && _memberControllers.length > 2) {
      setState(() {
        _memberControllers[index].dispose();
        _memberControllers.removeAt(index);
      });
    }
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final members = _memberControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (members.length < 2) {
        throw Exception('At least 2 team members are required');
      }

      await DataService.createTeam(
        name: _nameController.text.trim(),
        club: _clubController.text,
        members: members,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onTeamCreated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Team "${_nameController.text}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Edit Team Dialog
class _EditTeamDialog extends StatefulWidget {
  final Team team;
  final VoidCallback onTeamUpdated;

  const _EditTeamDialog({required this.team, required this.onTeamUpdated});

  @override
  State<_EditTeamDialog> createState() => _EditTeamDialogState();
}

class _EditTeamDialogState extends State<_EditTeamDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _clubController;
  late final List<TextEditingController> _memberControllers;

  bool _isLoading = false;

  final List<String> _asacClubs = [
    'American Angler',
    'Anglesea Surf Anglers',
    'Atlantic City Salt Water Anglers',
    'Barrington Rod & Reel',
    'Creek Keepers Surf Fishing Team',
    'Delaware Valley Surf Anglers',
    'Fishin Fuzz',
    'Frann\'s Fans in the Sand',
    'Long Beach Island Fishing Club',
    'Merchantville Fishing Club',
    'New Jersey Beach Buggy Assoc.',
    'Ocean City Fishing Club',
    'Pennsauken Fishing Club',
    'Seaside Heights Fishing Club',
    'Surf n\'Land Sportsmen\'s Club',
    'Surf City Sea Anglers',
    'Team Top Notch',
    'Women\'s Surf Fishing Club of NJ',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _clubController = TextEditingController(text: widget.team.club);
    _memberControllers = widget.team.members
        .map((member) => TextEditingController(text: member))
        .toList();

    // Ensure at least 2 member fields
    while (_memberControllers.length < 2) {
      _memberControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clubController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.team.name}'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Team name is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _asacClubs.contains(_clubController.text)
                      ? _clubController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Club',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: _asacClubs.map((club) {
                    return DropdownMenuItem(
                      value: club,
                      child: Text(club),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _clubController.text = value;
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Club is required' : null,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Team Members:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                ..._memberControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Member ${index + 1}',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: index < 2
                                ? (value) =>
                                    value?.isEmpty == true ? 'Required' : null
                                : null,
                          ),
                        ),
                        if (index >= 2)
                          IconButton(
                            onPressed: () => _removeMember(index),
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            tooltip: 'Remove Member',
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                if (_memberControllers.length < 6)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addMember,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Member'),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Team Stats:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Points:'),
                          Text(
                            '${widget.team.totalPoints}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fish Caught:'),
                          Text(
                            '${DataService.getCatchesForTeam(widget.team.id).length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateTeam,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  void _addMember() {
    if (_memberControllers.length < 6) {
      setState(() {
        _memberControllers.add(TextEditingController());
      });
    }
  }

  void _removeMember(int index) {
    if (index >= 2 && _memberControllers.length > 2) {
      setState(() {
        _memberControllers[index].dispose();
        _memberControllers.removeAt(index);
      });
    }
  }

  Future<void> _updateTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final members = _memberControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (members.length < 2) {
        throw Exception('At least 2 team members are required');
      }

      final updatedTeam = widget.team.copyWith(
        name: _nameController.text.trim(),
        club: _clubController.text,
        members: members,
      );

      final success = await DataService.updateTeam(updatedTeam);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onTeamUpdated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Team "${_nameController.text}" updated successfully!'
                : 'Failed to update team'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
