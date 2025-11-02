import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/features/auth/screens/login_screen.dart';
import 'package:itjobhub/features/candidate/screens/candidate_main_screen.dart';
import 'package:itjobhub/features/employer/screens/employer_main_screen.dart';
import 'package:itjobhub/services/user_state.dart';
import 'package:itjobhub/services/api_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final UserState _userState = UserState();
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    
    _controller.forward();
    
    // Check for existing session and navigate accordingly
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to play
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    
    // Load user state (ApiClient will auto-load token when needed)
    print('🔍 SplashScreen: Loading user state...');
    final bool hasUser = await _userState.loadUser();
    
    // Also ensure ApiClient token is loaded for auth check
    await _apiClient.init();
    
    print('🔍 SplashScreen: Token loaded: ${_apiClient.token != null}');
    print('🔍 SplashScreen: User loaded: $hasUser');
    print('🔍 SplashScreen: User role: ${_userState.role}');
    
    if (!mounted) return;
    
    // Navigate based on auth state
    if (hasUser && _apiClient.isAuthenticated) {
      print('✅ SplashScreen: User authenticated, navigating to main screen');
      final Widget destination = _userState.role == 'employer'
          ? const EmployerMainScreen()
          : const CandidateMainScreen();
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    } else {
      print('❌ SplashScreen: No authentication found, navigating to login');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.accent,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon/Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((255 * 0.2).toInt()),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.work,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingL),
                      // App Name
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      // Tagline
                      Text(
                        'Find Your Dream IT Job',
                        style: TextStyle(
                          color: Colors.white.withAlpha((255 * 0.9).toInt()),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXL),
                      // Loading Indicator
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
