// screens/main_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'home/home_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'profile/profile_screen.dart';
import 'judge/judge_screen.dart';
import 'admin/admin_dashboard.dart';
import 'admin/admin_tournament_screen.dart';
import 'registration/join_tournament_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _getNavigationItems(),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems() {
    final user = AuthService.currentUser;
    
    // For non-authenticated users or regular users
    if (user == null || user.role == UserRole.user) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.how_to_reg),
          label: 'Join Tournament',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    // For admin users
    if (user.role == UserRole.admin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Tournaments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gavel),
          label: 'Judge',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      ];
    }

    // For team captains
    if (user.role == UserRole.teamCaptain) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'My Team',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    // For judges
    if (user.role == UserRole.judge) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gavel),
          label: 'Judge',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    // Default fallback
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard),
        label: 'Leaderboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  Widget _getCurrentScreen() {
    final user = AuthService.currentUser;

    // For non-authenticated users or regular users
    if (user == null || user.role == UserRole.user) {
      switch (_selectedIndex) {
        case 0:
          return const HomeScreen();
        case 1:
          return const JoinTournamentScreen();
        case 2:
          return const LeaderboardScreen();
        case 3:
          return const ProfileScreen();
        default:
          return const HomeScreen();
      }
    }

    // For admin users
    if (user.role == UserRole.admin) {
      switch (_selectedIndex) {
        case 0:
          return const HomeScreen();
        case 1:
          return const AdminTournamentScreen();
        case 2:
          return const LeaderboardScreen();
        case 3:
          return const JudgeScreen();
        case 4:
          return const AdminDashboard();
        default:
          return const HomeScreen();
      }
    }

    // For team captains
    if (user.role == UserRole.teamCaptain) {
      switch (_selectedIndex) {
        case 0:
          return const HomeScreen();
        case 1:
          return const TeamManagementScreen(); // You may need to create this
        case 2:
          return const LeaderboardScreen();
        case 3:
          return const ProfileScreen();
        default:
          return const HomeScreen();
      }
    }

    // For judges
    if (user.role == UserRole.judge) {
      switch (_selectedIndex) {
        case 0:
          return const HomeScreen();
        case 1:
          return const JudgeScreen();
        case 2:
          return const LeaderboardScreen();
        case 3:
          return const ProfileScreen();
        default:
          return const HomeScreen();
      }
    }

    // Default fallback
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const LeaderboardScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}

// Admin Tournament Screen for managing tournaments and registrations
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

  Widget _buildTournamentCard(tournament) {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tournament.status == 'live' 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tournament.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: tournament.status == 'live' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
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
                      builder: (context) => const TournamentManagementScreen(),
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

  List _getFilteredTournaments() {
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

  void _showTournamentSelection(List tournaments) {
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

// Add necessary imports
import '../screens/admin/tournament_management_screen.dart';
import '../screens/admin/create_tournament_screen.dart';
import '../screens/admin/tournament_registration_screen.dart';
import '../services/data_service.dart';

// Placeholder for team management screen
class TeamManagementScreen extends StatelessWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Team'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Team Management'),
            Text('Feature coming soon!'),
          ],
        ),
      ),
    );
  }
}