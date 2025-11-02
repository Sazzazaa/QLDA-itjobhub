# Interview Scheduling Feature - Testing Guide

## Quick Start

The Interview Scheduling feature has been integrated into your app. Follow these steps to test it:

## 1. Run the App

```bash
cd /home/nguyenthanhhuy/Documents/CODER/it_job_finder
flutter run
```

## 2. Navigate to Interviews

### From Bottom Navigation (Main Method)
1. Launch the app
2. Navigate through the splash/login screens to reach the Candidate Main Screen
3. Look at the bottom navigation bar
4. Tap on the **"Interviews"** tab (third icon - calendar icon)
5. You should see the Interview List Screen with sample data

### Navigation Path
```
Splash Screen → Login/Auth → Candidate Main Screen → Interviews Tab (Bottom Navigation)
```

## 3. Test Features

### A. Interview List Screen

**Test Upcoming Interviews:**
1. You should see the "Upcoming" tab selected by default
2. Check for 3 sample upcoming interviews:
   - Senior Flutter Developer at TechCorp Inc. (2 days away)
   - Mobile Developer at StartUp Labs (5 hours away) - **Should show urgent warning**
   - Full Stack Developer at Enterprise Solutions (5 days away)
3. Verify badge showing count of upcoming interviews
4. Test pull-to-refresh by dragging down

**Test Past Interviews:**
1. Switch to "Past" tab
2. You should see 2 past interviews:
   - React Native Developer at Mobile First Co. (completed)
   - iOS Developer at Apple Store Builder (cancelled)
3. Verify different status colors and icons

**Test Empty State:**
- If you see "No upcoming/past interviews", the service might not be initialized
- Check console for any errors

### B. Interview Detail Screen

1. Tap any interview card from the list
2. Verify you see:
   - Company logo and job title
   - Status badge
   - Date, time, duration, type
   - Meeting link (for video) or location (for onsite) or phone (for phone)
   - Interviewer information
   - Interview notes
   - Action buttons (join, reschedule, cancel)

**Test Video Interview:**
1. Find the "Senior Flutter Developer" interview (video type)
2. Tap to open details
3. Check for "Join Meeting" button
4. Check for meeting link display
5. Test "Copy Link" functionality

**Test Phone Interview:**
1. Find the "Mobile Developer" interview (phone type)
2. Tap to open details
3. Check for phone number display
4. Check for "Call" button

**Test Onsite Interview:**
1. Find the "Full Stack Developer" interview (onsite type)
2. Tap to open details
3. Check for location display
4. Check for "Get Directions" button

**Test Reschedule:**
1. Open any upcoming interview
2. Tap the menu button (3 dots) in app bar
3. Select "Reschedule"
4. Verify it opens the Interview Scheduling Screen
5. Select a new date and time
6. Confirm the reschedule
7. Verify status changes to "RESCHEDULED"
8. Go back to list and verify the change

**Test Cancel:**
1. Open any upcoming interview
2. Tap the menu button (3 dots) in app bar
3. Select "Cancel Interview"
4. Confirm the cancellation
5. Verify status changes to "CANCELLED"
6. Interview should move to "Past" tab

### C. Interview Scheduling Screen

**Test Calendar Navigation:**
1. From interview detail, tap "Reschedule" OR
2. Navigate from a job application (if integrated)
3. Verify job title and company name in header
4. Test month navigation (left/right arrows)
5. Dates with available slots should be highlighted
6. Past dates should be disabled
7. Tap on an available date

**Test Interview Type Selection:**
1. Select different interview types (Video, Phone, On-site)
2. Verify chip colors change
3. Verify only one type can be selected at a time

**Test Time Slot Selection:**
1. After selecting a date, check available time slots
2. Tap a time slot to select
3. Verify selection is highlighted
4. Change selection to different time slot

**Test Schedule Confirmation:**
1. Select type, date, and time
2. Tap "Confirm Schedule" button
3. Review confirmation dialog
4. Verify all details are correct
5. Confirm scheduling
6. Verify success message
7. Navigate back to interview list
8. Verify new interview appears in "Upcoming" tab

## 4. Mock Data Details

The app includes 5 sample interviews:

### Upcoming (3):
1. **Senior Flutter Developer** @ TechCorp Inc.
   - Type: Video
   - Time: 2 days from now, 10:00 AM
   - Duration: 60 min
   - Meeting Link: https://meet.google.com/abc-defg-hij

2. **Mobile Developer** @ StartUp Labs
   - Type: Phone
   - Time: 5 hours from now
   - Duration: 30 min
   - Phone: +1-555-0123
   - **Shows urgent warning** (within 24 hours)

3. **Full Stack Developer** @ Enterprise Solutions
   - Type: On-site
   - Time: 5 days from now, 2:00 PM
   - Duration: 90 min
   - Location: 123 Business Ave, Suite 400, Tech City

