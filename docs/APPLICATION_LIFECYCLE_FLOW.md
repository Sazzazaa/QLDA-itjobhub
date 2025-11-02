# Application Lifecycle Flow

## Status Flow Chart

```
┌─────────────────────────────────────────────────────────────────┐
│                    APPLICATION LIFECYCLE                         │
└─────────────────────────────────────────────────────────────────┘

1. PENDING (Initial)
   ↓
   ├─→ REJECTED (Employer rejects without interview)
   │   └─→ END
   │
   └─→ APPROVED (Employer approves for interview)
       ↓
       2. INTERVIEW (Schedule interview)
          ↓
          ├─→ REJECTED (After interview - not hired)
          │   └─→ END
          │
          └─→ APPROVED (Hired after successful interview)
              └─→ END
```

## Detailed Status Descriptions

### 1. PENDING
- **Trigger:** Candidate submits application
- **Who sees:** Both candidate and employer
- **Actions available:**
  - **Employer:** Review → Approve/Reject
  - **Candidate:** Withdraw application

### 2. REVIEWING (Optional - future)
- **Trigger:** Employer opens application detail
- **Who sees:** Both
- **Actions available:**
  - **Employer:** Approve/Reject
  - **Candidate:** Withdraw

### 3. APPROVED (For Interview)
- **Trigger:** Employer clicks "Approve" button
- **Who sees:** Both
- **Notification:** Candidate receives "Your application has been approved"
- **Actions available:**
  - **Employer:** Schedule Interview, Send Message, Reject
  - **Candidate:** View details, Send Message

### 4. INTERVIEW
- **Trigger:** Employer schedules an interview
- **Who sees:** Both
- **Actions available:**
  - **Employer:** Update interview status, Hire/Reject after interview
  - **Candidate:** Accept/Reschedule interview

### 5. REJECTED
- **Trigger:** Employer clicks "Reject" at any stage
- **Who sees:** Both
- **Notification:** Candidate receives rejection notification
- **Actions available:** None (Final state)
- **Note:** Can include `rejectionReason` for feedback

### 6. WITHDRAWN
- **Trigger:** Candidate withdraws their application
- **Who sees:** Both
- **Notification:** Employer receives withdrawal notification
- **Actions available:** None (Final state)

---

## UI Changes Required

### Application Detail Screen (Employer)

**Current buttons:**
```dart
Row(
  children: [
    Expanded(OutlinedButton(onPressed: reject, label: 'Reject')),
    Expanded(ElevatedButton(onPressed: approve, label: 'Approve')),
  ],
)
```

**Updated logic:**
```dart
// If status == PENDING or APPROVED
if (_currentStatus == ApplicationStatus.pending || _currentStatus == ApplicationStatus.approved) {
  // Show Reject/Approve buttons
}

// If status == APPROVED
if (_currentStatus == ApplicationStatus.approved) {
  // Enable "Schedule Interview" button
  // After scheduling → Auto-change status to INTERVIEW
}

// If status == INTERVIEW and interview completed
if (_currentStatus == ApplicationStatus.interview && interviewCompleted) {
  // Show "Hire" and "Reject" buttons
  // "Hire" → status becomes APPROVED (final)
  // "Reject" → status becomes REJECTED
}

// If status == REJECTED or WITHDRAWN
// Show status badge only, no actions
```

---

## Backend Changes Required

### 1. Update ApplicationsService.updateStatus()

Add validation logic:
```typescript
async updateStatus(id: string, newStatus: ApplicationStatus, note?: string) {
  const application = await this.applicationModel.findById(id);
  
  // Validate status transitions
  if (application.status === 'rejected' || application.status === 'withdrawn') {
    throw new BadRequestException('Cannot change status of closed application');
  }
  
  // If changing to INTERVIEW, ensure there's a scheduled interview
  if (newStatus === 'interview') {
    const interview = await this.interviewModel.findOne({
      applicationId: id,
      status: { $in: ['scheduled', 'completed'] }
    });
    if (!interview) {
      throw new BadRequestException('Cannot set status to INTERVIEW without scheduling an interview');
    }
  }
  
  // Update status
  return this.applicationModel.findByIdAndUpdate(
    id,
    {
      status: newStatus,
      $push: {
        timeline: {
          status: newStatus,
          timestamp: new Date(),
          note,
        },
      },
    },
    { new: true },
  ).populate('jobId candidateId');
}
```

### 2. Auto-update status when interview is scheduled

In `InterviewsService.create()`:
```typescript
// After creating interview
await this.applicationModel.findByIdAndUpdate(
  createInterviewDto.applicationId,
  { 
    status: ApplicationStatus.INTERVIEW,
    $push: {
      timeline: {
        status: ApplicationStatus.INTERVIEW,
        timestamp: new Date(),
        note: 'Interview scheduled',
      },
    },
  }
);
```

### 3. Create notification on status change

In `ApplicationsService.updateStatus()`:
```typescript
// Create notification for candidate
if (newStatus === 'approved') {
  await this.notificationModel.create({
    userId: application.candidateId,
    type: 'application',
    title: 'Application Approved',
    message: `Your application for ${job.title} has been approved for interview`,
    relatedId: application._id,
    relatedType: 'application',
  });
} else if (newStatus === 'rejected') {
  await this.notificationModel.create({
    userId: application.candidateId,
    type: 'application',
    title: 'Application Status Update',
    message: `Your application for ${job.title} has been updated`,
    relatedId: application._id,
    relatedType: 'application',
  });
}
```

---

## Frontend Changes Required

### 1. ApplicationDetailScreen (Employer)

Update button logic based on status:
```dart
// Approve button - only if pending
if (_currentStatus == ApplicationStatus.pending) {
  ElevatedButton(
    onPressed: () => _updateStatus(ApplicationStatus.approved),
    child: Text('Approve for Interview'),
  )
}

// Reject button - only if pending or approved
if (_currentStatus == ApplicationStatus.pending || 
    _currentStatus == ApplicationStatus.approved) {
  OutlinedButton(
    onPressed: () => _showRejectDialog(),
    child: Text('Reject'),
  )
}

// Schedule Interview - only if approved
if (_currentStatus == ApplicationStatus.approved) {
  OutlinedButton(
    onPressed: _scheduleInterview,
    child: Text('Schedule Interview'),
  )
}

// Hire button - only if interview completed
if (_currentStatus == ApplicationStatus.interview && _hasCompletedInterview) {
  ElevatedButton(
    onPressed: () => _updateStatus(ApplicationStatus.approved, 'Candidate hired'),
    child: Text('Hire Candidate'),
  )
}
```

### 2. Add ApplicationService.updateStatus()

```dart
Future<void> updateStatus(String applicationId, ApplicationStatus newStatus, {String? note}) async {
  await _apiClient.put(
    '/applications/$applicationId/status',
    {
      'status': newStatus.name,
      if (note != null) 'note': note,
    },
  );
}
```

---

## Implementation Priority

1. ✅ Backend: Add status transition validation
2. ✅ Backend: Auto-update status when interview scheduled
3. ✅ Backend: Create notifications on status change
4. ✅ Frontend: Update ApplicationDetailScreen UI logic
5. ✅ Frontend: Add ApplicationService.updateStatus() method
6. ✅ Test: Full flow from application → approval → interview → hire

---

**Last Updated:** 2025-11-01
**Status:** Design complete, ready for implementation
