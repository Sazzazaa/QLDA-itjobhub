import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_application_model.dart';
import 'package:itjobhub/models/candidate_model.dart';
import 'package:itjobhub/services/application_service.dart';
import 'package:itjobhub/features/employer/screens/application_detail_screen.dart';
import 'package:itjobhub/features/employer/screens/employer_main_screen.dart';
import 'package:itjobhub/widgets/common/index.dart';

class EmployerApplicationsScreen extends StatefulWidget {
  final String? filterJobId;
  
  const EmployerApplicationsScreen({super.key, this.filterJobId});

  @override
  State<EmployerApplicationsScreen> createState() =>
      _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState extends State<EmployerApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<JobApplication> _applications = [];
  List<JobApplication> _filteredApplications = [];
  bool _isLoading = false;
  ApplicationStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedStatus = null; // All
          break;
        case 1:
          _selectedStatus = ApplicationStatus.pending;
          break;
        case 2:
          _selectedStatus = ApplicationStatus.reviewing;
          break;
        case 3:
          _selectedStatus = ApplicationStatus.interview;
          break;
        case 4:
          _selectedStatus = ApplicationStatus.approved;
          break;
      }
      _filterApplications();
    });
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    
    try {
      print('📋 EmployerApplicationsScreen: Fetching applications from API...');
      final applications = await ApplicationService().fetchApplications();
      
      // Convert Application to JobApplication with candidate data
      setState(() {
        _applications = applications.map((app) {
          // Use populated candidate data if available, otherwise create placeholder
          final candidate = app.candidate ?? Candidate(
            id: app.candidateId ?? 'unknown',
            name: 'Applicant',
            email: '',
            phone: '',
            location: '',
            skills: [],
            yearsOfExperience: 0,
          );
          
          return JobApplication(
            id: app.id,
            job: app.job,
            candidate: candidate,
            status: app.status,
            appliedDate: app.appliedDate,
            lastUpdateDate: app.lastUpdateDate,
            candidateCoverLetter: app.notes ?? '',
          );
        }).toList();
        _filteredApplications = _applications;
      });
      
      print('✅ EmployerApplicationsScreen: Loaded ${applications.length} applications');
    } catch (e) {
      print('❌ EmployerApplicationsScreen: Error loading applications - $e');
      // Show empty state on error
      setState(() {
        _applications = [];
        _filteredApplications = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
    
    _filterApplications();
  }

  void _filterApplications() {
    setState(() {
      var filtered = _applications;
      
      // Filter by job if filterJobId is provided
      if (widget.filterJobId != null) {
        filtered = filtered.where((app) => app.job.id == widget.filterJobId).toList();
      }
      
      // Filter by status
      if (_selectedStatus == null) {
        _filteredApplications = filtered;
      } else {
        _filteredApplications = filtered
            .where((app) => app.status == _selectedStatus)
            .toList();
      }
    });
  }

  void _updateApplicationStatus(
    JobApplication application,
    ApplicationStatus newStatus,
  ) async {
    try {
      print('📋 EmployerApplicationsScreen: Updating status to ${newStatus.name}');
      
      // Call API to update status
      await ApplicationService().updateApplicationStatus(
        applicationId: application.id,
        status: newStatus.name,
      );
      
      setState(() {
        final index = _applications.indexWhere((app) => app.id == application.id);
        if (index != -1) {
          _applications[index] = application.copyWith(
            status: newStatus,
            lastUpdateDate: DateTime.now(),
          );
        }
      });
      _filterApplications();
      
      print('✅ EmployerApplicationsScreen: Status updated successfully');
    } catch (e) {
      print('❌ EmployerApplicationsScreen: Failed to update status - $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update application status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _getCountForStatus(ApplicationStatus? status) {
    if (status == null) return _applications.length;
    return _applications.where((app) => app.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applications',
              style: TextStyle(color: Colors.white),
            ),
            if (widget.filterJobId != null)
              Text(
                'Filtered by job',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: widget.filterJobId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filter',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const EmployerMainScreen(initialIndex: 1),
                      ),
                    );
                  },
                ),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColors.primary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'All (${_getCountForStatus(null)})'),
                Tab(
                  text:
                      'New (${_getCountForStatus(ApplicationStatus.pending)})',
                ),
                Tab(
                  text:
                      'Reviewing (${_getCountForStatus(ApplicationStatus.reviewing)})',
                ),
                Tab(
                  text:
                      'Interview (${_getCountForStatus(ApplicationStatus.interview)})',
                ),
                Tab(
                  text:
                      'Approved (${_getCountForStatus(ApplicationStatus.approved)})',
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading applications...')
          : _filteredApplications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadApplications,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredApplications.length,
                itemBuilder: (context, index) {
                  final application = _filteredApplications[index];
                  return _ApplicationCard(
                    application: application,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ApplicationDetailScreen(application: application),
                        ),
                      );
                      if (result != null && result is ApplicationStatus) {
                        _updateApplicationStatus(application, result);
                      }
                    },
                    onStatusChange: (newStatus) {
                      _updateApplicationStatus(application, newStatus);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Application ${newStatus.displayName.toLowerCase()}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'No Applications Yet',
      message: _selectedStatus == null
          ? 'You haven\'t received any applications yet. Post a job to start receiving applications!'
          : 'No applications with this status',
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;
  final Function(ApplicationStatus) onStatusChange;

  const _ApplicationCard({
    required this.application,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate info row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    application.candidate.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and position
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.candidate.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${application.candidate.currentPosition ?? "Candidate"} • ${application.candidate.experienceText}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Match score
                if (application.candidate.matchScore != null)
                  StatusChip(
                    label: '${application.candidate.matchScore!.toInt()}%',
                    color: AppColors.success,
                    icon: Icons.stars,
                    size: ChipSize.small,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Job title
            Row(
              children: [
                Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Applied for: ${application.job.title}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Location and time
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  application.candidate.location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  application.appliedTimeAgo,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Skills
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: application.candidate.skills.take(3).map((skill) {
                return StatusChip(
                  label: skill,
                  color: AppColors.primary,
                  size: ChipSize.small,
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Status and actions
            Row(
              children: [
                StatusChip.applicationStatus(
                  application.status,
                  size: ChipSize.small,
                ),
                const Spacer(),
                if (application.status == ApplicationStatus.pending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SecondaryButton(
                        label: 'Reject',
                        icon: Icons.close,
                        onPressed: () =>
                            onStatusChange(ApplicationStatus.rejected),
                        size: ButtonSize.small,
                      ),
                      const SizedBox(width: 8),
                      PrimaryButton(
                        label: 'Review',
                        icon: Icons.visibility,
                        onPressed: () =>
                            onStatusChange(ApplicationStatus.reviewing),
                        size: ButtonSize.small,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
