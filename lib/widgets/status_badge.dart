// widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isLive;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.status,
    this.isLive = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border:
            isLive ? Border.all(color: Colors.green.shade300, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
              size: 14,
              color: _getTextColor(),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          if (isLive) ...[
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.green.shade100;
      case 'upcoming':
        return Colors.orange.shade100;
      case 'completed':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.green.shade700;
      case 'upcoming':
        return Colors.orange.shade700;
      case 'completed':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getIcon() {
    switch (status.toLowerCase()) {
      case 'live':
        return Icons.live_tv;
      case 'upcoming':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}

// Verification Status Badge for fish catches
class VerificationBadge extends StatelessWidget {
  final bool verified;
  final bool pending;

  const VerificationBadge({
    super.key,
    required this.verified,
    this.pending = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        verified ? Colors.green : (pending ? Colors.orange : Colors.grey);
    final icon =
        verified ? Icons.verified : (pending ? Icons.pending : Icons.help);
    final text = verified ? 'VERIFIED' : (pending ? 'PENDING' : 'UNVERIFIED');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Rank Badge for leaderboards
class RankBadge extends StatelessWidget {
  final int rank;
  final bool showMedal;

  const RankBadge({
    super.key,
    required this.rank,
    this.showMedal = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;

    return CircleAvatar(
      radius: 16,
      backgroundColor: rank.rankColor,
      child: showMedal && isTopThree
          ? Icon(_getMedalIcon(), color: Colors.white, size: 16)
          : Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
    );
  }

  IconData _getMedalIcon() {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.workspace_premium; // Medal
      case 3:
        return Icons.workspace_premium; // Medal
      default:
        return Icons.emoji_events;
    }
  }
}
