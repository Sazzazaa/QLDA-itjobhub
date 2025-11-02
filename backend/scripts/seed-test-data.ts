import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { getModelToken } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from '../src/schemas/user.schema';
import { Job, JobDocument } from '../src/schemas/job.schema';
import { Application, ApplicationDocument } from '../src/schemas/application.schema';
import { Interview } from '../src/schemas/interview.schema';
import * as bcrypt from 'bcrypt';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  
  // Get models using getModelToken
  const userModel = app.get<Model<UserDocument>>(getModelToken(User.name));
  const jobModel = app.get<Model<JobDocument>>(getModelToken(Job.name));
  const applicationModel = app.get<Model<ApplicationDocument>>(getModelToken(Application.name));
  const interviewModel = app.get<Model<Interview>>(getModelToken(Interview.name));

  console.log('🌱 Starting seed process...\n');

  try {
    // 0. Clear existing test data
    console.log('🧹 Cleaning up existing test data...');
    await userModel.deleteMany({ email: { $in: ['employer@techviet.com', 'candidate@flutter.dev'] } });
    await jobModel.deleteMany({ companyName: 'TechViet Solutions' });
    console.log('✅ Cleanup completed\n');

    // 1. Create Test Employer Account
    console.log('👔 Creating employer account...');
    const employerPassword = await bcrypt.hash('Employer123!', 10);
    const employer = new userModel({
      email: 'employer@techviet.com',
      password: employerPassword,
      name: 'TechViet Recruiter',
      role: 'employer',
      phone: '+84 901 234 567',
      location: 'Ho Chi Minh City, Vietnam',
      companyName: 'TechViet Solutions',
      industry: 'Information Technology',
      companySize: '50-200 employees',
      companyWebsite: 'https://techviet.com',
      companyDescription: 'Leading software development company in Vietnam specializing in Flutter, React, and Node.js development.',
      isActive: true,
      isEmailVerified: true,
    });
    await employer.save();
    console.log('✅ Employer created:', employer.email);

    // 2. Create Test Candidate Account (different from testuser@test.com)
    console.log('\n👨‍💻 Creating candidate account...');
    const candidatePassword = await bcrypt.hash('Candidate123!', 10);
    const candidate = new userModel({
      email: 'candidate@flutter.dev',
      password: candidatePassword,
      name: 'Nguyen Van A',
      role: 'candidate',
      phone: '+84 902 345 678',
      location: 'Hanoi, Vietnam',
      skills: ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git', 'Agile'],
      githubUrl: 'https://github.com/nguyenvana',
      linkedinUrl: 'https://linkedin.com/in/nguyenvana',
      portfolioUrl: 'https://nguyenvana.dev',
      desiredSalary: 2000,
      workLocation: 'hybrid',
      isActive: true,
      isEmailVerified: true,
      points: 100,
      experience: [{
        title: 'Flutter Developer',
        company: 'ABC Tech',
        startDate: '2021-01',
        endDate: 'Present',
        description: 'Developing mobile applications using Flutter',
      }],
      education: [{
        degree: 'Bachelor',
        major: 'Computer Science',
        institution: 'Vietnam National University',
        startYear: 2017,
        endYear: 2021,
      }],
    });
    await candidate.save();
    console.log('✅ Candidate created:', candidate.email);

    // 3. Create Jobs Posted by Employer
    console.log('\n💼 Creating job postings...');
    
    const job1 = new jobModel({
      title: 'Senior Flutter Developer',
      companyName: 'TechViet Solutions',
      location: 'Ho Chi Minh City - Hybrid',
      description: 'We are looking for an experienced Flutter developer to join our growing team. You will be working on exciting mobile applications for international clients.',
      requirements: `• 3+ years of Flutter development experience
• Strong understanding of Dart programming
• Experience with Firebase and REST APIs
• Good knowledge of state management (Riverpod, Bloc)
• Experience with Git and Agile methodologies`,
      responsibilities: `• Develop and maintain Flutter mobile applications
• Collaborate with designers and backend developers
• Write clean, maintainable code with proper documentation
• Participate in code reviews and technical discussions
• Mentor junior developers`,
      benefits: [
        'Competitive salary: $2000-3000/month',
        '13th month salary and performance bonus',
        'Health insurance and annual health check',
        'Flexible working hours',
        'Work from home 2 days/week',
        'Annual company trip and team building',
        'Free snacks and drinks',
        'Modern MacBook Pro provided'
      ],
      techStack: ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git'],
      experienceLevel: 'senior',
      jobType: 'hybrid',
      contractType: 'full-time',
      minSalary: 2000,
      maxSalary: 3000,
      employerId: employer._id,
      status: 'active',
      viewsCount: 45,
    });
    await job1.save();
    console.log('✅ Job 1 created:', job1.title);

    const job2 = new jobModel({
      title: 'Mid-level Mobile Developer (Flutter)',
      companyName: 'TechViet Solutions',
      location: 'Remote',
      description: 'Join our remote team and work on innovative mobile solutions. Perfect opportunity for developers looking for work-life balance.',
      requirements: `• 2+ years of mobile development experience
• Proficient in Flutter and Dart
• Understanding of mobile UI/UX principles
• Experience with RESTful APIs
• Self-motivated and able to work independently`,
      responsibilities: `• Build cross-platform mobile applications
• Implement new features and fix bugs
• Write unit tests and integration tests
• Collaborate with remote team members
• Participate in sprint planning and retrospectives`,
      benefits: [
        'Salary: $1500-2200/month',
        'Fully remote work',
        'Flexible schedule',
        'Annual salary review',
        'Training and certification budget',
        'Home office equipment support'
      ],
      techStack: ['Flutter', 'Dart', 'Provider', 'HTTP', 'Git'],
      experienceLevel: 'mid',
      jobType: 'remote',
      contractType: 'full-time',
      minSalary: 1500,
      maxSalary: 2200,
      employerId: employer._id,
      status: 'active',
      viewsCount: 32,
    });
    await job2.save();
    console.log('✅ Job 2 created:', job2.title);

    const job3 = new jobModel({
      title: 'Junior Flutter Developer',
      companyName: 'TechViet Solutions',
      location: 'Ho Chi Minh City - Onsite',
      description: 'Great opportunity for fresh graduates or junior developers to learn and grow in a supportive environment.',
      requirements: `• Basic knowledge of Flutter and Dart
• Understanding of OOP concepts
• Eager to learn and improve
• Good English communication
• Team player attitude`,
      responsibilities: `• Assist senior developers in app development
• Fix bugs and implement small features
• Learn best practices and coding standards
• Participate in team meetings
• Write technical documentation`,
      benefits: [
        'Salary: $800-1200/month',
        'Intensive training program',
        'Mentorship from senior developers',
        'Career advancement opportunities',
        'Health insurance',
        'Free lunch and snacks'
      ],
      techStack: ['Flutter', 'Dart', 'Firebase', 'Git'],
      experienceLevel: 'entry',
      jobType: 'onsite',
      contractType: 'full-time',
      minSalary: 800,
      maxSalary: 1200,
      employerId: employer._id,
      status: 'active',
      viewsCount: 18,
    });
    await job3.save();
    console.log('✅ Job 3 created:', job3.title);

    // 4. Create Application from Candidate to Job 1
    console.log('\n📝 Creating job application...');
    const application = new applicationModel({
      jobId: job1._id,
      candidateId: candidate._id,
      employerId: employer._id,
      coverLetter: `Dear Hiring Manager,

I am writing to express my strong interest in the Senior Flutter Developer position at TechViet Solutions. With over 3 years of experience in Flutter development and a proven track record of delivering high-quality mobile applications, I am confident that I would be a valuable addition to your team.

Key highlights of my experience:
- Built and published 5+ Flutter apps with 100K+ downloads on App Store and Google Play
- Proficient in state management using Riverpod and Bloc
- Strong experience with Firebase, REST APIs, and third-party integrations
- Led a team of 3 developers in an Agile environment
- Passionate about clean code and best practices

I am particularly excited about this opportunity because of TechViet Solutions' reputation for innovation and the chance to work on international projects. The hybrid working model also aligns perfectly with my preferences.

I have attached my resume and portfolio for your review. I look forward to discussing how I can contribute to your team's success.

Best regards,
Nguyen Van A`,
      cvUrl: 'https://drive.google.com/file/d/cv-nguyenvana-2024.pdf',
      status: 'reviewing',
      matchPercentage: 85,
      timeline: [
        {
          status: 'pending',
          timestamp: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
          note: 'Application submitted',
        },
        {
          status: 'reviewing',
          timestamp: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // 1 day ago
          note: 'Application under review by hiring manager',
        },
      ],
    });
    await application.save();
    console.log('✅ Application created for:', job1.title);

    // 5. Create Interview Scheduled
    console.log('\n📅 Creating interview...');
    const interviewDate = new Date();
    interviewDate.setDate(interviewDate.getDate() + 3); // 3 days from now
    interviewDate.setHours(14, 0, 0, 0); // 2:00 PM

    const interview = new interviewModel({
      jobId: job1._id,
      candidateId: candidate._id,
      employerId: employer._id,
      scheduledAt: interviewDate,
      duration: 60,
      type: 'video',
      status: 'scheduled',
      meetingLink: 'https://meet.google.com/abc-defg-hij',
      notes: 'Technical interview focusing on Flutter, Dart, and problem-solving skills. Please prepare to discuss your previous projects and do a live coding exercise.',
      interviewerDetails: {
        name: 'TechViet Recruiter',
        position: 'Senior Technical Lead',
        email: 'employer@techviet.com',
      },
    });
    await interview.save();
    console.log('✅ Interview scheduled for:', interviewDate.toLocaleString());

    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('✅ SEED DATA CREATED SUCCESSFULLY!');
    console.log('='.repeat(60));
    console.log('\n📊 Summary:');
    console.log('├─ 👔 Employer Account:');
    console.log('│  ├─ Email: employer@techviet.com');
    console.log('│  └─ Password: Employer123!');
    console.log('│');
    console.log('├─ 👨‍💻 Candidate Account:');
    console.log('│  ├─ Email: candidate@flutter.dev');
    console.log('│  └─ Password: Candidate123!');
    console.log('│');
    console.log('├─ 💼 Jobs Created: 3');
    console.log('│  ├─ Senior Flutter Developer (Hybrid)');
    console.log('│  ├─ Mid-level Mobile Developer (Remote)');
    console.log('│  └─ Junior Flutter Developer (Onsite)');
    console.log('│');
    console.log('├─ 📝 Applications: 1');
    console.log('│  └─ Candidate applied to Senior Flutter Developer');
    console.log('│');
    console.log('└─ 📅 Interviews: 1');
    console.log('   └─ Scheduled for', interviewDate.toLocaleString());
    
    console.log('\n🧪 Test Workflow:');
    console.log('1️⃣  Login as employer@techviet.com to see applications');
    console.log('2️⃣  Review and approve the application');
    console.log('3️⃣  Login as candidate@flutter.dev to see job listings');
    console.log('4️⃣  Check applications and interviews');
    console.log('5️⃣  Test messaging between employer and candidate');
    console.log('\n');

  } catch (error) {
    console.error('❌ Error during seeding:', error);
  } finally {
    await app.close();
  }
}

bootstrap();
