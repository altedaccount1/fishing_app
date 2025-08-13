// screens/tournament/tournament_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/team.dart';
import '../../services/data_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/theme.dart';
import '../../widgets/status_badge.dart';

class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareTournament(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tournament Info Header
          _buildTournamentHeader(),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Leaderboard', icon: Icon(Icons.leaderboard)),
                Tab(text: 'Teams', icon: Icon(Icons.group)),
                Tab(text: 'Live Feed', icon: Icon(Icons.feed)),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboard(),
                _buildTeamsList(),
                _buildLiveFeed(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
                      widget.tournament.location,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${DateFormatter.formatLongDate(widget.tournament.date)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: widget.tournament.status,
                isLive: widget.tournament.status == 'live',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.group,
                label: '${widget.tournament.teams.length} teams',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.business,
                label: 'Host: ${widget.tournament.hostClub}',
              ),
            ],
          ),
          if (widget.tournament.status == 'live') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.live_tv, color: Colors.green, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Tournament in progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    final teams = List<Team>.from(widget.tournament.teams);
    teams.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    if (teams.isEmpty) {
      return _buildEmptyState(
        icon: Icons.leaderboard,
        title: 'No Teams Yet',
        subtitle: 'Teams will appear here once they join the tournament',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
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
              leading: CircleAvatar(
                backgroundColor: rank.rankColor,
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                team.name,
                style: TextStyle(
                  fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              subtitle: Text(team.club),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${team.totalPoints}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rank.rankColor,
                    ),
                  ),
                  const Text(
                    'points',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamsList() {
    if (widget.tournament.teams.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group,
        title: 'No Teams Registered',
        subtitle:
            'Teams will appear here once they register for the tournament',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.tournament.teams.length,
      itemBuilder: (context, index) {
        final team = widget.tournament.teams[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
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
            subtitle: Text('${team.club} • ${team.totalPoints} points'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Members:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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
                    const SizedBox(height: 16),
                    _buildTeamCatches(team.id),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamCatches(String teamId) {
    final teamCatches = DataService.getCatchesForTeam(teamId)
        .where((fish) => fish.tournamentId == widget.tournament.id)
        .toList();

    if (teamCatches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No catches yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Catches:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...teamCatches.take(5).map((fish) => Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    fish.verified ? Icons.verified : Icons.pending,
                    color: fish.verified ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fish.species,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${fish.measurementDisplay} • ${fish.pointsDisplay}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormatter.getRelativeTime(fish.caughtTime),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildLiveFeed() {
    final tournamentCatches =
        DataService.getCatchesForTournament(widget.tournament.id);
    tournamentCatches.sort((a, b) => b.caughtTime.compareTo(a.caughtTime));

    if (tournamentCatches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hourglass_empty,
        title: 'No Catches Yet',
        subtitle: 'Catches will appear here in real-time as they are scored',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tournamentCatches.length,
        itemBuilder: (context, index) {
          final fish = tournamentCatches[index];
          final team = widget.tournament.teams.firstWhere(
            (t) => t.id == fish.teamId,
            orElse: () => Team(
              id: '',
              name: 'Unknown Team',
              club: '',
              members: [],
            ),
          );

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: fish.verified ? Colors.green : Colors.orange,
                child: Icon(
                  fish.verified ? Icons.verified : Icons.pending,
                  color: Colors.white,
                ),
              ),
              title: Text('${team.name} caught ${fish.species}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${fish.measurementDisplay} • ${fish.pointsDisplay}'),
                  Text(
                    DateFormatter.formatDateTime(fish.caughtTime),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    fish.verified ? Icons.check_circle : Icons.access_time,
                    color: fish.verified ? Colors.green : Colors.orange,
                  ),
                  Text(
                    fish.verified ? 'Verified' : 'Pending',
                    style: TextStyle(
                      fontSize: 10,
                      color: fish.verified ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    await DataService.refreshData();
    if (mounted) {
      setState(() {});
    }
  }

  void _shareTournament() {
    // Placeholder for sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing feature coming soon!'),
      ),
    );
  }
}
