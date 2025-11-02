import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cv_upload_service.dart';
import '../models/portfolio_link_model.dart';
import '../widgets/upload_progress_indicator.dart';

/// CV Upload State
enum CVUploadState {
  initial,
  picking,
  uploading,
  parsing,
  complete,
  error,
}

/// CV Upload Screen
/// 
/// Allows users to upload CV and view parsed data
class CVUploadScreen extends ConsumerStatefulWidget {
  const CVUploadScreen({super.key});

  @override
  ConsumerState<CVUploadScreen> createState() => _CVUploadScreenState();
}

class _CVUploadScreenState extends ConsumerState<CVUploadScreen> {
  final CVUploadService _cvService = CVUploadService();
  
  CVUploadState _uploadState = CVUploadState.initial;
  File? _selectedFile;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  String? _cvId;
  Map<String, dynamic>? _parsedData;

  /// Pick CV file
  Future<void> _pickFile() async {
    setState(() {
      _uploadState = CVUploadState.picking;
      _errorMessage = null;
    });

    try {
      final file = await _cvService.pickCVFile();
      
      if (file == null) {
        // User cancelled
        setState(() {
          _uploadState = CVUploadState.initial;
        });
        return;
      }

      // Validate file size
      if (!_cvService.validateFileSize(file)) {
        setState(() {
          _uploadState = CVUploadState.error;
          _errorMessage = 'File size exceeds 5MB limit';
        });
        return;
      }

      setState(() {
        _selectedFile = file;
        _uploadState = CVUploadState.uploading;
        _uploadProgress = 0.0;
      });

      // Upload file
      await _uploadFile(file);
    } catch (e) {
      setState(() {
        _uploadState = CVUploadState.error;
        _errorMessage = 'Failed to pick file: $e';
      });
    }
  }

  /// Upload file to server
  Future<void> _uploadFile(File file) async {
    try {
      String? cvId;
      await for (final data in _cvService.uploadCVWithProgress(file)) {
        if (!mounted) return;
        setState(() {
          _uploadProgress = data['progress'] ?? 0.0;
          if (data.containsKey('cvId')) {
            cvId = data['cvId'];
          }
        });
      }

      // Start parsing with the CV ID from upload
      setState(() {
        _uploadState = CVUploadState.parsing;
        _cvId = cvId;
      });

      // Poll for parsing status
      await _waitForParsing();
    } catch (e) {
      setState(() {
        _uploadState = CVUploadState.error;
        _errorMessage = 'Upload failed: $e';
      });
    }
  }

