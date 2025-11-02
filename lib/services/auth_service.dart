import 'api_client.dart';
import 'user_state.dart';
import '../core/constants/app_constants.dart';

/// Authentication service for login, register, and token management
class AuthService {
  final ApiClient _apiClient = ApiClient();
  final UserState _userState = UserState();

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 AuthService: Attempting login for $email');
      print('📡 API URL: ${AppConstants.baseUrl}/auth/login');
      
      final response = await _apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      print('✅ Login response: $response');

      // Save token
      if (response['access_token'] != null) {
        await _apiClient.setToken(response['access_token']);
        
        // Save user state
        final user = response['user'];
        await _userState.setUser(
          id: user['id'] ?? user['_id'] ?? '',
          email: user['email'] ?? '',
          name: user['name'] ?? '',
          role: user['role'] ?? '',
          token: response['access_token'],
        );
        
        print('✅ User state saved: ${user['name']} (${user['role']})');
      }

      return {
        'success': true,
        'user': response['user'],
        'token': response['access_token'],
      };
    } on ApiException catch (e) {
      print('❌ API Exception: ${e.statusCode} - ${e.message}');
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      print('❌ Unexpected error in login: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role, // 'candidate' or 'employer'
  }) async {
    try {
      print('📝 AuthService: Attempting registration for $email as $role');
      
      final response = await _apiClient.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      });

      print('✅ Registration response: $response');

      // Register successful, but no token returned
      // User needs to login separately
      return {
        'success': true,
        'message': response['message'] ?? 'Registration successful',
        'user': response['user'],
      };
    } on ApiException catch (e) {
      print('❌ Registration API Exception: ${e.statusCode} - ${e.message}');
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      print('❌ Unexpected error in registration: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    await _apiClient.clearToken();
    await _userState.clearUser();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    await _apiClient.loadToken();
    return _apiClient.isAuthenticated;
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/profile');
      return response;
    } catch (e) {
      return null;
    }
  }
}
