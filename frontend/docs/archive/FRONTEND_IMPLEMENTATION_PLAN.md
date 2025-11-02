# 🎨 Flutter Frontend Implementation Plan - Complete Requirements

**Project**: ITJobHub - IT Job Finder App  
**Focus**: Complete all frontend requirements from requirements.md  
**Status**: Planning Phase  
**Timeline**: 6-8 weeks (estimated)

---

## 📊 Current State Analysis

### ✅ **What We Have** (47% Complete)

#### **Screens Implemented:**
1. ✅ splash_screen.dart - Animated splash
2. ✅ role_selection_screen.dart - Role picker
3. ✅ login_screen.dart - Email login (refactored)
4. ✅ register_screen.dart - Registration (refactored)
5. ✅ candidate_main_screen.dart - Navigation wrapper
6. ✅ employer_main_screen.dart - Navigation wrapper
7. ✅ candidate_home_screen.dart - Dashboard
8. ✅ employer_home_screen.dart - Dashboard
9. ✅ job_board_screen.dart - Job search (refactored)
10. ✅ job_detail_screen.dart - Job details (refactored)
11. ✅ saved_jobs_screen.dart - Saved jobs (refactored)
12. ✅ applications_screen.dart - Application tracking (refactored)
13. ✅ employer_applications_screen.dart - Review applications (refactored)
14. ✅ application_detail_screen.dart - Application details
15. ✅ post_job_screen.dart - Job posting form
16. ✅ employer_jobs_screen.dart - Employer job list
17. ✅ candidate_profile_screen.dart - Profile editing
18. ✅ employer_profile_screen.dart - Company profile
19. ✅ settings_screen.dart - App settings

#### **Component Library (18 components):**
✅ EmptyState, ErrorState, LoadingState, ShimmerLoading  
✅ PrimaryButton, SecondaryButton, AppTextButton  
✅ StatusChip, SelectableChip  
✅ CustomCard, HeaderCard, IconCard, InfoCard  
✅ CustomInput, SearchInput, DropdownInput

#### **Models:**
✅ job_model.dart  
✅ candidate_model.dart  
✅ application_model.dart  
✅ job_application_model.dart

#### **Services:**
✅ job_service.dart

---

## 🎯 **What's Missing** (Requirements Gap Analysis)

### 🔴 **Critical Missing Features:**

#### **1. Social Authentication UI** ❌
**Required:**
- Google Sign-In button
- GitHub OAuth button
- LinkedIn OAuth button
- Social login flow screens

**Components Needed:**
- SocialLoginButton widget
- OAuth callback handlers

**Files to Create:**
- `lib/widgets/common/social_login_button.dart`

**Files to Modify:**
- `lib/features/auth/screens/login_screen.dart`
- `lib/features/auth/screens/register_screen.dart`

---

#### **2. CV Upload & Parsing UI** ❌ **MAJOR**
**Required:**
- File picker for PDF/DOC upload
- CV upload card/button
- Upload progress indicator
- Parsing status display
- Auto-filled profile preview

**Components Needed:**
- FileUploadCard
- UploadProgressIndicator
- CVParsingStatusCard

**Files to Create:**
- `lib/widgets/common/file_upload_card.dart`
- `lib/features/candidate/screens/cv_upload_screen.dart`
- `lib/features/candidate/widgets/cv_preview_card.dart`
- `lib/services/cv_upload_service.dart`

**Files to Modify:**
- `lib/features/candidate/screens/candidate_profile_screen.dart` (add CV upload button)

---

#### **3. Skills Tagging System** ❌
**Required:**
- Tag-based skill input (like chips)
- Skill autocomplete/suggestions
- Add/remove skills
- Visual skill tags display
- Skill level indicators (beginner/intermediate/expert)

**Components Needed:**
- SkillTag widget
- SkillInput widget with autocomplete
- SkillLevelIndicator

**Files to Create:**
- `lib/widgets/common/skill_tag.dart`
- `lib/widgets/common/skill_input.dart`
- `lib/features/candidate/widgets/skills_section.dart`

**Files to Modify:**
- `lib/features/candidate/screens/candidate_profile_screen.dart`
- `lib/models/candidate_model.dart` (add skills field)

