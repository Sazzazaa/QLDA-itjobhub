# 📋 Phase 2: Profile Enhancement - Implementation Plan

**Based on**: requirements.md  
**Started**: October 8, 2025  
**Status**: In Progress  

---

## 🎯 **Requirements from requirements.md**

### **Candidate Profile Must Have:**

1. ✅ **CV Upload**
   - Upload CVs via file picker
   - Support PDF, DOC, DOCX formats
   - Show upload progress
   - LLM parsing status display
   - Multilingual support (Vietnamese/English)

2. ✅ **Skills Management**
   - Add skills as tags (React, Node.js, AWS, etc.)
   - Autocomplete suggestions
   - Skill levels (beginner/intermediate/advanced/expert)
   - Visual skill display

3. ✅ **Portfolio & Projects**
   - GitHub profile link
   - Behance portfolio
   - Personal website
   - Project experience descriptions

4. ✅ **Work Experience**
   - Job titles and roles
   - Years of experience
   - Company names
   - Descriptions

5. ✅ **Education**
   - University/institution
   - Major/degree
   - Graduation year

6. ✅ **Location Preferences**
   - Desired location
   - Remote/Onsite/Hybrid preference

7. ✅ **Salary Expectations**
   - Desired salary range
   - Currency

8. ✅ **Quick Apply Feature**
   - One-tap application using profile data

---

## 📦 **Components to Build**

### **1. CV Upload Screen** (`cv_upload_screen.dart`)
**Purpose**: Upload and manage CV with parsing  
**Components Used**:
- FileUploadCard ✅ (already built)
- LoadingState ✅
- ErrorState ✅

**Features**:
- File picker integration
- Upload progress
- Parsing status (pending/processing/complete)
- Auto-fill profile from parsed data
- View parsed data
- Re-upload option

---

### **2. Skills Section** (`skills_section.dart`)
**Purpose**: Manage skills with levels  
**Components Used**:
- SkillInput ✅ (already built)
- SkillTag ✅ (already built)

**Features**:
- Add skills with autocomplete
- Set skill levels
- Remove skills
- Max 20 skills limit
- Popular IT skills suggestions

---

### **3. Portfolio Section** (`portfolio_section.dart`)
**Purpose**: Add portfolio links  
**Components Used**:
- PortfolioLinkCard ✅ (already built)

**Features**:
- Add GitHub link
- Add Behance/Dribbble
- Add personal website
- Add project descriptions
- Edit/delete links

---

### **4. Experience Section** (`experience_section.dart`)
**Purpose**: Work experience management  
**Components Used**:
- CustomCard ✅

**Features**:
- Add job experience
- Job title, company, period
- Description
- Currently working checkbox
- Edit/delete experience

---

### **5. Education Section** (`education_section.dart`)
**Purpose**: Education history  
**Components Used**:
- CustomCard ✅

**Features**:
- Add education
- Degree, university, major
- Period (start-end year)
- Edit/delete education

---

### **6. Preferences Section** (`preferences_section.dart`)
**Purpose**: Job preferences  
**Components Used**:
- CustomInput ✅
- DropdownInput ✅ (if available)

**Features**:
- Location preference
- Remote/Onsite/Hybrid selector
- Desired salary range
- Currency selector
- Contract type preference

---

## 🗂️ **File Structure**

```
lib/features/candidate/
├── screens/
│   ├── candidate_profile_screen.dart ✅ (enhance)
│   ├── cv_upload_screen.dart (NEW)
│   └── edit_profile_screen.dart (enhance from existing)
│
└── widgets/
    ├── skills_section.dart (NEW)
    ├── portfolio_section.dart (NEW)
    ├── experience_section.dart (NEW)
    ├── education_section.dart (NEW)
    └── preferences_section.dart (NEW)

lib/models/
├── candidate_model.dart ✅ (enhance)
├── experience_model.dart (NEW)
├── education_model.dart (NEW)
└── portfolio_link_model.dart (NEW)

lib/services/
└── cv_upload_service.dart (NEW)
```

---

## 📝 **Data Models Updates**

