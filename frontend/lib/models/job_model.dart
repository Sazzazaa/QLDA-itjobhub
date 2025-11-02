import 'package:equatable/equatable.dart';

enum JobType {
  remote,
  onsite,
  hybrid,
}

extension JobTypeExtension on JobType {
  String get displayName {
    switch (this) {
      case JobType.remote:
        return 'Remote';
      case JobType.onsite:
        return 'Onsite';
      case JobType.hybrid:
        return 'Hybrid';
    }
  }
}

enum ExperienceLevel {
  junior,
  mid,
  senior,
  lead,
}

extension ExperienceLevelExtension on ExperienceLevel {
  String get displayName {
    switch (this) {
      case ExperienceLevel.junior:
        return 'Junior';
      case ExperienceLevel.mid:
        return 'Mid-level';
      case ExperienceLevel.senior:
        return 'Senior';
      case ExperienceLevel.lead:
        return 'Lead/Principal';
    }
  }
}

class Job extends Equatable {
  final String id;
  final String title;
  final String companyName;
  final String? companyLogo;
  final String description;
  final String requirements;
  final String? benefits;
  final JobType jobType;
  final ExperienceLevel experienceLevel;
  final String location;
  final double? salaryMin;
  final double? salaryMax;
  final String? salaryCurrency;
  final List<String> techStack;
  final DateTime postedDate;
  final DateTime? deadline;
  final bool isPremium;
  final bool isBookmarked;
  final bool hasApplied;
  final int applicantCount;
  final String? employerId; // Add employerId field

  const Job({
    required this.id,
    required this.title,
    required this.companyName,
    this.companyLogo,
    required this.description,
    required this.requirements,
    this.benefits,
    required this.jobType,
    required this.experienceLevel,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'USD',
    required this.techStack,
    required this.postedDate,
    this.deadline,
    this.isPremium = false,
    this.isBookmarked = false,
    this.hasApplied = false,
    this.applicantCount = 0,
    this.employerId, // Add to constructor
  });

  /// Create Job from JSON (API response)
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      companyName: json['companyName'] ?? '',
      companyLogo: json['companyLogo'],
      description: json['description'] ?? '',
      // Convert array to string if needed
      requirements: _parseStringOrList(json['requirements']),
      benefits: _parseStringOrList(json['benefits']),
      jobType: _parseJobType(json['jobType']),
      experienceLevel: _parseExperienceLevel(json['experienceLevel']),
      location: json['location'] ?? '',
      salaryMin: json['salaryMin']?.toDouble() ?? json['minSalary']?.toDouble(),
      salaryMax: json['salaryMax']?.toDouble() ?? json['maxSalary']?.toDouble(),
      salaryCurrency: json['salaryCurrency'] ?? 'USD',
      techStack: (json['techStack'] as List?)?.map((e) => e.toString()).toList() ?? [],
      postedDate: json['postedDate'] != null || json['createdAt'] != null
          ? DateTime.parse(json['postedDate'] ?? json['createdAt']) 
          : DateTime.now(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isPremium: json['isPremium'] ?? json['isFeatured'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      hasApplied: json['hasApplied'] ?? false,
      applicantCount: json['applicantCount'] ?? json['applicantsCount'] ?? 0,
      employerId: json['employerId'] is String ? json['employerId'] : null, // Add employerId parsing
    );
  }
  