---

#### **4. Real-Time Chat UI** ❌ **MAJOR**
**Required:**
- Chat list screen (conversations)
- Chat screen (1-on-1 messaging)
- Message bubbles (sent/received)
- Chat input bar
- Typing indicator
- Online status indicator
- Timestamp display
- Read receipts

**Components Needed:**
- ChatBubble widget
- ChatInputBar widget
- TypingIndicator widget
- OnlineStatusBadge widget
- MessageTimestamp widget

**Files to Create:**
- `lib/features/chat/screens/chat_list_screen.dart`
- `lib/features/chat/screens/chat_screen.dart`
- `lib/features/chat/widgets/chat_bubble.dart`
- `lib/features/chat/widgets/chat_input_bar.dart`
- `lib/features/chat/widgets/typing_indicator.dart`
- `lib/features/chat/widgets/conversation_card.dart`
- `lib/models/message_model.dart`
- `lib/models/conversation_model.dart`
- `lib/services/chat_service.dart` (WebSocket wrapper)

**Files to Modify:**
- `lib/features/candidate/screens/candidate_main_screen.dart` (add chat tab)
- `lib/features/employer/screens/employer_main_screen.dart` (add chat tab)

---

#### **5. AI Job Matching Display** ❌ **MAJOR**
**Required:**
- Match percentage display on job cards
- Match breakdown (which skills match)
- "Why this job" explanation
- Match score indicator (visual)

**Components Needed:**
- MatchPercentageCard
- MatchBreakdownDialog
- SkillMatchIndicator

**Files to Create:**
- `lib/widgets/common/match_percentage_card.dart`
- `lib/widgets/common/match_indicator.dart`
- `lib/features/candidate/widgets/match_breakdown_dialog.dart`

**Files to Modify:**
- `lib/features/candidate/widgets/job_card.dart` (add match percentage)
- `lib/features/candidate/screens/job_board_screen.dart` (show matches)
- `lib/models/job_model.dart` (add matchPercentage field)

---

#### **6. Interview Scheduling UI** ❌
**Required:**
- Calendar view for interviews
- Schedule interview screen
- Interview list with status
- Reminder notifications UI
- Time slot picker

**Components Needed:**
- CalendarWidget
- InterviewCard
- TimeSlotPicker
- InterviewStatusBadge

**Files to Create:**
- `lib/features/interviews/screens/interview_calendar_screen.dart`
- `lib/features/interviews/screens/schedule_interview_screen.dart`
- `lib/features/interviews/screens/interview_list_screen.dart`
- `lib/features/interviews/widgets/interview_card.dart`
- `lib/features/interviews/widgets/time_slot_picker.dart`
- `lib/widgets/common/calendar_widget.dart`
- `lib/models/interview_model.dart`
- `lib/services/interview_service.dart`

**Files to Modify:**
- `lib/features/candidate/screens/candidate_main_screen.dart` (add interviews tab)
- `lib/features/employer/screens/employer_main_screen.dart` (add interviews tab)

---

#### **7. Portfolio Links** ❌
**Required:**
- GitHub profile link input
- Behance/Dribbble links
- Personal website URL
- Portfolio project list
- External link buttons/icons

**Components Needed:**
- PortfolioLinkInput
- PortfolioLinkCard
- ProjectCard

**Files to Create:**
- `lib/features/candidate/widgets/portfolio_section.dart`
- `lib/features/candidate/widgets/portfolio_link_card.dart`
- `lib/features/candidate/widgets/project_card.dart`

**Files to Modify:**
- `lib/features/candidate/screens/candidate_profile_screen.dart`
- `lib/models/candidate_model.dart` (add portfolio fields)

---

### 🟡 **Important Missing Features:**

#### **8. Review System UI** ❌
**Required:**
- Company review screen (rate & write review)
- Review list display
- Star rating widget
- Review cards
- Candidate review (employer perspective)

**Components Needed:**
- RatingWidget (star input)
- RatingDisplay (star display)
- ReviewCard
- ReviewForm

