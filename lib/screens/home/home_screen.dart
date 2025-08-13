// screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';
import '../../widgets/tournament_card.dart';
import '../tournament/tournament_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final liveTournaments = DataService.getTournamentsByStatus('live');
    final upcomingTournaments = DataService.getTournamentsByStatus('upcoming');

    return RefreshIndicator(
      onRefresh: () => DataService.refreshData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            _buildWelcomeHeader(context),
            const SizedBox(height: 24),

            // Live Tournaments Section
            if (liveTournaments.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Live Tournaments',
                color: Colors.green,
                icon: Icons.live_tv,
              ),
              const SizedBox(height: 12),
              _buildLiveTournamentsList(context, liveTournaments),
              const SizedBox(height: 24),
            ],

            // Upcoming Tournaments Section
            _buildSectionHeader(context, 'Upcoming Tournaments'),
            const SizedBox(height: 12),

            if (upcomingTournaments.isNotEmpty)
              _buildUpcomingTournamentsList(context, upcomingTournaments)
            else
              _buildEmptyState(context, 'No upcoming tournaments'),

            const SizedBox(height: 24),

            // Quick Stats Section
            _buildQuickStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const Text(
            'ASAC Fishing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track tournaments, scores, and compete with anglers across clubs',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    Color color = Colors.black,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontSize: 20,
              ),
        ),
      ],
    );
  }

  Widget _buildLiveTournamentsList(
      BuildContext context, List<Tournament> tournaments) {
    return Column(
      children: tournaments
          .map((tournament) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TournamentCard(
                  tournament: tournament,
                  isLiveHighlighted: true,
                  onTap: () => _navigateToTournamentDetail(context, tournament),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildUpcomingTournamentsList(
      BuildContext context, List<Tournament> tournaments) {
    return Column(
      children: tournaments
          .map((tournament) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TournamentCard(
                  tournament: tournament,
                  isLiveHighlighted: false,
                  onTap: () => _navigateToTournamentDetail(context, tournament),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final allTournaments = DataService.getAllTournaments();
    final allTeams = DataService.getAllTeams();
    final totalCatches = DataService.getAllCatches();

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
          Text(
            'ASAC Stats',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Tournaments',
                  allTournaments.length.toString(),
                  Icons.event,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Teams',
                  allTeams.length.toString(),
                  Icons.group,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Fish Caught',
                  totalCatches.length.toString(),
                  Icons.set_meal,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _navigateToTournamentDetail(
      BuildContext context, Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailScreen(tournament: tournament),
      ),
    );
  }
}
