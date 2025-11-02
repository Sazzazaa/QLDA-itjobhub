import 'package:flutter/material.dart';

/// App Constants
class AppConstants {
  // App Info
  static const String appName = 'ITJobHub';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // IMPORTANT: Choose the correct URL based on your device:
  // - iOS Simulator / Web / Desktop: http://localhost:3000/api
  // - Android Emulator: http://10.0.2.2:3000/api  
  // - Physical Device: http://YOUR_COMPUTER_IP:3000/api (e.g., http://192.168.1.100:3000/api)
  
  // ✅ CURRENT: Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // ← Android Emulator
  
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String languageKey = 'language';
  static const String themeKey = 'theme_mode';
  
  // Pagination
  static const int pageSize = 20;
  static const int maxRetries = 3;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minDescriptionLength = 50;
  static const int maxDescriptionLength = 5000;
}

/// App Colors (Blue Theme)
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // Accent Colors
  static const Color accent = Color(0xFF26C6DA); // Cyan
  static const Color accentLight = Color(0xFF4DD0E1);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Application Status Colors
  static const Color pending = Color(0xFFFFA726); // Orange
  static const Color approved = Color(0xFF4CAF50); // Green
  static const Color rejected = Color(0xFFF44336); // Red
  
  // Neutral Colors (Light Mode)
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  
  // Dark Mode Text
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  // Premium Badge
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumGradientStart = Color(0xFFFFD700);
  static const Color premiumGradientEnd = Color(0xFFFFA500);
  
  // Divider
  static const Color divider = Color(0xFFE0E0E0);
  static const Color darkDivider = Color(0xFF424242);
}

/// App Sizes
class AppSizes {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 100.0;
  
  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Avatar Sizes
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 64.0;
  static const double avatarXL = 100.0;
  
  // Button Height
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
  
  // Card
  static const double cardElevation = 2.0;
  static const double cardBorderWidth = 1.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Min Touch Target
  static const double minTouchTarget = 48.0;
}

/// App Elevations
class AppElevations {
  static const double none = 0.0;
  static const double card = 2.0;
  static const double button = 2.0;
  static const double appBar = 4.0;
  static const double fab = 6.0;
  static const double dialog = 8.0;
  static const double drawer = 16.0;
}

/// App Durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 1500);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 300);
}

/// App Strings
class AppStrings {
  // Common
  static const String appName = 'ITJobHub';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String submit = 'Submit';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String skip = 'Skip';
  static const String done = 'Done';
  
  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String orContinueWith = 'Or continue with';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  
  // Roles
  static const String selectRole = 'Select Your Role';
  static const String candidate = 'Candidate';
  static const String employer = 'Employer';
  static const String lookingForJob = 'Looking for IT jobs';
  static const String lookingToHire = 'Looking to hire IT talent';
  
  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPassword = 'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String requiredField = 'This field is required';
}

/// User Roles
enum UserRole {
  candidate,
  employer,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.candidate:
        return 'candidate';
      case UserRole.employer:
        return 'employer';
    }
  }
  
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'candidate':
        return UserRole.candidate;
      case 'employer':
        return UserRole.employer;
      default:
        return UserRole.candidate;
    }
  }
}

/// Application Status
enum ApplicationStatus {
  pending,
  reviewing,
  approved,
  interview,
  interviewScheduled,
  interviewCompleted,
  hired,
  rejected,
  withdrawn,
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.reviewing:
        return 'Reviewing';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.interviewScheduled:
        return 'Interview Scheduled';
      case ApplicationStatus.interviewCompleted:
        return 'Interview Completed';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
  
  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return AppColors.pending;
      case ApplicationStatus.reviewing:
        return Colors.blue;
      case ApplicationStatus.approved:
        return AppColors.approved;
      case ApplicationStatus.interview:
        return Colors.purple;
      case ApplicationStatus.interviewScheduled:
        return Colors.blue;
      case ApplicationStatus.interviewCompleted:
        return Colors.indigo;
      case ApplicationStatus.hired:
        return Colors.teal;
      case ApplicationStatus.rejected:
        return AppColors.rejected;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
    }
  }
}
