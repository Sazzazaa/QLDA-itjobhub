import 'package:itjobhub/models/interview_model.dart';
import 'api_client.dart';

/// Interview Service
/// Manages interview data and operations
class InterviewService {
  static final InterviewService _instance = InterviewService._internal();
  factory InterviewService() => _instance;
  InterviewService._internal();

  final ApiClient _apiClient = ApiClient();
  List<Interview> _interviews = [];
  final List<Function()> _listeners = [];

  /// Fetch interviews from API
  Future<List<Interview>> fetchInterviews() async {
    try {
      print('📅 InterviewService: Fetching interviews from API...');
      final response = await _apiClient.get('/interviews');
      
      print('📋 InterviewService: Raw API response: $response');
      print('📋 InterviewService: Response type: ${response.runtimeType}');
      
      if (response is List) {
        print('📋 InterviewService: Response is List with ${response.length} items');
        if (response.isNotEmpty) {
          print('📋 InterviewService: First item: ${response[0]}');
        }
      }
      
      _interviews = (response as List)
          .map((json) => Interview.fromJson(json))
          .toList();
      
      print('✅ InterviewService: Loaded ${_interviews.length} interviews');
      if (_interviews.isNotEmpty) {
        print('📋 InterviewService: First interview: ${_interviews[0].id} - ${_interviews[0].scheduledAt}');
      }
      _notifyListeners();
      return _interviews;
    } catch (e, stackTrace) {
      print('❌ InterviewService: Failed to fetch - $e');
      print('❌ InterviewService: Stack trace: $stackTrace');
      _interviews = []; // Return empty list instead of mock
      return _interviews;
    }
  }

  /// Get all interviews
  List<Interview> getAllInterviews() {
    return List.unmodifiable(_interviews);
  }

  /// Get upcoming interviews
  List<Interview> getUpcomingInterviews() {
    return _interviews
        .where((interview) => 
            interview.status == InterviewStatus.scheduled &&
            interview.scheduledAt.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Get past interviews
  List<Interview> getPastInterviews() {
    return _interviews
        .where((interview) => 
            interview.scheduledAt.isBefore(DateTime.now()) ||
            interview.status == InterviewStatus.completed ||
            interview.status == InterviewStatus.cancelled ||
            interview.status == InterviewStatus.noShow)
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  /// Get interview by ID
  Interview? getInterviewById(String id) {
    try {
      return _interviews.firstWhere((interview) => interview.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get interviews for a specific job
  List<Interview> getInterviewsForJob(String jobId) {
    return _interviews
        .where((interview) => interview.jobId == jobId)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Add a new interview
  void addInterview(Interview interview) {
    _interviews.add(interview);
    _notifyListeners();
  }

  /// Update interview
  void updateInterview(Interview updatedInterview) {
    final index = _interviews.indexWhere((i) => i.id == updatedInterview.id);
    if (index != -1) {
      _interviews[index] = updatedInterview;
      _notifyListeners();
    }
  }

  /// Cancel interview
  void cancelInterview(String interviewId) {
    final interview = getInterviewById(interviewId);
    if (interview != null) {
      final updatedInterview = interview.copyWith(
        status: InterviewStatus.cancelled,
      );
      updateInterview(updatedInterview);
    }
  }

  /// Reschedule interview
  void rescheduleInterview(String interviewId, DateTime newDateTime) {
    final interview = getInterviewById(interviewId);
    if (interview != null) {
      final updatedInterview = interview.copyWith(
        scheduledAt: newDateTime,
        status: InterviewStatus.rescheduled,
      );
      updateInterview(updatedInterview);
    }
  }

  /// Mark interview as completed
  Future<void> completeInterview(String interviewId, {String? feedback}) async {
    try {
      print('✅ InterviewService: Marking interview as completed...');
      await _apiClient.put('/interviews/$interviewId/complete', {
        if (feedback != null) 'feedback': feedback,
      });
      
      // Update local state
      final interview = getInterviewById(interviewId);
      if (interview != null) {
        final updatedInterview = interview.copyWith(
          status: InterviewStatus.completed,
          feedback: feedback,
        );
        updateInterview(updatedInterview);
      }
      
      print('✅ InterviewService: Interview marked as completed');
    } catch (e) {
      print('❌ InterviewService: Failed to complete interview - $e');
      rethrow;
    }
  }

  /// Confirm interview (candidate confirms attendance)
  Future<void> confirmInterview(String interviewId) async {
    try {
      print('✅ InterviewService: Confirming interview...');
      await _apiClient.put('/interviews/$interviewId/confirm', {});
      
      // Update local state
      final interview = getInterviewById(interviewId);
      if (interview != null) {
        final updatedInterview = interview.copyWith(confirmed: true);
        updateInterview(updatedInterview);
      }
      
      print('✅ InterviewService: Interview confirmed');
    } catch (e) {
      print('❌ InterviewService: Failed to confirm interview - $e');
      rethrow;
    }
  }

  /// Mark interview as no-show
  void markAsNoShow(String interviewId) {
    final interview = getInterviewById(interviewId);
    if (interview != null) {
      final updatedInterview = interview.copyWith(
        status: InterviewStatus.noShow,
      );
      updateInterview(updatedInterview);
    }
  }

  /// Delete interview
  void deleteInterview(String interviewId) {
    _interviews.removeWhere((interview) => interview.id == interviewId);
    _notifyListeners();
  }

  /// Get interviews happening today
  List<Interview> getTodayInterviews() {
    final now = DateTime.now();
    return _interviews
        .where((interview) {
          final interviewDate = interview.scheduledAt;
          return interviewDate.year == now.year &&
              interviewDate.month == now.month &&
              interviewDate.day == now.day &&
              interview.status == InterviewStatus.scheduled;
        })
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Get interviews happening within next 24 hours
  List<Interview> getUpcoming24Hours() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(hours: 24));
    return _interviews
        .where((interview) =>
            interview.status == InterviewStatus.scheduled &&
            interview.scheduledAt.isAfter(now) &&
            interview.scheduledAt.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Add listener for changes
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  /// Clear all data (for testing)
  void clear() {
    _interviews.clear();
    _notifyListeners();
  }
}