**Files to Create:**
- `lib/features/reviews/screens/write_review_screen.dart`
- `lib/features/reviews/screens/company_reviews_screen.dart`
- `lib/features/reviews/screens/candidate_reviews_screen.dart`
- `lib/features/reviews/widgets/rating_widget.dart`
- `lib/features/reviews/widgets/review_card.dart`
- `lib/features/reviews/widgets/review_form.dart`
- `lib/models/review_model.dart`
- `lib/services/review_service.dart`

**Files to Modify:**
- `lib/features/candidate/screens/job_detail_screen.dart` (add company reviews)
- `lib/features/employer/screens/application_detail_screen.dart` (add review option)

---

#### **9. AI Candidate Search Chat (Employer)** ❌ **MAJOR**
**Required:**
- Conversational AI chat interface
- Natural language query input
- AI response with candidate suggestions
- Follow-up question handling
- Candidate profile quick view
- Integration with job posts

**Components Needed:**
- AIChatBubble
- CandidateSuggestionCard
- QuickActionButtons

**Files to Create:**
- `lib/features/employer/screens/ai_candidate_search_screen.dart`
- `lib/features/employer/widgets/ai_chat_bubble.dart`
- `lib/features/employer/widgets/candidate_suggestion_card.dart`
- `lib/services/ai_search_service.dart`

**Files to Modify:**
- `lib/features/employer/screens/employer_home_screen.dart` (add AI search shortcut)

---

#### **10. Push Notifications UI** ❌
**Required:**
- Notification center screen
- Notification cards/list
- Notification badges (unread count)
- Notification settings
- In-app notification banners

**Components Needed:**
- NotificationCard
- NotificationBadge
- NotificationBanner

**Files to Create:**
- `lib/features/notifications/screens/notification_center_screen.dart`
- `lib/features/notifications/screens/notification_settings_screen.dart`
- `lib/features/notifications/widgets/notification_card.dart`
- `lib/features/notifications/widgets/notification_badge.dart`
- `lib/models/notification_model.dart`
- `lib/services/notification_service.dart`

**Files to Modify:**
- `lib/features/candidate/screens/candidate_main_screen.dart` (add notification icon)
- `lib/features/employer/screens/employer_main_screen.dart` (add notification icon)

---

#### **11. Advanced Filters Enhancement** ❌
**Required:**
- Remote/Onsite/Hybrid filter
- Contract type (Full-time/Freelance/Contract)
- Salary range slider
- Benefits filter (checkboxes)
- Experience level filter

**Components Needed:**
- RangeSlider wrapper
- FilterCheckboxGroup
- RemoteTypeFilter

**Files to Create:**
- `lib/features/candidate/widgets/advanced_filters_dialog.dart`
- `lib/widgets/common/range_slider_input.dart`
- `lib/widgets/common/filter_checkbox_group.dart`

**Files to Modify:**
- `lib/features/candidate/screens/job_board_screen.dart` (add advanced filters)
- `lib/models/job_model.dart` (add new filter fields)

---

### 🟢 **Nice-to-Have Features:**

#### **12. Forum/Blog** ❌
**Required:**
- Forum post list
- Post detail screen
- Create post screen
- Comments section
- Like/share functionality

**Files to Create:**
- `lib/features/forum/screens/forum_list_screen.dart`
- `lib/features/forum/screens/post_detail_screen.dart`
- `lib/features/forum/screens/create_post_screen.dart`
- `lib/features/forum/widgets/post_card.dart`
- `lib/features/forum/widgets/comment_card.dart`
- `lib/models/post_model.dart`
- `lib/services/forum_service.dart`

---

#### **13. Badges & Rankings** ❌
**Required:**
- Badge display (achievement icons)
- User ranking/leaderboard
- Skill certification screen
- Quiz/assessment UI

**Files to Create:**
- `lib/features/badges/screens/badges_screen.dart`
- `lib/features/badges/screens/leaderboard_screen.dart`
- `lib/features/badges/screens/skill_quiz_screen.dart`
- `lib/features/badges/widgets/badge_icon.dart`
- `lib/features/badges/widgets/rank_card.dart`
- `lib/models/badge_model.dart`

---

#### **14. Analytics Dashboard (Employer)** ❌
**Required:**
- Statistics overview
- Charts (bar, line, pie)
- Popular skills display
- Application trends
- Candidate insights

