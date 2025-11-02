import 'package:equatable/equatable.dart';
import 'package:itjobhub/models/job_model.dart';

/// Job Search Filter
/// 
/// Model for managing job search criteria
class JobSearchFilter extends Equatable {
  final String? keyword;
  final String? location;
  final List<JobType>? jobTypes;
  final List<ExperienceLevel>? experienceLevels;
  final double? minSalary;
  final double? maxSalary;
  final List<String>? techStack;
  final bool? isPremiumOnly;
  final bool? hasRemoteOption;
  final DateTime? postedAfter;

  const JobSearchFilter({
    this.keyword,
    this.location,
    this.jobTypes,
    this.experienceLevels,
    this.minSalary,
    this.maxSalary,
    this.techStack,
    this.isPremiumOnly,
    this.hasRemoteOption,
    this.postedAfter,
  });

  /// Check if any filters are active
  bool get hasActiveFilters {
    return keyword != null && keyword!.isNotEmpty ||
        location != null && location!.isNotEmpty ||
        (jobTypes != null && jobTypes!.isNotEmpty) ||
        (experienceLevels != null && experienceLevels!.isNotEmpty) ||
        minSalary != null ||
        maxSalary != null ||
        (techStack != null && techStack!.isNotEmpty) ||
        isPremiumOnly == true ||
        hasRemoteOption == true ||
        postedAfter != null;
  }

  /// Count active filters (excluding keyword)
  int get activeFilterCount {
    int count = 0;
    if (location != null && location!.isNotEmpty) count++;
    if (jobTypes != null && jobTypes!.isNotEmpty) count++;
    if (experienceLevels != null && experienceLevels!.isNotEmpty) count++;
    if (minSalary != null || maxSalary != null) count++;
    if (techStack != null && techStack!.isNotEmpty) count++;
    if (isPremiumOnly == true) count++;
    if (hasRemoteOption == true) count++;
    if (postedAfter != null) count++;
    return count;
  }

  /// Clear all filters
  JobSearchFilter clearAll() {
    return const JobSearchFilter();
  }

  JobSearchFilter copyWith({
    String? keyword,
    String? location,
    List<JobType>? jobTypes,
    List<ExperienceLevel>? experienceLevels,
    double? minSalary,
    double? maxSalary,
    List<String>? techStack,
    bool? isPremiumOnly,
    bool? hasRemoteOption,
    DateTime? postedAfter,
    bool clearKeyword = false,
    bool clearLocation = false,
    bool clearJobTypes = false,
    bool clearExperienceLevels = false,
    bool clearSalary = false,
    bool clearTechStack = false,
    bool clearPremiumOnly = false,
    bool clearRemoteOption = false,
    bool clearPostedAfter = false,
  }) {
    return JobSearchFilter(
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      location: clearLocation ? null : (location ?? this.location),
      jobTypes: clearJobTypes ? null : (jobTypes ?? this.jobTypes),
      experienceLevels: clearExperienceLevels ? null : (experienceLevels ?? this.experienceLevels),
      minSalary: clearSalary ? null : (minSalary ?? this.minSalary),
      maxSalary: clearSalary ? null : (maxSalary ?? this.maxSalary),
      techStack: clearTechStack ? null : (techStack ?? this.techStack),
      isPremiumOnly: clearPremiumOnly ? null : (isPremiumOnly ?? this.isPremiumOnly),
      hasRemoteOption: clearRemoteOption ? null : (hasRemoteOption ?? this.hasRemoteOption),
      postedAfter: clearPostedAfter ? null : (postedAfter ?? this.postedAfter),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'location': location,
      'jobTypes': jobTypes?.map((e) => e.name).toList(),
      'experienceLevels': experienceLevels?.map((e) => e.name).toList(),
      'minSalary': minSalary,
      'maxSalary': maxSalary,
      'techStack': techStack,
      'isPremiumOnly': isPremiumOnly,
      'hasRemoteOption': hasRemoteOption,
      'postedAfter': postedAfter?.toIso8601String(),
    };
  }

  factory JobSearchFilter.fromJson(Map<String, dynamic> json) {
    return JobSearchFilter(
      keyword: json['keyword'] as String?,
      location: json['location'] as String?,
      jobTypes: (json['jobTypes'] as List<dynamic>?)
          ?.map((e) => JobType.values.byName(e as String))
          .toList(),
      experienceLevels: (json['experienceLevels'] as List<dynamic>?)
          ?.map((e) => ExperienceLevel.values.byName(e as String))
          .toList(),
      minSalary: (json['minSalary'] as num?)?.toDouble(),
      maxSalary: (json['maxSalary'] as num?)?.toDouble(),
      techStack: (json['techStack'] as List<dynamic>?)?.cast<String>(),
      isPremiumOnly: json['isPremiumOnly'] as bool?,
      hasRemoteOption: json['hasRemoteOption'] as bool?,
      postedAfter: json['postedAfter'] != null
          ? DateTime.parse(json['postedAfter'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        keyword,
        location,
        jobTypes,
        experienceLevels,
        minSalary,
        maxSalary,
        techStack,
        isPremiumOnly,
        hasRemoteOption,
        postedAfter,
      ];
}

/// Saved Search
/// 
/// Model for saving frequently used search queries
class SavedSearch extends Equatable {
  final String id;
  final String name;
  final JobSearchFilter filter;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  const SavedSearch({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
    this.lastUsedAt,
  });

  SavedSearch copyWith({
    String? id,
    String? name,
    JobSearchFilter? filter,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      name: name ?? this.name,
      filter: filter ?? this.filter,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filter': filter.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'] as String,
      name: json['name'] as String,
      filter: JobSearchFilter.fromJson(json['filter'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, filter, createdAt, lastUsedAt];
}
