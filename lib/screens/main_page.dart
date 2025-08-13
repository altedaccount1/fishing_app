// Step 1: Update your main_page.dart navigation

// Add to screens/main_page.dart
class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Add this method to get navigation items
  List<BottomNavigationBarItem> _getNavigationItems() {
    final user = AuthService.currentUser;
    if (user == null) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Join Tournament'), // NEW
        BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    switch (user.role) {
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Tournaments'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Judge'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ];
      // ... other roles remain the same
    }
  }

  // Update _getCurrentScreen method
  Widget _getCurrentScreen() {
    final user = AuthService.currentUser;
    
    if (user == null) {
      switch (_selectedIndex) {
        case 0: return const HomeScreen();
        case 1: return const JoinTournamentScreen(); // NEW
        case 2: return const LeaderboardScreen();
        case 3: return const ProfileScreen();
        default: return const HomeScreen();
      }
    }

    switch (user.role) {
      case UserRole.admin:
        switch (_selectedIndex) {
          case 0: return const HomeScreen();
          case 1: return const AdminTournamentScreen(); // NEW - Enhanced version
          case 2: return const LeaderboardScreen();
          case 3: return const JudgeScreen();
          case 4: return const AdminDashboard();
          default: return const HomeScreen();
        }
      // ... handle other roles
    }
  }
}

// Step 2: Create the new AdminTournamentScreen that includes registration management

// screens/admin/admin_tournament_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import 'tournament_management_screen.dart';
import 'tournament_registration_screen.dart';
import 'create_tournament_screen.dart';

class AdminTournamentScreen extends StatefulWidget {
  const AdminTournamentScreen({super.key});

  @override
  State<AdminTournamentScreen> createState() => _AdminTournamentScreenState();
}

class _AdminTournamentScreenState extends State<AdminTournamentScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Admin access required')),
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
          _buildQuickActions(),
          _buildFilterBar(),
          Expanded(child: _buildTournamentList()),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Create Tournament',
                  'Start a new tournament',
                  Icons.add_circle,
                  Colors.green,
                  () => _navigateToCreateTournament(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Live Registration',
                  'Manage active registrations',
                  Icons.how_to_reg,
                  Colors.orange,
                  () => _navigateToLiveRegistration(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, 
      Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filterOptions = ['all', 'live', 'upcoming', 'completed'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Filter: '),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterOptions.map((filter) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter.toUpperCase()),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = filter);
                    },
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentList() {
    final tournaments = _getFilteredTournaments();
    
    if (tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No tournaments found'),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) => _buildTournamentCard(tournaments[index]),
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final registrations = DataService.getIndividualRegistrations(tournament.id);
    final paidCount = registrations.where((r) => r.isPaid).length;
    final pendingCount = registrations.length - paidCount;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        tournament.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('${tournament.location} • ${tournament.hostClub}'),
                    ],
                  ),
                ),
                StatusBadge(status: tournament.status, isLive: tournament.status == 'live'),
              ],
            ),
            const SizedBox(height: 12),
            
            // Registration Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildStatChip('Teams', '${tournament.teams.length}', Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatChip('Individuals', '$paidCount', Colors.green),
                  const SizedBox(width: 8),
                  if (pendingCount > 0)
                    _buildStatChip('Pending', '$pendingCount', Colors.orange),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TournamentManagementScreen(),
                    )),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Manage'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TournamentRegistrationScreen(tournament: tournament),
                    )),
                    icon: const Icon(Icons.people, size: 16),
                    label: const Text('Registration'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tournament.status == 'live' ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  List<Tournament> _getFilteredTournaments() {
    final allTournaments = DataService.getAllTournaments();
    if (_selectedFilter == 'all') return allTournaments;
    return DataService.getTournamentsByStatus(_selectedFilter);
  }

  void _navigateToCreateTournament() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const CreateTournamentScreen(),
    )).then((created) {
      if (created == true) setState(() {});
    });
  }

  void _navigateToLiveRegistration() {
    final liveTournaments = DataService.getTournamentsByStatus('live');
    if (liveTournaments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No live tournaments for registration')),
      );
      return;
    }

    if (liveTournaments.length == 1) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => TournamentRegistrationScreen(tournament: liveTournaments.first),
      ));
    } else {
      _showTournamentSelection(liveTournaments);
    }
  }

  void _showTournamentSelection(List<Tournament> tournaments) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Live Tournament'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: tournaments.map((tournament) => ListTile(
            title: Text(tournament.name),
            subtitle: Text(tournament.location),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => TournamentRegistrationScreen(tournament: tournament),
              ));
            },
          )).toList(),
        ),
      ),
    );
  }
}

// Step 3: Update your leaderboard to show both teams and individuals

// screens/leaderboard/enhanced_leaderboard_screen.dart
class EnhancedLeaderboardScreen extends StatefulWidget {
  const EnhancedLeaderboardScreen({super.key});

  @override
  State<EnhancedLeaderboardScreen> createState() => _EnhancedLeaderboardScreenState();
}

class _EnhancedLeaderboardScreenState extends State<EnhancedLeaderboardScreen> {
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
              ButtonSegment(value: true, label: Text('Season'), icon: Icon(Icons.emoji_events)),
              ButtonSegment(value: false, label: Text('Tournaments'), icon: Icon(Icons.event)),
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
                      children: ['teams', 'individuals', 'kids'].map((category) => 
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_getCategoryDisplayName(category)),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              if (selected) setState(() => selectedCategory = category);
                            },
                          ),
                        )
                      ).toList(),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        final rank = index + 1;
        return _buildTeamLeaderboardCard(team, rank);
      },
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
    
    if (allIndividuals.isEmpty) return _buildEmptyState('No individual participants yet');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allIndividuals.length,
      itemBuilder: (context, index) {
        final individual = allIndividuals[index];
        final rank = index + 1;
        return _buildIndividualLeaderboardCard(individual, rank);
      },
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allKids.length,
      itemBuilder: (context, index) {
        final kid = allKids[index];
        final rank = index + 1;
        return _buildKidLeaderboardCard(kid, rank);
      },
    );
  }

  // Individual leaderboard card widgets...
  Widget _buildIndividualLeaderboardCard(IndividualRegistration individual, int rank) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: RankBadge(rank: rank),
        title: Text(individual.displayName),
        subtitle: Text('${individual.totalPoints} points • ${individual.catches.length} fish'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${individual.totalPoints}', 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text('points', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Add other methods...
}

// Step 4: Add navigation to your existing screens

// In your existing HomeScreen, add a floating action button for quick tournament join
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... existing code ...
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => DataService.refreshData(),
        child: SingleChildScrollView(
          // ... existing content ...
        ),
      ),
      floatingActionButton: AuthService.currentUser == null 
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => const JoinTournamentScreen(),
            )),
            icon: const Icon(Icons.add),
            label: const Text('Join Tournament'),
            backgroundColor: Colors.green,
          )
        : null,
    );
  }
}