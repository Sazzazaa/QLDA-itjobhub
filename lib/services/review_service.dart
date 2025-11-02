import 'package:itjobhub/models/review_model.dart';
import 'package:itjobhub/services/api_client.dart';

/// Review Service
/// 
/// Singleton service to manage company and candidate reviews
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final ApiClient _apiClient = ApiClient();

  // Storage
  final List<CompanyReview> _companyReviews = [];
  final List<CandidateReview> _candidateReviews = [];
  
  bool _isInitialized = false;

  /// Initialize service
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  // ============ COMPANY REVIEWS ============

  /// Get all company reviews
  Future<List<CompanyReview>> getAllCompanyReviews() async {
    if (_companyReviews.isEmpty) {
      // Could fetch all reviews here if needed
    }
    return List.unmodifiable(_companyReviews);
  }

  /// Get reviews for specific company from API
  Future<List<CompanyReview>> fetchCompanyReviews(String companyId) async {
    print('📥 ReviewService: Fetching company reviews for $companyId');
    
    try {
      final response = await _apiClient.get(
        '/reviews?revieweeId=$companyId&revieweeRole=employer',
      );
      
      final List<dynamic> reviewsJson = response as List<dynamic>;
      final reviews = reviewsJson.map((json) {
        return CompanyReview(
          id: json['_id'],
          companyId: json['revieweeId'],
          companyName: json['revieweeName'],
          reviewerId: json['reviewerId'],
          reviewerName: json['reviewerName'],
          isAnonymous: false, // Could add to backend
          isCurrentEmployee: false, // Could add to backend
          overallRating: (json['overallRating'] as num).toDouble(),
          cultureRating: json['cultureRating'] != null 
              ? (json['cultureRating'] as num).toDouble() 
              : 3.0,
          compensationRating: json['compensationRating'] != null 
              ? (json['compensationRating'] as num).toDouble() 
              : 3.0,
          workLifeBalanceRating: json['workLifeBalanceRating'] != null 
              ? (json['workLifeBalanceRating'] as num).toDouble() 
              : 3.0,
          managementRating: json['managementRating'] != null 
              ? (json['managementRating'] as num).toDouble() 
              : 3.0,
          title: json['reviewTitle'],
          reviewText: json['reviewText'],
          createdAt: DateTime.parse(json['createdAt']),
          helpfulCount: 0,
          helpfulUserIds: [],
        );
      }).toList();
      
      print('✅ ReviewService: Loaded ${reviews.length} company reviews');
      
      // Update cache
      _companyReviews.removeWhere((r) => r.companyId == companyId);
      _companyReviews.addAll(reviews);
      
      return reviews;
    } catch (e) {
      print('❌ ReviewService: Failed to fetch company reviews - $e');
      return [];
    }
  }

  /// Get reviews for specific company (from cache)
  List<CompanyReview> getCompanyReviews(String companyId) {
    return _companyReviews.where((r) => r.companyId == companyId).toList();
  }

  /// Get company review statistics
  ReviewStatistics getCompanyReviewStatistics(String companyId) {
    final reviews = getCompanyReviews(companyId);
    
    if (reviews.isEmpty) {
      return ReviewStatistics(
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        recommendPercentage: 0,
      );
    }

    // Calculate average rating
    final avgRating = reviews.fold<double>(
          0, (sum, r) => sum + r.overallRating) / reviews.length;

    // Calculate rating distribution
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      final starRating = review.overallRating.round();
      distribution[starRating] = (distribution[starRating] ?? 0) + 1;
    }

    // Calculate recommend percentage (4+ stars)
    final recommendCount = reviews.where((r) => r.overallRating >= 4.0).length;
    final recommendPercentage = ((recommendCount / reviews.length) * 100).round();

    return ReviewStatistics(
      averageRating: avgRating,
      totalReviews: reviews.length,
      ratingDistribution: distribution,
      recommendPercentage: recommendPercentage,
    );
  }

  /// Sort company reviews
  List<CompanyReview> sortCompanyReviews(
    List<CompanyReview> reviews,
    ReviewSortOption sortOption,
  ) {
    final sorted = List<CompanyReview>.from(reviews);
    
    switch (sortOption) {
      case ReviewSortOption.mostRecent:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReviewSortOption.highestRated:
        sorted.sort((a, b) => b.overallRating.compareTo(a.overallRating));
        break;
      case ReviewSortOption.lowestRated:
        sorted.sort((a, b) => a.overallRating.compareTo(b.overallRating));
        break;
      case ReviewSortOption.mostHelpful:
        sorted.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
    }
    
    return sorted;
  }

  /// Filter company reviews by rating
  List<CompanyReview> filterCompanyReviewsByRating(
    List<CompanyReview> reviews,
    int? minStars,
  ) {
    if (minStars == null) return reviews;
    return reviews.where((r) => r.overallRating >= minStars).toList();
  }

  /// Add company review
  Future<void> addCompanyReview(CompanyReview review) async {
    print('📝 ReviewService: Submitting company review...');
    
    await _apiClient.post(
      '/reviews',
      {
        'revieweeId': review.companyId,
        'revieweeName': review.companyName,
        'revieweeRole': 'employer',
        'companyName': review.companyName,
        'jobTitle': 'N/A', // Not applicable for company reviews
        'overallRating': review.overallRating,
        'cultureRating': review.cultureRating,
        'compensationRating': review.compensationRating,
        'workLifeBalanceRating': review.workLifeBalanceRating,
        'managementRating': review.managementRating,
        'reviewTitle': review.title,
        'reviewText': review.reviewText,
      },
    );
    
    print('✅ ReviewService: Company review submitted successfully');
    
    // Add to local cache
    _companyReviews.add(review);
  }

  /// Mark review as helpful
  Future<void> markReviewHelpful(String reviewId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _companyReviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      final review = _companyReviews[index];
      if (!review.isHelpfulBy(userId)) {
        final updatedHelpfulIds = List<String>.from(review.helpfulUserIds)..add(userId);
        _companyReviews[index] = review.copyWith(
          helpfulCount: review.helpfulCount + 1,
          helpfulUserIds: updatedHelpfulIds,
        );
      }
    }
  }

  /// Remove helpful mark
  Future<void> unmarkReviewHelpful(String reviewId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _companyReviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      final review = _companyReviews[index];
      if (review.isHelpfulBy(userId)) {
        final updatedHelpfulIds = List<String>.from(review.helpfulUserIds)..remove(userId);
        _companyReviews[index] = review.copyWith(
          helpfulCount: review.helpfulCount - 1,
          helpfulUserIds: updatedHelpfulIds,
        );
      }
    }
  }

  // ============ CANDIDATE REVIEWS ============

  /// Get all candidate reviews
  List<CandidateReview> getAllCandidateReviews() => List.unmodifiable(_candidateReviews);

  /// Get reviews for specific candidate
  List<CandidateReview> getCandidateReviews(String candidateId) {
    return _candidateReviews.where((r) => r.candidateId == candidateId).toList();
  }

  /// Get candidate review statistics
  ReviewStatistics getCandidateReviewStatistics(String candidateId) {
    final reviews = getCandidateReviews(candidateId);
    
    if (reviews.isEmpty) {
      return ReviewStatistics(
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        recommendPercentage: 0,
      );
    }

    // Calculate average rating
    final avgRating = reviews.fold<double>(
          0, (sum, r) => sum + r.overallRating) / reviews.length;

    // Calculate rating distribution
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      final starRating = review.overallRating.round();
      distribution[starRating] = (distribution[starRating] ?? 0) + 1;
    }

    // Calculate recommend percentage (would work again)
    final recommendCount = reviews.where((r) => r.wouldWorkAgain).length;
    final recommendPercentage = reviews.isEmpty 
        ? 0 
        : ((recommendCount / reviews.length) * 100).round();

    return ReviewStatistics(
      averageRating: avgRating,
      totalReviews: reviews.length,
      ratingDistribution: distribution,
      recommendPercentage: recommendPercentage,
    );
  }

  /// Add candidate review
  Future<void> addCandidateReview(CandidateReview review) async {
    print('📝 ReviewService: Submitting candidate review...');
    
    await _apiClient.post(
      '/reviews',
      {
        'revieweeId': review.candidateId,
        'revieweeName': review.candidateName,
        'revieweeRole': 'candidate',
        'companyName': review.companyName,
        'jobTitle': review.jobTitle,
        'overallRating': review.overallRating,
        'skillsRating': review.skillsRating,
        'communicationRating': review.communicationRating,
        'professionalismRating': review.professionalismRating,
        'punctualityRating': review.punctualityRating,
        'reviewText': review.reviewText,
        'wouldWorkAgain': review.wouldWorkAgain,
      },
    );
    
    print('✅ ReviewService: Review submitted successfully');
    
    // Optionally add to local cache
    _candidateReviews.add(review);
  }

  /// Get reviews for specific candidate from API
  Future<List<CandidateReview>> fetchCandidateReviews(String candidateId) async {
    print('📥 ReviewService: Fetching reviews for candidate $candidateId');
    
    final response = await _apiClient.get(
      '/reviews?revieweeId=$candidateId&revieweeRole=candidate',
    );
    
    final List<dynamic> reviewsJson = response as List<dynamic>;
    final reviews = reviewsJson.map((json) {
      return CandidateReview(
        id: json['_id'],
        candidateId: json['revieweeId'],
        candidateName: json['revieweeName'],
        employerId: json['reviewerId'],
        employerName: json['reviewerName'],
        companyName: json['companyName'],
        jobTitle: json['jobTitle'],
        overallRating: (json['overallRating'] as num).toDouble(),
        skillsRating: json['skillsRating'] != null 
            ? (json['skillsRating'] as num).toDouble() 
            : 0.0,
        communicationRating: json['communicationRating'] != null 
            ? (json['communicationRating'] as num).toDouble() 
            : 0.0,
        professionalismRating: json['professionalismRating'] != null 
            ? (json['professionalismRating'] as num).toDouble() 
            : 0.0,
        punctualityRating: json['punctualityRating'] != null 
            ? (json['punctualityRating'] as num).toDouble() 
            : 0.0,
        reviewText: json['reviewText'],
        wouldWorkAgain: json['wouldWorkAgain'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );
    }).toList();
    
    print('✅ ReviewService: Loaded ${reviews.length} reviews');
    
    // Update cache
    _candidateReviews.clear();
    _candidateReviews.addAll(reviews);
    
    return reviews;
  }

  /// Check if user has reviewed a company
  bool hasReviewedCompany(String userId, String companyId) {
    return _companyReviews.any(
      (r) => r.reviewerId == userId && r.companyId == companyId,
    );
  }

  /// Check if employer has reviewed a candidate
  bool hasReviewedCandidate(String employerId, String candidateId) {
    return _candidateReviews.any(
      (r) => r.employerId == employerId && r.candidateId == candidateId,
    );
  }
}
