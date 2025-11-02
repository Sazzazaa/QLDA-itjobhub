import 'package:flutter/material.dart';

/// Badge Category
enum BadgeCategory {
  profile,
  job,
  interview,
  community,
  skill,
  achievement;

  String get displayName {
    switch (this) {
      case BadgeCategory.profile:
        return 'Profile';
      case BadgeCategory.job:
        return 'Job Search';
      case BadgeCategory.interview:
        return 'Interviews';
      case BadgeCategory.community:
        return 'Community';
      case BadgeCategory.skill:
        return 'Skills';
      case BadgeCategory.achievement:
        return 'Achievements';
    }
  }
}

/// Badge Tier
enum BadgeTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond;

  String get displayName {
    switch (this) {
      case BadgeTier.bronze:
        return 'Bronze';
      case BadgeTier.silver:
        return 'Silver';
      case BadgeTier.gold:
        return 'Gold';
      case BadgeTier.platinum:
        return 'Platinum';
      case BadgeTier.diamond:
        return 'Diamond';
    }
  }

  Color get color {
    switch (this) {
      case BadgeTier.bronze:
        return const Color(0xFFCD7F32);
      case BadgeTier.silver:
        return const Color(0xFFC0C0C0);
      case BadgeTier.gold:
        return const Color(0xFFFFD700);
      case BadgeTier.platinum:
        return const Color(0xFFE5E4E2);
      case BadgeTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  int get points {
    switch (this) {
      case BadgeTier.bronze:
        return 10;
      case BadgeTier.silver:
        return 25;
      case BadgeTier.gold:
        return 50;
      case BadgeTier.platinum:
        return 100;
      case BadgeTier.diamond:
        return 200;
    }
  }
}

/// Badge Model
class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeCategory category;
  final BadgeTier tier;
  final IconData icon;
  final String requirement;
  final int requiredCount; // Number needed to unlock
  final bool isSecret; // Hidden until earned

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tier,
    required this.icon,
    required this.requirement,
    required this.requiredCount,
    this.isSecret = false,
  });

  int get points => tier.points;
}

/// User Badge Progress
class UserBadge {
  final String badgeId;
  final Badge badge;
  final bool isEarned;
  final DateTime? earnedAt;
  final int currentProgress;
  final int targetProgress;

  const UserBadge({
    required this.badgeId,
    required this.badge,
    required this.isEarned,
    this.earnedAt,
    required this.currentProgress,
    required this.targetProgress,
  });

  double get progressPercentage {
    if (targetProgress == 0) return 0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  bool get isInProgress => !isEarned && currentProgress > 0;

  int get remainingProgress => (targetProgress - currentProgress).clamp(0, targetProgress);

  UserBadge copyWith({
    String? badgeId,
    Badge? badge,
    bool? isEarned,
    DateTime? earnedAt,
    int? currentProgress,
    int? targetProgress,
  }) {
    return UserBadge(
      badgeId: badgeId ?? this.badgeId,
      badge: badge ?? this.badge,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
    );
  }
}

/// User Statistics for Rankings
class UserStats {
  final String userId;
  final String userName;
  final String? userAvatar;
  final int totalPoints;
  final int badgesEarned;
  final int profileCompleteness;
  final int applicationsSubmitted;
  final int interviewsAttended;
  final int forumPostsCreated;
  final int forumCommentsCreated;
  final int skillsVerified;

  const UserStats({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.totalPoints,
    required this.badgesEarned,
    required this.profileCompleteness,
    required this.applicationsSubmitted,
    required this.interviewsAttended,
    required this.forumPostsCreated,
    required this.forumCommentsCreated,
    required this.skillsVerified,
  });

  int get activityScore {
    return applicationsSubmitted +
        (interviewsAttended * 2) +
        (forumPostsCreated * 3) +
        forumCommentsCreated;
  }
}

/// Leaderboard Entry
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int points;
  final int badgeCount;
  final String category;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.points,
    required this.badgeCount,
    required this.category,
  });
}

/// Leaderboard Period
enum LeaderboardPeriod {
  daily,
  weekly,
  monthly,
  allTime;

  String get displayName {
    switch (this) {
      case LeaderboardPeriod.daily:
        return 'Today';
      case LeaderboardPeriod.weekly:
        return 'This Week';
      case LeaderboardPeriod.monthly:
        return 'This Month';
      case LeaderboardPeriod.allTime:
        return 'All Time';
    }
  }
}

/// Leaderboard Category
enum LeaderboardCategory {
  overall,
  badges,
  activity,
  skills;

  String get displayName {
    switch (this) {
      case LeaderboardCategory.overall:
        return 'Overall';
      case LeaderboardCategory.badges:
        return 'Most Badges';
      case LeaderboardCategory.activity:
        return 'Most Active';
      case LeaderboardCategory.skills:
        return 'Skills Master';
    }
  }

  String get description {
    switch (this) {
      case LeaderboardCategory.overall:
        return 'Total points earned';
      case LeaderboardCategory.badges:
        return 'Number of badges earned';
      case LeaderboardCategory.activity:
        return 'Applications & community activity';
      case LeaderboardCategory.skills:
        return 'Verified skills count';
    }
  }

  IconData get icon {
    switch (this) {
      case LeaderboardCategory.overall:
        return Icons.emoji_events;
      case LeaderboardCategory.badges:
        return Icons.military_tech;
      case LeaderboardCategory.activity:
        return Icons.trending_up;
      case LeaderboardCategory.skills:
        return Icons.star;
    }
  }
}