  /// Wait for CV parsing to complete
  Future<void> _waitForParsing() async {
    if (_cvId == null) return;

    try {
      // Poll parsing status
      while (true) {
        final status = await _cvService.getCVParseStatus(_cvId!);
        
        if (status == CVParseStatus.complete) {
          // Get parsed data
          final data = await _cvService.getParsedCVData(_cvId!);
          
          setState(() {
            _parsedData = data;
            _uploadState = CVUploadState.complete;
          });
          break;
        } else if (status == CVParseStatus.failed) {
          setState(() {
            _uploadState = CVUploadState.error;
            _errorMessage = 'CV parsing failed';
          });
          break;
        }
        
        // Wait before next poll
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      setState(() {
        _uploadState = CVUploadState.error;
        _errorMessage = 'Failed to parse CV: $e';
      });
    }
  }

  /// Cancel upload
  void _cancelUpload() {
    setState(() {
      _uploadState = CVUploadState.initial;
      _selectedFile = null;
      _uploadProgress = 0.0;
    });
  }

  /// Retry upload
  void _retryUpload() {
    if (_selectedFile != null) {
      setState(() {
        _uploadState = CVUploadState.uploading;
        _uploadProgress = 0.0;
        _errorMessage = null;
      });
      _uploadFile(_selectedFile!);
    } else {
      _pickFile();
    }
  }

  /// Remove uploaded file
  void _removeFile() {
    setState(() {
      _uploadState = CVUploadState.initial;
      _selectedFile = null;
      _uploadProgress = 0.0;
      _errorMessage = null;
      _cvId = null;
      _parsedData = null;
    });
  }

  /// Use parsed data (callback for parent screen)
  void _useParsedData() {
    if (_parsedData == null) return;
    
    // TODO: Navigate back or pass data to parent
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CV data imported successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context, _parsedData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload CV'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              _buildInstructions(theme),
              const SizedBox(height: 24),

              // Upload area
              _buildUploadArea(theme),
              const SizedBox(height: 24),

              // Parsed data preview
              if (_uploadState == CVUploadState.complete && _parsedData != null)
                _buildParsedDataPreview(theme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _uploadState == CVUploadState.complete
          ? _buildBottomBar(theme)
          : null,
    );
  }

  Widget _buildInstructions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload Instructions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              '• Supported formats: PDF, DOC, DOCX',
              theme,
            ),
            _buildInstructionItem(
              '• Maximum file size: 5MB',
              theme,
            ),
            _buildInstructionItem(
              '• AI will extract your skills, experience, and education',
              theme,
            ),
            _buildInstructionItem(
              '• Review and edit the extracted data before saving',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildUploadArea(ThemeData theme) {
    // Initial state - show upload button
    if (_uploadState == CVUploadState.initial) {
      return InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Your CV',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to browse files',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Uploading state
    if (_uploadState == CVUploadState.uploading) {
      return UploadProgressIndicator(
        progress: _uploadProgress,
        fileName: _selectedFile?.path.split('/').last,
        fileSize: _selectedFile != null
            ? _cvService.getFileSizeString(_selectedFile!)
            : null,
        onCancel: _cancelUpload,
      );
    }

    // Parsing state
    if (_uploadState == CVUploadState.parsing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'AI is analyzing your CV...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few moments',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_uploadState == CVUploadState.error) {
      return UploadErrorIndicator(
        fileName: _selectedFile?.path.split('/').last ?? 'Unknown file',
        errorMessage: _errorMessage ?? 'An error occurred',
        onRetry: _retryUpload,
        onRemove: _removeFile,
      );
    }

    // Complete state
    if (_uploadState == CVUploadState.complete && _selectedFile != null) {
      return UploadCompleteIndicator(
        fileName: _selectedFile!.path.split('/').last,
        fileSize: _cvService.getFileSizeString(_selectedFile!),
        onRemove: _removeFile,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildParsedDataPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extracted Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Skills
        if (_parsedData!['skills'] != null)
          _buildDataSection(
            theme,
            'Skills',
            Icons.code,
            (_parsedData!['skills'] as List).join(', '),
          ),

        // Experience
        if (_parsedData!['experiences'] != null)
          _buildExperienceSection(theme),

        // Education
        if (_parsedData!['educations'] != null)
          _buildEducationSection(theme),

        // Languages
        if (_parsedData!['languages'] != null)
          _buildDataSection(
            theme,
            'Languages',
            Icons.language,
            (_parsedData!['languages'] as List).join(', '),
          ),

        // Certifications
        if (_parsedData!['certifications'] != null)
          _buildDataSection(
            theme,
            'Certifications',
            Icons.workspace_premium,
            (_parsedData!['certifications'] as List).join(', '),
          ),
      ],
    );
  }

  Widget _buildDataSection(
    ThemeData theme,
    String title,
    IconData icon,
    String content,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection(ThemeData theme) {
    final experiences = _parsedData!['experiences'] as List;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.work_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Work Experience',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...experiences.map((exp) => _buildExperienceItem(theme, exp)),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceItem(ThemeData theme, Map<String, dynamic> exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp['jobTitle'] ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            exp['company'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (exp['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              exp['description'],
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationSection(ThemeData theme) {
    final educations = _parsedData!['educations'] as List;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Education',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...educations.map((edu) => _buildEducationItem(theme, edu)),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationItem(ThemeData theme, Map<String, dynamic> edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu['degree'] ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${edu['major'] ?? ''} • ${edu['institution'] ?? ''}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${edu['startYear']} - ${edu['endYear']}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _removeFile,
              child: const Text('Upload Another'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _useParsedData,
              child: const Text('Use This Data'),
            ),
          ),
        ],
      ),
    );
  }
}
