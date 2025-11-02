import 'package:flutter/material.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/features/candidate/widgets/job_card.dart';
import 'package:itjobhub/features/candidate/screens/job_detail_screen.dart';
import 'package:itjobhub/features/candidate/screens/saved_jobs_screen.dart';
import 'package:itjobhub/features/candidate/screens/job_search_screen.dart';
import 'package:itjobhub/services/job_service.dart';
import 'package:itjobhub/widgets/common/index.dart';
import 'package:itjobhub/widgets/common/notification_icon_button.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  final JobService _jobService = JobService();
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  
  // Filter state
  String? _selectedLocation;
  List<String> _selectedJobTypes = [];
  List<String> _selectedExperienceLevels = [];
  RangeValues _salaryRange = const RangeValues(0, 200000);
  bool _isPremiumOnly = false;
  bool _isRemoteOnly = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _searchController.addListener(_filterJobs);
    // Listen for bookmark changes
    _jobService.addBookmarkListener(_onBookmarkChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _jobService.removeBookmarkListener(_onBookmarkChanged);
    super.dispose();
  }
  
  void _onBookmarkChanged() {
    if (mounted) {
      setState(() {
        _jobs = _jobService.getAllJobs();
      });
      _filterJobs();
    }
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch jobs from real API
      await _jobService.fetchJobs();
      setState(() {
        _jobs = _jobService.getAllJobs();
        _filteredJobs = _jobs;
      });
    } catch (e) {
      print('Error loading jobs: $e');
      // Fallback to cached/mock data
      setState(() {
        _jobs = _jobService.getAllJobs();
        _filteredJobs = _jobs;
      });
    } finally {
      setState(() => _isLoading = false);
      _filterJobs();
    }
  }

  Future<void> _refreshJobs() async {
    await _loadJobs();
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _jobs.where((job) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            job.title.toLowerCase().contains(searchQuery) ||
            job.companyName.toLowerCase().contains(searchQuery) ||
            job.description.toLowerCase().contains(searchQuery);
        
        // Category filter
        final matchesCategory = _selectedCategory == 'All' ||
            (_selectedCategory == 'Remote' && job.location.toLowerCase().contains('remote')) ||
            job.jobType.displayName == _selectedCategory;
        
        // Location filter
        final matchesLocation = _selectedLocation == null ||
            _selectedLocation == 'All' ||
            job.location.contains(_selectedLocation!);
        
        // Job type filter
        final matchesJobType = _selectedJobTypes.isEmpty ||
            _selectedJobTypes.contains(job.jobType.displayName);
        
        return matchesSearch && matchesCategory && matchesLocation && matchesJobType;
      }).toList();
    });
  }
  
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedLocation = null;
                          _selectedJobTypes.clear();
                          _selectedExperienceLevels.clear();
                          _salaryRange = const RangeValues(0, 200000);
                          _isPremiumOnly = false;
                          _isRemoteOnly = false;
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
                                          final isSelected = _selectedLocation == location;
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
                                              setModalState(() {
                                                _selectedLocation = location == 'All Locations' ? null : location;
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
                                  _selectedLocation ?? 'Location',
                                  style: TextStyle(
                                    color: _selectedLocation != null ? Colors.black87 : Colors.grey[500],
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
                      
                      // Job Type Filter
                      Text(
                        'Job Type',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: ['Remote', 'Onsite', 'Hybrid'].map((type) {
                          final isSelected = _selectedJobTypes.contains(type);
                          return _ModernFilterChip(
                            label: type,
                            isSelected: isSelected,
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  _selectedJobTypes.remove(type);
                                } else {
                                  _selectedJobTypes.add(type);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Experience Level
                      Text(
                        'Experience Level',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: ['Junior', 'Mid-level', 'Senior', 'Lead/Principal'].map((level) {
                          final isSelected = _selectedExperienceLevels.contains(level);
                          return _ModernFilterChip(
                            label: level,
                            isSelected: isSelected,
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  _selectedExperienceLevels.remove(level);
                                } else {
                                  _selectedExperienceLevels.add(level);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Salary Range Filter
                      Text(
                        'Salary Range (Annual)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          '\$${(_salaryRange.start / 1000).toInt()}K - \$${(_salaryRange.end / 1000).toInt()}K',
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
                          max: 200000,
                          divisions: 40,
                          onChanged: (values) {
                            setModalState(() {
                              _salaryRange = values;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Premium and Remote toggles
                      _FilterToggle(
                        label: 'Premium jobs only',
                        value: _isPremiumOnly,
                        onChanged: (value) {
                          setModalState(() {
                            _isPremiumOnly = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _FilterToggle(
                        label: 'Remote jobs only',
                        value: _isRemoteOnly,
                        onChanged: (value) {
                          setModalState(() {
                            _isRemoteOnly = value;
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
                        setState(() {
                          _selectedLocation = _selectedLocation;
                          _selectedJobTypes = List.from(_selectedJobTypes);
                          _selectedExperienceLevels = List.from(_selectedExperienceLevels);
                          _salaryRange = _salaryRange;
                          _isPremiumOnly = _isPremiumOnly;
                          _isRemoteOnly = _isRemoteOnly;
                        });
                        _filterJobs();
                        Navigator.pop(context);
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
                        'Apply Filters (${_selectedJobTypes.length + _selectedExperienceLevels.length + (_selectedLocation != null ? 1 : 0) + (_isPremiumOnly ? 1 : 0) + (_isRemoteOnly ? 1 : 0)})',
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text and Saved Jobs Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find Your',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Dream Job',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Notification Icon
                          NotificationIconButton(),
                          const SizedBox(width: 8),
                          // Saved Jobs Icon
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.bookmark, color: AppColors.primary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SavedJobsScreen(),
                                  ),
                                );
                              },
                              tooltip: 'Saved Jobs',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Search Bar and Filter
                  Row(
                    children: [
                      // Search Bar - Tap to open advanced search
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const JobSearchScreen(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[400]),
                                const SizedBox(width: 12),
                                Text(
                                  'Search job, company...',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: _showFilterSheet,
                          tooltip: 'Filter Jobs',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryChip(
                          label: 'All',
                          isSelected: _selectedCategory == 'All',
                          onTap: () {
                            setState(() => _selectedCategory = 'All');
                            _filterJobs();
                          },
                        ),
                        _CategoryChip(
                          label: 'Remote',
                          isSelected: _selectedCategory == 'Remote',
                          onTap: () {
                            setState(() => _selectedCategory = 'Remote');
                            _filterJobs();
                          },
                        ),
                        _CategoryChip(
                          label: 'Full Time',
                          isSelected: _selectedCategory == 'Full Time',
                          onTap: () {
                            setState(() => _selectedCategory = 'Full Time');
                            _filterJobs();
                          },
                        ),
                        _CategoryChip(
                          label: 'Part Time',
                          isSelected: _selectedCategory == 'Part Time',
                          onTap: () {
                            setState(() => _selectedCategory = 'Part Time');
                            _filterJobs();
                          },
                        ),
                        _CategoryChip(
                          label: 'Contract',
                          isSelected: _selectedCategory == 'Contract',
                          onTap: () {
                            setState(() => _selectedCategory = 'Contract');
                            _filterJobs();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Jobs List Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Jobs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_filteredJobs.length} jobs',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Jobs List
            Expanded(
              child: _isLoading
                  ? const LoadingState(message: 'Finding jobs for you...')
                  : _filteredJobs.isEmpty
                      ? EmptyState(
                          icon: Icons.work_off_outlined,
                          title: 'No Jobs Found',
                          message: 'Try adjusting your search filters or check back later for new opportunities.',
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshJobs,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredJobs.length,
                            itemBuilder: (context, index) {
                              final job = _filteredJobs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: JobCard(
                                  job: job,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => JobDetailScreen(job: job),
                                      ),
                                    );
                                  },
                                  onBookmark: () {
                                    _jobService.toggleBookmark(job.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          job.isBookmarked
                                              ? 'Removed from bookmarks'
                                              : 'Added to bookmarks',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Category Chip Widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SelectableChip(
        label: label,
        isSelected: isSelected,
        onTap: onTap,
        size: ChipSize.medium,
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
