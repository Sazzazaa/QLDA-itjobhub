import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/services/job_service.dart';
import 'package:itjobhub/features/employer/screens/post_job_screen.dart';
import 'package:itjobhub/features/employer/screens/employer_main_screen.dart';

class EmployerJobsScreen extends StatefulWidget {
  const EmployerJobsScreen({super.key});

  @override
  State<EmployerJobsScreen> createState() => _EmployerJobsScreenState();
}

class _EmployerJobsScreenState extends State<EmployerJobsScreen> {
  List<Job> _jobs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    
    try {
      print('💼 EmployerJobsScreen: Fetching employer jobs from API...');
      final jobs = await JobService().fetchMyJobs();
      
      setState(() {
        _jobs = jobs;
      });
      print('✅ EmployerJobsScreen: Loaded ${jobs.length} employer jobs');
    } catch (e) {
      print('❌ EmployerJobsScreen: Error loading jobs - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load jobs: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _jobs = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMenuAction(String action, Job job) async {
    switch (action) {
      case 'edit':
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PostJobScreen(job: job),
          ),
        );
        if (result == true && mounted) {
          _loadJobs(); // Refresh the list
        }
        break;

      case 'view':
        // Navigate to Applications tab with filter
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmployerMainScreen(
              initialIndex: 1, // Applications tab
              filterJobId: job.id,
            ),
          ),
        );
        break;

      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Job?'),
            content: Text(
              'Are you sure you want to delete "${job.title}"?\n\n'
              'This action cannot be undone and will affect all related applications.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await JobService().deleteJob(job.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadJobs(); // Refresh the list
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete job: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Job Postings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.post_add, size: 80, color: AppColors.textSecondary),
                      const SizedBox(height: AppSizes.spacingL),
                      Text('No jobs posted yet', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSizes.spacingS),
                      const Text('Start by posting your first job', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: AppSizes.spacingXL),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const PostJobScreen()),
                          );
                          if (result == true) {
                            _loadJobs();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Post a Job'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    final job = _jobs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withAlpha((255 * 0.1).toInt()),
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: const Icon(Icons.work, color: AppColors.primary),
                        ),
                        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${job.applicantCount} applicants • Posted ${job.timeAgo}'),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            )),
                            const PopupMenuItem(value: 'view', child: Row(
                              children: [
                                Icon(Icons.people, size: 20),
                                SizedBox(width: 8),
                                Text('View Applicants'),
                              ],
                            )),
                            const PopupMenuItem(value: 'delete', child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            )),
                          ],
                          onSelected: (value) => _handleMenuAction(value, job),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const PostJobScreen()),
          );
          
          // Reload jobs if a job was posted
          if (result == true) {
            _loadJobs();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
      ),
    );
  }
}
