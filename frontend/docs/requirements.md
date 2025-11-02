# ITJobHub Project Overview

## User Registration and Profiles

### Candidate Features
- **Quick Registration**: Sign up via email, Google, GitHub, or LinkedIn.
- **Candidate Profile**:
  - Upload CV.
  - Add skills (e.g., React, Node.js, AWS) as tags.
  - Include project experience and portfolio links (e.g., GitHub, Behance).
  - Specify desired salary and location preferences (supports remote/onsite).
- **Employer Profile**:
  - Company details, logo, and work culture description.
  - Recruitment history tracking.

## Job Search and Matching

- **Job Search**:
  - Filter by skills, job title (e.g., Junior Developer), location, salary, and contract type (full-time, freelance).
- **Job Recommendations**:
  - AI-driven suggestions based on profile skills, showing match percentage (e.g., 80% match if 4/5 required skills met).
- **Job Posting**:
  - Employers create job posts with skill requirements, job descriptions, and benefits (e.g., remote work, stock options).

## Interaction and Communication

- **Real-Time Chat**:
  - Integrated messaging for candidates and employers using WebSocket in NestJS.
- **Interview Scheduling**:
  - Calendar integration for scheduling interviews with push notification reminders.
- **Quick Apply**:
  - One-tap job application using existing candidate profile.

## Reviews and Community

- **Two-Way Reviews**:
  - Candidates review companies (culture, compensation).
  - Employers review candidates post-interview.
- **Forum/Blog**:
  - Knowledge-sharing section for IT tips (e.g., interview tips, tech trends) to boost engagement.
- **Badges and Rankings**:
  - Candidates earn badges for skills (e.g., "Certified React Expert") based on self-assessment or simple quizzes.

## Notifications and Security

- **Push Notifications**:
  - Alerts for new jobs, messages, and upcoming interviews.
- **Security**:
  - Account verification via email/OTP.
  - Data protection compliant with GDPR or Vietnam regulations.

## Candidate Workflow

1. Download app, register, and complete profile.
2. Browse recommended jobs or search manually.
3. Apply to jobs and communicate with employers via chat.
4. Receive notifications and attend interviews.
5. Provide feedback after the process.

## Employer Workflow

1. Register and verify company account.
2. Post job openings.
3. View matching candidate profiles and initiate chats.
4. Manage applications and schedule interviews.
5. Review and store candidate data.

## Automated CV Parsing

- **CV Upload**:
  - Candidates upload CVs via Flutter app with file picker support.
- **LLM Processing**:
  - Extracts skills (e.g., Java, AWS), experience (years, roles), education (university, major), projects, and additional details (languages, certifications).
  - Stores data in MongoDB under a dedicated CVData collection (e.g., skills array, experience timeline).
- **Multilingual Support**:
  - Handles CVs in Vietnamese and English using a multilingual LLM.

## CV Data Search

- **Semantic Search**:
  - Employers input queries, and AI matches them semantically with CV data (e.g., "mobile dev" matches "Flutter developer" or "Android engineer").
- **Advanced Filtering**:
  - Combines with existing filters (location, salary) and ranks candidates by match score.

## AI-Powered Candidate Search Chat

- **Dedicated Chat Interface**:
  - Integrated into the app’s messaging module.
- **Natural Language Queries**:
  - Employers chat naturally, and AI queries the database to return matching candidates (e.g., "Found 5 suitable candidates: [list with profile summaries]").
- **Follow-Up Questions**:
  - AI seeks clarification for vague queries (e.g., "How many years of experience do you require?").
- **Job Post Integration**:
  - AI suggests candidates based on open job postings.

## Additional Features

- **CV Improvement Suggestions**:
  - AI analyzes CVs and provides recommendations (e.g., "Add project details to improve matching").
- **Analytics Reports**:
  - Employers access statistics (e.g., popular skills in CV database).
- **Security and Ethics**:
  - Data used only with consent.
  - CVs deleted after retention period.
  - Matching avoids bias (e.g., no gender discrimination).