enum InterviewType {
  phone,
  video,
  inPerson,
  technical,
  hr,
}

enum InterviewStatus {
  scheduled,
  completed,
  cancelled,
  rescheduled,
}

class Interview {
  final String id;
  final String jobId;
  final String applicationId;
  final String candidateId;
  final String employerId;
  final String jobTitle;
  final String companyName;
  final InterviewType type;
  final DateTime scheduledTime;
  final int duration; // in minutes
  final InterviewStatus status;
  final String? meetingLink;
  final String? location;
  final String? interviewerName;
  final String? interviewerEmail;
  final String? interviewerPhone;
  final String? notes;
  final String? feedback;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Interview({
    required this.id,
    required this.jobId,
    required this.applicationId,
    required this.candidateId,
    required this.employerId,
    required this.jobTitle,
    required this.companyName,
    required this.type,
    required this.scheduledTime,
    required this.duration,
    required this.status,
    this.meetingLink,
    this.location,
    this.interviewerName,
    this.interviewerEmail,
    this.interviewerPhone,
    this.notes,
    this.feedback,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Interview copyWith({
    String? id,
    String? jobId,
    String? applicationId,
    String? candidateId,
    String? employerId,
    String? jobTitle,
    String? companyName,
    InterviewType? type,
    DateTime? scheduledTime,
    int? duration,
    InterviewStatus? status,
    String? meetingLink,
    String? location,
    String? interviewerName,
    String? interviewerEmail,
    String? interviewerPhone,
    String? notes,
    String? feedback,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Interview(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      applicationId: applicationId ?? this.applicationId,
      candidateId: candidateId ?? this.candidateId,
      employerId: employerId ?? this.employerId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      meetingLink: meetingLink ?? this.meetingLink,
      location: location ?? this.location,
      interviewerName: interviewerName ?? this.interviewerName,
      interviewerEmail: interviewerEmail ?? this.interviewerEmail,
      interviewerPhone: interviewerPhone ?? this.interviewerPhone,
      notes: notes ?? this.notes,
      feedback: feedback ?? this.feedback,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'applicationId': applicationId,
      'candidateId': candidateId,
      'employerId': employerId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'type': type.toString().split('.').last,
      'scheduledTime': scheduledTime.toIso8601String(),
      'duration': duration,
      'status': status.toString().split('.').last,
      'meetingLink': meetingLink,
      'location': location,
      'interviewerName': interviewerName,
      'interviewerEmail': interviewerEmail,
      'interviewerPhone': interviewerPhone,
      'notes': notes,
      'feedback': feedback,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      applicationId: json['applicationId'] as String,
      candidateId: json['candidateId'] as String,
      employerId: json['employerId'] as String,
      jobTitle: json['jobTitle'] as String,
      companyName: json['companyName'] as String,
      type: InterviewType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      duration: json['duration'] as int,
      status: InterviewStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      meetingLink: json['meetingLink'] as String?,
      location: json['location'] as String?,
      interviewerName: json['interviewerName'] as String?,
      interviewerEmail: json['interviewerEmail'] as String?,
      interviewerPhone: json['interviewerPhone'] as String?,
      notes: json['notes'] as String?,
      feedback: json['feedback'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Mock data generator for testing
  static List<Interview> generateMockInterviews() {
    final now = DateTime.now();
    return [
      Interview(
        id: '1',
        jobId: 'job_1',
        applicationId: 'app_1',
        candidateId: 'current_user_id',
        employerId: 'employer_1',
        jobTitle: 'Senior Flutter Developer',
        companyName: 'TechCorp Inc.',
        type: InterviewType.video,
        scheduledTime: now.add(const Duration(days: 2, hours: 10)),
        duration: 60,
        status: InterviewStatus.scheduled,
        meetingLink: 'https://meet.google.com/abc-defg-hij',
        interviewerName: 'John Doe',
        interviewerEmail: 'john.doe@techcorp.com',
        notes: 'First round technical interview. Be prepared to discuss your Flutter projects.',
      ),
      Interview(
        id: '2',
        jobId: 'job_2',
        applicationId: 'app_2',
        candidateId: 'current_user_id',
        employerId: 'employer_2',
        jobTitle: 'Mobile Developer',
        companyName: 'StartUp Labs',
        type: InterviewType.phone,
        scheduledTime: now.add(const Duration(hours: 5)),
        duration: 30,
        status: InterviewStatus.scheduled,
        interviewerName: 'Sarah Smith',
        interviewerEmail: 'sarah@startuplabs.com',
        interviewerPhone: '+1-555-0123',
        notes: 'Initial screening call.',
      ),
      Interview(
        id: '3',
        jobId: 'job_3',
        applicationId: 'app_3',
        candidateId: 'current_user_id',
        employerId: 'employer_3',
        jobTitle: 'Full Stack Developer',
        companyName: 'Enterprise Solutions',
        type: InterviewType.inPerson,
        scheduledTime: now.add(const Duration(days: 5, hours: 14)),
        duration: 90,
        status: InterviewStatus.scheduled,
        location: '123 Business Ave, Suite 400, Tech City',
        interviewerName: 'Mike Johnson',
        interviewerEmail: 'mike.johnson@enterprise.com',
        notes: 'Final round interview. Meet with the entire team.',
      ),
      Interview(
        id: '4',
        jobId: 'job_4',
        applicationId: 'app_4',
        candidateId: 'current_user_id',
        employerId: 'employer_4',
        jobTitle: 'React Native Developer',
        companyName: 'Mobile First Co.',
        type: InterviewType.technical,
        scheduledTime: now.subtract(const Duration(days: 3)),
        duration: 120,
        status: InterviewStatus.completed,
        meetingLink: 'https://zoom.us/j/123456789',
        interviewerName: 'Alice Williams',
        interviewerEmail: 'alice@mobilefirst.com',
        notes: 'Technical coding assessment.',
        feedback: 'Strong performance on algorithmic challenges. Good communication skills.',
        completedAt: now.subtract(const Duration(days: 3)),
      ),
      Interview(
        id: '5',
        jobId: 'job_5',
        applicationId: 'app_5',
        candidateId: 'current_user_id',
        employerId: 'employer_5',
        jobTitle: 'iOS Developer',
        companyName: 'Apple Store Builder',
        type: InterviewType.hr,
        scheduledTime: now.subtract(const Duration(days: 10)),
        duration: 45,
        status: InterviewStatus.cancelled,
        meetingLink: 'https://teams.microsoft.com/xyz',
        interviewerName: 'Bob Brown',
        interviewerEmail: 'bob@applestorebuilder.com',
        notes: 'HR screening cancelled due to role being filled.',
      ),
    ];
  }
}
