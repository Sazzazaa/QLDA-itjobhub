import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/review_model.dart';
import 'package:itjobhub/services/review_service.dart';
import 'package:itjobhub/services/user_state.dart';

/// Write Candidate Review Screen
/// 
/// Form for employers to review candidates after interviews
class WriteCandidateReviewScreen extends StatefulWidget {
  final String candidateId;
  final String candidateName;
  final String jobTitle;

  const WriteCandidateReviewScreen({
    super.key,
    required this.candidateId,
    required this.candidateName,
    required this.jobTitle,
  });

  @override
  State<WriteCandidateReviewScreen> createState() => _WriteCandidateReviewScreenState();
}

class _WriteCandidateReviewScreenState extends State<WriteCandidateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReviewService _reviewService = ReviewService();
  final UserState _userState = UserState();
  
  // Form fields
  double _overallRating = 3.0;
  double _skillsRating = 3.0;
  double _communicationRating = 3.0;
  double _professionalismRating = 3.0;
  double _punctualityRating = 3.0;
  
  final _reviewController = TextEditingController();
  
  bool _wouldWorkAgain = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final review = CandidateReview(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Backend will generate real ID
      candidateId: widget.candidateId,
      candidateName: widget.candidateName,
      employerId: _userState.userId ?? 'unknown',
      employerName: _userState.name ?? 'Unknown Employer',
      companyName: _userState.name ?? 'Unknown Company', // Using employer name as company
      jobTitle: widget.jobTitle,
      overallRating: _overallRating,
      skillsRating: _skillsRating,
      communicationRating: _communicationRating,
      professionalismRating: _professionalismRating,
      punctualityRating: _punctualityRating,
      reviewText: _reviewController.text,
      wouldWorkAgain: _wouldWorkAgain,
      createdAt: DateTime.now(),
    );

    try {
      await _reviewService.addCandidateReview(review);
      
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
        title: const Text('Review Candidate'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Candidate Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        widget.candidateName[0].toUpperCase(),
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
                            widget.candidateName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.jobTitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
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
              label: 'Technical Skills',
              value: _skillsRating,
              onChanged: (value) => setState(() => _skillsRating = value),
            ),
            _CategoryRating(
              label: 'Communication',
              value: _communicationRating,
              onChanged: (value) => setState(() => _communicationRating = value),
            ),
            _CategoryRating(
              label: 'Professionalism',
              value: _professionalismRating,
              onChanged: (value) => setState(() => _professionalismRating = value),
            ),
            _CategoryRating(
              label: 'Punctuality',
              value: _punctualityRating,
              onChanged: (value) => setState(() => _punctualityRating = value),
            ),
            const SizedBox(height: 24),

            // Review Text
            TextFormField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Your Feedback *',
                hintText: 'Share your experience working with this candidate',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please write your feedback';
                }
                if (value.trim().length < 50) {
                  return 'Feedback must be at least 50 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Would Work Again
            SwitchListTile(
              title: const Text(
                'Would work with this candidate again',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Recommend this candidate to other employers'),
              value: _wouldWorkAgain,
              onChanged: (value) => setState(() => _wouldWorkAgain = value),
              activeColor: AppColors.success,
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your review will help other employers and improve the candidate\'s profile.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
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