### Past (2):
4. **React Native Developer** @ Mobile First Co.
   - Status: Completed
   - Time: 3 days ago
   - Feedback available

5. **iOS Developer** @ Apple Store Builder
   - Status: Cancelled
   - Time: 10 days ago

## 5. Available Dates for Scheduling

When testing the scheduling screen, these dates have available time slots:
- **January 15, 2025**: 9:00 AM, 10:00 AM, 2:00 PM, 3:00 PM, 4:00 PM
- **January 16, 2025**: 9:00 AM, 11:00 AM, 2:00 PM, 4:00 PM
- **January 17, 2025**: 10:00 AM, 11:00 AM, 1:00 PM, 3:00 PM, 4:00 PM
- **January 18, 2025**: 9:00 AM, 10:00 AM, 2:00 PM, 3:00 PM
- **January 20, 2025**: 9:00 AM, 10:00 AM, 11:00 AM, 2:00 PM, 3:00 PM, 4:00 PM

## 6. Visual Checklist

### Colors to Verify:
- ✅ **Blue**: Scheduled status, Phone interview type
- ✅ **Purple**: Video interview type
- ✅ **Green**: On-site interview type, Completed status
- ✅ **Orange**: Urgent warning (24h), Rescheduled status
- ✅ **Red**: Cancelled status, Cancel buttons
- ✅ **Grey**: No-show status

### Icons to Verify:
- ✅ Calendar icon in bottom navigation
- ✅ Status icons (schedule, check, cancel, update)
- ✅ Interview type icons (phone, video, location)
- ✅ Duration timer icon
- ✅ Company logo placeholder

## 7. Expected Behaviors

### Good UX Elements:
- Smooth transitions between screens
- Clear visual feedback on selections
- Loading indicators during operations
- Success/error messages via SnackBar
- Pull-to-refresh on interview list
- Badge counts update in real-time
- Disabled states for unavailable actions

### Edge Cases to Test:
1. **No interviews**: Empty state should show helpful message
2. **Interview within 24 hours**: Orange urgent warning should display
3. **Past date selection**: Should be disabled in calendar
4. **No available slots**: Should show "No available slots" message
5. **Reschedule same interview twice**: Should update correctly
6. **Cancel and try to join**: Join button should not appear

## 8. Common Issues & Solutions

### Issue: No interviews showing
**Solution**: Check if InterviewService is initialized in main.dart (should be already done)

### Issue: App crashes on navigation
**Solution**: Verify all imports are correct in candidate_main_screen.dart

### Issue: Calendar not showing available dates
**Solution**: Check date format in mock data matches current month/year

### Issue: Can't see Interviews tab
**Solution**: Make sure you're logged in as a candidate (not employer)

## 9. Performance Testing

Monitor for:
- Smooth scrolling in interview list
- Quick calendar month navigation
- Fast state updates on selections
- No lag on tab switching
- Efficient rendering of interview cards

## 10. Accessibility Testing

Verify:
- All buttons have proper labels
- Colors have sufficient contrast
- Touch targets are at least 44x44 pixels
- Screen reader compatibility (if enabled)

## 11. Debug Commands

If you encounter issues:

```bash
# Check for compilation errors
flutter analyze

# Clear build cache
flutter clean && flutter pub get

# Run with verbose logging
flutter run -v

# Check specific screen
flutter analyze lib/features/candidate/screens/interview_list_screen.dart
```

## 12. Screenshot Checklist

For documentation, capture:
1. Interview list - Upcoming tab with badges
2. Interview list - Past tab
3. Interview detail - Video type
4. Interview detail - Phone type
5. Interview detail - Onsite type
6. Scheduling screen - Calendar view
7. Scheduling screen - Time slot selection
8. Confirmation dialog
9. Urgent warning (24h interview)
10. Empty state

## Success Criteria

✅ All 5 mock interviews display correctly  
✅ Tab switching works smoothly  
✅ Interview details show complete information  
✅ Reschedule flow completes successfully  
✅ Cancel flow completes successfully  
✅ New interview can be scheduled  
✅ Urgent warnings appear for 24h interviews  
✅ Status badges show correct colors  
✅ Pull-to-refresh works  
✅ Empty states display properly  

## Next Steps After Testing

Once testing is complete:
1. Take screenshots/screen recording
2. Note any bugs or UX improvements
3. Test on different screen sizes (phone/tablet)
4. Test on both Android and iOS (if available)
5. Prepare for backend integration
6. Add real authentication
7. Implement push notifications

## Need Help?

Check the implementation documentation:
- `INTERVIEW_SCHEDULING_FEATURE.md` - Complete feature documentation
- Console logs for error messages
- Flutter DevTools for debugging

Happy Testing! 🚀
