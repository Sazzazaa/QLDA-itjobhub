import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/services/application_service.dart';
import 'package:itjobhub/services/cv_service.dart';
import 'package:itjobhub/services/api_client.dart';

/// Job Application Form Screen
/// 
/// Allows candidates to submit a job application with cover letter and resume
class JobApplicationFormScreen extends StatefulWidget {
  final Job job;
  
  const JobApplicationFormScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobApplicationFormScreen> createState() => _JobApplicationFormScreenState();
}

class _JobApplicationFormScreenState extends State<JobApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  
  final CVService _cvService = CVService(ApiClient());
  List<Map<String, dynamic>> _uploadedCVs = [];
  String? _selectedCVId;
  bool _isUploadingCV = false;
  bool _isLoadingCVs = true; // Start as true to show loading initially
  
  bool _isSubmitting = false;
  bool _agreeToTerms = false;
  bool _isGeneratingCoverLetter = false;
  
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _loadUserCVs();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _additionalInfoController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }
  
  void _startStatusPolling() {
    // Check CV status every 3 seconds
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _checkProcessingCVs();
      }
    });
  }
  
  Future<void> _checkProcessingCVs() async {
    // Only check if there are CVs with "parsing" or "pending" status
    final hasProcessing = _uploadedCVs.any((cv) => 
      cv['status'] == 'parsing' || cv['status'] == 'pending'
    );
    
    if (hasProcessing) {
      await _loadUserCVs();
    }
  }

  Future<void> _loadUserCVs() async {
    setState(() => _isLoadingCVs = true);
    try {
      final cvs = await _cvService.getMyCVs();
      setState(() {
        _uploadedCVs = cvs;
        _isLoadingCVs = false;
      });
    } catch (e) {
      setState(() => _isLoadingCVs = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load CVs: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadCV() async {
    final file = await _cvService.pickPDFFile();
    if (file == null) return;

    setState(() => _isUploadingCV = true);

    try {
      final result = await _cvService.uploadCV(file);
      setState(() {
        _isUploadingCV = false;
        _selectedCVId = result['_id'];
      });
      
      // Reload CV list
      await _loadUserCVs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingCV = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload CV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteCV(String cvId, String fileName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete CV?'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _cvService.deleteCV(cvId);
      
      // Reload CV list
      await _loadUserCVs();
      
      // Clear selection if deleted CV was selected
      if (_selectedCVId == cvId) {
        setState(() => _selectedCVId = null);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete CV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _generateCoverLetter() async {
    // Check if CV is selected and completed
    if (_selectedCVId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a CV first to generate cover letter'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selectedCV = _uploadedCVs.firstWhere(
      (cv) => cv['_id'] == _selectedCVId,
      orElse: () => {},
    );

    if (selectedCV['status'] != 'completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for CV parsing to complete'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isGeneratingCoverLetter = true);

    try {
      final coverLetter = await _cvService.generateCoverLetter(
        _selectedCVId!,
        widget.job.id,
      );

      setState(() {
        _coverLetterController.text = coverLetter;
        _isGeneratingCoverLetter = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Cover letter generated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGeneratingCoverLetter = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate cover letter: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      print('📝 JobApplicationForm: Submitting application for job ${widget.job.id}...');
      
      await ApplicationService().submitApplication(
        jobId: widget.job.id,
        coverLetter: _coverLetterController.text.trim(),
        cvId: _selectedCVId,
        additionalInfo: _additionalInfoController.text.trim().isEmpty 
            ? null 
            : _additionalInfoController.text.trim(),
      );
      
      print('✅ JobApplicationForm: Application submitted successfully');
      
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 64,
            ),
            title: const Text('Application Submitted!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your application for ${widget.job.title} at ${widget.job.companyName} has been submitted successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingL),
                Text(
                  'You can track your application status in the Applications tab.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Return to job detail
                },
                child: const Text('View Applications'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Return to job detail
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ JobApplicationForm: Error submitting application - $e');
      
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Job'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingM),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          children: [
            // Job Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.job.companyName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(widget.job.jobType.displayName),
                          avatar: const Icon(Icons.work_outline, size: 16),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        Chip(
                          label: Text(widget.job.location),
                          avatar: const Icon(Icons.location_on_outlined, size: 16),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // Resume/CV Upload Section
            Text(
              'Resume/CV (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            // Upload button
            OutlinedButton.icon(
              onPressed: _isUploadingCV ? null : _pickAndUploadCV,
              icon: _isUploadingCV 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
              label: Text(_isUploadingCV ? 'Uploading...' : 'Upload PDF Resume'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            // List of uploaded CVs
            if (_isLoadingCVs)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingL),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_uploadedCVs.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Column(
                  children: _uploadedCVs.map((cv) {
                    final isSelected = _selectedCVId == cv['_id'];
                    final status = cv['status'] ?? 'pending';
                    final parseError = cv['parseError'];
                    
                    return ListTile(
                      leading: Radio<String>(
                        value: cv['_id'],
                        groupValue: _selectedCVId,
                        onChanged: (value) {
                          setState(() => _selectedCVId = value);
                          
                          // Show error details if failed
                          if (status == 'failed' && parseError != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Parsing error: $parseError'),
                                backgroundColor: AppColors.error,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                      ),
                      title: Text(cv['fileName'] ?? 'Unknown'),
                      subtitle: Row(
                        children: [
                          if (status == 'completed')
                            const Icon(Icons.check_circle, size: 16, color: AppColors.success)
                          else if (status == 'parsing')
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (status == 'failed')
                            const Icon(Icons.error, size: 16, color: AppColors.error)
                          else
                            const Icon(Icons.pending, size: 16, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              status == 'completed' 
                                ? 'Parsed' 
                                : status == 'parsing'
                                  ? 'Processing...'
                                  : status == 'failed'
                                    ? 'Failed${parseError != null ? " (tap for details)" : ""}'
                                    : 'Pending',
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(cv['fileSize'] / 1024).toStringAsFixed(0)} KB',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _deleteCV(cv['_id'], cv['fileName'] ?? 'CV'),
                        tooltip: 'Delete CV',
                      ),
                      selected: isSelected,
                      onTap: () {
                        setState(() => _selectedCVId = cv['_id']);
                        
                        // Show error details if failed
                        if (status == 'failed' && parseError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Parsing error: $parseError'),
                              backgroundColor: AppColors.error,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: AppSizes.spacingM),
                    Expanded(
                      child: Text(
                        'Upload your resume in PDF format. Our AI will automatically parse it to match you with the best opportunities.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSizes.spacingXL),

            // Cover Letter with AI button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cover Letter *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // AI Generate button
                TextButton.icon(
                  onPressed: _isGeneratingCoverLetter ? null : _generateCoverLetter,
                  icon: _isGeneratingCoverLetter
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    _isGeneratingCoverLetter 
                        ? 'Generating...' 
                        : 'Generate with AI',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _coverLetterController,
              decoration: InputDecoration(
                hintText: 'Tell us why you\'re the perfect fit for this role...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(AppSizes.paddingL),
                helperText: 'Min 100 characters',
              ),
              maxLines: 8,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Cover letter is required';
                }
                if (value.trim().length < 100) {
                  return 'Cover letter must be at least 100 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // Additional Information
            Text(
              'Additional Information (Optional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _additionalInfoController,
              decoration: InputDecoration(
                hintText: 'Portfolio links, references, availability, salary expectations, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(AppSizes.paddingL),
              ),
              maxLines: 5,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // Terms and Conditions
            CheckboxListTile(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() => _agreeToTerms = value ?? false);
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: const TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // Submit Button
            SizedBox(
              height: AppSizes.buttonHeightL,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Application'),
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Cancel Button
            SizedBox(
              height: AppSizes.buttonHeightM,
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
