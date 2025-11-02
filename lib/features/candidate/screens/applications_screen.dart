import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/application_model.dart';
import 'package:itjobhub/features/candidate/widgets/application_card.dart';
import 'package:itjobhub/features/candidate/screens/application_detail_candidate_screen.dart';
import 'package:itjobhub/widgets/common/index.dart';
import 'package:itjobhub/widgets/common/notification_icon_button.dart';
import 'package:itjobhub/services/api_client.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  List<Application> _applications = [];
  ApplicationStatus? _filterStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('📋 ApplicationsScreen: initState called');
    // Schedule load for after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📋 ApplicationsScreen: PostFrameCallback - calling _loadApplications');
      _loadApplications();
    });
  }

  Future<void> _loadApplications() async {
    if (!mounted) return;
    
    print('📋 ApplicationsScreen: Starting to load applications...');
    setState(() => _isLoading = true);
    
    try {
      print('📋 ApplicationsScreen: Fetching applications from API...');
      final response = await ApiClient().get('/applications');
      
      print('✅ ApplicationsScreen: Received ${(response as List).length} applications');
      print('📋 ApplicationsScreen: Raw response: $response');
      
      // Parse applications from API
      final List<Application> apiApplications = [];
      for (var json in response) {
        try {
          print('🔍 Parsing application: ${json['_id']}');
          
          // The backend returns jobId (populated) or job
          final jobData = json['jobId'] ?? json['job'];
          
          if (jobData == null) {
            print('⚠️ Application ${json['_id']} has no job data, skipping');
            continue;
          }
          
          // Use Application.fromJson which handles all cases
          final application = Application.fromJson(json);
          apiApplications.add(application);
          
          print('✅ Parsed application: ${application.id} for job: ${application.job.title}');
        } catch (e, stackTrace) {
          print('❌ Error parsing application ${json['_id']}: $e');
          print('❌ Parse StackTrace: $stackTrace');
        }
      }
      
      print('📋 ApplicationsScreen: Parsed ${apiApplications.length} out of ${response.length} applications');
      
      if (mounted) {
        setState(() {
          _applications = apiApplications;
          _isLoading = false;
        });
        
        print('✅ ApplicationsScreen: setState() called - applications: ${_applications.length}, isLoading: $_isLoading');
        
        if (apiApplications.isEmpty) {
          print('ℹ️ ApplicationsScreen: No applications found (user has not applied to any jobs yet)');
        } else {
          print('✅ ApplicationsScreen: Successfully loaded ${_applications.length} applications');
        }
      }
    } catch (e, stackTrace) {
      print('❌ ApplicationsScreen: API call failed - $e');
      print('❌ StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _applications = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshApplications() async {
    await _loadApplications();
  }

  List<Application> get _filteredApplications {
    if (_filterStatus == null) {
      return _applications;
    }
    return _applications.where((app) => app.status == _filterStatus).toList();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter by Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spacingL),
            _FilterOption(
              label: 'All Applications',
              isSelected: _filterStatus == null,
              onTap: () {
                setState(() => _filterStatus = null);
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              label: 'Pending',
              color: AppColors.pending,
              isSelected: _filterStatus == ApplicationStatus.pending,
              onTap: () {
                setState(() => _filterStatus = ApplicationStatus.pending);
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              label: 'Approved',
              color: AppColors.approved,
              isSelected: _filterStatus == ApplicationStatus.approved,
              onTap: () {
                setState(() => _filterStatus = ApplicationStatus.approved);
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              label: 'Rejected',
              color: AppColors.rejected,
              isSelected: _filterStatus == ApplicationStatus.rejected,
              onTap: () {
                setState(() => _filterStatus = ApplicationStatus.rejected);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: [
          NotificationIconButton(iconColor: Colors.white),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading your applications...')
          : _filteredApplications.isEmpty
          ? EmptyState(
              icon: Icons.inbox_outlined,
              title: _filterStatus == null
                  ? 'No Applications Yet'
                  : 'No ${_filterStatus!.displayName} Applications',
              message: _filterStatus == null
                  ? 'Start applying to jobs to see them here'
                  : 'Try a different filter to see your applications',
            )
          : Column(
              children: [
                // Status Summary
                if (_filterStatus == null)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatusCount(
                          label: 'Pending',
                          count: _applications
                              .where(
                                (app) =>
                                    app.status == ApplicationStatus.pending,
                              )
                              .length,
                          color: AppColors.pending,
                        ),
                        _StatusCount(
                          label: 'Approved',
                          count: _applications
                              .where(
                                (app) =>
                                    app.status == ApplicationStatus.approved,
                              )
                              .length,
                          color: AppColors.approved,
                        ),
                        _StatusCount(
                          label: 'Rejected',
                          count: _applications
                              .where(
                                (app) =>
                                    app.status == ApplicationStatus.rejected,
                              )
                              .length,
                          color: AppColors.rejected,
                        ),
                      ],
                    ),
                  ),
                // Applications List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshApplications,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      itemCount: _filteredApplications.length,
                      itemBuilder: (context, index) {
                        final application = _filteredApplications[index];
                        return ApplicationCard(
                          application: application,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ApplicationDetailCandidateScreen(
                                      application: application,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusCount({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: color != null
          ? Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          : const Icon(Icons.all_inclusive),
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
