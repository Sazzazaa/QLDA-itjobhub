import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:itjobhub/services/api_client.dart';

class CVService {
  final ApiClient _apiClient;

  CVService(this._apiClient);

  /// Pick a PDF file from device
  Future<File?> pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Upload CV to backend
  Future<Map<String, dynamic>> uploadCV(File file) async {
    try {
      final response = await _apiClient.uploadFile(
        '/files/cv/upload',
        file,
        fieldName: 'file',
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error uploading CV: $e');
      rethrow;
    }
  }

  /// Get all CVs uploaded by current user
  Future<List<Map<String, dynamic>>> getMyCVs() async {
    try {
      final data = await _apiClient.get('/files/cv/my-cvs');
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching CVs: $e');
      return [];
    }
  }

  /// Get CV parsing status
  Future<Map<String, dynamic>?> getCVStatus(String cvId) async {
    try {
      final data = await _apiClient.get('/files/cv/$cvId/status');
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting CV status: $e');
      return null;
    }
  }

  /// Get parsed CV data
  Future<Map<String, dynamic>?> getParsedData(String cvId) async {
    try {
      final data = await _apiClient.get('/files/cv/$cvId/parsed');
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting parsed data: $e');
      return null;
    }
  }

  /// Delete a CV
  Future<bool> deleteCV(String cvId) async {
    try {
      await _apiClient.delete('/files/cv/$cvId');
      print('✅ CV deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting CV: $e');
      rethrow;
    }
  }

  /// Generate cover letter using AI based on CV and job
  Future<String> generateCoverLetter(String cvId, String jobId) async {
    try {
      final response = await _apiClient.post(
        '/files/cv/generate-cover-letter',
        {
          'cvId': cvId,
          'jobId': jobId,
        },
      );
      
      if (response is Map<String, dynamic> && response['coverLetter'] != null) {
        return response['coverLetter'] as String;
      }
      
      throw Exception('Invalid response from server');
    } catch (e) {
      print('Error generating cover letter: $e');
      rethrow;
    }
  }
}