### **CandidateModel** (enhance existing)
```dart
class CandidateModel {
  String id;
  String name;
  String email;
  String phone;
  String? bio;
  String? avatar;
  
  // NEW FIELDS (Phase 2)
  List<String> skills;  // ['Flutter', 'Dart', 'Firebase']
  Map<String, SkillLevel>? skillLevels;  // {'Flutter': SkillLevel.expert}
  List<PortfolioLink> portfolioLinks;
  List<Experience> experiences;
  List<Education> educations;
  String? desiredSalaryMin;
  String? desiredSalaryMax;
  String? currency;  // 'USD', 'VND'
  String? desiredLocation;
  LocationPreference? locationPreference;  // remote/onsite/hybrid
  List<String>? languages;  // ['English', 'Vietnamese']
  List<String>? certifications;
  String? cvUrl;  // Uploaded CV file URL
  DateTime? cvUploadedAt;
  CVParseStatus? cvParseStatus;  // pending/processing/complete/failed
  Map<String, dynamic>? parsedCVData;  // Data from LLM
}
```

### **Experience** (new model)
```dart
class Experience {
  String id;
  String jobTitle;
  String company;
  DateTime startDate;
  DateTime? endDate;  // null if currently working
  bool isCurrentlyWorking;
  String? description;
  List<String>? skills;  // Skills used in this job
}
```

### **Education** (new model)
```dart
class Education {
  String id;
  String degree;  // 'Bachelor', 'Master', 'PhD'
  String major;  // 'Computer Science'
  String institution;  // 'University of Technology'
  int startYear;
  int endYear;
  String? description;
}
```

### **PortfolioLink** (new model)
```dart
class PortfolioLink {
  String id;
  PortfolioPlatform platform;  // github, linkedin, behance, website, etc.
  String url;
  String? username;
  String? description;
}
```

### **Enums** (new)
```dart
enum LocationPreference { remote, onsite, hybrid }
enum CVParseStatus { pending, processing, complete, failed }
enum SkillLevel { beginner, intermediate, advanced, expert }
```

---

## 🔄 **Implementation Order**

### **Step 1: Models** (30 min)
1. Create experience_model.dart
2. Create education_model.dart
3. Create portfolio_link_model.dart
4. Update candidate_model.dart

### **Step 2: Services** (15 min)
1. Create cv_upload_service.dart (stub with mock)

### **Step 3: Section Widgets** (2 hours)
1. skills_section.dart (30 min)
2. portfolio_section.dart (30 min)
3. experience_section.dart (30 min)
4. education_section.dart (20 min)
5. preferences_section.dart (20 min)

### **Step 4: Screens** (1 hour)
1. cv_upload_screen.dart (40 min)
2. Enhance edit_profile_screen.dart (20 min)

### **Step 5: Integration** (1 hour)
1. Update candidate_profile_screen.dart
2. Wire up all sections
3. Add navigation

### **Step 6: Testing** (30 min)
1. Flutter analyze
2. Test all flows
3. Fix any issues

**Total Estimated Time**: 5-6 hours

---

## ✅ **Success Criteria**

- [ ] All required fields from requirements.md implemented
- [ ] CV upload with file picker working
- [ ] Skills management with autocomplete
- [ ] Portfolio links (GitHub, Behance, website)
- [ ] Work experience CRUD
- [ ] Education CRUD
- [ ] Location preferences (remote/onsite/hybrid)
- [ ] Salary expectations
- [ ] All sections integrated into profile
- [ ] 0 lint errors
- [ ] Proper navigation between screens

---

## 🎨 **UI/UX Guidelines**

1. **Consistent with Phase 1 components**
2. **Use existing design system**
3. **Clear section headers**
4. **Easy add/edit/delete actions**
5. **Validation for required fields**
6. **Save button prominently displayed**
7. **Loading states for async operations**
8. **Error handling with ErrorState**
9. **Empty states with EmptyState**

---

## 📱 **User Flow**

1. User opens Profile tab
2. Sees complete profile with all sections
3. Can tap "Edit Profile" to modify
4. Can tap "Manage CV" to upload/view CV
5. CV upload triggers LLM parsing (UI shows progress)
6. Parsed data auto-fills profile fields
7. User can add/edit skills, portfolio, experience, education
8. User sets location and salary preferences
9. Save changes
10. Profile updated and ready for "Quick Apply"

---

## 🚀 **Ready to Start!**

Phase 1 components ready:
- ✅ FileUploadCard
- ✅ SkillInput & SkillTag
- ✅ PortfolioLinkCard
- ✅ CustomInput
- ✅ PrimaryButton, SecondaryButton
- ✅ CustomCard
- ✅ LoadingState, ErrorState, EmptyState

Let's build Phase 2! 🎨

