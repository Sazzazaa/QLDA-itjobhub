/// Interview Type Enum
enum InterviewType {
  online,
  onsite;

  String get displayName {
    switch (this) {
      case InterviewType.online:
        return 'Online';
      case InterviewType.onsite:
        return 'On-site';
    }
  }

  String get icon {
    switch (this) {
      case InterviewType.online:
        return '💻';
      case InterviewType.onsite:
        return '🏢';
    }
  }
}

/// Interview Status Enum
enum InterviewStatus {
  scheduled,
  completed,
  cancelled,
  rescheduled,
  noShow;

  String get displayName {
    switch (this) {
      case InterviewStatus.scheduled:
        return 'Scheduled';
      case InterviewStatus.completed:
        return 'Completed';
      case InterviewStatus.cancelled:
        return 'Cancelled';
      case InterviewStatus.rescheduled:
        return 'Rescheduled';
      case InterviewStatus.noShow:
        return 'No Show';
    }
  }
}

/// Interview Model
class Interview {
  final String id;
  final String jobId;
  final String? applicationId;
  final String jobTitle;
  final String companyName;
  final String companyLogo;
  final InterviewType type;
  final InterviewStatus status;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? location; // For onsite interviews
  final String? meetingLink; // For video interviews
  final String? phoneNumber; // For phone interviews
  final String interviewerName;
  final String? interviewerTitle;
  final String? interviewerEmail;
  final String? notes;
  final String? feedback; // Post-interview feedback
  final List<String>? documents; // Documents to bring/prepare
  final bool isUpcoming;
  final bool confirmed; // Candidate confirmed the interview

  Interview({
    required this.id,
    required this.jobId,
    this.applicationId,
    required this.jobTitle,
    required this.companyName,
    required this.companyLogo,
    required this.type,
    required this.status,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.location,
    this.meetingLink,
    this.phoneNumber,
    required this.interviewerName,
    this.interviewerTitle,
    this.interviewerEmail,
    this.notes,
    this.feedback,
    this.documents,
    bool? isUpcoming,
    this.confirmed = false,
  }) : isUpcoming = isUpcoming ?? scheduledAt.isAfter(DateTime.now());

  /// Get time until interview
  Duration get timeUntilInterview => scheduledAt.difference(DateTime.now());

  /// Check if interview is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  /// Check if interview is within next 24 hours
  bool get isWithin24Hours {
    return timeUntilInterview.inHours <= 24 && timeUntilInterview.inHours >= 0;
  }

  /// Format time until interview as string
  String get timeUntilString {
    if (timeUntilInterview.isNegative) return 'Past';
    
    final hours = timeUntilInterview.inHours;
    final days = timeUntilInterview.inDays;
    
    if (days > 0) {
      return '$days ${days == 1 ? 'day' : 'days'}';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else {
      final minutes = timeUntilInterview.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
  }

  /// Get formatted date string
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[scheduledAt.month - 1]} ${scheduledAt.day}, ${scheduledAt.year}';
  }

