import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/education_model.dart';
import '../../core/constants/app_constants.dart';

/// Edit Education Screen
/// 
/// Form to add or edit education
class EditEducationScreen extends StatefulWidget {
  final Education? education;
  
  const EditEducationScreen({
    super.key,
    this.education,
  });

  @override
  State<EditEducationScreen> createState() => _EditEducationScreenState();
}

class _EditEducationScreenState extends State<EditEducationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _degreeController;
  late TextEditingController _majorController;
  late TextEditingController _institutionController;
  late TextEditingController _startYearController;
  late TextEditingController _endYearController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing data if editing
    _degreeController = TextEditingController(
      text: widget.education?.degree ?? '',
    );
    _majorController = TextEditingController(
      text: widget.education?.major ?? '',
    );
    _institutionController = TextEditingController(
      text: widget.education?.institution ?? '',
    );
    _startYearController = TextEditingController(
      text: widget.education?.startYear.toString() ?? '',
    );
    _endYearController = TextEditingController(
      text: widget.education?.endYear.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.education?.description ?? '',
    );
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _majorController.dispose();
    _institutionController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveEducation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startYear = int.tryParse(_startYearController.text.trim());
    final endYear = int.tryParse(_endYearController.text.trim());

    if (startYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid start year')),
      );
      return;
    }

    if (endYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid end year')),
      );
      return;
    }

    if (endYear < startYear) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End year must be after start year')),
      );
      return;
    }

    final education = Education(
      id: widget.education?.id ?? DateTime.now().toString(),
      degree: _degreeController.text.trim(),
      major: _majorController.text.trim(),
      institution: _institutionController.text.trim(),
      startYear: startYear,
      endYear: endYear,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
    );

    Navigator.pop(context, education);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.education != null;
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Education' : 'Add Education'),
        actions: [
          TextButton(
            onPressed: _saveEducation,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          children: [
            // Degree
            TextFormField(
              controller: _degreeController,
              decoration: const InputDecoration(
                labelText: 'Degree *',
                hintText: 'e.g., Bachelor of Science',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter degree';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Major/Field of Study
            TextFormField(
              controller: _majorController,
              decoration: const InputDecoration(
                labelText: 'Major/Field of Study *',
                hintText: 'e.g., Computer Science',
                prefixIcon: Icon(Icons.book_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter major';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Institution
            TextFormField(
              controller: _institutionController,
              decoration: const InputDecoration(
                labelText: 'Institution *',
                hintText: 'e.g., Stanford University',
                prefixIcon: Icon(Icons.account_balance),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter institution';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Year Range
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startYearController,
                    decoration: const InputDecoration(
                      labelText: 'Start Year *',
                      hintText: 'e.g., 2016',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final year = int.tryParse(value);
                      if (year == null || year < 1950 || year > currentYear + 5) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _endYearController,
                    decoration: const InputDecoration(
                      labelText: 'End Year *',
                      hintText: 'e.g., 2020',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final year = int.tryParse(value);
                      if (year == null || year < 1950 || year > currentYear + 10) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Description (optional)
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Activities, honors, coursework, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(AppSizes.paddingL),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // Helper Text
            Text(
              '* Required fields',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
