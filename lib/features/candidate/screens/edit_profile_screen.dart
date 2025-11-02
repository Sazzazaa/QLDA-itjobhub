import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/candidate_model.dart';
import 'package:itjobhub/models/experience_project_model.dart';
import 'package:itjobhub/features/candidate/screens/projects_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String location;
  final List<String> skills;
  final List<ExperienceProject>? projects;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final double? desiredSalary;
  final WorkLocation? workLocation;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.skills,
    this.projects,
    this.githubUrl,
    this.linkedinUrl,
    this.portfolioUrl,
    this.desiredSalary,
    this.workLocation,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _desiredSalaryController = TextEditingController();
  final _skillController = TextEditingController();

  List<String> _skills = [];
  List<ExperienceProject> _projects = [];
  WorkLocation _selectedWorkLocation = WorkLocation.hybrid;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _emailController.text = widget.email;
    _phoneController.text = widget.phone;
    _locationController.text = widget.location;
    _githubController.text = widget.githubUrl ?? '';
    _linkedinController.text = widget.linkedinUrl ?? '';
    _portfolioController.text = widget.portfolioUrl ?? '';
    _desiredSalaryController.text = widget.desiredSalary?.toString() ?? '';
    _skills = List.from(widget.skills);
    _projects = widget.projects != null ? List.from(widget.projects!) : [];
    _selectedWorkLocation = widget.workLocation ?? WorkLocation.hybrid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _desiredSalaryController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _manageProjects() async {
    final result = await Navigator.push<List<ExperienceProject>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectsScreen(initialProjects: _projects),
      ),
    );

    if (result != null) {
      setState(() {
        _projects = result;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to backend/state management
      Navigator.pop(context, {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'githubUrl': _githubController.text.isNotEmpty ? _githubController.text : null,
        'linkedinUrl': _linkedinController.text.isNotEmpty ? _linkedinController.text : null,
        'portfolioUrl': _portfolioController.text.isNotEmpty ? _portfolioController.text : null,
        'desiredSalary': _desiredSalaryController.text.isNotEmpty 
            ? double.tryParse(_desiredSalaryController.text) 
            : null,
        'workLocation': _selectedWorkLocation,
        'skills': _skills,
        'projects': _projects,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
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
            // Basic Information Section
            _SectionHeader(title: 'Basic Information'),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.spacingXL),

            // Social Links Section
            _SectionHeader(title: 'Social Links'),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(
                labelText: 'GitHub URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
                hintText: 'https://github.com/username',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _linkedinController,
              decoration: const InputDecoration(
                labelText: 'LinkedIn URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work_outline),
                hintText: 'https://linkedin.com/in/username',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _portfolioController,
              decoration: const InputDecoration(
                labelText: 'Portfolio URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
                hintText: 'https://yourportfolio.com',
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: AppSizes.spacingXL),

            // Skills Section
            _SectionHeader(title: 'Skills'),
            const SizedBox(height: AppSizes.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      labelText: 'Add Skill',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., React.js, Node.js',
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                ElevatedButton(
                  onPressed: _addSkill,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            if (_skills.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeSkill(skill),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.primary),
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
                  'No skills added yet. Add skills to showcase your expertise.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

            const SizedBox(height: AppSizes.spacingXL),

            // Experience Projects Section
            _SectionHeader(title: 'Experience Projects'),
            const SizedBox(height: AppSizes.spacingM),
            Card(
              child: InkWell(
                onTap: _manageProjects,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.work_outline,
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage Projects',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_projects.length} project${_projects.length != 1 ? 's' : ''} added',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
              child: Text(
                'Showcase your professional experience by adding projects with technologies and achievements',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacingXL),

            // Work Preferences Section
            _SectionHeader(title: 'Work Preferences'),
            const SizedBox(height: AppSizes.spacingM),
            TextFormField(
              controller: _desiredSalaryController,
              decoration: const InputDecoration(
                labelText: 'Desired Salary (USD/year)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                hintText: '80000',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            
            // Work Location
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: Row(
                      children: [
                        Icon(Icons.location_city_outlined, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Work Location Preference',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  RadioListTile<WorkLocation>(
                    title: const Text('Remote'),
                    subtitle: const Text('Work from anywhere'),
                    value: WorkLocation.remote,
                    groupValue: _selectedWorkLocation,
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<WorkLocation>(
                    title: const Text('Onsite'),
                    subtitle: const Text('Work from office'),
                    value: WorkLocation.onsite,
                    groupValue: _selectedWorkLocation,
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkLocation = value!;
                      });
                    },
                  ),
                  RadioListTile<WorkLocation>(
                    title: const Text('Hybrid'),
                    subtitle: const Text('Mix of remote and onsite'),
                    value: WorkLocation.hybrid,
                    groupValue: _selectedWorkLocation,
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkLocation = value!;
                      });
                    },
                  ),
                ],
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
    );
  }
}