  /// Parse string or list to string
  static String _parseStringOrList(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      return value.map((e) => '• ${e.toString()}').join('\n');
    }
    return value.toString();
  }

  /// Convert Job to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'description': description,
      'requirements': requirements,
      'benefits': benefits,
      'jobType': jobType.name,
      'experienceLevel': experienceLevel.name,
      'location': location,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'salaryCurrency': salaryCurrency,
      'techStack': techStack,
      'postedDate': postedDate.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'isPremium': isPremium,
      'applicantCount': applicantCount,
    };
  }

  static JobType _parseJobType(dynamic value) {
    if (value == null) return JobType.remote;
    final str = value.toString().toLowerCase();
    return JobType.values.firstWhere(
      (e) => e.name == str,
      orElse: () => JobType.remote,
    );
  }

  static ExperienceLevel _parseExperienceLevel(dynamic value) {
    if (value == null) return ExperienceLevel.mid;
    final str = value.toString().toLowerCase();
    return ExperienceLevel.values.firstWhere(
      (e) => e.name == str,
      orElse: () => ExperienceLevel.mid,
    );
  }

  String get salaryRange {
    if (salaryMin == null && salaryMax == null) {
      return 'Competitive';
    }
    if (salaryMin != null && salaryMax != null) {
      return '\$${salaryMin!.toStringAsFixed(0)}K - \$${salaryMax!.toStringAsFixed(0)}K';
    }
    if (salaryMin != null) {
      return 'From \$${salaryMin!.toStringAsFixed(0)}K';
    }
    return 'Up to \$${salaryMax!.toStringAsFixed(0)}K';
  }

  String get timeAgo {
    final difference = DateTime.now().difference(postedDate);
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Job copyWith({
    String? id,
    String? title,
    String? companyName,
    String? companyLogo,
    String? description,
    String? requirements,
    String? benefits,
    JobType? jobType,
    ExperienceLevel? experienceLevel,
    String? location,
    double? salaryMin,
    double? salaryMax,
    String? salaryCurrency,
    List<String>? techStack,
    DateTime? postedDate,
    DateTime? deadline,
    bool? isPremium,
    bool? isBookmarked,
    bool? hasApplied,
    int? applicantCount,
    String? employerId,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      jobType: jobType ?? this.jobType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      techStack: techStack ?? this.techStack,
      postedDate: postedDate ?? this.postedDate,
      deadline: deadline ?? this.deadline,
      isPremium: isPremium ?? this.isPremium,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasApplied: hasApplied ?? this.hasApplied,
      applicantCount: applicantCount ?? this.applicantCount,
      employerId: employerId ?? this.employerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        companyName,
        companyLogo,
        description,
        requirements,
        benefits,
        jobType,
        experienceLevel,
        location,
        salaryMin,
        salaryMax,
        salaryCurrency,
        techStack,
        postedDate,
        deadline,
        isPremium,
        isBookmarked,
        hasApplied,
        applicantCount,
        employerId,
      ];

  // Mock data for testing
  static List<Job> getMockJobs() {
    return [
      Job(
        id: '1',
        title: 'Senior Flutter Developer',
        companyName: 'Tech Solutions Inc',
        description: 'We are looking for an experienced Flutter developer to join our team...',
        requirements: '5+ years of experience with Flutter and Dart...',
        benefits: 'Health insurance, Remote work, Flexible hours',
        jobType: JobType.remote,
        experienceLevel: ExperienceLevel.senior,
        location: 'Remote',
        salaryMin: 80,
        salaryMax: 120,
        techStack: ['Flutter', 'Dart', 'Firebase', 'REST API'],
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        isPremium: true,
        applicantCount: 25,
      ),
      Job(
        id: '2',
        title: 'Full Stack Developer',
        companyName: 'StartupHub',
        description: 'Join our innovative startup as a full stack developer...',
        requirements: '3+ years of experience with React and Node.js...',
        jobType: JobType.hybrid,
        experienceLevel: ExperienceLevel.mid,
        location: 'San Francisco, CA',
        salaryMin: 90,
        salaryMax: 130,
        techStack: ['React', 'Node.js', 'MongoDB', 'AWS'],
        postedDate: DateTime.now().subtract(const Duration(hours: 5)),
        applicantCount: 42,
      ),
      Job(
        id: '3',
        title: 'Mobile Developer (iOS/Android)',
        companyName: 'Mobile First Corp',
        description: 'We need a talented mobile developer...',
        requirements: '2+ years of mobile development experience...',
        jobType: JobType.onsite,
        experienceLevel: ExperienceLevel.mid,
        location: 'New York, NY',
        salaryMin: 70,
        salaryMax: 100,
        techStack: ['Swift', 'Kotlin', 'React Native', 'Flutter'],
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        isPremium: true,
        applicantCount: 18,
      ),
      Job(
        id: '4',
        title: 'Junior Frontend Developer',
        companyName: 'WebDev Agency',
        description: 'Great opportunity for junior developers to grow...',
        requirements: '1+ year of experience with modern frontend frameworks...',
        jobType: JobType.remote,
        experienceLevel: ExperienceLevel.junior,
        location: 'Remote',
        salaryMin: 50,
        salaryMax: 70,
        techStack: ['React', 'TypeScript', 'CSS', 'Git'],
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        applicantCount: 67,
      ),
      Job(
        id: '5',
        title: 'DevOps Engineer',
        companyName: 'Cloud Systems',
        description: 'Looking for a DevOps engineer with strong cloud experience...',
        requirements: '4+ years of DevOps and cloud infrastructure experience...',
        jobType: JobType.hybrid,
        experienceLevel: ExperienceLevel.senior,
        location: 'Austin, TX',
        salaryMin: 100,
        salaryMax: 140,
        techStack: ['AWS', 'Docker', 'Kubernetes', 'Terraform'],
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        applicantCount: 31,
      ),
    ];
  }
}