**Files to Create:**
- `lib/features/employer/screens/analytics_screen.dart`
- `lib/features/employer/widgets/stat_card.dart`
- `lib/features/employer/widgets/chart_widget.dart` (use fl_chart package)
- `lib/services/analytics_service.dart`

---

#### **15. CV Improvement Suggestions** ❌
**Required:**
- AI suggestions display
- Improvement checklist
- Before/after comparison
- Tips and recommendations

**Files to Create:**
- `lib/features/candidate/screens/cv_improvement_screen.dart`
- `lib/features/candidate/widgets/suggestion_card.dart`
- `lib/features/candidate/widgets/improvement_checklist.dart`

---

## 🏗️ **Implementation Phases**

### **Phase 1: Component Library Extension (Week 1)**
**Priority: HIGH** - Foundation for all other features

#### **New Components to Build:**
1. `social_login_button.dart` - For OAuth login
2. `file_upload_card.dart` - CV upload UI
3. `skill_tag.dart` - Skill display chips
4. `skill_input.dart` - Autocomplete skill input
5. `chat_bubble.dart` - Message display
6. `chat_input_bar.dart` - Message composition
7. `match_percentage_card.dart` - Match score display
8. `rating_widget.dart` - Star rating input/display
9. `notification_card.dart` - Notification display
10. `calendar_widget.dart` - Calendar view
11. `portfolio_link_card.dart` - Portfolio links
12. `badge_icon.dart` - Achievement badges

**Deliverables:**
- [ ] 12 new reusable components
- [ ] Updated `lib/widgets/common/index.dart`
- [ ] Documentation for each component
- [ ] 0 lint errors

**Estimated Time: 5-7 days**

---

### **Phase 2: Profile Enhancement (Week 2)**
**Priority: HIGH** - Core user functionality

#### **Tasks:**
1. **CV Upload Screen**
   - [ ] Build file picker integration
   - [ ] Upload progress UI
   - [ ] Parsing status display
   - [ ] Success/error handling

2. **Skills Management**
   - [ ] Skills tagging input
   - [ ] Autocomplete suggestions
   - [ ] Skill level selection
   - [ ] Visual skill display

3. **Portfolio Section**
   - [ ] GitHub link input
   - [ ] Portfolio URL fields
   - [ ] Project showcase cards
   - [ ] External link buttons

4. **Enhanced Profile Forms**
   - [ ] Update candidate_profile_screen.dart
   - [ ] Add all new fields from requirements
   - [ ] Location preferences (remote/onsite)
   - [ ] Salary expectations

**Deliverables:**
- [ ] cv_upload_screen.dart
- [ ] Enhanced candidate_profile_screen.dart
- [ ] skills_section.dart widget
- [ ] portfolio_section.dart widget
- [ ] Updated candidate_model.dart

**Estimated Time: 5-7 days**

---

### **Phase 3: Chat System UI (Week 3)**
**Priority: HIGH** - Major feature

#### **Tasks:**
1. **Chat List Screen**
   - [ ] Conversation list
   - [ ] Last message preview
   - [ ] Unread badges
   - [ ] Search conversations

2. **Chat Screen**
   - [ ] Message list (scrollable)
   - [ ] Sent/received bubbles
   - [ ] Timestamp display
   - [ ] Online status indicator

3. **Chat Input**
   - [ ] Text input field
   - [ ] Send button
   - [ ] Typing indicator
   - [ ] Character count (optional)

4. **Integration**
   - [ ] Add chat tab to navigation
   - [ ] Chat service (WebSocket ready)
   - [ ] Message models

**Deliverables:**
- [ ] chat_list_screen.dart
- [ ] chat_screen.dart
- [ ] All chat widgets
- [ ] message_model.dart
- [ ] conversation_model.dart
- [ ] chat_service.dart (stub for WebSocket)

**Estimated Time: 5-7 days**

---

### **Phase 4: AI Features UI (Week 4)**
**Priority: HIGH** - Differentiator features

#### **Tasks:**
1. **Job Matching Display**
   - [ ] Match percentage on job cards
   - [ ] Match breakdown dialog
   - [ ] Skill match indicators
   - [ ] "Why recommended" section

