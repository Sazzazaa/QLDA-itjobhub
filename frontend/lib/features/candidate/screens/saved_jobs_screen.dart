import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/features/candidate/widgets/job_card.dart';
import 'package:itjobhub/features/candidate/screens/job_detail_screen.dart';
import 'package:itjobhub/services/job_service.dart';
import 'package:itjobhub/widgets/common/index.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final JobService _jobService = JobService();
  List<Job> _savedJobs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
    // Listen for bookmark changes from other screens
    _jobService.addBookmarkListener(_loadSavedJobs);
  }
  
  @override
  void dispose() {
    _jobService.removeBookmarkListener(_loadSavedJobs);
    super.dispose();
  }

  Future<void> _loadSavedJobs() async {
    if (mounted) {
      setState(() => _isLoading = true);
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          // Get only bookmarked jobs from service
          _savedJobs = _jobService.getSavedJobs();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshSavedJobs() async {
    await _loadSavedJobs();
  }

  void _removeBookmark(Job job, int index) {
    _jobService.toggleBookmark(job.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from saved jobs'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _jobService.toggleBookmark(job.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_savedJobs.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Saved Jobs?'),
                    content: const Text(
                      'Are you sure you want to remove all saved jobs? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _jobService.clearAllBookmarks();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All saved jobs cleared'),
                            ),
                          );
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading saved jobs...')
          : _savedJobs.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshSavedJobs,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Saved Jobs',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            StatusChip(
                              label: '${_savedJobs.length} jobs',
                              color: AppColors.primary,
                              size: ChipSize.small,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Jobs List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _savedJobs.length,
                          itemBuilder: (context, index) {
                            final job = _savedJobs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: Key(job.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  _removeBookmark(job, index);
                                },
                                child: JobCard(
                                  job: job,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => JobDetailScreen(job: job),
                                      ),
                                    );
                                  },
                                  onBookmark: () {
                                    _jobService.toggleBookmark(job.id);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.bookmark_border,
      title: 'No Saved Jobs',
      message: 'Start saving jobs you\'re interested in to find them here later.',
      actionLabel: 'Browse Jobs',
      onAction: () {
        Navigator.pop(context);
      },
    );
  }
}
