import 'package:equatable/equatable.dart';

/// Model representing a project in candidate's experience
class ExperienceProject extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> technologies;
  final String? startDate; // Format: "YYYY-MM"
  final String? endDate; // Format: "YYYY-MM" or "Present"
  final String? projectUrl;
  final String? role;

  const ExperienceProject({
    required this.id,
    required this.name,
    required this.description,
    required this.technologies,
    this.startDate,
    this.endDate,
    this.projectUrl,
    this.role,
  });

  String get duration {
    if (startDate == null) return 'Duration not specified';
    if (endDate == null || endDate == 'Present') {
      return '$startDate - Present';
    }
    return '$startDate - $endDate';
  }

  ExperienceProject copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? technologies,
    String? startDate,
    String? endDate,
    String? projectUrl,
    String? role,
  }) {
    return ExperienceProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      projectUrl: projectUrl ?? this.projectUrl,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        technologies,
        startDate,
        endDate,
        projectUrl,
        role,
      ];

  // Mock data for testing
  static List<ExperienceProject> getMockProjects() {
    return [
      ExperienceProject(
        id: '1',
        name: 'E-Commerce Mobile App',
        description: 'Built a cross-platform e-commerce application with Flutter, featuring real-time inventory updates and secure payment integration.',
        technologies: ['Flutter', 'Dart', 'Firebase', 'Stripe API'],
        startDate: '2023-01',
        endDate: '2023-06',
        projectUrl: 'https://github.com/user/ecommerce-app',
        role: 'Lead Mobile Developer',
      ),
      ExperienceProject(
        id: '2',
        name: 'Healthcare Management System',
        description: 'Developed a comprehensive healthcare management system with appointment scheduling, patient records, and telemedicine features.',
        technologies: ['React Native', 'Node.js', 'MongoDB', 'WebRTC'],
        startDate: '2022-06',
        endDate: '2022-12',
        projectUrl: 'https://github.com/user/healthcare-system',
        role: 'Full Stack Developer',
      ),
      ExperienceProject(
        id: '3',
        name: 'Social Media Analytics Dashboard',
        description: 'Created a real-time analytics dashboard for tracking social media metrics across multiple platforms.',
        technologies: ['Flutter', 'GraphQL', 'AWS', 'Redis'],
        startDate: '2023-07',
        endDate: 'Present',
        role: 'Mobile Developer',
      ),
    ];
  }
}
