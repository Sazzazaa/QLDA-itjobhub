import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// User State Manager - Manages logged in user data
class UserState {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;
  UserState._internal();

  String? _userId;
  String? _email;
  String? _name;
  String? _role;
  String? _token;

  // Getters
  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;
  String? get role => _role;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _userId != null;

  /// Save user data after login
  Future<void> setUser({
    required String id,
    required String email,
    required String name,
    required String role,
    required String token,
  }) async {
    _userId = id;
    _email = email;
    _name = name;
    _role = role;
    _token = token;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode({
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'token': token,
    }));
  }

  /// Load user data from storage
  Future<bool> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        final data = jsonDecode(userData);
        _userId = data['id'];
        _email = data['email'];
        _name = data['name'];
        _role = data['role'];
        _token = data['token'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear user data on logout
  Future<void> clearUser() async {
    _userId = null;
    _email = null;
    _name = null;
    _role = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  /// Update user profile data
  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    if (name != null) _name = name;
    if (email != null) _email = email;

    if (_userId != null && _role != null && _token != null) {
      await setUser(
        id: _userId!,
        email: _email!,
        name: _name!,
        role: _role!,
        token: _token!,
      );
    }
  }
}
