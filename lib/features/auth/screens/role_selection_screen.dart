import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/features/auth/screens/login_screen.dart';
import 'package:itjobhub/services/auth_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  
  const RoleSelectionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleRoleSelection(String role) async {
    setState(() => _isLoading = true);

    try {
      // Call real API to register user
      final result = await _authService.register(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        role: role,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration successful! Please login.'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to login screen (user needs to login after registration)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.selectRole,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingS),
                Text(
                  'Choose your role to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingXL * 2),
                
                // Candidate Card
                _RoleCard(
                  icon: Icons.person_search,
                  title: AppStrings.candidate,
                  description: AppStrings.lookingForJob,
                  isLoading: _isLoading,
                  onTap: () => _handleRoleSelection('candidate'),
                ),
                const SizedBox(height: AppSizes.spacingL),
                
                // Employer Card
                _RoleCard(
                  icon: Icons.business_center,
                  title: AppStrings.employer,
                  description: AppStrings.lookingToHire,
                  isLoading: _isLoading,
                  onTap: () => _handleRoleSelection('employer'),
                ),
                
                if (_isLoading) ...[
                  const SizedBox(height: AppSizes.spacingL),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLoading;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha((255 * 0.1).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.iconXL,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
