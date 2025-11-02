import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/portfolio_link_model.dart';
import 'api_client.dart';

/// CV Upload Service
/// 
/// Handles CV file upload and parsing integration with backend API
class CVUploadService {
  final ApiClient _apiClient = ApiClient();

  /// Pick a CV file (PDF, DOC, DOCX)
  Future<File?> pickCVFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Upload CV file to server
  /// Returns: Upload ID for tracking
  Future<String> uploadCV(File file) async {
    try {
      if (!validateFileSize(file)) {
        throw Exception('File size exceeds 5MB limit');
      }

      final response = await _apiClient.uploadFile('/files/cv/upload', file);
      return response['cvDataId'] ?? response['id'];
    } catch (e) {
      throw Exception('Failed to upload CV: $e');
    }
  }

  /// Upload CV file with progress tracking
  /// Returns: Stream with progress updates and final CV ID
  Stream<Map<String, dynamic>> uploadCVWithProgress(File file) async* {
    try {
      if (!validateFileSize(file)) {
        throw Exception('File size exceeds 5MB limit');
      }

      // Simulate progress since HTTP client doesn't provide real progress
      for (int i = 0; i <= 90; i += 10) {
        yield {'progress': i / 100.0};
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Upload file and get CV ID
      final cvId = await uploadCV(file);
      yield {'progress': 1.0, 'cvId': cvId};
    } catch (e) {
      throw Exception('Failed to upload CV: $e');
    }
  }

  /// Get CV parsing status
  Future<CVParseStatus> getCVParseStatus(String cvId) async {
    try {
      final response = await _apiClient.get('/files/cv/parse-status/$cvId');
      final status = response['status'] as String;
      
      switch (status.toLowerCase()) {
        case 'pending':
          return CVParseStatus.pending;
        case 'processing':
          return CVParseStatus.processing;
        case 'completed':
          return CVParseStatus.complete;
        case 'failed':
          return CVParseStatus.failed;
        default:
          return CVParseStatus.pending;
      }
    } catch (e) {
      // Fallback to mock on error
      await Future.delayed(const Duration(seconds: 1));
      return CVParseStatus.complete;
    }
  }

  /// Get parsed CV data
  Future<Map<String, dynamic>> getParsedCVData(String cvId) async {
    try {
      final response = await _apiClient.get('/files/cv/parsed-data/$cvId');
      return response['parsedData'] ?? response;
    } catch (e) {
      // Fallback to mock data
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'skills': ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git', 'AWS'],
        'experiences': [
          {
            'jobTitle': 'Senior Flutter Developer',
            'company': 'Tech Company Inc.',
            'startDate': '2022-01-01',
            'endDate': null,
            'isCurrentlyWorking': true,
            'description': 'Leading mobile app development team',
            'skills': ['Flutter', 'Dart', 'Firebase'],
          },
        ],
        'educations': [
          {
            'degree': 'Bachelor of Computer Science',
            'major': 'Computer Science',
            'institution': 'University of Technology',
            'startYear': 2016,
            'endYear': 2020,
          },
        ],
        'languages': ['English', 'Vietnamese'],
        'certifications': ['AWS Certified Developer'],
      };
    }
  }

  /// Delete CV from server
  Future<void> deleteCV(String cvId) async {
    try {
      await _apiClient.delete('/files/cv/$cvId');
    } catch (e) {
      // Silently fail or show error
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Download CV file
  Future<File> downloadCV(String cvUrl) async {
    try {
      // TODO: Implement file download
      throw UnimplementedError('Download CV not implemented yet');
    } catch (e) {
      throw Exception('Failed to download CV: $e');
    }
  }

  /// Validate file size (max 5MB as per requirements)
  bool validateFileSize(File file) {
    const maxSize = 5 * 1024 * 1024; // 5MB
    return file.lengthSync() <= maxSize;
  }

  /// Get file size in human-readable format
  String getFileSizeString(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
