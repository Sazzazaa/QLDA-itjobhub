import 'package:intl/intl.dart';

/// Company Review Model
/// 
/// Represents a review of a company by a candidate
class CompanyReview {
  final String id;
  final String companyId;
  final String companyName;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatar;
  final bool isAnonymous;
  final bool isCurrentEmployee;
  final double overallRating;
  final double cultureRating;
  final double compensationRating;
  final double workLifeBalanceRating;
  final double managementRating;
  final String? title;
  final String reviewText;
  final String? pros;
  final String? cons;
  final String? adviceToManagement;
  final DateTime createdAt;
  final int helpfulCount;
  final List<String> helpfulUserIds; // Users who marked as helpful

  CompanyReview({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatar,
    this.isAnonymous = false,
    this.isCurrentEmployee = false,
    required this.overallRating,
    required this.cultureRating,
    required this.compensationRating,
    required this.workLifeBalanceRating,
    required this.managementRating,
    this.title,
    required this.reviewText,
    this.pros,
    this.cons,
    this.adviceToManagement,
    required this.createdAt,
    this.helpfulCount = 0,
    this.helpfulUserIds = const [],
  });

  // Calculate average of category ratings
  double get averageCategoryRating {
    return (cultureRating + compensationRating + workLifeBalanceRating + managementRating) / 4;
  }

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(createdAt);
    }
  }

  // Display name (Anonymous if review is anonymous)
  String get displayName => isAnonymous ? 'Anonymous' : reviewerName;

  // Check if user found this helpful
  bool isHelpfulBy(String userId) => helpfulUserIds.contains(userId);

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'companyName': companyName,
        'reviewerId': reviewerId,
        'reviewerName': reviewerName,
        'reviewerAvatar': reviewerAvatar,
        'isAnonymous': isAnonymous,
        'isCurrentEmployee': isCurrentEmployee,
        'overallRating': overallRating,
        'cultureRating': cultureRating,
        'compensationRating': compensationRating,
        'workLifeBalanceRating': workLifeBalanceRating,
        'managementRating': managementRating,
        'title': title,
        'reviewText': reviewText,
        'pros': pros,
        'cons': cons,
        'adviceToManagement': adviceToManagement,
        'createdAt': createdAt.toIso8601String(),
        'helpfulCount': helpfulCount,
        'helpfulUserIds': helpfulUserIds,
      };

  factory CompanyReview.fromJson(Map<String, dynamic> json) => CompanyReview(
        id: json['id'],
        companyId: json['companyId'],
        companyName: json['companyName'],
        reviewerId: json['reviewerId'],
        reviewerName: json['reviewerName'],
        reviewerAvatar: json['reviewerAvatar'],
        isAnonymous: json['isAnonymous'] ?? false,
        isCurrentEmployee: json['isCurrentEmployee'] ?? false,
        overallRating: json['overallRating'].toDouble(),
        cultureRating: json['cultureRating'].toDouble(),
        compensationRating: json['compensationRating'].toDouble(),
        workLifeBalanceRating: json['workLifeBalanceRating'].toDouble(),
        managementRating: json['managementRating'].toDouble(),
        title: json['title'],
        reviewText: json['reviewText'],
        pros: json['pros'],
        cons: json['cons'],
        adviceToManagement: json['adviceToManagement'],
        createdAt: DateTime.parse(json['createdAt']),
        helpfulCount: json['helpfulCount'] ?? 0,
        helpfulUserIds: List<String>.from(json['helpfulUserIds'] ?? []),
      );

  CompanyReview copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? reviewerId,
    String? reviewerName,
    String? reviewerAvatar,
    bool? isAnonymous,
    bool? isCurrentEmployee,
    double? overallRating,
    double? cultureRating,
    double? compensationRating,
    double? workLifeBalanceRating,
    double? managementRating,
    String? title,
    String? reviewText,
    String? pros,
    String? cons,
    String? adviceToManagement,
    DateTime? createdAt,
    int? helpfulCount,
    List<String>? helpfulUserIds,
  }) {
    return CompanyReview(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerAvatar: reviewerAvatar ?? this.reviewerAvatar,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isCurrentEmployee: isCurrentEmployee ?? this.isCurrentEmployee,
      overallRating: overallRating ?? this.overallRating,
      cultureRating: cultureRating ?? this.cultureRating,
      compensationRating: compensationRating ?? this.compensationRating,
      workLifeBalanceRating: workLifeBalanceRating ?? this.workLifeBalanceRating,
      managementRating: managementRating ?? this.managementRating,
      title: title ?? this.title,
      reviewText: reviewText ?? this.reviewText,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      adviceToManagement: adviceToManagement ?? this.adviceToManagement,
      createdAt: createdAt ?? this.createdAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUserIds: helpfulUserIds ?? this.helpfulUserIds,
    );
  }
}