2. **AI Candidate Search (Employer)**
   - [ ] Chat-style search interface
   - [ ] Candidate suggestion cards
   - [ ] Follow-up prompts
   - [ ] Quick actions (view profile, message)

3. **CV Improvement Suggestions**
   - [ ] Suggestions screen
   - [ ] Improvement checklist
   - [ ] Action buttons
   - [ ] Progress tracking

**Deliverables:**
- [ ] match_percentage_card.dart
- [ ] match_breakdown_dialog.dart
- [ ] ai_candidate_search_screen.dart
- [ ] cv_improvement_screen.dart
- [ ] Updated job_card.dart with match %
- [ ] ai_search_service.dart (API ready)

**Estimated Time: 5-7 days**

---

### **Phase 5: Interview Scheduling (Week 5)**
**Priority: MEDIUM** - Important for workflow

#### **Tasks:**
1. **Calendar View**
   - [ ] Month view calendar
   - [ ] Day selection
   - [ ] Interview markers
   - [ ] Navigation controls

2. **Schedule Interview Screen**
   - [ ] Date/time picker
   - [ ] Time slot selection
   - [ ] Interview type (video/phone/onsite)
   - [ ] Notes field
   - [ ] Confirmation

3. **Interview List**
   - [ ] Upcoming interviews
   - [ ] Past interviews
   - [ ] Status indicators
   - [ ] Reminder settings

**Deliverables:**
- [ ] interview_calendar_screen.dart
- [ ] schedule_interview_screen.dart
- [ ] interview_list_screen.dart
- [ ] interview_card.dart
- [ ] interview_model.dart
- [ ] interview_service.dart

**Estimated Time: 4-5 days**

---

### **Phase 6: Social Auth & Notifications (Week 6)**
**Priority: HIGH** - User engagement

#### **Tasks:**
1. **Social Login**
   - [ ] Google Sign-In button
   - [ ] GitHub OAuth button
   - [ ] LinkedIn OAuth button
   - [ ] OAuth flow handling
   - [ ] Update login/register screens

2. **Notification Center**
   - [ ] Notification list screen
   - [ ] Notification cards
   - [ ] Unread badges
   - [ ] Mark as read functionality
   - [ ] Notification settings

3. **Push Notification Setup**
   - [ ] Firebase integration (UI side)
   - [ ] Permission request UI
   - [ ] In-app notification banners

**Deliverables:**
- [ ] social_login_button.dart
- [ ] Updated login_screen.dart
- [ ] Updated register_screen.dart
- [ ] notification_center_screen.dart
- [ ] notification_card.dart
- [ ] notification_service.dart

**Estimated Time: 4-5 days**

---

### **Phase 7: Reviews & Advanced Filters (Week 7)**
**Priority: MEDIUM** - Enhancement features

#### **Tasks:**
1. **Review System**
   - [ ] Write review screen
   - [ ] Company reviews display
   - [ ] Candidate reviews (employer view)
   - [ ] Star rating widget
   - [ ] Review cards

2. **Advanced Filters**
   - [ ] Remote/Onsite/Hybrid filter
   - [ ] Contract type selection
   - [ ] Salary range slider
   - [ ] Benefits checkboxes
   - [ ] Experience level filter
   - [ ] Apply filters to job search

**Deliverables:**
- [ ] write_review_screen.dart
- [ ] company_reviews_screen.dart
- [ ] rating_widget.dart
- [ ] review_card.dart
- [ ] advanced_filters_dialog.dart
- [ ] Updated job_board_screen.dart

**Estimated Time: 4-5 days**

---

### **Phase 8: Community Features (Week 8)**
**Priority: LOW** - Nice-to-have

#### **Tasks:**
1. **Forum/Blog**
   - [ ] Forum post list
   - [ ] Post detail screen
   - [ ] Create post screen
   - [ ] Comments section
   - [ ] Like/share buttons

2. **Badges & Rankings**
   - [ ] Badges screen
   - [ ] Leaderboard screen
   - [ ] Badge icons
   - [ ] Rank cards
   - [ ] Skill quiz UI (optional)

3. **Analytics (Employer)**
   - [ ] Analytics dashboard
   - [ ] Stat cards
   - [ ] Charts (using fl_chart)
   - [ ] Insights display

