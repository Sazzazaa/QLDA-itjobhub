import 'api_client.dart';
import '../services/user_state.dart';

/// User Profile Service
/// Manages user profile data and updates (both candidate and employer)
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final ApiClient _apiClient = ApiClient();
  final UserState _userState = UserState();
  
  Map<String, dynamic>? _currentProfile;

  /// Fetch current user profile from API
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      print('👤 UserProfileService: Fetching profile from API...');
      final response = await _apiClient.get('/users/profile');
      
      _currentProfile = response;
      print('✅ UserProfileService: Profile loaded - ${response['name']}');
      
      return response;
    } catch (e) {
      print('❌ UserProfileService: Failed to fetch profile - $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    try {
      print('📝 UserProfileService: Updating profile...');
      print('📝 Updates: $updates');
      
      final response = await _apiClient.put('/users/profile', updates);
      
      _currentProfile = response;
      print('✅ UserProfileService: Profile updated successfully');
      
      // Update UserState name if changed
      if (updates['name'] != null) {
        await _userState.updateProfile(name: updates['name']);
      }
      
      return response;
    } catch (e) {
      print('❌ UserProfileService: Failed to update profile - $e');
      rethrow;
    }
  }

  /// Get cached profile (without API call)
  Map<String, dynamic>? getCachedProfile() {
    return _currentProfile;
  }

  /// Clear cached profile
  void clearCache() {
    _currentProfile = null;
  }
}
