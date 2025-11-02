import '../models/job_model.dart';
import 'api_client.dart';

/// Service to manage job state and API interactions
class JobService {
  static final JobService _instance = JobService._internal();
  factory JobService() => _instance;
  JobService._internal();

  final ApiClient _apiClient = ApiClient();
  
  // Store all jobs
  List<Job> _allJobs = [];
  
  // Listeners for bookmark changes
  final List<Function()> _bookmarkListeners = [];

  /// Fetch jobs from API with optional filters
  Future<List<Job>> fetchJobs({
    String? skills,
    String? location,
    String? jobType,
    String? experienceLevel,
  }) async {
    print('🔍 JobService: Fetching jobs from API...');
    
    try {
      String endpoint = '/jobs';
      
      // Build query parameters
      final params = <String, String>{};
      if (skills != null && skills.isNotEmpty) params['skills'] = skills;
      if (location != null && location.isNotEmpty) params['location'] = location;
      if (jobType != null && jobType.isNotEmpty) params['jobType'] = jobType;
      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        params['experienceLevel'] = experienceLevel;
      }

      if (params.isNotEmpty) {
        endpoint += '?' + params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }

      print('🔍 JobService: Calling GET $endpoint');
      final response = await _apiClient.get(endpoint);
      
      if (response is! List) {
        print('❌ JobService: Invalid response type: ${response.runtimeType}');
        throw Exception('Invalid API response format');
      }
      
      print('✅ JobService: Received ${response.length} jobs from API');
      
      _allJobs = response.map((json) => Job.fromJson(json)).toList();
      _notifyListeners();
      
      print('✅ JobService: Jobs stored successfully: ${_allJobs.map((j) => j.companyName).take(3).toList()}');
      return _allJobs;
    } catch (e) {
      print('❌ JobService: API call failed - $e');
      print('⚠️ JobService: FALLBACK to mock data');
      
      // DO NOT use mock data in production!
      // For now, only use if cache is empty
      if (_allJobs.isEmpty) {
        print('📦 JobService: Loading mock data as fallback');
        _allJobs = Job.getMockJobs();
      } else {
        print('📦 JobService: Using cached jobs (${_allJobs.length} jobs)');
      }
      return _allJobs;
    }
  }

  /// Get job recommendations for current user
  Future<List<Job>> getRecommendations() async {
    try {
      final response = await _apiClient.get('/jobs/recommendations');
      return (response as List).map((json) => Job.fromJson(json)).toList();
    } catch (e) {
      // Return filtered jobs from cache
      return _allJobs.take(5).toList();
    }
  }

  /// Get jobs posted by current employer
  Future<List<Job>> fetchMyJobs() async {
    print('💼 JobService: Fetching employer\'s jobs from API...');
    
    try {
      final response = await _apiClient.get('/jobs/my-jobs');
      
      if (response is! List) {
        print('❌ JobService: Invalid response type: ${response.runtimeType}');
        throw Exception('Invalid API response format');
      }
      
      print('✅ JobService: Received ${response.length} employer jobs from API');
      final jobs = response.map((json) => Job.fromJson(json)).toList();
      
      return jobs;
    } catch (e) {
      print('❌ JobService: Failed to fetch employer jobs - $e');
      rethrow;
    }
  }

  /// Initialize jobs (call once when app starts or when loading jobs)
  void initializeJobs(List<Job> jobs) {
    _allJobs = jobs;
    _notifyListeners();
  }

  /// Get all jobs (returns cached data, call fetchJobs() to refresh)
  List<Job> getAllJobs() {
    if (_allJobs.isEmpty) {
      _allJobs = Job.getMockJobs();
    }
    return List.from(_allJobs);
  }

  /// Get saved/bookmarked jobs
  List<Job> getSavedJobs() {
    return _allJobs.where((job) => job.isBookmarked).toList();
  }

  /// Toggle bookmark for a job
  void toggleBookmark(String jobId) {
    final index = _allJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _allJobs[index] = _allJobs[index].copyWith(
        isBookmarked: !_allJobs[index].isBookmarked,
      );
      _notifyListeners();
    }
  }

  /// Add a bookmark listener
  void addBookmarkListener(Function() listener) {
    _bookmarkListeners.add(listener);
  }

  /// Remove a bookmark listener
  void removeBookmarkListener(Function() listener) {
    _bookmarkListeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (var listener in _bookmarkListeners) {
      listener();
    }
  }

  /// Clear all bookmarks
  void clearAllBookmarks() {
    for (int i = 0; i < _allJobs.length; i++) {
      if (_allJobs[i].isBookmarked) {
        _allJobs[i] = _allJobs[i].copyWith(isBookmarked: false);
      }
    }
    _notifyListeners();
  }

  /// Get a single job by ID (from cache or API)
  Future<Job?> getJobById(String jobId) async {
    // Try from cache first
    try {
      return _allJobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      // Fetch from API if not in cache
      try {
        final response = await _apiClient.get('/jobs/$jobId');
        return Job.fromJson(response);
      } catch (apiError) {
        return null;
      }
    }
  }

  /// Increment job views
  Future<void> incrementViews(String jobId) async {
    try {
      await _apiClient.post('/jobs/$jobId/increment-views', {});
    } catch (e) {
      // Silently fail
    }
  }

  /// Create job posting (Employer only)
  Future<Job> createJob(Map<String, dynamic> jobData) async {
    print('📤 JobService: Creating new job...');
    print('📤 JobService: Job data: ${jobData.keys.toList()}');
    
    try {
      final response = await _apiClient.post('/jobs', jobData);
      print('✅ JobService: Job created successfully: ${response['id']}');
      
      final job = Job.fromJson(response);
      _allJobs.insert(0, job);
      _notifyListeners();
      
      return job;
    } catch (e) {
      print('❌ JobService: Failed to create job - $e');
      rethrow;
    }
  }

  /// Update job posting
  Future<Job?> updateJob(String jobId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/jobs/$jobId', updates);
      final updatedJob = Job.fromJson(response);
      
      final index = _allJobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _allJobs[index] = updatedJob;
        _notifyListeners();
      }
      
      return updatedJob;
    } catch (e) {
      return null;
    }
  }

  /// Delete job posting
  Future<bool> deleteJob(String jobId) async {
    try {
      await _apiClient.delete('/jobs/$jobId');
      _allJobs.removeWhere((job) => job.id == jobId);
      _notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