/// Candidate Review Model
/// 
/// Represents a review of a candidate by an employer
class CandidateReview {
  final String id;
  final String candidateId;
  final String candidateName;
  final String? candidateAvatar;
  final String employerId;
  final String employerName;
  final String companyName;
  final String jobTitle;
  final double overallRating;
  final double skillsRating;
  final double communicationRating;
  final double professionalismRating;
  final double punctualityRating;
  final String reviewText;
  final bool wouldWorkAgain;
  final DateTime createdAt;

  CandidateReview({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    this.candidateAvatar,
    required this.employerId,
    required this.employerName,
    required this.companyName,
    required this.jobTitle,
    required this.overallRating,
    required this.skillsRating,
    required this.communicationRating,
    required this.professionalismRating,
    required this.punctualityRating,
    required this.reviewText,
    this.wouldWorkAgain = false,
    required this.createdAt,
  });

  // Calculate average of category ratings
  double get averageCategoryRating {
    return (skillsRating + communicationRating + professionalismRating + punctualityRating) / 4;
  }

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(createdAt);
    }
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'candidateId': candidateId,
        'candidateName': candidateName,
        'candidateAvatar': candidateAvatar,
        'employerId': employerId,
        'employerName': employerName,
        'companyName': companyName,
        'jobTitle': jobTitle,
        'overallRating': overallRating,
        'skillsRating': skillsRating,
        'communicationRating': communicationRating,
        'professionalismRating': professionalismRating,
        'punctualityRating': punctualityRating,
        'reviewText': reviewText,
        'wouldWorkAgain': wouldWorkAgain,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CandidateReview.fromJson(Map<String, dynamic> json) => CandidateReview(
        id: json['id'],
        candidateId: json['candidateId'],
        candidateName: json['candidateName'],
        candidateAvatar: json['candidateAvatar'],
        employerId: json['employerId'],
        employerName: json['employerName'],
        companyName: json['companyName'],
        jobTitle: json['jobTitle'],
        overallRating: json['overallRating'].toDouble(),
        skillsRating: json['skillsRating'].toDouble(),
        communicationRating: json['communicationRating'].toDouble(),
        professionalismRating: json['professionalismRating'].toDouble(),
        punctualityRating: json['punctualityRating'].toDouble(),
        reviewText: json['reviewText'],
        wouldWorkAgain: json['wouldWorkAgain'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

/// Review Sort Options
enum ReviewSortOption {
  mostRecent,
  highestRated,
  lowestRated,
  mostHelpful;

  String get displayName {
    switch (this) {
      case ReviewSortOption.mostRecent:
        return 'Most Recent';
      case ReviewSortOption.highestRated:
        return 'Highest Rated';
      case ReviewSortOption.lowestRated:
        return 'Lowest Rated';
      case ReviewSortOption.mostHelpful:
        return 'Most Helpful';
    }
  }
}

/// Review Statistics
class ReviewStatistics {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // star -> count
  final int recommendPercentage;

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.recommendPercentage,
  });

  // Get count for specific star rating
  int getCountForRating(int stars) => ratingDistribution[stars] ?? 0;

  // Get percentage for specific star rating
  double getPercentageForRating(int stars) {
    if (totalReviews == 0) return 0;
    return (getCountForRating(stars) / totalReviews) * 100;
  }
}