**Deliverables:**
- [ ] forum_list_screen.dart
- [ ] post_detail_screen.dart
- [ ] badges_screen.dart
- [ ] leaderboard_screen.dart
- [ ] analytics_screen.dart
- [ ] All supporting widgets

**Estimated Time: 5-7 days**

---

### **Phase 9: Polish & Testing (Week 8-9)**
**Priority: HIGH** - Quality assurance

#### **Tasks:**
1. **Finish Screen Refactoring**
   - [ ] Complete remaining 9 screens to use component library
   - [ ] Consistent styling across all screens
   - [ ] Update all imports

2. **Testing**
   - [ ] Run `flutter analyze` on all files
   - [ ] Fix all lint errors
   - [ ] Test all navigation flows
   - [ ] Test all forms
   - [ ] Test error states

3. **Documentation**
   - [ ] Update README
   - [ ] API integration guide
   - [ ] Component usage examples
   - [ ] Screen navigation map

4. **Final Polish**
   - [ ] Animations and transitions
   - [ ] Loading states
   - [ ] Error handling
   - [ ] Empty states
   - [ ] Responsive design checks

**Deliverables:**
- [ ] 0 lint errors
- [ ] All screens refactored
- [ ] Complete documentation
- [ ] Test coverage report
- [ ] Production-ready app

**Estimated Time: 5-7 days**

---

## 📦 **Required Flutter Packages**

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing (verify)
  provider: ^6.0.0
  http: ^1.0.0
  
  # New packages needed:
  
  # File handling
  file_picker: ^8.0.0  # CV upload
  path_provider: ^2.1.0  # File storage
  
  # Authentication
  google_sign_in: ^6.1.0  # Google OAuth
  flutter_web_auth: ^0.5.0  # GitHub/LinkedIn OAuth
  
  # Networking
  web_socket_channel: ^2.4.0  # Chat WebSocket
  dio: ^5.0.0  # Better HTTP client
  
  # State management (if not using provider)
  # riverpod: ^2.4.0  # Alternative to provider
  
  # UI Components
  shimmer: ^3.0.0  # Already have ShimmerLoading
  flutter_rating_bar: ^4.0.1  # Star ratings
  calendar_view: ^1.0.0  # Calendar for interviews
  fl_chart: ^0.65.0  # Charts for analytics
  
  # Notifications
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.0.0
  
  # Utilities
  intl: ^0.18.0  # Date formatting
  uuid: ^4.0.0  # Generate IDs
  url_launcher: ^6.2.0  # Open portfolio links
  image_picker: ^1.0.0  # Profile pictures
  cached_network_image: ^3.3.0  # Image caching
  
  # Storage
  shared_preferences: ^2.2.0  # Local storage
  hive: ^2.2.3  # Offline data storage
  hive_flutter: ^1.1.0
