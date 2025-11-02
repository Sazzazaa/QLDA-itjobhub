import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/badge_model.dart';
import 'package:itjobhub/services/badge_service.dart';

/// Leaderboard Screen
/// Shows user rankings based on points and achievements
class LeaderboardScreen extends StatefulWidget {
  final String currentUserId;

  const LeaderboardScreen({super.key, required this.currentUserId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final BadgeService _badgeService = BadgeService();
  List<LeaderboardEntry> _globalLeaderboard = [];
  LeaderboardEntry? _currentUserEntry;
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.allTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _badgeService.initialize();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    setState(() => _isLoading = true);
    _globalLeaderboard = _badgeService.getLeaderboard(period: _selectedPeriod);
    
    // Find current user in leaderboard
    try {
      _currentUserEntry = _globalLeaderboard.firstWhere(
        (entry) => entry.userId == widget.currentUserId,
      );
    } catch (e) {
      _currentUserEntry = null;
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildPeriodSelector(),
                if (_currentUserEntry != null) _buildCurrentUserRank(),
                _buildTopThree(),
                Expanded(child: _buildLeaderboardList()),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: LeaderboardPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = period);
                _loadLeaderboard();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentUserRank() {
    if (_currentUserEntry == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${_currentUserEntry!.rank}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Rank',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUserEntry!.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentUserEntry!.points}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.military_tech,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentUserEntry!.badgeCount} badges',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    if (_globalLeaderboard.length < 3) return const SizedBox.shrink();

    final top3 = _globalLeaderboard.take(3).toList();
    // Reorder: 2nd, 1st, 3rd
    final displayOrder = [
      if (top3.length > 1) top3[1], // 2nd place
      top3[0], // 1st place
      if (top3.length > 2) top3[2], // 3rd place
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: displayOrder.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _TopThreeCard(
              entry: entry,
              isCurrentUser: entry.userId == widget.currentUserId,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    final remainingEntries = _globalLeaderboard.length > 3
        ? _globalLeaderboard.sublist(3)
        : <LeaderboardEntry>[];

    if (remainingEntries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No more entries',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: remainingEntries.length,
      itemBuilder: (context, index) {
        final entry = remainingEntries[index];
        final isCurrentUser = entry.userId == widget.currentUserId;
        return _LeaderboardListItem(
          entry: entry,
          isCurrentUser: isCurrentUser,
        );
      },
    );
  }
}

class _TopThreeCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _TopThreeCard({
    required this.entry,
    required this.isCurrentUser,
  });

  Color get _medalColor {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  IconData get _crownIcon {
    switch (entry.rank) {
      case 1:
        return Icons.workspace_premium;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  double get _cardHeight {
    switch (entry.rank) {
      case 1:
        return 180;
      case 2:
        return 160;
      case 3:
        return 160;
      default:
        return 150;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: _cardHeight,
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : _medalColor,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Medal/Crown
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _medalColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_crownIcon, size: 32, color: _medalColor),
              ),
              if (entry.rank == 1)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, size: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // User name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              entry.userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isCurrentUser ? AppColors.primary : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _medalColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${entry.points} pts',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _medalColor,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Badge count
          Text(
            '${entry.badgeCount} 🏅',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardListItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardListItem({
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : Colors.grey[200]!,
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColors.primary
                  : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCurrentUser ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isCurrentUser ? AppColors.primary : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.military_tech, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.badgeCount} badges',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars, color: AppColors.warning, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.points}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'points',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
