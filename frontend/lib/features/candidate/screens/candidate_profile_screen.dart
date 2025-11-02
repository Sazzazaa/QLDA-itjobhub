import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/features/shared/screens/settings_screen.dart';
import 'package:itjobhub/screens/cv_upload_screen.dart';
import 'package:itjobhub/features/candidate/screens/my_reviews_screen.dart';
import 'package:itjobhub/features/shared/screens/forum_home_screen.dart';
import 'package:itjobhub/features/shared/screens/badges_screen.dart';
import 'package:itjobhub/features/shared/screens/leaderboard_screen.dart';
import 'package:itjobhub/features/candidate/screens/applications_screen.dart';
import 'package:itjobhub/features/candidate/screens/interviews_screen.dart';
import 'package:itjobhub/features/candidate/screens/saved_jobs_screen.dart';
import 'package:itjobhub/services/badge_service.dart';
import 'package:itjobhub/services/user_state.dart';
import 'package:itjobhub/services/api_client.dart';
import 'package:itjobhub/models/badge_model.dart';
import 'package:itjobhub/widgets/common/social_link_button.dart';
import 'package:itjobhub/models/candidate_model.dart';
import 'package:itjobhub/models/experience_project_model.dart';
import 'package:itjobhub/features/candidate/screens/edit_profile_screen.dart';
import 'package:itjobhub/features/candidate/screens/projects_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  final UserState _userState = UserState();
  final ApiClient _apiClient = ApiClient();
  final BadgeService _badgeService = BadgeService();
  
  // User data from API
  String _candidateId = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  String? _githubUrl;
  String? _linkedinUrl;
  String? _portfolioUrl;
  List<String> _skills = [];
  List<ExperienceProject> _projects = [];
  double? _desiredSalary;
  WorkLocation _workLocation = WorkLocation.hybrid;
  File? _avatarImage;
  
  // Statistics
  int _totalApplications = 0;
  int _upcomingInterviews = 0;
  int _savedJobs = 0;
  
  List<UserBadge> _userBadges = [];
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _badgeService.initialize();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      print('👤 ProfileScreen: Loading user profile...');
      
      // Load user state first
      await _userState.loadUser();
      
      // Fetch full profile from API
      final response = await _apiClient.get('/users/profile');
      
      print('✅ ProfileScreen: Profile loaded successfully');
      
      setState(() {
        _candidateId = response['_id'] ?? response['id'] ?? '';
        _name = response['name'] ?? _userState.name ?? '';
        _email = response['email'] ?? _userState.email ?? '';
        _phone = response['phone'] ?? '';
        _location = response['location'] ?? '';
        _githubUrl = response['githubUrl'];
        _linkedinUrl = response['linkedinUrl'];
        _portfolioUrl = response['portfolioUrl'];
        _skills = response['skills'] != null 
            ? List<String>.from(response['skills'])
            : [];
        _desiredSalary = response['desiredSalary']?.toDouble();
        
        // Parse work location
        if (response['preferredWorkLocation'] != null) {
          final locStr = response['preferredWorkLocation'].toString().toLowerCase();
          if (locStr.contains('remote')) {
            _workLocation = WorkLocation.remote;
          } else if (locStr.contains('onsite')) {
            _workLocation = WorkLocation.onsite;
          } else {
            _workLocation = WorkLocation.hybrid;
          }
        }
        
        // TODO: Parse projects from response when backend supports it
        _projects = ExperienceProject.getMockProjects();
      });
      
      // Load badges
      _loadBadgeInfo();
      
      // TODO: Load statistics from API
      _loadStatistics();
      
    } catch (e) {
      print('❌ ProfileScreen: Failed to load profile - $e');
      // Fallback to UserState data
      setState(() {
        _name = _userState.name ?? 'User';
        _email = _userState.email ?? '';
        _candidateId = _userState.userId ?? '';
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      // Fetch applications count
      final appsResponse = await _apiClient.get('/applications');
      _totalApplications = (appsResponse as List).length;
      
      // Fetch interviews count
      final interviewsResponse = await _apiClient.get('/interviews');
      final interviews = interviewsResponse as List;
      _upcomingInterviews = interviews.where((i) {
        final scheduledAt = DateTime.parse(i['scheduledAt']);
        return scheduledAt.isAfter(DateTime.now()) && i['status'] == 'scheduled';
      }).length;
      
      // TODO: Fetch saved jobs when backend supports it
      _savedJobs = 0;
      
      setState(() {});
    } catch (e) {
      print('⚠️ ProfileScreen: Failed to load statistics - $e');
    }
  }

  void _loadBadgeInfo() {
    _userBadges = _badgeService.getUserBadges(_candidateId);
    _totalPoints = _badgeService.getUserPoints(_candidateId);
    setState(() {});
  }

  void _manageCv() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CvManagerScreen(),
      ),
    );
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        // TODO: Upload to backend/storage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _manageProjects() async {
    final result = await Navigator.push<List<ExperienceProject>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectsScreen(initialProjects: _projects),
      ),
    );

    if (result != null) {
      setState(() {
        _projects = result;
      });
    }
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          name: _name,
          email: _email,
          phone: _phone,
          location: _location,
          skills: _skills,
          projects: _projects,
          githubUrl: _githubUrl,
          linkedinUrl: _linkedinUrl,
          portfolioUrl: _portfolioUrl,
          desiredSalary: _desiredSalary,
          workLocation: _workLocation,
        ),
      ),
    );
    
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _name = result['name'];
        _email = result['email'];
        _phone = result['phone'];
        _location = result['location'];
        _githubUrl = result['githubUrl'];
        _linkedinUrl = result['linkedinUrl'];
        _portfolioUrl = result['portfolioUrl'];
        _desiredSalary = result['desiredSalary'];
        _workLocation = result['workLocation'];
        _skills = result['skills'];
        if (result['projects'] != null) {
          _projects = result['projects'];
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForumHomeScreen(),
                ),
              );
            },
            tooltip: 'Community Forum',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with avatar and basic info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _avatarImage != null
                            ? FileImage(_avatarImage!)
                            : null,
                        child: _avatarImage == null
                            ? Text(
                                _name.split(' ').map((e) => e[0]).join().toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            onPressed: _uploadProfilePhoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  Text(
                    _name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    _email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _phone,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Social Links
                  const SizedBox(height: AppSizes.spacingM),
                  SocialLinksRow(
                    githubUrl: _githubUrl,
                    linkedinUrl: _linkedinUrl,
                  ),
                  if (_portfolioUrl != null) ...[
                    const SizedBox(height: AppSizes.spacingS),
                    InkWell(
                      onTap: () {
                        // TODO: Use url_launcher to open portfolio
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Portfolio: $_portfolioUrl')),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Portfolio',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingL),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _editProfile,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _manageCv,
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('Manage CV'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Stats Section
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.work_outline,
                          label: 'Applications',
                          value: _totalApplications.toString(),
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ApplicationsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.event,
                          label: 'Interviews',
                          value: _upcomingInterviews.toString(),
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InterviewsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.bookmark_outline,
                          label: 'Saved Jobs',
                          value: _savedJobs.toString(),
                          color: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SavedJobsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.rate_review_outlined,
                          label: 'My Reviews',
                          value: '3',
                          color: AppColors.accent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyReviewsScreen(
                                  candidateId: _candidateId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Skills Section
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  if (_skills.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(color: AppColors.primary),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                        );
                      }).toList(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No skills added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Projects Section
            if (_projects.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Experience Projects',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    ..._projects.take(3).map((project) => _ProjectCard(project: project)),
                    if (_projects.length > 3)
                      Center(
                        child: TextButton(
                          onPressed: _manageProjects,
                          child: const Text('View All Projects'),
                        ),
                      ),
                  ],
                ),
              ),

            const Divider(height: 1),

            // Work Preferences Section
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Work Preferences',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.attach_money,
                          label: 'Desired Salary',
                          value: _desiredSalary != null 
                              ? '\$${(_desiredSalary! / 1000).toStringAsFixed(0)}K/year'
                              : 'Not specified',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.location_city_outlined,
                          label: 'Work Location',
                          value: _workLocation.displayName,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Badges and Rankings Section
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.military_tech, color: AppColors.primary, size: 24),
                          const SizedBox(width: AppSizes.spacingS),
                          Text(
                            'Badges & Rankings',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BadgesScreen(userId: _candidateId),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.stars,
                          label: 'Total Points',
                          value: _totalPoints.toString(),
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaderboardScreen(
                                  currentUserId: _candidateId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: _StatsCard(
                          icon: Icons.military_tech,
                          label: 'Badges Earned',
                          value: '${_userBadges.where((b) => b.isEarned).length}/${_userBadges.length}',
                          color: AppColors.success,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BadgesScreen(userId: _candidateId),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  if (_userBadges.where((b) => b.isEarned).isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _userBadges
                            .where((b) => b.isEarned)
                            .take(5)
                            .map((userBadge) => _MiniBadge(userBadge: userBadge))
                            .toList(),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600]),
                          const SizedBox(width: AppSizes.spacingM),
                          Expanded(
                            child: Text(
                              'Complete activities to earn badges!',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spacingXL),
          ],
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatsCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ExperienceProject project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (project.projectUrl != null)
                  IconButton(
                    icon: const Icon(Icons.link, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Project: ${project.projectUrl}')),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            if (project.role != null) ...[
              const SizedBox(height: 4),
              Text(
                project.role!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              project.duration,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (project.technologies.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingS),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: project.technologies.map((tech) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tech,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final UserBadge userBadge;

  const _MiniBadge({required this.userBadge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: userBadge.badge.tier.color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: userBadge.badge.tier.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              userBadge.badge.icon,
              size: 20,
              color: userBadge.badge.tier.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userBadge.badge.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


// CV Manager Screen
class CvManagerScreen extends StatelessWidget {
  const CvManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your CVs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description, color: AppColors.primary),
                title: const Text('John_Doe_CV.pdf'),
                subtitle: const Text('Uploaded on 2024-01-15'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download coming soon')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Delete coming soon')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Navigate to CV upload screen
                  final parsedData = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CVUploadScreen(),
                    ),
                  );
                  
                  if (parsedData != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('CV uploaded and parsed successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    // TODO: Save parsed data to user profile
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload New CV'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
