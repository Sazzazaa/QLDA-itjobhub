import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/features/shared/screens/settings_screen.dart';
import 'package:itjobhub/services/user_profile_service.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🏢 EmployerProfileScreen: Loading employer profile...');
      final profile = await _profileService.fetchProfile();
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
        print('✅ EmployerProfileScreen: Profile loaded');
      }
    } catch (e) {
      print('❌ EmployerProfileScreen: Failed to load profile - $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withAlpha((255 * 0.1).toInt()),
                                shape: BoxShape.circle,
                              ),
                              child: _profile?['profileImage'] != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _profile!['profileImage'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.business,
                                          size: 50,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.business, size: 50, color: AppColors.primary),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingL),
                      
                      Text(
                        _profile?['companyName'] ?? _profile?['name'] ?? 'Company Name',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        _profile?['location'] ?? 'Location not set',
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.spacingXL),
                      
                      _ProfileSection(
                        title: 'Company Information',
                        items: [
                          _ProfileItem(
                            icon: Icons.business,
                            label: 'Industry',
                            value: _profile?['industry'] ?? 'Not specified',
                          ),
                          _ProfileItem(
                            icon: Icons.people,
                            label: 'Company Size',
                            value: _profile?['companySize'] ?? 'Not specified',
                          ),
                          _ProfileItem(
                            icon: Icons.language,
                            label: 'Website',
                            value: _profile?['companyWebsite'] ?? 'Not specified',
                          ),
                          _ProfileItem(
                            icon: Icons.email,
                            label: 'Email',
                            value: _profile?['email'] ?? 'Not specified',
                          ),
                          if (_profile?['phone'] != null)
                            _ProfileItem(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: _profile!['phone'],
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingL),
                      
                      _ProfileSection(
                        title: 'About Company',
                        items: [
                          Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            child: Text(
                              _profile?['companyDescription'] ?? 'No company description provided.',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingL),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCompanyProfileScreen(profile: _profile),
                              ),
                            );
                            
                            // Reload profile if edited
                            if (result == true) {
                              _loadProfile();
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Company Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.spacingM),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}

// Edit Company Profile Screen
class EditCompanyProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  
  const EditCompanyProfileScreen({super.key, this.profile});

  @override
  State<EditCompanyProfileScreen> createState() => _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _companyNameController;
  late final TextEditingController _industryController;
  late final TextEditingController _locationController;
  late final TextEditingController _websiteController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _aboutController;
  
  String? _companySize;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current profile data
    _companyNameController = TextEditingController(
      text: widget.profile?['companyName'] ?? widget.profile?['name'] ?? '',
    );
    _industryController = TextEditingController(
      text: widget.profile?['industry'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.profile?['location'] ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.profile?['companyWebsite'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.profile?['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.profile?['phone'] ?? '',
    );
    _aboutController = TextEditingController(
      text: widget.profile?['companyDescription'] ?? '',
    );
    _companySize = widget.profile?['companySize'];
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      print('💾 EditCompanyProfileScreen: Saving profile...');
      
      final updates = {
        'companyName': _companyNameController.text.trim(),
        'name': _companyNameController.text.trim(), // Update name too for display
        'industry': _industryController.text.trim(),
        'location': _locationController.text.trim(),
        'companyWebsite': _websiteController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'companyDescription': _aboutController.text.trim(),
        if (_companySize != null) 'companySize': _companySize,
      };

      await _profileService.updateProfile(updates);
      
      if (mounted) {
        print('✅ EditCompanyProfileScreen: Profile saved successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Company profile updated successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate profile was updated
      }
    } catch (e) {
      print('❌ EditCompanyProfileScreen: Failed to save - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Company Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo upload section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withAlpha((255 * 0.1).toInt()),
                        shape: BoxShape.circle,
                      ),
                      child: widget.profile?['profileImage'] != null
                          ? ClipOval(
                              child: Image.network(
                                widget.profile!['profileImage'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.business,
                                  size: 60,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : const Icon(Icons.business, size: 60, color: AppColors.primary),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Logo upload coming soon')),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),

              // Company Name
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Company name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacingL),

              // Industry
              TextFormField(
                controller: _industryController,
                decoration: const InputDecoration(
                  labelText: 'Industry',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),

              // Company Size
              DropdownButtonFormField<String>(
                value: _companySize,
                decoration: const InputDecoration(
                  labelText: 'Company Size',
                  prefixIcon: Icon(Icons.people),
                ),
                items: const [
                  DropdownMenuItem(value: '1-10 employees', child: Text('1-10 employees')),
                  DropdownMenuItem(value: '11-50 employees', child: Text('11-50 employees')),
                  DropdownMenuItem(value: '50-200 employees', child: Text('50-200 employees')),
                  DropdownMenuItem(value: '200-500 employees', child: Text('200-500 employees')),
                  DropdownMenuItem(value: '500+ employees', child: Text('500+ employees')),
                ],
                onChanged: (value) {
                  setState(() => _companySize = value);
                },
              ),
              const SizedBox(height: AppSizes.spacingL),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  prefixIcon: Icon(Icons.language),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSizes.spacingL),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacingL),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.spacingL),

              // About Company
              TextFormField(
                controller: _aboutController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'About Company',
                  prefixIcon: Icon(Icons.info_outline),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