```

---

## 📁 **New Folder Structure**

```
lib/
├── main.dart
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       ├── date_formatter.dart (NEW)
│       ├── validators.dart (NEW)
│       └── file_utils.dart (NEW)
│
├── models/
│   ├── job_model.dart ✅
│   ├── candidate_model.dart ✅ (ENHANCE)
│   ├── application_model.dart ✅
│   ├── message_model.dart (NEW)
│   ├── conversation_model.dart (NEW)
│   ├── interview_model.dart (NEW)
│   ├── review_model.dart (NEW)
│   ├── notification_model.dart (NEW)
│   ├── badge_model.dart (NEW)
│   ├── post_model.dart (NEW)
│   └── skill_model.dart (NEW)
│
├── services/
│   ├── job_service.dart ✅
│   ├── auth_service.dart (NEW)
│   ├── cv_upload_service.dart (NEW)
│   ├── chat_service.dart (NEW)
│   ├── interview_service.dart (NEW)
│   ├── review_service.dart (NEW)
│   ├── notification_service.dart (NEW)
│   ├── ai_search_service.dart (NEW)
│   ├── forum_service.dart (NEW)
│   └── analytics_service.dart (NEW)
│
├── widgets/
│   └── common/
│       ├── index.dart ✅
│       ├── [18 existing components] ✅
│       ├── social_login_button.dart (NEW)
│       ├── file_upload_card.dart (NEW)
│       ├── skill_tag.dart (NEW)
│       ├── skill_input.dart (NEW)
│       ├── chat_bubble.dart (NEW)
│       ├── chat_input_bar.dart (NEW)
│       ├── match_percentage_card.dart (NEW)
│       ├── rating_widget.dart (NEW)
│       ├── notification_card.dart (NEW)
│       ├── calendar_widget.dart (NEW)
│       ├── portfolio_link_card.dart (NEW)
│       └── badge_icon.dart (NEW)
│
└── features/
    ├── auth/
    │   └── screens/
    │       ├── splash_screen.dart ✅
    │       ├── role_selection_screen.dart ✅
    │       ├── login_screen.dart ✅ (ENHANCE)
    │       └── register_screen.dart ✅ (ENHANCE)
    │
    ├── candidate/
    │   ├── screens/
    │   │   ├── candidate_main_screen.dart ✅ (ENHANCE)
    │   │   ├── candidate_home_screen.dart ✅
    │   │   ├── job_board_screen.dart ✅ (ENHANCE)
    │   │   ├── job_detail_screen.dart ✅ (ENHANCE)
    │   │   ├── saved_jobs_screen.dart ✅
    │   │   ├── applications_screen.dart ✅
    │   │   ├── candidate_profile_screen.dart ✅ (ENHANCE)
    │   │   ├── cv_upload_screen.dart (NEW)
    │   │   └── cv_improvement_screen.dart (NEW)
    │   └── widgets/
    │       ├── job_card.dart ✅ (ENHANCE)
    │       ├── application_card.dart ✅
    │       ├── skills_section.dart (NEW)
    │       ├── portfolio_section.dart (NEW)
    │       ├── cv_preview_card.dart (NEW)
    │       ├── match_breakdown_dialog.dart (NEW)
    │       └── advanced_filters_dialog.dart (NEW)
    │
    ├── employer/
    │   ├── screens/
    │   │   ├── employer_main_screen.dart ✅ (ENHANCE)
    │   │   ├── employer_home_screen.dart ✅
    │   │   ├── employer_applications_screen.dart ✅
    │   │   ├── application_detail_screen.dart ✅
    │   │   ├── post_job_screen.dart ✅
    │   │   ├── employer_jobs_screen.dart ✅
    │   │   ├── employer_profile_screen.dart ✅
    │   │   ├── ai_candidate_search_screen.dart (NEW)
    │   │   └── analytics_screen.dart (NEW)
    │   └── widgets/
    │       ├── ai_chat_bubble.dart (NEW)
    │       ├── candidate_suggestion_card.dart (NEW)
    │       ├── stat_card.dart (NEW)
    │       └── chart_widget.dart (NEW)
    │
    ├── chat/ (NEW)
    │   ├── screens/
    │   │   ├── chat_list_screen.dart
    │   │   └── chat_screen.dart
    │   └── widgets/
    │       ├── chat_bubble.dart (link to common)
    │       ├── chat_input_bar.dart (link to common)
    │       ├── typing_indicator.dart
    │       └── conversation_card.dart
    │
    ├── interviews/ (NEW)
    │   ├── screens/
    │   │   ├── interview_calendar_screen.dart
    │   │   ├── schedule_interview_screen.dart
    │   │   └── interview_list_screen.dart
    │   └── widgets/
    │       ├── interview_card.dart
    │       └── time_slot_picker.dart
    │
    ├── reviews/ (NEW)
    │   ├── screens/
    │   │   ├── write_review_screen.dart
    │   │   ├── company_reviews_screen.dart
    │   │   └── candidate_reviews_screen.dart
    │   └── widgets/
    │       ├── rating_widget.dart (link to common)
    │       ├── review_card.dart
    │       └── review_form.dart
    │
    ├── notifications/ (NEW)
    │   ├── screens/
    │   │   ├── notification_center_screen.dart
    │   │   └── notification_settings_screen.dart
    │   └── widgets/
    │       ├── notification_card.dart (link to common)
    │       └── notification_badge.dart
    │
    ├── forum/ (NEW)
    │   ├── screens/
    │   │   ├── forum_list_screen.dart
    │   │   ├── post_detail_screen.dart
    │   │   └── create_post_screen.dart
    │   └── widgets/
    │       ├── post_card.dart
    │       └── comment_card.dart
    │
    ├── badges/ (NEW)
    │   ├── screens/
    │   │   ├── badges_screen.dart
    │   │   ├── leaderboard_screen.dart
    │   │   └── skill_quiz_screen.dart
    │   └── widgets/
    │       ├── badge_icon.dart (link to common)
    │       └── rank_card.dart
    │
    └── shared/
        └── screens/
            └── settings_screen.dart ✅
