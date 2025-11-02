import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/interview_model.dart';
import '../../../services/interview_service.dart';
import '../../../services/api_client.dart';

class InterviewSchedulingScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String candidateId;
  final String applicationId;
  final Interview? existingInterview; // For rescheduling

  const InterviewSchedulingScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.candidateId,
    required this.applicationId,
    this.existingInterview,
  });

  @override
  State<InterviewSchedulingScreen> createState() =>
      _InterviewSchedulingScreenState();
}

class _InterviewSchedulingScreenState extends State<InterviewSchedulingScreen> {
  final InterviewService _interviewService = InterviewService();
  final TextEditingController _meetingLinkController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  InterviewType _selectedType = InterviewType.online;
  bool _isLoading = false;

  @override
  void dispose() {
    _meetingLinkController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Mock available time slots - in real app, fetch from backend
  // Generate slots for today and next 30 days (excluding past hours for today)
  Map<String, List<String>> get _availableSlots {
    final now = DateTime.now();
    final slots = <String, List<String>>{};
    
    // Add slots for today and next 30 days (excluding weekends)
    for (int i = 0; i <= 30; i++) {
      final date = now.add(Duration(days: i));
      // Skip weekends (Saturday = 6, Sunday = 7)
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        
        // All available time slots for the day
        List<String> allSlots;
        if (i % 3 == 0) {
          allSlots = ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM', '04:00 PM'];
        } else if (i % 2 == 0) {
          allSlots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'];
        } else {
          allSlots = ['10:00 AM', '11:00 AM', '01:00 PM', '03:00 PM'];
        }
        
        // For today, filter out past time slots
        if (i == 0) {
          final currentHour = now.hour;
          allSlots = allSlots.where((slot) {
            final hour = int.parse(slot.split(':')[0]);
            final isPM = slot.contains('PM');
            final hour24 = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);
            return hour24 > currentHour;
          }).toList();
        }
        
        slots[dateKey] = allSlots;
      }
    }
    
    return slots;
  }

  bool get _isRescheduling => widget.existingInterview != null;

  List<String> get _currentDaySlots {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _availableSlots[dateKey] ?? [];
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 60));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(firstDate) ? firstDate : _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot when date changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRescheduling ? 'Reschedule Interview' : 'Schedule Interview'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Info Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jobTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.companyName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (_isRescheduling) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
              'Current: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.existingInterview!.scheduledAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Interview Type Selection
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interview Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: InterviewType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getInterviewTypeIcon(type),
                              size: 16,
                              color: isSelected ? Colors.white : _getInterviewTypeColor(type),
                            ),
                            const SizedBox(width: 4),
                            Text(_getInterviewTypeLabel(type)),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  
                  // Meeting Link / Location Input based on type
                  const SizedBox(height: 16),
                  if (_selectedType == InterviewType.online) ...[
                    TextField(
                      controller: _meetingLinkController,
                      decoration: InputDecoration(
                        labelText: 'Meeting Link (Optional)',
                        hintText: 'https://meet.google.com/xxx-xxxx-xxx',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ] else if (_selectedType == InterviewType.onsite) ...[
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Interview Location (Optional)',
                        hintText: 'Enter office address',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                  // close inner Column and Padding for Interview Type
                  ],
                ),
              ),

            // Time Slots
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Available Time Slots',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Date Picker Button
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_selectedDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTimeSlots(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedTimeSlot == null || _isLoading
                ? null
                : _confirmScheduling,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isRescheduling ? 'Confirm Reschedule' : 'Confirm Schedule',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_currentDaySlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No available slots for this date',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _currentDaySlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        return ChoiceChip(
          label: Text(slot),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedTimeSlot = selected ? slot : null;
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _confirmScheduling() async {
    if (_selectedTimeSlot == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isRescheduling ? 'Confirm Reschedule' : 'Confirm Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isRescheduling
                  ? 'Are you sure you want to reschedule this interview?'
                  : 'Are you sure you want to schedule this interview?',
            ),
            const SizedBox(height: 16),
            _buildConfirmationDetail('Job', widget.jobTitle),
            _buildConfirmationDetail('Company', widget.companyName),
            _buildConfirmationDetail(
              'Type',
              _getInterviewTypeLabel(_selectedType),
            ),
            _buildConfirmationDetail(
              'Date',
              DateFormat('MMM dd, yyyy').format(_selectedDate),
            ),
            _buildConfirmationDetail('Time', _selectedTimeSlot!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      // Parse the selected time
      final timeParts = _selectedTimeSlot!.split(' ');
      final timeComponents = timeParts[0].split(':');
      int hour = int.parse(timeComponents[0]);
      final minute = int.parse(timeComponents[1]);
      final isPM = timeParts[1] == 'PM';

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      if (_isRescheduling) {
        // Update existing interview
        final updatedInterview = widget.existingInterview!.copyWith(
          scheduledAt: scheduledDateTime,
          type: _selectedType,
          status: InterviewStatus.rescheduled,
        );
        _interviewService.updateInterview(updatedInterview);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Interview rescheduled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new interview via backend API so application and notifications are handled server-side
        try {
          final api = ApiClient();
          final payload = {
            'jobId': widget.jobId,
            'candidateId': widget.candidateId,
            'applicationId': widget.applicationId,
            'scheduledAt': scheduledDateTime.toIso8601String(),
            'type': _selectedType.name,
            'duration': 60,
            'meetingLink': _selectedType == InterviewType.online && _meetingLinkController.text.isNotEmpty
                ? _meetingLinkController.text.trim()
                : null,
            'location': _selectedType == InterviewType.onsite && _locationController.text.isNotEmpty
                ? _locationController.text.trim()
                : null,
            'notes': 'Please be prepared to discuss your experience and technical skills.',
          };

          final created = await api.post('/interviews', payload);
          final interview = Interview.fromJson(created as Map<String, dynamic>);
          _interviewService.addInterview(interview);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Interview scheduled successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to schedule interview: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      setState(() => _isLoading = false);

      // Navigate back
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule interview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildConfirmationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getInterviewTypeColor(InterviewType type) {
    switch (type) {
      case InterviewType.online:
        return Colors.purple;
      case InterviewType.onsite:
        return Colors.green;
    }
  }

  IconData _getInterviewTypeIcon(InterviewType type) {
    switch (type) {
      case InterviewType.online:
        return Icons.videocam;
      case InterviewType.onsite:
        return Icons.location_on;
    }
  }

  String _getInterviewTypeLabel(InterviewType type) {
    switch (type) {
      case InterviewType.online:
        return 'Online';
      case InterviewType.onsite:
        return 'On-site';
    }
  }
}
