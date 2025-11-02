import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/services/job_service.dart';

class PostJobScreen extends StatefulWidget {
  final Job? job; // If provided, we're in edit mode
  
  const PostJobScreen({super.key, this.job});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _locationController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _skillsController = TextEditingController();
  
  JobType _selectedJobType = JobType.remote;
  ExperienceLevel _selectedLevel = ExperienceLevel.mid;
  bool _isPosting = false;
  
  bool get isEditMode => widget.job != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFields();
    }
  }
  
  void _populateFields() {
    final job = widget.job!;
    _titleController.text = job.title;
    _descriptionController.text = job.description;
    _requirementsController.text = job.requirements;
    _locationController.text = job.location;
    _selectedJobType = job.jobType;
    _selectedLevel = job.experienceLevel;
    _skillsController.text = job.techStack.join(', ');
    
    // Salary parsing can be added if needed later
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isPosting = true);
    
    try {
      print('📤 PostJobScreen: ${isEditMode ? "Updating" : "Posting new"} job...');
      
      // Format salary as string
      String salaryStr = '';
      final minSalary = _minSalaryController.text.trim();
      final maxSalary = _maxSalaryController.text.trim();
      
      if (minSalary.isNotEmpty && maxSalary.isNotEmpty) {
        salaryStr = '\$${minSalary}K - \$${maxSalary}K/month';
      } else if (minSalary.isNotEmpty) {
        salaryStr = 'From \$${minSalary}K/month';
      } else if (maxSalary.isNotEmpty) {
        salaryStr = 'Up to \$${maxSalary}K/month';
      } else {
        salaryStr = 'Negotiable';
      }
      
      final jobData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text.trim(), // Send as string
        'location': _locationController.text.trim(),
        'jobType': _selectedJobType.name,
        'contractType': 'full-time', // Default to full-time for now
        'experienceLevel': _selectedLevel.name,
        'salary': salaryStr, // Send as string
        'skills': _skillsController.text.trim().isNotEmpty
            ? _skillsController.text.trim().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
            : ['Flutter', 'Dart'], // Default skills if none entered
        'benefits': [], // Optional
      };
      
      print('📤 PostJobScreen: Sending job data: $jobData');
      
      if (isEditMode) {
        await JobService().updateJob(widget.job!.id, jobData);
        print('✅ PostJobScreen: Job updated successfully');
      } else {
        await JobService().createJob(jobData);
        print('✅ PostJobScreen: Job posted successfully');
      }
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Job updated successfully!' : 'Job posted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ PostJobScreen: Error - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${isEditMode ? "update" : "post"} job: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Job' : 'Post a Job'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                hintText: 'e.g. Senior Flutter Developer',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            DropdownButtonFormField<JobType>(
              value: _selectedJobType,
              decoration: const InputDecoration(labelText: 'Job Type *'),
              items: JobType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.displayName));
              }).toList(),
              onChanged: (v) => setState(() => _selectedJobType = v!),
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            DropdownButtonFormField<ExperienceLevel>(
              value: _selectedLevel,
              decoration: const InputDecoration(labelText: 'Experience Level *'),
              items: ExperienceLevel.values.map((level) {
                return DropdownMenuItem(value: level, child: Text(level.displayName));
              }).toList(),
              onChanged: (v) => setState(() => _selectedLevel = v!),
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'e.g. San Francisco, CA or Remote',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minSalaryController,
                    decoration: const InputDecoration(labelText: 'Min Salary (K)', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _maxSalaryController,
                    decoration: const InputDecoration(labelText: 'Max Salary (K)', prefixText: '\$'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Job Description *'),
              maxLines: 5,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            TextFormField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: 'Required Skills *',
                hintText: 'e.g. Flutter, Dart, Firebase (comma-separated)',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            TextFormField(
              controller: _requirementsController,
              decoration: const InputDecoration(labelText: 'Requirements *'),
              maxLines: 5,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSizes.spacingXL),
            
            ElevatedButton(
              onPressed: _isPosting ? null : _postJob,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 56)),
              child: _isPosting
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(isEditMode ? 'Update Job' : 'Post Job', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
