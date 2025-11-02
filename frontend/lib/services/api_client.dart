import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Centralized API client for making HTTP requests
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;
  bool _isInitialized = false;
  
  /// Initialize and load token from storage
  Future<void> init() async {
    if (!_isInitialized) {
      await loadToken();
      _isInitialized = true;
    }
  }

  /// Set authentication token
  Future<void> setToken(String token) async {
    _token = token;
    _isInitialized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, token);
  }

  /// Load token from storage
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.authTokenKey);
    _isInitialized = true;
    print('🔑 ApiClient: Token loaded: ${_token != null ? "Yes (${_token!.substring(0, 20)}...)" : "No"}');
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
  }

  /// Get current token
  String? get token => _token;

  /// Check if user is authenticated
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Get headers with authentication
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// GET request
  Future<dynamic> get(String endpoint) async {
    // Ensure token is loaded before making request
    await init();
    
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('📤 GET: $url');
      print('🔑 Headers: $_headers');
      
      final response = await http
          .get(url, headers: _headers)
          .timeout(AppConstants.apiTimeout);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw ApiException(0, 'No internet connection');
    } on HttpException catch (e) {
      print('❌ HttpException: $e');
      throw ApiException(0, 'Server error');
    } catch (e) {
      print('❌ Exception in GET: $e');
      throw ApiException(0, e.toString());
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    // Ensure token is loaded before making request
    await init();
    
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('📤 POST: $url');
      print('📦 Data: $data');
      print('🔑 Headers: $_headers');
      
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(AppConstants.apiTimeout);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw ApiException(0, 'No internet connection');
    } on HttpException catch (e) {
      print('❌ HttpException: $e');
      throw ApiException(0, 'Server error');
    } catch (e) {
      print('❌ Exception in POST: $e');
      throw ApiException(0, e.toString());
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    // Ensure token is loaded before making request
    await init();
    
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('📤 PUT: $url');
      print('📦 Data: $data');
      print('🔑 Headers: $_headers');
      
      final response = await http
          .put(
            url,
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(AppConstants.apiTimeout);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw ApiException(0, 'No internet connection');
    } on HttpException catch (e) {
      print('❌ HttpException: $e');
      throw ApiException(0, 'Server error');
    } catch (e) {
      print('❌ Exception in PUT: $e');
      throw ApiException(0, e.toString());
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    // Ensure token is loaded before making request
    await init();
    
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http
          .delete(url, headers: _headers)
          .timeout(AppConstants.apiTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(0, 'No internet connection');
    } on HttpException {
      throw ApiException(0, 'Server error');
    } catch (e) {
      throw ApiException(0, e.toString());
    }
  }

  /// Upload file with multipart
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
  }) async {
    // Ensure token is loaded before making request
    await init();
    
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Add headers
      if (_token != null && _token!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(0, 'No internet connection');
    } on HttpException {
      throw ApiException(0, 'Server error');
    } catch (e) {
      throw ApiException(0, e.toString());
    }
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      String message = 'Request failed';
      try {
        final error = jsonDecode(response.body);
        message = error['message'] ?? error['error'] ?? message;
      } catch (e) {
        message = response.body.isNotEmpty ? response.body : message;
      }
      throw ApiException(response.statusCode, message);
    }
  }
}

/// API Exception class
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
