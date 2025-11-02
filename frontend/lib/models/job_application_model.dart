import 'package:equatable/equatable.dart';
import 'package:itjobhub/core/constants/app_constants.dart';
import 'package:itjobhub/models/job_model.dart';
import 'package:itjobhub/models/candidate_model.dart';

/// Represents a job application with both job and candidate information
class JobApplication extends Equatable {
  final String id;
  final Job job;
  final Candidate candidate;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final DateTime? lastUpdateDate;
  final String? employerNotes;
  final String? candidateCoverLetter;

  const JobApplication({
    required this.id,
    required this.job,
    required this.candidate,
    required this.status,
    required this.appliedDate,
    this.lastUpdateDate,
    this.employerNotes,
    this.candidateCoverLetter,
  });

  String get statusText => status.displayName;

  String get appliedTimeAgo {
    final difference = DateTime.now().difference(appliedDate);
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  JobApplication copyWith({
    String? id,
    Job? job,
    Candidate? candidate,
    ApplicationStatus? status,
    DateTime? appliedDate,
    DateTime? lastUpdateDate,
    String? employerNotes,
    String? candidateCoverLetter,
  }) {
    return JobApplication(
      id: id ?? this.id,
      job: job ?? this.job,
      candidate: candidate ?? this.candidate,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      employerNotes: employerNotes ?? this.employerNotes,
      candidateCoverLetter: candidateCoverLetter ?? this.candidateCoverLetter,
    );
  }

  @override
  List<Object?> get props => [
        id,
        job,
        candidate,
        status,
        appliedDate,
        lastUpdateDate,
        employerNotes,
        candidateCoverLetter,
      ];

  // Mock data for testing
  static List<JobApplication> getMockApplications() {
    final jobs = Job.getMockJobs();
    final candidates = Candidate.getMockCandidates();

    return [
      JobApplication(
        id: '1',
        job: jobs[0],
        candidate: candidates[0],
        status: ApplicationStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(hours: 2)),
        candidateCoverLetter: 'I am excited to apply for this position. With 3 years of Flutter development experience, I believe I would be a great fit for your team.',
      ),
      JobApplication(
        id: '2',
        job: jobs[0],
        candidate: candidates[4],
        status: ApplicationStatus.reviewing,
        appliedDate: DateTime.now().subtract(const Duration(days: 1)),
        lastUpdateDate: DateTime.now().subtract(const Duration(hours: 5)),
        candidateCoverLetter: 'As a lead mobile developer with 6 years of experience, I am confident I can bring value to your organization.',
      ),
      JobApplication(
        id: '3',
        job: jobs[1],
        candidate: candidates[2],
        status: ApplicationStatus.interview,
        appliedDate: DateTime.now().subtract(const Duration(days: 3)),
        lastUpdateDate: DateTime.now().subtract(const Duration(days: 1)),
        employerNotes: 'Strong candidate. Schedule interview for next week.',
        candidateCoverLetter: 'I would love to join your team and contribute to building amazing mobile applications.',
      ),
      JobApplication(
        id: '4',
        job: jobs[1],
        candidate: candidates[1],
        status: ApplicationStatus.approved,
        appliedDate: DateTime.now().subtract(const Duration(days: 5)),
        lastUpdateDate: DateTime.now().subtract(const Duration(hours: 12)),
        employerNotes: 'Excellent interview. Proceeding with offer.',
      ),
      JobApplication(
        id: '5',
        job: jobs[2],
        candidate: candidates[3],
        status: ApplicationStatus.rejected,
        appliedDate: DateTime.now().subtract(const Duration(days: 7)),
        lastUpdateDate: DateTime.now().subtract(const Duration(days: 2)),
        employerNotes: 'Not enough experience for this senior position.',
      ),
      JobApplication(
        id: '6',
        job: jobs[3],
        candidate: candidates[0],
        status: ApplicationStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JobApplication(
        id: '7',
        job: jobs[4],
        candidate: candidates[2],
        status: ApplicationStatus.reviewing,
        appliedDate: DateTime.now().subtract(const Duration(days: 2)),
        lastUpdateDate: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ];
  }
}