```

---

## 🎯 **Success Metrics**

### **Completion Criteria:**
- [ ] All requirements from requirements.md implemented (UI)
- [ ] 30+ new components added to library
- [ ] 30+ new screens created
- [ ] 0 lint errors across entire codebase
- [ ] All screens use design system components
- [ ] Comprehensive documentation
- [ ] Backend API integration ready (service layer)

### **Quality Metrics:**
- Code coverage: Aim for 70%+
- Performance: 60 FPS on all screens
- Accessibility: Support screen readers
- Responsive: Works on all screen sizes
- Offline support: Basic caching

---

## 🚀 **Getting Started**

### **Week 1 - Immediate Action:**

1. **Install Required Packages**
```bash
cd /home/nguyenthanhhuy/Documents/CODER/it_job_finder
flutter pub add file_picker path_provider google_sign_in web_socket_channel dio shimmer flutter_rating_bar calendar_view fl_chart firebase_core firebase_messaging flutter_local_notifications intl uuid url_launcher image_picker cached_network_image shared_preferences
```

2. **Create New Folder Structure**
```bash
mkdir -p lib/features/{chat,interviews,reviews,notifications,forum,badges}/{screens,widgets}
mkdir -p lib/core/utils
```

3. **Start with Component Library Extension**
   - Begin building the 12 new components
   - Add to `lib/widgets/common/`
   - Update `index.dart` exports

4. **Update Models**
   - Add new fields to existing models
   - Create new model files

---

## 📝 **Notes**

### **Backend Integration:**
- All service files will have stubbed methods
- Actual API calls will be added once backend is ready
- Use mock data for development/testing

### **WebSocket:**
- chat_service.dart will be WebSocket-ready
- Connection management handled in service layer
- UI remains decoupled from connection logic

### **State Management:**
- Continue using Provider (or switch to Riverpod if preferred)
- Services return Futures/Streams
- UI reacts to state changes

### **Testing Strategy:**
- Unit tests for services
- Widget tests for components
- Integration tests for key flows (login, apply job, chat)

---

## ✅ **Checklist Summary**

### **Phase 1: Components (Week 1)**
- [ ] 12 new components built
- [ ] Documentation updated
- [ ] 0 lint errors

### **Phase 2: Profile (Week 2)**
- [ ] CV upload screen
- [ ] Skills management
- [ ] Portfolio section
- [ ] Enhanced profile

### **Phase 3: Chat (Week 3)**
- [ ] Chat list screen
- [ ] Chat screen
- [ ] All chat widgets
- [ ] Chat service

### **Phase 4: AI Features (Week 4)**
- [ ] Match display
- [ ] AI search screen
- [ ] CV improvement screen

### **Phase 5: Interviews (Week 5)**
- [ ] Calendar screen
- [ ] Schedule screen
- [ ] Interview list

### **Phase 6: Auth & Notifications (Week 6)**
- [ ] Social login
- [ ] Notification center
- [ ] Push setup

### **Phase 7: Reviews & Filters (Week 7)**
- [ ] Review system
- [ ] Advanced filters

### **Phase 8: Community (Week 8)**
- [ ] Forum
- [ ] Badges
- [ ] Analytics

### **Phase 9: Polish (Week 8-9)**
- [ ] All screens refactored
- [ ] Testing complete
- [ ] Documentation done
- [ ] Production ready

---

**Total Timeline: 6-8 weeks**  
**Total New Files: 80+ files**  
**Total New Components: 30+ components**  
**Total Features: 15 major features**

---

**Ready to start implementing? Let's begin with Phase 1! 🚀**
