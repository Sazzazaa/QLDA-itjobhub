import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/review_model.dart';
import 'package:itjobhub/services/review_service.dart';
import 'package:itjobhub/services/user_state.dart';

/// Write Company Review Screen
/// 
/// Form for candidates to write a review for a company
class WriteCompanyReviewScreen extends StatefulWidget {
  final String companyId;
  final String companyName;

  const WriteCompanyReviewScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<WriteCompanyReviewScreen> createState() => _WriteCompanyReviewScreenState();
}

class _WriteCompanyReviewScreenState extends State<WriteCompanyReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReviewService _reviewService = ReviewService();
  final UserState _userState = UserState();
  
  // Form fields
  double _overallRating = 3.0;
  double _cultureRating = 3.0;
  double _compensationRating = 3.0;
  double _workLifeBalanceRating = 3.0;
  double _managementRating = 3.0;
  
  final _titleController = TextEditingController();
  final _reviewController = TextEditingController();
  final _prosController = TextEditingController();
  final _consController = TextEditingController();
  final _adviceController = TextEditingController();
  
  bool _isAnonymous = false;
  bool _isCurrentEmployee = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    _prosController.dispose();
    _consController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final review = CompanyReview(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Backend will generate
      companyId: widget.companyId,
      companyName: widget.companyName,
      reviewerId: _userState.userId ?? 'unknown',
      reviewerName: _isAnonymous ? 'Anonymous' : (_userState.name ?? 'Unknown User'),
      isAnonymous: _isAnonymous,
      isCurrentEmployee: _isCurrentEmployee,
      overallRating: _overallRating,
      cultureRating: _cultureRating,
      compensationRating: _compensationRating,
      workLifeBalanceRating: _workLifeBalanceRating,
      managementRating: _managementRating,
      title: _titleController.text.isEmpty ? null : _titleController.text,
      reviewText: _reviewController.text,
      pros: _prosController.text.isEmpty ? null : _prosController.text,
      cons: _consController.text.isEmpty ? null : _consController.text,
      adviceToManagement: _adviceController.text.isEmpty ? null : _adviceController.text,
      createdAt: DateTime.now(),
    );

    try {
      await _reviewService.addCompanyReview(review);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${widget.companyName}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Company Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        widget.companyName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.companyName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Share your experience',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Overall Rating
            Text(
              'Overall Rating *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _RatingSlider(
              value: _overallRating,
              onChanged: (value) => setState(() => _overallRating = value),
            ),
            const SizedBox(height: 24),

            // Category Ratings
            Text(
              'Rate Specific Areas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _CategoryRating(
              label: 'Culture',
              value: _cultureRating,
              onChanged: (value) => setState(() => _cultureRating = value),
            ),
            _CategoryRating(
              label: 'Compensation',
              value: _compensationRating,
              onChanged: (value) => setState(() => _compensationRating = value),
            ),
            _CategoryRating(
              label: 'Work-Life Balance',
              value: _workLifeBalanceRating,
              onChanged: (value) => setState(() => _workLifeBalanceRating = value),
            ),
            _CategoryRating(
              label: 'Management',
              value: _managementRating,
              onChanged: (value) => setState(() => _managementRating = value),
            ),
            const SizedBox(height: 24),

            // Review Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Review Title (Optional)',
                hintText: 'Summarize your experience',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Review Text
            TextFormField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Your Review *',
                hintText: 'Share details about your experience working at this company',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please write your review';
                }
                if (value.trim().length < 50) {
                  return 'Review must be at least 50 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Pros
            TextFormField(
              controller: _prosController,
              decoration: const InputDecoration(
                labelText: 'Pros (Optional)',
                hintText: 'What do you like about this company?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_circle, color: AppColors.success),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Cons
            TextFormField(
              controller: _consController,
              decoration: const InputDecoration(
                labelText: 'Cons (Optional)',
                hintText: 'What could be improved?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.remove_circle, color: AppColors.error),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Advice to Management
            TextFormField(
              controller: _adviceController,
              decoration: const InputDecoration(
                labelText: 'Advice to Management (Optional)',
                hintText: 'What would you advise management to improve?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 24),

            // Options
            SwitchListTile(
              title: const Text('Post anonymously'),
              subtitle: const Text('Your name will not be shown'),
              value: _isAnonymous,
              onChanged: (value) => setState(() => _isAnonymous = value),
            ),
            SwitchListTile(
              title: const Text('I am a current employee'),
              value: _isCurrentEmployee,
              onChanged: (value) => setState(() => _isCurrentEmployee = value),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RatingSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _RatingSlider({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.star, color: AppColors.warning, size: 48),
          ],
        ),
        Slider(
          value: value,
          min: 1.0,
          max: 5.0,
          divisions: 8,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            5,
            (index) => Icon(
              index < value.round() ? Icons.star : Icons.star_border,
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRating extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _CategoryRating({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 16, color: AppColors.warning),
                ],
              ),
            ],
          ),
          Slider(
            value: value,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
