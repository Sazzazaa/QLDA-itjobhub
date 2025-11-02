# API Integration TODO List

Danh sách chi tiết các tính năng còn dùng MOCK DATA hoặc chưa hoàn thiện API integration.

## ❌ CRITICAL - Cần fix ngay (Ảnh hưởng chức năng chính)

### 1. FORUM SYSTEM (100% Mock)
**Files:**
- `lib/services/forum_service.dart`
- `lib/features/shared/screens/forum_home_screen.dart`
- `lib/features/shared/screens/forum_post_detail_screen.dart`
- `lib/features/shared/screens/create_post_screen.dart`

**Backend cần:**
- [ ] Create Forum schema (Post, Comment)
- [ ] POST /api/forum/posts - Create post
- [ ] GET /api/forum/posts - Get all posts
- [ ] GET /api/forum/posts/:id - Get post detail
- [ ] POST /api/forum/posts/:id/comments - Add comment
- [ ] PUT /api/forum/posts/:id/like - Like/unlike post
- [ ] PUT /api/forum/comments/:id/like - Like/unlike comment
- [ ] DELETE /api/forum/posts/:id - Delete post
- [ ] DELETE /api/forum/comments/:id - Delete comment

**Frontend cần:**
- [ ] Update ForumService to call API instead of mock
- [ ] Handle real-time updates (optional)

---

### 2. COMPANY REVIEWS (Only Employer → Candidate works)
**Files:**
- `lib/services/review_service.dart` (Lines 20-315 - all company review methods use mock)
- `lib/features/shared/screens/write_company_review_screen.dart`

**Backend:**
- ✅ Schema already exists (Review schema supports both types)
- ✅ Endpoints exist (same as candidate reviews)

**Frontend cần:**
- [ ] Update ReviewService.addCompanyReview() to call API
- [ ] Update ReviewService.fetchCompanyReviews() 
- [ ] Update WriteCo

mpanyReviewScreen to use UserState for reviewer info
- [ ] Load real company reviews in company detail screens

---

## ⚠️ MEDIUM - Cần fix sớm (Ảnh hưởng trải nghiệm)

### 3. BADGE SYSTEM (100% Mock)
**Files:**
- `lib/services/badge_service.dart`

**Backend cần:**
- [ ] Create Badge schema
- [ ] Create UserStats schema  
- [ ] GET /api/badges - Get all available badges
- [ ] GET /api/badges/user/:userId - Get user's earned badges
- [ ] GET /api/stats/user/:userId - Get user statistics
- [ ] POST /api/stats/activity - Track user activity (applications, interviews, etc.)

**Frontend cần:**
- [ ] Update BadgeService to call API
- [ ] Auto-calculate badge eligibility based on stats

---

### 4. CANDIDATE PROFILE - Projects & Statistics
**File:** `lib/features/candidate/screens/candidate_profile_screen.dart`

**Issues:**
- Line 105: `_projects = ExperienceProject.getMockProjects()`
- Line 111: Statistics not loaded from API
- Line 139: Saved jobs not fetched from API

**Backend cần:**
- [ ] Add `projects` array to User schema (already exists in frontend model)
- [ ] GET /api/users/profile/projects - Get user projects
- [ ] POST /api/users/profile/projects - Add project
- [ ] PUT /api/users/profile/projects/:id - Update project
- [ ] DELETE /api/users/profile/projects/:id - Delete project
- [ ] GET /api/stats/profile/:userId - Get profile statistics
- [ ] POST /api/jobs/:jobId/save - Save job
- [ ] DELETE /api/jobs/:jobId/save - Unsave job
- [ ] GET /api/jobs/saved - Get saved jobs

**Frontend cần:**
- [ ] Update profile screen to load real projects from API
- [ ] Implement save/unsave job functionality
- [ ] Load real statistics

---

### 5. AVATAR UPLOAD
**File:** `lib/features/candidate/screens/candidate_profile_screen.dart` (Line 186)

**Backend:**
- ✅ Endpoint exists: POST /api/users/profile/avatar

**Frontend cần:**
- [ ] Implement _uploadAvatar() function to call API
- [ ] Handle file upload with multipart/form-data

---

## 🔵 LOW - Nice to have (Không ảnh hưởng nhiều)

### 6. SWIPE SCREEN (Tinder-like feature)
**File:** `lib/screen/swipe_screen.dart`

**Issues:**
- Line 75: Like/dislike not sent to backend
- Line 196: CV viewer not implemented

**Backend cần:**
- [ ] Create Match schema
- [ ] POST /api/matches/like - Like a candidate/job
- [ ] POST /api/matches/dislike - Dislike
- [ ] GET /api/matches - Get matches
- [ ] GET /api/matches/potential - Get candidates/jobs to swipe

**Frontend cần:**
- [ ] Implement swipe actions API calls
- [ ] Implement CV viewer (can use url_launcher or pdf viewer)

---

### 7. INTERVIEW TIME SLOTS
**File:** `lib/features/candidate/screens/interview_scheduling_screen.dart` (Line 34)

**Current:** Mock time slots
**Backend cần:**
- [ ] GET /api/interviews/available-slots?date=YYYY-MM-DD - Get available time slots
- [ ] Consider employer's calendar integration

**Frontend cần:**
- [ ] Fetch real available slots from API

---

## ✅ COMPLETED (Already using real API)

- ✅ Jobs (create, read, update, delete, search, recommendations)
- ✅ Applications (submit, view, update status, withdraw)
- ✅ Interviews (create, read, update, cancel, reschedule)
- ✅ Messages (conversations, send, read)
- ✅ Notifications (get, mark read, delete)
- ✅ CV Upload & Parsing (Gemini AI)
- ✅ Candidate Reviews (Employer → Candidate)
- ✅ User Profile (basic info, skills)
- ✅ Authentication (register, login, JWT)

---

## 📝 EXECUTION PLAN

### Phase 1: Critical Features (Forum + Company Reviews)
1. Implement Forum backend API
2. Connect Forum frontend to API
3. Connect Company Reviews to existing API

### Phase 2: User Experience (Badges + Profile)
1. Implement Badge backend
2. Add Projects CRUD to User API
3. Add Saved Jobs API
4. Implement Avatar Upload
5. Add Profile Statistics API

### Phase 3: Nice-to-have Features
1. Swipe/Match system backend
2. Connect Swipe frontend
3. Dynamic interview time slots

---

**Last Updated:** 2025-11-01
**Status:** Ready for implementation
