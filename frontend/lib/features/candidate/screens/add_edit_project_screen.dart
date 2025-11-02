import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/experience_project_model.dart';
import 'package:uuid/uuid.dart';

class AddEditProjectScreen extends StatefulWidget {
  final ExperienceProject? project; // null for new project

  const AddEditProjectScreen({
    super.key,
    this.project,
  });

  @override
  State<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roleController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _techController = TextEditingController();

  List<String> _technologies = [];
  bool _isCurrentProject = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _roleController.text = widget.project!.role ?? '';
      _projectUrlController.text = widget.project!.projectUrl ?? '';
      _startDateController.text = widget.project!.startDate ?? '';
      _endDateController.text = widget.project!.endDate ?? '';
      _technologies = List.from(widget.project!.technologies);
      _isCurrentProject = widget.project!.endDate == 'Present';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _roleController.dispose();
    _projectUrlController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _techController.dispose();
    super.dispose();
  }

  void _addTechnology() {
    if (_techController.text.trim().isNotEmpty) {
      setState(() {
        _technologies.add(_techController.text.trim());
        _techController.clear();
      });
    }
  }

  void _removeTechnology(String tech) {
    setState(() {
      _technologies.remove(tech);
    });
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      final project = ExperienceProject(
        id: widget.project?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        technologies: _technologies,
        role: _roleController.text.trim().isNotEmpty 
            ? _roleController.text.trim() 
            : null,
        projectUrl: _projectUrlController.text.trim().isNotEmpty 
            ? _projectUrlController.text.trim() 
            : null,
        startDate: _startDateController.text.trim().isNotEmpty 
            ? _startDateController.text.trim() 
            : null,
        endDate: _isCurrentProject 
            ? 'Present' 
            : (_endDateController.text.trim().isNotEmpty 
                ? _endDateController.text.trim() 
                : null),
      );

      Navigator.pop(context, project);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'Add Project'),
        actions: [
          TextButton(
            onPressed: _saveProject,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
            // Project Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work_outline),
                hintText: 'E-Commerce Mobile App',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter project name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingM),

            // Role
            TextFormField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: 'Your Role',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Lead Developer, Frontend Developer, etc.',
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
                hintText: 'Describe the project, your contributions, and key achievements',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter project description';
                }
                if (value.length < 50) {
                  return 'Description should be at least 50 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingM),

            // Project URL
            TextFormField(
              controller: _projectUrlController,
              decoration: const InputDecoration(
                labelText: 'Project URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
                hintText: 'https://github.com/user/project',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // Duration Section
            Text(
              'Project Duration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingM),

            // Start Date
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'YYYY-MM (e.g., 2023-01)',
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),

            // Current Project Checkbox
            CheckboxListTile(
              title: const Text('I am currently working on this project'),
              value: _isCurrentProject,
              onChanged: (value) {
                setState(() {
                  _isCurrentProject = value ?? false;
                  if (_isCurrentProject) {
                    _endDateController.clear();
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: AppSizes.spacingM),

            // End Date
            if (!_isCurrentProject)
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'YYYY-MM (e.g., 2023-06)',
                ),
              ),
            const SizedBox(height: AppSizes.spacingXL),

            // Technologies Section
            Text(
              'Technologies Used',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _techController,
                    decoration: const InputDecoration(
                      labelText: 'Add Technology',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Flutter, React, Node.js',
                    ),
                    onFieldSubmitted: (_) => _addTechnology(),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                ElevatedButton(
                  onPressed: _addTechnology,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            if (_technologies.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _technologies.map((tech) {
                  return Chip(
                    label: Text(tech),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTechnology(tech),
                    backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.accent),
                    side: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  );
                }).toList(),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No technologies added yet. Add technologies used in this project.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

            const SizedBox(height: AppSizes.spacingXL),
            const SizedBox(height: AppSizes.spacingXL),
          ],
        ),
      ),
    );
  }
}
