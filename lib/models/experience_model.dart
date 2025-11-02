import 'package:equatable/equatable.dart';

/// Work Experience Model
class Experience extends Equatable {
  final String id;
  final String jobTitle;
  final String company;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentlyWorking;
  final String? description;
  final List<String>? skills;

  const Experience({
    required this.id,
    required this.jobTitle,
    required this.company,
    required this.startDate,
    this.endDate,
    this.isCurrentlyWorking = false,
    this.description,
    this.skills,
  });

  Experience copyWith({
    String? id,
    String? jobTitle,
    String? company,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentlyWorking,
    String? description,
    List<String>? skills,
  }) {
    return Experience(
      id: id ?? this.id,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentlyWorking: isCurrentlyWorking ?? this.isCurrentlyWorking,
      description: description ?? this.description,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'company': company,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrentlyWorking': isCurrentlyWorking,
      'description': description,
      'skills': skills,
    };
  }

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as String,
      jobTitle: json['jobTitle'] as String,
      company: json['company'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isCurrentlyWorking: json['isCurrentlyWorking'] as bool? ?? false,
      description: json['description'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>(),
    );
  }

  String get period {
    final start = '${startDate.month}/${startDate.year}';
    final end = isCurrentlyWorking 
        ? 'Present' 
        : endDate != null 
            ? '${endDate!.month}/${endDate!.year}' 
            : 'Present';
    return '$start - $end';
  }

  int get durationInMonths {
    final end = isCurrentlyWorking ? DateTime.now() : (endDate ?? DateTime.now());
    return (end.year - startDate.year) * 12 + (end.month - startDate.month);
  }

  String get durationText {
    final months = durationInMonths;
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    
    if (years > 0 && remainingMonths > 0) {
      return '$years ${years == 1 ? 'year' : 'years'} $remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
    } else if (years > 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else {
      return '$remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
    }
  }

  @override
  List<Object?> get props => [
        id,
        jobTitle,
        company,
        startDate,
        endDate,
        isCurrentlyWorking,
        description,
        skills,
      ];
}
