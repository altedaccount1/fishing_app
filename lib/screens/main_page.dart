// screens/main_page.dart
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'schedule/schedule_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'judge/judge_screen.dart';
import 'profile/profile_screen.dart';
import 'auth/login_screen.dart';
import 'admin/admin_dashboard.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Get navigation items based on user role
  List<BottomNavigationBarItem> _getNavigationItems() {
    final user = AuthService.currentUser;
    if (user == null) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Schedule'),
        BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    switch (user.role) {
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Judge'),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ];
      case UserRole.teamCaptain:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'My Team'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      case UserRole.judge:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Judge'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      case UserRole.user:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
    }
  }

  List<String> _getScreenTitles() {
    final user = AuthService.currentUser;
    if (user == null) {
      return ['ASAC Fishing', 'Schedule', 'Leaderboard', 'Profile'];
    }

    switch (user.role) {
      case UserRole.admin:
        return [
          'ASAC Fishing',
          'Schedule',
          'Leaderboard',
          'Judge',
          'Admin Panel'
        ];
      case UserRole.teamCaptain:
        return [
          'ASAC Fishing',
          'Schedule',
          'My Team',
          'Leaderboard',
          'Profile'
        ];
      case UserRole.judge:
        return ['ASAC Fishing', 'Schedule', 'Judge', 'Leaderboard', 'Profile'];
      case UserRole.user:
        return ['ASAC Fishing', 'Schedule', 'Leaderboard', 'Profile'];
    }
  }

  // Get current screen based on role and index
  Widget _getCurrentScreen() {
    final user = AuthService.currentUser;
    if (user == null) {
      switch (_selectedIndex) {
        case 0:
          return const HomeScreen();
        case 1:
          return const ScheduleScreen();
        case 2:
          return const LeaderboardScreen();
        case 3:
          return const ProfileScreen();
        default:
          return const HomeScreen();
      }
    }

    switch (user.role) {
      case UserRole.admin:
        switch (_selectedIndex) {
          case 0:
            return const HomeScreen();
          case 1:
            return const ScheduleScreen();
          case 2:
            return const LeaderboardScreen();
          case 3:
            return const JudgeScreen();
          case 4:
            return const AdminDashboard();
          default:
            return const HomeScreen();
        }
      case UserRole.teamCaptain:
        switch (_selectedIndex) {
          case 0:
            return const HomeScreen();
          case 1:
            return const ScheduleScreen();
          case 2:
            return _buildMyTeamScreen();
          case 3:
            return const LeaderboardScreen();
          case 4:
            return const ProfileScreen();
          default:
            return const HomeScreen();
        }
      case UserRole.judge:
        switch (_selectedIndex) {
          case 0:
            return const HomeScreen();
          case 1:
            return const ScheduleScreen();
          case 2:
            return const JudgeScreen();
          case 3:
            return const LeaderboardScreen();
          case 4:
            return const ProfileScreen();
          default:
            return const HomeScreen();
        }
      case UserRole.user:
        switch (_selectedIndex) {
          case 0:
            return const HomeScreen();
          case 1:
            return const ScheduleScreen();
          case 2:
            return const LeaderboardScreen();
          case 3:
            return const ProfileScreen();
          default:
            return const HomeScreen();
        }
    }
  }

  // Temporary placeholder screens
  Widget _buildAdminScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Admin Panel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Tournament & User Management'),
          SizedBox(height: 16),
          Text('Coming in Phase 2!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMyTeamScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('My Team',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Team Management & Registration'),
          SizedBox(height: 16),
          Text('Coming in Phase 3!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.teamCaptain:
        return Colors.green;
      case UserRole.judge:
        return Colors.orange;
      case UserRole.user:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final titles = _getScreenTitles();
    final currentTitle = _selectedIndex < titles.length
        ? titles[_selectedIndex]
        : 'ASAC Fishing';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(currentTitle),
            const Spacer(),
            if (user != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.displayRole,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh data',
          ),
          if (user != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    _showProfile();
                    break;
                  case 'logout':
                    _signOut();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sign Out', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: _getNavigationItems(),
      ),
    );
  }

  void _showProfile() {
    final user = AuthService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.fullName}'),
            Text('Email: ${user.email}'),
            Text('Role: ${user.displayRole}'),
            if (user.club != null) Text('Club: ${user.club}'),
            if (user.phoneNumber != null) Text('Phone: ${user.phoneNumber}'),
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

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Refreshing data...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      await DataService.refreshData();
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
