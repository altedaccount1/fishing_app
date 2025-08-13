// screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import 'tournament_management_screen.dart';
import 'user_management_screen.dart';
import 'team_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isAdmin) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Admin access required'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(),
          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 24),

          // Management Cards
          _buildManagementCards(context),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final user = AuthService.currentUser;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back, ${user?.firstName ?? "Admin"}!',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const Text(
            'Manage tournaments, teams, and users for ASAC',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final tournaments = DataService.getAllTournaments();
    final users = AuthService.getAllUsers();
    final totalTeams = DataService.getSeasonLeaderboard().length;
    final liveTournaments = DataService.getTournamentsByStatus('live').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tournaments',
                  tournaments.length.toString(),
                  Icons.event,
                  Colors.blue,
                  subtitle: '$liveTournaments live',
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Users',
                  users.length.toString(),
                  Icons.people,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Teams',
                  totalTeams.toString(),
                  Icons.group,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  'Fish Caught',
                  DataService.getAllCatches().length.toString(),
                  Icons.set_meal,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color,
      {String? subtitle}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildManagementCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildManagementCard(
                context,
                'Tournament Management',
                'Create, edit, and manage tournaments',
                Icons.event,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TournamentManagementScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementCard(
                context,
                'User Management',
                'Manage user accounts and roles',
                Icons.people,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserManagementScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManagementCard(
                context,
                'Team Management',
                'View and manage team registrations',
                Icons.group,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TeamManagementScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementCard(
                context,
                'Reports & Analytics',
                'View detailed reports and statistics',
                Icons.analytics,
                Colors.purple,
                () => _showComingSoon(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const Spacer(),
                  Icon(Icons.arrow_forward,
                      color: Colors.grey.shade400, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'New tournament created',
            'Summer Slam tournament was created',
            Icons.event,
            Colors.blue,
            '2 hours ago',
          ),
          _buildActivityItem(
            'User registered',
            'New team captain joined',
            Icons.person_add,
            Colors.green,
            '4 hours ago',
          ),
          _buildActivityItem(
            'Fish scored',
            'Judge verified 3 new catches',
            Icons.verified,
            Colors.orange,
            '6 hours ago',
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => _showComingSoon(null),
              child: const Text('View All Activity'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, Color color, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext? context) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feature coming soon!'),
        ),
      );
    }
  }
}