  /// Get formatted time string
  String get formattedTime {
    final hour = scheduledAt.hour > 12 ? scheduledAt.hour - 12 : scheduledAt.hour;
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    final period = scheduledAt.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  /// Copy with method for immutability
  Interview copyWith({
    String? id,
    String? jobId,
    String? applicationId,
    String? jobTitle,
    String? companyName,
    String? companyLogo,
    InterviewType? type,
    InterviewStatus? status,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? location,
    String? meetingLink,
    String? phoneNumber,
    String? interviewerName,
    String? interviewerTitle,
    String? interviewerEmail,
    String? notes,
    String? feedback,
    List<String>? documents,
    bool? confirmed,
  }) {
    return Interview(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
  applicationId: applicationId ?? this.applicationId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      interviewerName: interviewerName ?? this.interviewerName,
      interviewerTitle: interviewerTitle ?? this.interviewerTitle,
      interviewerEmail: interviewerEmail ?? this.interviewerEmail,
      notes: notes ?? this.notes,
      feedback: feedback ?? this.feedback,
      documents: documents ?? this.documents,
      confirmed: confirmed ?? this.confirmed,
    );
  }

  /// Parse InterviewType from string
  static InterviewType _parseInterviewType(String? type) {
    if (type == null) return InterviewType.online;
    switch (type.toLowerCase()) {
      case 'online':
        return InterviewType.online;
      case 'in-person':
      case 'onsite':
        return InterviewType.onsite;
      default:
        return InterviewType.online;
    }
  }

  /// Parse InterviewStatus from string
  static InterviewStatus _parseInterviewStatus(String? status) {
    if (status == null) return InterviewStatus.scheduled;
    switch (status.toLowerCase()) {
      case 'scheduled':
        return InterviewStatus.scheduled;
      case 'rescheduled':
        return InterviewStatus.rescheduled;
      case 'completed':
        return InterviewStatus.completed;
      case 'cancelled':
        return InterviewStatus.cancelled;
      case 'no-show':
        return InterviewStatus.noShow;
      default:
        return InterviewStatus.scheduled;
    }
  }

  /// Create Interview from JSON
  factory Interview.fromJson(Map<String, dynamic> json) {
    // Extract job data
    final jobData = json['jobId'] is Map ? json['jobId'] : null;
    
    // Extract interviewer details
    final interviewerDetails = json['interviewerDetails'] as Map<String, dynamic>?;
    
    return Interview(
      id: json['_id'] ?? json['id'] ?? '',
      jobId: jobData?['_id'] ?? json['jobId']?.toString() ?? '',
      applicationId: json['applicationId'] is Map ? (json['applicationId']?['_id'] ?? '') : (json['applicationId']?.toString()),
      jobTitle: jobData?['title'] ?? 'Interview',
      companyName: jobData?['companyName'] ?? 'Company',
      companyLogo: jobData?['companyLogo'] ?? '',
      type: _parseInterviewType(json['type']),
      status: _parseInterviewStatus(json['status']),
      scheduledAt: DateTime.parse(json['scheduledAt'] ?? DateTime.now().toIso8601String()),
      durationMinutes: json['duration'] ?? 60,
      location: json['location'],
      meetingLink: json['meetingLink'],
      phoneNumber: json['phoneNumber'],
      interviewerName: interviewerDetails?['name'] ?? json['interviewerName'] ?? 'Interviewer',
      interviewerTitle: interviewerDetails?['position'] ?? json['interviewerTitle'],
      interviewerEmail: interviewerDetails?['email'] ?? json['interviewerEmail'],
      notes: json['notes'],
      feedback: json['feedback'],
      documents: json['documents'] != null 
          ? List<String>.from(json['documents'])
          : null,
      confirmed: json['confirmed'] ?? false,
    );
  }

  /// Create mock interviews for testing
  static List<Interview> getMockInterviews() {
    final now = DateTime.now();
    
    return [
      Interview(
        id: 'int-1',
        jobId: '1',  // Matches Job ID '1' - Senior Flutter Developer
        jobTitle: 'Senior Flutter Developer',
        companyName: 'Tech Solutions Inc',
        companyLogo: '🏢',
        type: InterviewType.online,
        status: InterviewStatus.scheduled,
        scheduledAt: now.add(const Duration(days: 2, hours: 10)),
        durationMinutes: 60,
        meetingLink: 'https://meet.google.com/abc-defg-hij',
        interviewerName: 'Sarah Johnson',
        interviewerTitle: 'Senior Engineering Manager',
        interviewerEmail: 'sarah.johnson@techsolutions.com',
        notes: 'Please prepare to discuss your Flutter projects and experience with state management.',
        documents: ['Resume', 'Portfolio', 'GitHub Profile'],
      ),
      Interview(
        id: 'int-2',
        jobId: '3',  // Matches Job ID '3' - Mobile Developer
        jobTitle: 'Mobile Developer (iOS/Android)',
        companyName: 'Mobile First Corp',
        companyLogo: '🚀',
        type: InterviewType.online,
        status: InterviewStatus.scheduled,
        scheduledAt: now.add(const Duration(hours: 3)),
        durationMinutes: 30,
        phoneNumber: '+1 (555) 123-4567',
        interviewerName: 'Michael Chen',
        interviewerTitle: 'Technical Recruiter',
        interviewerEmail: 'michael@startuphub.com',
        notes: 'Initial screening call to discuss your background and interest in the role.',
      ),
      Interview(
        id: 'int-3',
        jobId: '2',  // Matches Job ID '2' - Full Stack Developer
        jobTitle: 'Full Stack Developer',
        companyName: 'StartupHub',
        companyLogo: '📱',
        type: InterviewType.onsite,
        status: InterviewStatus.scheduled,
        scheduledAt: now.add(const Duration(days: 7, hours: 14)),
        durationMinutes: 120,
        location: '123 Tech Street, San Francisco, CA 94102',
        interviewerName: 'Emily Rodriguez',
        interviewerTitle: 'CTO',
        interviewerEmail: 'emily@mobilefirst.com',
        notes: 'Final round interview. Please bring a valid ID and be prepared for a technical whiteboard session.',
        documents: ['ID', 'References', 'Certifications'],
      ),
      Interview(
        id: 'int-4',
        jobId: '1',  // Matches Job ID '1' - Past interview
        jobTitle: 'Senior Flutter Developer',
        companyName: 'Tech Solutions Inc',
        companyLogo: '🏢',
        type: InterviewType.online,
        status: InterviewStatus.completed,
        scheduledAt: now.subtract(const Duration(days: 5)),
        durationMinutes: 60,
        meetingLink: 'https://meet.google.com/xyz-abcd-efg',
        interviewerName: 'John Smith',
        interviewerTitle: 'Lead Developer',
        interviewerEmail: 'john.smith@techsolutions.com',
        feedback: 'Great technical skills and communication. Moving forward to next round.',
      ),
      Interview(
        id: 'int-5',
        jobId: '4',  // Matches Job ID '4' - Junior Frontend Developer
        jobTitle: 'Junior Frontend Developer',
        companyName: 'WebDev Agency',
        companyLogo: '💡',
        type: InterviewType.online,
        status: InterviewStatus.cancelled,
        scheduledAt: now.add(const Duration(days: 1, hours: 15)),
        durationMinutes: 45,
        interviewerName: 'Lisa Wang',
        interviewerTitle: 'HR Manager',
        notes: 'Interview cancelled by company due to position being filled.',
      ),
    ];
  }
}
