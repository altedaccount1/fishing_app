// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/theme.dart';
import '../../widgets/status_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This would come from user authentication in a real app
    const String userClub = 'Cape May Fishing Club';
    const String userName = 'Judge/Official';
    const String userRole = 'Tournament Judge';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(userName, userClub, userRole),
          const SizedBox(height: 32),

          // Hosting Schedule Card
          _buildHostingScheduleCard(userClub),
          const SizedBox(height: 16),

          // Statistics Card
          _buildStatisticsCard(),
          const SizedBox(height: 16),

          // Judge Tools Card
          _buildJudgeToolsCard(context),
          const SizedBox(height: 16),

          // Settings Card
          _buildSettingsCard(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      String userName, String userClub, String userRole) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          userClub,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            userRole,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHostingScheduleCard(String userClub) {
    final clubTournaments = DataService.getTournamentsByHostClub(userClub);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.event, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Your Club\'s Tournaments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (clubTournaments.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No tournaments hosted by your club',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...clubTournaments
                  .map((tournament) => _buildTournamentRow(tournament)),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentRow(Tournament tournament) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            tournament.status.statusIcon,
            color: tournament.status.statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournament.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${DateFormatter.formatShortDate(tournament.date)} • ${tournament.teams.length} teams',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: tournament.status),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final totalCatches = DataService.getAllCatches().length;
    final totalPointsAwarded = DataService.getTotalPointsAwarded();
    final totalTournaments = DataService.getAllTournaments().length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Judging Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tournaments\nJudged',
                    totalTournaments.toString(),
                    Icons.event,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Fish\nScored',
                    totalCatches.toString(),
                    Icons.set_meal,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Points\nAwarded',
                    totalPointsAwarded.toString(),
                    Icons.star,
                    Colors.green,
                  ),
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
      ],
    );
  }

  Widget _buildJudgeToolsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Judge Tools',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildToolItem(
              icon: Icons.rule,
              title: 'ASAC Scoring Rules',
              subtitle: 'View official scoring guidelines',
              onTap: () => _showScoringRules(context),
            ),
            _buildToolItem(
              icon: Icons.checklist,
              title: 'Verify Submissions',
              subtitle: 'Review and verify pending fish',
              onTap: () => _showComingSoon(context),
            ),
            _buildToolItem(
              icon: Icons.download,
              title: 'Export Tournament Data',
              subtitle: 'Download results and statistics',
              onTap: () => _showComingSoon(context),
            ),
            _buildToolItem(
              icon: Icons.history,
              title: 'Judging History',
              subtitle: 'View your past judging activities',
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildToolItem(
              icon: Icons.notifications,
              title: 'Notification Settings',
              subtitle: 'Manage your notification preferences',
              onTap: () => _showComingSoon(context),
            ),
            _buildToolItem(
              icon: Icons.security,
              title: 'Account Security',
              subtitle: 'Update password and security settings',
              onTap: () => _showComingSoon(context),
            ),
            _buildToolItem(
              icon: Icons.contact_support,
              title: 'Contact ASAC',
              subtitle: 'Get help and support',
              onTap: () => _showContactInfo(context),
            ),
            _buildToolItem(
              icon: Icons.info,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () => _showAbout(context),
            ),
            const Divider(),
            _buildToolItem(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              titleColor: Colors.red,
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: titleColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showScoringRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ASAC Scoring Rules'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Point Calculation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Length (inches) × 1.5'),
              Text('• Weight (pounds) × 3.0'),
              Text('• Total = Length Points + Weight Points'),
              SizedBox(height: 16),
              Text(
                'Minimum Requirements:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Fish must meet species-specific size limits'),
              Text('• All measurements must be accurate'),
              Text('• Photos recommended for verification'),
              SizedBox(height: 16),
              Text(
                'Special Species Multipliers:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Striped Bass: 1.2x multiplier'),
              Text('• Red Drum: 1.1x multiplier'),
              Text('• Tautog: 1.3x multiplier'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact ASAC'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atlantic Surf Angling Club',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16),
                SizedBox(width: 8),
                Text('info@asacfishing.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16),
                SizedBox(width: 8),
                Text('(555) 123-4567'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.web, size: 16),
                SizedBox(width: 8),
                Text('www.asacfishing.com'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About ASAC Fishing'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ASAC Fishing Tournament App',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'The official app for Atlantic Surf Angling Club tournaments. Track scores, view leaderboards, and manage tournament judging.',
            ),
            SizedBox(height: 16),
            Text(
              'Built with Flutter',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement sign out logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sign out functionality coming soon!'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
