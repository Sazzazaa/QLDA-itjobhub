import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/badge_model.dart';
import 'package:itjobhub/services/badge_service.dart';

/// Badges Screen
/// Displays all user badges, earned and locked
class BadgesScreen extends StatefulWidget {
  final String userId;

  const BadgesScreen({super.key, required this.userId});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final BadgeService _badgeService = BadgeService();
  List<UserBadge> _allBadges = [];
  List<UserBadge> _filteredBadges = [];
  BadgeCategory? _selectedCategory;
  bool _showOnlyEarned = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _badgeService.initialize();
    _loadBadges();
  }

  void _loadBadges() {
    setState(() => _isLoading = true);
    _allBadges = _badgeService.getUserBadges(widget.userId);
    _filterBadges();
    setState(() => _isLoading = false);
  }

  void _filterBadges() {
    setState(() {
      _filteredBadges = _allBadges.where((userBadge) {
        final matchesCategory = _selectedCategory == null ||
            userBadge.badge.category == _selectedCategory;
        final matchesEarned = !_showOnlyEarned || userBadge.isEarned;
        return matchesCategory && matchesEarned;
      }).toList();
    });
  }

  int get _earnedCount => _allBadges.where((b) => b.isEarned).length;
  int get _totalPoints => _badgeService.getUserPoints(widget.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Badges'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsHeader(),
                _buildFilters(),
                Expanded(
                  child: _filteredBadges.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredBadges.length,
                          itemBuilder: (context, index) {
                            return _BadgeCard(
                              userBadge: _filteredBadges[index],
                              onTap: () => _showBadgeDetail(_filteredBadges[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.military_tech,
            label: 'Earned',
            value: '$_earnedCount/${_allBadges.length}',
            color: AppColors.success,
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _StatItem(
            icon: Icons.stars,
            label: 'Points',
            value: _totalPoints.toString(),
            color: AppColors.warning,
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _StatItem(
            icon: Icons.trending_up,
            label: 'Progress',
            value:
                '${((_earnedCount / _allBadges.length) * 100).toStringAsFixed(0)}%',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Filter by:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              FilterChip(
                label: const Text('Earned Only'),
                selected: _showOnlyEarned,
                onSelected: (selected) {
                  setState(() => _showOnlyEarned = selected);
                  _filterBadges();
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    _filterBadges();
                  },
                ),
                const SizedBox(width: 8),
                ...BadgeCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: category.displayName,
                      isSelected: _selectedCategory == category,
                      onTap: () {
                        setState(() => _selectedCategory = category);
                        _filterBadges();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.military_tech_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No badges match your filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filter settings',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(UserBadge userBadge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BadgeDetailSheet(userBadge: userBadge),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final UserBadge userBadge;
  final VoidCallback onTap;

  const _BadgeCard({
    required this.userBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEarned = userBadge.isEarned;
    final badge = userBadge.badge;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEarned
                ? badge.tier.color.withValues(alpha: 0.5)
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            if (isEarned)
              BoxShadow(
                color: badge.tier.color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isEarned
                    ? badge.tier.color.withValues(alpha: 0.2)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 36,
                color: isEarned ? badge.tier.color : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12),

            // Badge Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                badge.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isEarned ? Colors.black87 : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),

            // Tier Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isEarned
                    ? badge.tier.color.withValues(alpha: 0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.tier.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isEarned ? badge.tier.color : Colors.grey[500],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Progress or Points
            if (isEarned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      '${badge.points} pts',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              )
            else if (userBadge.isInProgress)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: userBadge.progressPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(badge.tier.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${userBadge.currentProgress}/${userBadge.targetProgress}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  final UserBadge userBadge;

  const _BadgeDetailSheet({required this.userBadge});

  @override
  Widget build(BuildContext context) {
    final badge = userBadge.badge;
    final isEarned = userBadge.isEarned;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Badge Icon (larger)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isEarned
                  ? badge.tier.color.withValues(alpha: 0.2)
                  : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              size: 50,
              color: isEarned ? badge.tier.color : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),

          // Badge Name
          Text(
            badge.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Tier
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: badge.tier.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${badge.tier.displayName} • ${badge.points} Points',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: badge.tier.color,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Requirement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Requirement',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  badge.requirement,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress or Status
          if (isEarned)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Earned!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      if (userBadge.earnedAt != null)
                        Text(
                          'On ${userBadge.earnedAt!.toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${userBadge.currentProgress}/${userBadge.targetProgress}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: userBadge.progressPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(badge.tier.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${userBadge.remainingProgress} more to go!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
