import '../models/application_model.dart';
import '../core/constants/app_constants.dart';
import 'api_client.dart';

/// Service to manage job applications
class ApplicationService {
  static final ApplicationService _instance = ApplicationService._internal();
  factory ApplicationService() => _instance;
  ApplicationService._internal();

  final ApiClient _apiClient = ApiClient();
  List<Application> _applications = [];

  /// Fetch all applications for current user
  Future<List<Application>> fetchApplications() async {
    print('📋 ApplicationService: Fetching applications...');
    
    try {
      final response = await _apiClient.get('/applications');
      print('✅ ApplicationService: Received ${(response as List).length} applications');
      
      _applications = response
          .map((json) => Application.fromJson(json))
          .toList();
      
      return _applications;
    } catch (e) {
      print('❌ ApplicationService: Failed to fetch - $e');
      _applications = [];
      return _applications;
    }
  }

  /// Submit a new job application
  Future<Application> submitApplication({
    required String jobId,
    required String coverLetter,
    String? cvUrl,
    String? cvId,
    String? additionalInfo,
  }) async {
    print('📋 ApplicationService: Submitting application for job $jobId');
    
    try {
      final data = {
        'jobId': jobId,
        'coverLetter': coverLetter,
      };
      
      // Add optional fields only if they have values
      if (cvUrl != null && cvUrl.isNotEmpty) {
        data['cvUrl'] = cvUrl;
      }
      if (cvId != null && cvId.isNotEmpty) {
        data['cvId'] = cvId;
      }
      if (additionalInfo != null && additionalInfo.isNotEmpty) {
        data['additionalInfo'] = additionalInfo;
      }
      
      final response = await _apiClient.post('/applications', data);
      
      print('✅ ApplicationService: Application submitted successfully');
      final application = Application.fromJson(response);
      
      // Add to local cache
      _applications.add(application);
      
      return application;
    } catch (e) {
      print('❌ ApplicationService: Submit failed - $e');
      rethrow;
    }
  }

  /// Withdraw an application
  Future<void> withdrawApplication(String applicationId) async {
    print('📋 ApplicationService: Withdrawing application $applicationId');
    
    try {
      await _apiClient.put('/applications/$applicationId/withdraw', {});
      print('✅ ApplicationService: Application withdrawn');
      
      // Update local cache - set to rejected since withdrawn doesn't exist
      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(
          status: ApplicationStatus.rejected,
        );
      }
    } catch (e) {
      print('❌ ApplicationService: Withdraw failed - $e');
      rethrow;
    }
  }

  /// Update application status (for employers)
  Future<Application> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? note,
  }) async {
    print('📋 ApplicationService: Updating application $applicationId to $status');
    
    try {
      final response = await _apiClient.put('/applications/$applicationId/status', {
        'status': status,
        if (note != null) 'note': note,
      });
      
      print('✅ ApplicationService: Application status updated');
      final application = Application.fromJson(response);
      
      // Update local cache
      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        _applications[index] = application;
      }
      
      return application;
    } catch (e) {
      print('❌ ApplicationService: Update status failed - $e');
      rethrow;
    }
  }

  /// Delete application (for employers when rejecting)
  Future<void> deleteApplication(String applicationId) async {
    print('📋 ApplicationService: Deleting application $applicationId');
    
    try {
      await _apiClient.delete('/applications/$applicationId');
      print('✅ ApplicationService: Application deleted');
      
      // Remove from local cache
      _applications.removeWhere((a) => a.id == applicationId);
    } catch (e) {
      print('❌ ApplicationService: Delete failed - $e');
      rethrow;
    }
  }

  /// Get cached applications
  List<Application> getCachedApplications() => List.from(_applications);

  /// Clear cache
  void clearCache() {
    _applications.clear();
  }
}
