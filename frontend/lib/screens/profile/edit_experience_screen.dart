import 'package:flutter/material.dart';
import '../../models/experience_model.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/skill_input.dart';

/// Edit Experience Screen
/// 
/// Form to add or edit work experience
class EditExperienceScreen extends StatefulWidget {
  final Experience? experience;
  
  const EditExperienceScreen({
    super.key,
    this.experience,
  });

  @override
  State<EditExperienceScreen> createState() => _EditExperienceScreenState();
}

class _EditExperienceScreenState extends State<EditExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _jobTitleController;
  late TextEditingController _companyController;
  late TextEditingController _descriptionController;
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentlyWorking = false;
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing data if editing
    _jobTitleController = TextEditingController(
      text: widget.experience?.jobTitle ?? '',
    );
    _companyController = TextEditingController(
      text: widget.experience?.company ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.experience?.description ?? '',
    );
    
    _startDate = widget.experience?.startDate;
    _endDate = widget.experience?.endDate;
    _isCurrentlyWorking = widget.experience?.isCurrentlyWorking ?? false;
    _skills = List.from(widget.experience?.skills ?? []);
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.month}/${date.year}';
  }

  void _saveExperience() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    if (!_isCurrentlyWorking && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date or mark as current')),
      );
      return;
    }

    final experience = Experience(
      id: widget.experience?.id ?? DateTime.now().toString(),
      jobTitle: _jobTitleController.text.trim(),
      company: _companyController.text.trim(),
      startDate: _startDate!,
      endDate: _isCurrentlyWorking ? null : _endDate,
      isCurrentlyWorking: _isCurrentlyWorking,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      skills: _skills.isEmpty ? null : _skills,
    );

    Navigator.pop(context, experience);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.experience != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Experience' : 'Add Experience'),
        actions: [
          TextButton(
            onPressed: _saveExperience,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          children: [
            // Job Title
            TextFormField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                hintText: 'e.g., Senior Flutter Developer',
                prefixIcon: Icon(Icons.work_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter job title';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Company
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company *',
                hintText: 'e.g., Google',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date *',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _formatDate(_startDate),
                        style: _startDate == null
                            ? theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              )
                            : theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: InkWell(
                    onTap: _isCurrentlyWorking 
                        ? null 
                        : () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        enabled: !_isCurrentlyWorking,
                      ),
                      child: Text(
                        _isCurrentlyWorking 
                            ? 'Present' 
                            : _formatDate(_endDate),
                        style: (_endDate == null && !_isCurrentlyWorking)
                            ? theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              )
                            : theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),

            // Currently Working Checkbox
            CheckboxListTile(
              title: const Text('I currently work here'),
              value: _isCurrentlyWorking,
              onChanged: (value) {
                setState(() {
                  _isCurrentlyWorking = value ?? false;
                  if (_isCurrentlyWorking) {
                    _endDate = null;
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your responsibilities and achievements...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(AppSizes.paddingL),
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.spacingL),

            // Skills Section
            Text(
              'Skills Used',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            SkillInput(
              selectedSkills: _skills,
              onSkillsChanged: (skills) {
                setState(() {
                  _skills = skills;
                });
              },
              maxSkills: 10,
              hint: 'Add skills used in this role',
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
