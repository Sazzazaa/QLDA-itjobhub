import 'package:equatable/equatable.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/models/candidate_model.dart';

class Application extends Equatable {
  final String id;
  final Job job;
  final String? employerId;
  final String? candidateId;
  final Candidate? candidate; // Populated candidate data
  final ApplicationStatus status;
  final DateTime appliedDate;
  final DateTime? lastUpdateDate;
  final String? notes;

  const Application({
    required this.id,
    required this.job,
    this.employerId,
    this.candidateId,
    this.candidate,
    required this.status,
    required this.appliedDate,
    this.lastUpdateDate,
    this.notes,
  });

  String get statusText => status.displayName;
  
  String get appliedTimeAgo {
    final difference = DateTime.now().difference(appliedDate);
    if (difference.inDays > 30) {
      return 'Applied ${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return 'Applied ${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return 'Applied ${difference.inHours} hours ago';
    } else {
      return 'Applied today';
    }
  }

  String get lastUpdateText {
    if (lastUpdateDate == null) return '';
    final difference = DateTime.now().difference(lastUpdateDate!);
    if (difference.inDays > 30) {
      return 'Updated ${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return 'Updated ${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return 'Updated ${difference.inHours} hours ago';
    } else {
      return 'Updated recently';
    }
  }

  /// Parse ApplicationStatus from string
  static ApplicationStatus _parseStatus(String? status) {
    if (status == null) return ApplicationStatus.pending;
    switch (status.toLowerCase().replaceAll('_', '')) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'reviewing':
        return ApplicationStatus.reviewing;
      case 'approved':
      case 'accepted':
        return ApplicationStatus.approved;
      case 'interview':
        return ApplicationStatus.interview;
      case 'interviewscheduled':
        return ApplicationStatus.interviewScheduled;
      case 'interviewcompleted':
        return ApplicationStatus.interviewCompleted;
      case 'hired':
        return ApplicationStatus.hired;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        print('⚠️ Unknown status: $status, defaulting to pending');
        return ApplicationStatus.pending;
    }
  }

  /// Create Application from JSON
  factory Application.fromJson(Map<String, dynamic> json) {
    // Handle job field - it might be a populated object or just an ID
    Job job;
    if (json['job'] != null && json['job'] is Map) {
      job = Job.fromJson(json['job']);
    } else if (json['jobId'] != null && json['jobId'] is Map) {
      job = Job.fromJson(json['jobId']);
    } else {
      // If job is not populated, create a minimal job object
      job = Job(
        id: (json['jobId'] ?? json['job'] ?? '').toString(),
        title: 'Loading...',
        companyName: '',
        description: '',
        requirements: '',
        location: '',
        jobType: JobType.remote,
        experienceLevel: ExperienceLevel.mid,
        techStack: [],
        postedDate: DateTime.now(),
      );
    }
    
    // Handle candidate field - it might be a populated object or just an ID
    Candidate? candidate;
    String? candidateId;
    
    if (json['candidateId'] != null && json['candidateId'] is Map) {
      // Backend populated the candidateId reference
      candidate = Candidate.fromJson(json['candidateId']);
      candidateId = candidate.id;
    } else if (json['candidateId'] != null) {
      // Just the ID string
      candidateId = json['candidateId'].toString();
    }
    
    return Application(
      id: json['_id'] ?? json['id'] ?? '',
      job: job,
      employerId: json['employerId']?.toString(),
      candidateId: candidateId,
      candidate: candidate,
      status: _parseStatus(json['status']),
      appliedDate: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastUpdateDate: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      notes: json['notes'] ?? json['coverLetter'],
    );
  }

  /// Convert Application to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job': job.toJson(),
      'status': status.name,
      'appliedDate': appliedDate.toIso8601String(),
      'lastUpdateDate': lastUpdateDate?.toIso8601String(),
      'notes': notes,
    };
  }

  Application copyWith({
    String? id,
    Job? job,
    String? employerId,
    String? candidateId,
    Candidate? candidate,
    ApplicationStatus? status,
    DateTime? appliedDate,
    DateTime? lastUpdateDate,
    String? notes,
  }) {
    return Application(
      id: id ?? this.id,
      job: job ?? this.job,
      employerId: employerId ?? this.employerId,
      candidateId: candidateId ?? this.candidateId,
      candidate: candidate ?? this.candidate,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        job,
        employerId,
        candidateId,
        candidate,
        status,
        appliedDate,
        lastUpdateDate,
        notes,
      ];

  // Mock data for testing
  static List<Application> getMockApplications() {
    final jobs = Job.getMockJobs();
    return [
      Application(
        id: '1',
        job: jobs[0],
        status: ApplicationStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 2)),
        lastUpdateDate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Application(
        id: '2',
        job: jobs[1],
        status: ApplicationStatus.approved,
        appliedDate: DateTime.now().subtract(const Duration(days: 5)),
        lastUpdateDate: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Congratulations! We would like to schedule an interview with you.',
      ),
      Application(
        id: '3',
        job: jobs[3],
        status: ApplicationStatus.rejected,
        appliedDate: DateTime.now().subtract(const Duration(days: 7)),
        lastUpdateDate: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Thank you for your application. Unfortunately, we have decided to move forward with other candidates.',
      ),
      Application(
        id: '4',
        job: jobs[4],
        status: ApplicationStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
