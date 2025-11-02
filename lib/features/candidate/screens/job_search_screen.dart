import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/models/job_search_filter.dart';
import 'package:itjobhub/features/candidate/widgets/job_card.dart';
import 'package:itjobhub/features/candidate/screens/job_detail_screen.dart';
import 'package:itjobhub/services/job_service.dart';

/// Job Search Screen
/// 
/// Advanced search screen with filters for finding jobs
class JobSearchScreen extends StatefulWidget {
  final JobSearchFilter? initialFilter;
  
  const JobSearchScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final _searchController = TextEditingController();
  final _jobService = JobService();
  late JobSearchFilter _currentFilter;
  List<Job> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter ?? const JobSearchFilter();
    _searchController.text = _currentFilter.keyword ?? '';
    
    // If initial filter has content, perform search
    if (_currentFilter.hasActiveFilters) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty && !_currentFilter.hasActiveFilters) {
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      print('🔍 JobSearchScreen: Searching jobs with filters...');
      
      // Fetch all jobs from API
      final allJobs = await _jobService.fetchJobs();
      final query = _searchController.text.toLowerCase().trim();
      
      // Apply client-side filtering
      final filteredJobs = allJobs.where((job) {
        // Keyword matching
        final matchesKeyword = query.isEmpty ||
            job.title.toLowerCase().contains(query) ||
            job.companyName.toLowerCase().contains(query) ||
            job.techStack.any((skill) => skill.toLowerCase().contains(query));
        
        // Apply other filters from JobSearchFilter
        final matchesLocation = _currentFilter.location == null ||
            job.location.toLowerCase().contains(_currentFilter.location!.toLowerCase());
        
        final matchesJobType = _currentFilter.jobTypes == null || 
            _currentFilter.jobTypes!.isEmpty ||
            _currentFilter.jobTypes!.contains(job.jobType);
        
        final matchesExperience = _currentFilter.experienceLevels == null ||
            _currentFilter.experienceLevels!.isEmpty ||
            _currentFilter.experienceLevels!.contains(job.experienceLevel);
        
        return matchesKeyword && matchesLocation && matchesJobType && matchesExperience;
      }).toList();
      
      setState(() {
        _searchResults = filteredJobs;
      });
      
      print('✅ JobSearchScreen: Found ${filteredJobs.length} matching jobs');
    } catch (e) {
      print('❌ JobSearchScreen: Error searching jobs - $e');
      setState(() {
        _searchResults = [];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to search jobs: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _currentFilter = const JobSearchFilter();
      _searchResults = [];
      _hasSearched = false;
    });
  }

  Future<void> _showFilterBottomSheet() async {
    final result = await showModalBottomSheet<JobSearchFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(initialFilter: _currentFilter),
    );

    if (result != null) {
      setState(() {
        _currentFilter = result;
      });
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Jobs'),
        actions: [
          if (_currentFilter.hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all filters',
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search jobs, companies, keywords...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  onSubmitted: (_) => _performSearch(),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSearching ? null : _performSearch,
                        icon: _isSearching
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    Badge(
                      isLabelVisible: _currentFilter.activeFilterCount > 0,
                      label: Text(_currentFilter.activeFilterCount.toString()),
                      child: OutlinedButton.icon(
                        onPressed: _showFilterBottomSheet,
                        icon: const Icon(Icons.tune),
                        label: const Text('Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Active Filters Chips
          if (_currentFilter.activeFilterCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
              color: AppColors.primary.withValues(alpha: 0.05),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildFilterChips(),
              ),
            ),

          // Results
          Expanded(
            child: _buildResultsView(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    final chips = <Widget>[];

    if (_currentFilter.location != null) {
      chips.add(_FilterChip(
        label: _currentFilter.location!,
        onDeleted: () {
          setState(() {
            _currentFilter = _currentFilter.copyWith(clearLocation: true);
          });
          _performSearch();
        },
      ));
    }

    if (_currentFilter.jobTypes != null && _currentFilter.jobTypes!.isNotEmpty) {
      for (final type in _currentFilter.jobTypes!) {
        chips.add(_FilterChip(
          label: type.displayName,
          onDeleted: () {
            setState(() {
              final types = List<JobType>.from(_currentFilter.jobTypes!);
              types.remove(type);
              _currentFilter = _currentFilter.copyWith(
                jobTypes: types.isEmpty ? null : types,
                clearJobTypes: types.isEmpty,
              );
            });
            _performSearch();
          },
        ));
      }
    }

    if (_currentFilter.experienceLevels != null && _currentFilter.experienceLevels!.isNotEmpty) {
      for (final level in _currentFilter.experienceLevels!) {
        chips.add(_FilterChip(
          label: level.displayName,
          onDeleted: () {
            setState(() {
              final levels = List<ExperienceLevel>.from(_currentFilter.experienceLevels!);
              levels.remove(level);
              _currentFilter = _currentFilter.copyWith(
                experienceLevels: levels.isEmpty ? null : levels,
                clearExperienceLevels: levels.isEmpty,
              );
            });
            _performSearch();
          },
        ));
      }
    }

    if (_currentFilter.minSalary != null || _currentFilter.maxSalary != null) {
      final min = _currentFilter.minSalary?.toInt() ?? 0;
      final max = _currentFilter.maxSalary?.toInt() ?? 0;
      chips.add(_FilterChip(
        label: '\$${min}K - \$${max}K',
        onDeleted: () {
          setState(() {
            _currentFilter = _currentFilter.copyWith(clearSalary: true);
          });
          _performSearch();
        },
      ));
    }

    if (_currentFilter.techStack != null && _currentFilter.techStack!.isNotEmpty) {
      for (final tech in _currentFilter.techStack!) {
        chips.add(_FilterChip(
          label: tech,
          onDeleted: () {
            setState(() {
              final stack = List<String>.from(_currentFilter.techStack!);
              stack.remove(tech);
              _currentFilter = _currentFilter.copyWith(
                techStack: stack.isEmpty ? null : stack,
                clearTechStack: stack.isEmpty,
              );
            });
            _performSearch();
          },
        ));
      }
    }

    return chips;
  }

  Widget _buildResultsView() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'Search for jobs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              'Enter keywords or use filters\nto find your dream job',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'No jobs found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      itemCount: _searchResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingL),
            child: Text(
              '${_searchResults.length} ${_searchResults.length == 1 ? 'job' : 'jobs'} found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        }

        final job = _searchResults[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
          child: JobCard(
            job: job,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailScreen(job: job),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: AppColors.primary),
    );
  }
}

// Filter Bottom Sheet will be in the next file for better organization
class _FilterBottomSheet extends StatefulWidget {
  final JobSearchFilter initialFilter;

  const _FilterBottomSheet({required this.initialFilter});

  @override
  State<_FilterBottomSheet> createState() => __FilterBottomSheetState();
}

class __FilterBottomSheetState extends State<_FilterBottomSheet> {
  late JobSearchFilter _filter;
  final _locationController = TextEditingController();
  late RangeValues _salaryRange;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _locationController.text = _filter.location ?? '';
    _salaryRange = RangeValues(
      _filter.minSalary ?? 0,
      _filter.maxSalary ?? 200,
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = const JobSearchFilter();
                      _locationController.clear();
                      _salaryRange = const RangeValues(0, 200);
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Filter - Tappable
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => SafeArea(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.6,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Handle bar
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                
                                // Header
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Select Location',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Scrollable list
                                Flexible(
                                  child: ListView(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(bottom: 20),
                                    children: ['All Locations', 'Remote', 'New York', 'San Francisco', 'London', 'Berlin', 'Tokyo', 'Sydney'].map((location) {
                                      final isSelected = _filter.location == location || 
                                          (location == 'All Locations' && _filter.location == null);
                                      return ListTile(
                                        leading: Icon(
                                          isSelected ? Icons.check_circle : Icons.location_on_outlined,
                                          color: isSelected ? AppColors.primary : Colors.grey[400],
                                        ),
                                        title: Text(
                                          location,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            color: isSelected ? AppColors.primary : Colors.black87,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            final newLocation = location == 'All Locations' ? null : location;
                                            _filter = _filter.copyWith(
                                              location: newLocation,
                                              clearLocation: newLocation == null,
                                            );
                                            _locationController.text = newLocation ?? '';
                                          });
                                          Navigator.pop(context);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _filter.location ?? 'Location',
                              style: TextStyle(
                                color: _filter.location != null ? Colors.black87 : Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Job Type
                  Text(
                    'Job Type',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: JobType.values.map((type) {
                      final isSelected = _filter.jobTypes?.contains(type) ?? false;
                      return _ModernFilterChip(
                        label: type.displayName,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            final types = List<JobType>.from(_filter.jobTypes ?? []);
                            if (isSelected) {
                              types.remove(type);
                            } else {
                              types.add(type);
                            }
                            _filter = _filter.copyWith(
                              jobTypes: types.isEmpty ? null : types,
                              clearJobTypes: types.isEmpty,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Experience Level
                  Text(
                    'Experience Level',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ExperienceLevel.values.map((level) {
                      final isSelected = _filter.experienceLevels?.contains(level) ?? false;
                      return _ModernFilterChip(
                        label: level.displayName,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            final levels = List<ExperienceLevel>.from(_filter.experienceLevels ?? []);
                            if (isSelected) {
                              levels.remove(level);
                            } else {
                              levels.add(level);
                            }
                            _filter = _filter.copyWith(
                              experienceLevels: levels.isEmpty ? null : levels,
                              clearExperienceLevels: levels.isEmpty,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Salary Range
                  Text(
                    'Salary Range (Annual)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${_salaryRange.start.toInt()}K - \$${_salaryRange.end.toInt()}K',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.1),
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                    ),
                    child: RangeSlider(
                      values: _salaryRange,
                      min: 0,
                      max: 200,
                      divisions: 40,
                      onChanged: (values) {
                        setState(() {
                          _salaryRange = values;
                          _filter = _filter.copyWith(
                            minSalary: values.start,
                            maxSalary: values.end,
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Additional Options
                  _FilterToggle(
                    label: 'Premium jobs only',
                    value: _filter.isPremiumOnly ?? false,
                    onChanged: (value) {
                      setState(() {
                        _filter = _filter.copyWith(
                          isPremiumOnly: value,
                          clearPremiumOnly: value == false,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _FilterToggle(
                    label: 'Remote jobs only',
                    value: _filter.hasRemoteOption ?? false,
                    onChanged: (value) {
                      setState(() {
                        _filter = _filter.copyWith(
                          hasRemoteOption: value,
                          clearRemoteOption: value == false,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _filter);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filters (${_filter.activeFilterCount})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Filter Chip Widget
class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// Filter Toggle Widget
class _FilterToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Checkbox(
            value: value,
            onChanged: (val) => onChanged(val ?? false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
