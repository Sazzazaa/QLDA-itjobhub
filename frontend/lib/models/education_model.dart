import 'package:equatable/equatable.dart';

/// Education Model
class Education extends Equatable {
  final String id;
  final String degree;
  final String major;
  final String institution;
  final int startYear;
  final int endYear;
  final String? description;

  const Education({
    required this.id,
    required this.degree,
    required this.major,
    required this.institution,
    required this.startYear,
    required this.endYear,
    this.description,
  });

  Education copyWith({
    String? id,
    String? degree,
    String? major,
    String? institution,
    int? startYear,
    int? endYear,
    String? description,
  }) {
    return Education(
      id: id ?? this.id,
      degree: degree ?? this.degree,
      major: major ?? this.major,
      institution: institution ?? this.institution,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'degree': degree,
      'major': major,
      'institution': institution,
      'startYear': startYear,
      'endYear': endYear,
      'description': description,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as String,
      degree: json['degree'] as String,
      major: json['major'] as String,
      institution: json['institution'] as String,
      startYear: json['startYear'] as int,
      endYear: json['endYear'] as int,
      description: json['description'] as String?,
    );
  }

  String get period {
    return '$startYear - $endYear';
  }

  int get duration {
    return endYear - startYear;
  }

  @override
  List<Object?> get props => [
        id,
        degree,
        major,
        institution,
        startYear,
        endYear,
        description,
      ];
}
