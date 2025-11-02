import 'dart:math';
import 'package:flutter/material.dart' hide Badge;
import 'package:itjobhub/models/badge_model.dart';

/// Badge Service
/// Manages badges, user progress, and leaderboards
class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  final List<Badge> _allBadges = [];
  final Map<String, Map<String, UserBadge>> _userBadges = {}; // userId -> badgeId -> UserBadge
  final Map<String, UserStats> _userStats = {};
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _allBadges.addAll(_generateBadges());
    _userStats.addAll(_generateMockUserStats());
    _isInitialized = true;
  }

  // Get all available badges
  List<Badge> getAllBadges() {
    initialize();
    return List.from(_allBadges);
  }

  // Get badges by category
  List<Badge> getBadgesByCategory(BadgeCategory category) {
    initialize();
    return _allBadges.where((badge) => badge.category == category).toList();
  }

  // Get user's badge progress
  List<UserBadge> getUserBadges(String userId) {
    initialize();
    
    // Generate user badges if not exists
    if (!_userBadges.containsKey(userId)) {
      _userBadges[userId] = _generateUserBadgeProgress(userId);
    }
    
    return _userBadges[userId]!.values.toList()
      ..sort((a, b) {
        // Earned first, then by tier
        if (a.isEarned && !b.isEarned) return -1;
        if (!a.isEarned && b.isEarned) return 1;
        return b.badge.tier.points.compareTo(a.badge.tier.points);
      });
  }

  // Get earned badges for user
  List<UserBadge> getEarnedBadges(String userId) {
    return getUserBadges(userId).where((ub) => ub.isEarned).toList();
  }

  // Get user's total points
  int getUserPoints(String userId) {
    return getEarnedBadges(userId).fold(0, (sum, ub) => sum + ub.badge.points);
  }

  // Get user stats
  UserStats? getUserStats(String userId) {
    initialize();
    return _userStats[userId];
  }

  // Get leaderboard with period filter
  List<LeaderboardEntry> getLeaderboard({LeaderboardPeriod period = LeaderboardPeriod.allTime}) {
    initialize();
    
    // For now, period is not used in mock data, but it's available for future implementation
    // In a real app, you'd filter based on period here
    
    final sortedUsers = _userStats.entries.toList()
      ..sort((a, b) => b.value.totalPoints.compareTo(a.value.totalPoints));

    return sortedUsers.asMap().entries.map((entry) {
      final rank = entry.key + 1;
      final user = entry.value.value;
      
      return LeaderboardEntry(
        rank: rank,
        userId: user.userId,
        userName: user.userName,
        userAvatar: user.userAvatar,
        points: user.totalPoints,
        badgeCount: user.badgesEarned,
        category: 'Overall',
      );
    }).toList();
  }

  // Get user's rank
  int? getUserRank(String userId) {
    final leaderboard = getLeaderboard();
    final index = leaderboard.indexWhere((entry) => entry.userId == userId);
    return index >= 0 ? index + 1 : null;
  }

  // ===== Mock Data Generation =====

  List<Badge> _generateBadges() {
    return [
      // Profile Badges
      const Badge(
        id: 'badge_profile_complete',
        name: 'Profile Master',
        description: 'Complete your profile 100%',
        category: BadgeCategory.profile,
        tier: BadgeTier.bronze,
        icon: Icons.person,
        requirement: 'Complete all profile sections',
        requiredCount: 1,
      ),
      const Badge(
        id: 'badge_cv_uploaded',
        name: 'CV Pro',
        description: 'Upload your CV',
        category: BadgeCategory.profile,
        tier: BadgeTier.bronze,
        icon: Icons.description,
        requirement: 'Upload a CV',
        requiredCount: 1,
      ),
      const Badge(
        id: 'badge_skills_10',
        name: 'Skill Collector',
        description: 'Add 10+ skills to your profile',
        category: BadgeCategory.skill,
        tier: BadgeTier.silver,
        icon: Icons.collections,
        requirement: 'Add 10 skills',
        requiredCount: 10,
      ),

      // Job Search Badges
      const Badge(
        id: 'badge_first_application',
        name: 'First Step',
        description: 'Submit your first job application',
        category: BadgeCategory.job,
        tier: BadgeTier.bronze,
        icon: Icons.send,
        requirement: 'Submit 1 application',
        requiredCount: 1,
      ),
      const Badge(
        id: 'badge_applications_10',
        name: 'Job Seeker',
        description: 'Submit 10 job applications',
        category: BadgeCategory.job,
        tier: BadgeTier.silver,
        icon: Icons.work,
        requirement: 'Submit 10 applications',
        requiredCount: 10,
      ),
      const Badge(
        id: 'badge_applications_50',
        name: 'Determined',
        description: 'Submit 50 job applications',
        category: BadgeCategory.job,
        tier: BadgeTier.gold,
        icon: Icons.local_fire_department,
        requirement: 'Submit 50 applications',
        requiredCount: 50,
      ),

      // Interview Badges
      const Badge(
        id: 'badge_first_interview',
        name: 'Interview Ready',
        description: 'Attend your first interview',
        category: BadgeCategory.interview,
        tier: BadgeTier.silver,
        icon: Icons.event_available,
        requirement: 'Attend 1 interview',
        requiredCount: 1,
      ),
      const Badge(
        id: 'badge_interviews_5',
        name: 'Interview Pro',
        description: 'Complete 5 interviews',
        category: BadgeCategory.interview,
        tier: BadgeTier.gold,
        icon: Icons.star,
        requirement: 'Attend 5 interviews',
        requiredCount: 5,
      ),
      const Badge(
        id: 'badge_interviews_20',
        name: 'Interview Master',
        description: 'Complete 20 interviews',
        category: BadgeCategory.interview,
        tier: BadgeTier.platinum,
        icon: Icons.stars,
        requirement: 'Attend 20 interviews',
        requiredCount: 20,
      ),

      // Community Badges
      const Badge(
        id: 'badge_first_post',
        name: 'Community Member',
        description: 'Create your first forum post',
        category: BadgeCategory.community,
        tier: BadgeTier.bronze,
        icon: Icons.chat,
        requirement: 'Create 1 post',
        requiredCount: 1,
      ),
      const Badge(
        id: 'badge_posts_10',
        name: 'Contributor',
        description: 'Create 10 forum posts',
        category: BadgeCategory.community,
        tier: BadgeTier.silver,
        icon: Icons.forum,
        requirement: 'Create 10 posts',
        requiredCount: 10,
      ),
      const Badge(
        id: 'badge_comments_50',
        name: 'Helpful',
        description: 'Write 50 comments on forum',
        category: BadgeCategory.community,
        tier: BadgeTier.gold,
        icon: Icons.thumb_up,
        requirement: 'Post 50 comments',
        requiredCount: 50,
      ),
      const Badge(
        id: 'badge_upvotes_100',
        name: 'Popular',
        description: 'Receive 100 upvotes on your posts',
        category: BadgeCategory.community,
        tier: BadgeTier.platinum,
        icon: Icons.trending_up,
        requirement: 'Get 100 upvotes',
        requiredCount: 100,
        isSecret: true,
      ),

      // Achievement Badges
      const Badge(
        id: 'badge_early_bird',
        name: 'Early Bird',
        description: 'Join the platform early',
        category: BadgeCategory.achievement,
        tier: BadgeTier.gold,
        icon: Icons.wb_sunny,
        requirement: 'Join in first 6 months',
        requiredCount: 1,
        isSecret: true,
      ),
      const Badge(
        id: 'badge_streak_7',
        name: 'Consistent',
        description: 'Log in for 7 days straight',
        category: BadgeCategory.achievement,
        tier: BadgeTier.silver,
        icon: Icons.calendar_today,
        requirement: '7 day login streak',
        requiredCount: 7,
      ),
      const Badge(
        id: 'badge_streak_30',
        name: 'Dedicated',
        description: 'Log in for 30 days straight',
        category: BadgeCategory.achievement,
        tier: BadgeTier.diamond,
        icon: Icons.whatshot,
        requirement: '30 day login streak',
        requiredCount: 30,
      ),
    ];
  }

  Map<String, UserBadge> _generateUserBadgeProgress(String userId) {
    final random = Random(userId.hashCode);
    final Map<String, UserBadge> badges = {};
    
    for (final badge in _allBadges) {
      // Simulate some earned badges and progress
      final shouldEarn = random.nextDouble() < 0.3; // 30% chance earned
      final progress = shouldEarn 
          ? badge.requiredCount 
          : (random.nextDouble() * badge.requiredCount * 0.8).toInt();
      
      badges[badge.id] = UserBadge(
        badgeId: badge.id,
        badge: badge,
        isEarned: shouldEarn,
        earnedAt: shouldEarn ? DateTime.now().subtract(Duration(days: random.nextInt(60))) : null,
        currentProgress: progress,
        targetProgress: badge.requiredCount,
      );
    }
    
    return badges;
  }

  Map<String, UserStats> _generateMockUserStats() {
    final random = Random();
    final names = [
      'John Doe', 'Sarah Johnson', 'Mike Chen', 'Emma Davis', 'Alex Kumar',
      'Jessica Brown', 'David Lee', 'Rachel Green', 'Tom Wilson', 'Lisa Anderson',
      'Chris Martin', 'Anna Taylor', 'James White', 'Maria Garcia', 'Robert Miller',
    ];

    final Map<String, UserStats> stats = {};
    
    for (int i = 0; i < names.length; i++) {
      final userId = 'user_${i + 1}';
      final badgesEarned = random.nextInt(10) + 2;
      final applicationsSubmitted = random.nextInt(40) + 5;
      final interviewsAttended = random.nextInt(15) + 1;
      final forumPostsCreated = random.nextInt(20);
      final forumCommentsCreated = random.nextInt(50);
      final skillsVerified = random.nextInt(15) + 3;
      
      stats[userId] = UserStats(
        userId: userId,
        userName: names[i],
        totalPoints: badgesEarned * 30 + skillsVerified * 5,
        badgesEarned: badgesEarned,
        profileCompleteness: random.nextInt(30) + 70,
        applicationsSubmitted: applicationsSubmitted,
        interviewsAttended: interviewsAttended,
        forumPostsCreated: forumPostsCreated,
        forumCommentsCreated: forumCommentsCreated,
        skillsVerified: skillsVerified,
      );
    }
    
    return stats;
  }
}
