import 'package:equatable/equatable.dart';
import 'package:itjobhub/models/experience_project_model.dart';

/// Work location preference
enum WorkLocation {
  remote,
  onsite,
  hybrid,
}

extension WorkLocationExtension on WorkLocation {
  String get displayName {
    switch (this) {
      case WorkLocation.remote:
        return 'Remote';
      case WorkLocation.onsite:
        return 'Onsite';
      case WorkLocation.hybrid:
        return 'Hybrid';
    }
  }

  static WorkLocation fromString(String value) {
    switch (value.toLowerCase()) {
      case 'remote':
        return WorkLocation.remote;
      case 'onsite':
        return WorkLocation.onsite;
      case 'hybrid':
        return WorkLocation.hybrid;
      default:
        return WorkLocation.hybrid;
    }
  }
}

class Candidate extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? avatarUrl;
  final List<String> skills;
  final int yearsOfExperience;
  final String? currentPosition;
  final String? currentCompany;
  final String? bio;
  final String? cvUrl;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final List<ExperienceProject> projects;
  final double? desiredSalary; // In USD per year
  final WorkLocation? workLocation;
  final double? matchScore; // AI matching score (0-100)

  const Candidate({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.avatarUrl,
    required this.skills,
    required this.yearsOfExperience,
    this.currentPosition,
    this.currentCompany,
    this.bio,
    this.cvUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.portfolioUrl,
    this.projects = const [],
    this.desiredSalary,
    this.workLocation,
    this.matchScore,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String get experienceText {
    if (yearsOfExperience == 0) return 'Entry Level';
    if (yearsOfExperience == 1) return '1 year';
    return '$yearsOfExperience years';
  }

  /// Create Candidate from JSON (from backend User schema)
  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      avatarUrl: json['profileImage'] ?? json['avatarUrl'],
      skills: json['skills'] != null 
          ? List<String>.from(json['skills'])
          : [],
      yearsOfExperience: json['yearsOfExperience']?.toInt() ?? 0,
      currentPosition: json['currentPosition'],
      currentCompany: json['currentCompany'],
      bio: json['bio'],
      cvUrl: json['cvUrl'],
      githubUrl: json['githubUrl'],
      linkedinUrl: json['linkedinUrl'],
      portfolioUrl: json['portfolioUrl'],
      projects: [], // TODO: Parse projects if needed
      desiredSalary: json['desiredSalary']?.toDouble(),
      workLocation: json['workLocation'] != null
          ? WorkLocationExtension.fromString(json['workLocation'])
          : null,
      matchScore: json['matchScore']?.toDouble(),
    );
  }

  Candidate copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? avatarUrl,
    List<String>? skills,
    int? yearsOfExperience,
    String? currentPosition,
    String? currentCompany,
    String? bio,
    String? cvUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? portfolioUrl,
    List<ExperienceProject>? projects,
    double? desiredSalary,
    WorkLocation? workLocation,
    double? matchScore,
  }) {
    return Candidate(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      skills: skills ?? this.skills,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      currentPosition: currentPosition ?? this.currentPosition,
      currentCompany: currentCompany ?? this.currentCompany,
      bio: bio ?? this.bio,
      cvUrl: cvUrl ?? this.cvUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      projects: projects ?? this.projects,
      desiredSalary: desiredSalary ?? this.desiredSalary,
      workLocation: workLocation ?? this.workLocation,
      matchScore: matchScore ?? this.matchScore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        location,
        avatarUrl,
        skills,
        yearsOfExperience,
        currentPosition,
        currentCompany,
        bio,
        cvUrl,
        githubUrl,
        linkedinUrl,
        portfolioUrl,
        projects,
        desiredSalary,
        workLocation,
        matchScore,
      ];

  // Mock data for testing
  static List<Candidate> getMockCandidates() {
    return [
      Candidate(
        id: '1',
        name: 'Alice Johnson',
        email: 'alice.johnson@email.com',
        phone: '+1 (555) 123-4567',
        location: 'San Francisco, CA',
        skills: ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git'],
        yearsOfExperience: 3,
        currentPosition: 'Mobile Developer',
        currentCompany: 'Tech Startup Inc',
        bio: 'Passionate mobile developer with 3 years of experience building cross-platform applications.',
        githubUrl: 'https://github.com/alicejohnson',
        linkedinUrl: 'https://linkedin.com/in/alicejohnson',
        portfolioUrl: 'https://alicejohnson.dev',
        projects: ExperienceProject.getMockProjects().take(2).toList(),
        desiredSalary: 90000,
        workLocation: WorkLocation.hybrid,
        matchScore: 92,
      ),
      Candidate(
        id: '2',
        name: 'Bob Smith',
        email: 'bob.smith@email.com',
        phone: '+1 (555) 234-5678',
        location: 'New York, NY',
        skills: ['React Native', 'JavaScript', 'Node.js', 'MongoDB'],
        yearsOfExperience: 5,
        currentPosition: 'Senior Mobile Developer',
        currentCompany: 'Big Corp',
        bio: 'Experienced mobile developer specializing in React Native and cross-platform solutions.',
        githubUrl: 'https://github.com/bobsmith',
        linkedinUrl: 'https://linkedin.com/in/bobsmith',
        matchScore: 85,
      ),
      Candidate(
        id: '3',
        name: 'Carol Williams',
        email: 'carol.williams@email.com',
        phone: '+1 (555) 345-6789',
        location: 'Austin, TX',
        skills: ['Flutter', 'iOS', 'Swift', 'Kotlin', 'Android'],
        yearsOfExperience: 4,
        currentPosition: 'Mobile Engineer',
        currentCompany: 'Mobile Solutions Ltd',
        bio: 'Full-stack mobile engineer with expertise in both native and cross-platform development.',
        matchScore: 88,
      ),
      Candidate(
        id: '4',
        name: 'David Brown',
        email: 'david.brown@email.com',
        phone: '+1 (555) 456-7890',
        location: 'Seattle, WA',
        skills: ['Flutter', 'Dart', 'GraphQL', 'AWS'],
        yearsOfExperience: 2,
        currentPosition: 'Junior Mobile Developer',
        currentCompany: 'StartupCo',
        bio: 'Enthusiastic junior developer eager to work on challenging mobile projects.',
        matchScore: 78,
      ),
      Candidate(
        id: '5',
        name: 'Eve Martinez',
        email: 'eve.martinez@email.com',
        phone: '+1 (555) 567-8901',
        location: 'Remote',
        skills: ['Flutter', 'Dart', 'Firebase', 'CI/CD', 'Testing'],
        yearsOfExperience: 6,
        currentPosition: 'Lead Mobile Developer',
        currentCompany: 'Enterprise Solutions',
        bio: 'Seasoned mobile developer with leadership experience and a passion for clean code.',
        matchScore: 95,
      ),
    ];
  }
}
