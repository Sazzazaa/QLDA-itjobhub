import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { JobsService } from '../src/modules/jobs/jobs.service';
import { AuthService } from '../src/modules/auth/auth.service';

async function seed() {
  const app = await NestFactory.createApplicationContext(AppModule);
  
  const authService = app.get(AuthService);
  const jobsService = app.get(JobsService);

  try {
    // Create an employer account for posting jobs
    console.log('Creating employer account...');
    let employer;
    try {
      employer = await authService.register({
        email: 'employer@itjobhub.com',
        password: 'Employer123!',
        name: 'Tech Company HR',
        role: 'employer',
      });
      console.log('✅ Employer created:', employer.user.id);
    } catch (e) {
      // Employer might already exist, try to find it
      console.log('⚠️ Employer might already exist');
      employer = { user: { id: '6720a1b2c3d4e5f6g7h8i9j0' } }; // Fallback
    }

    // Sample jobs data
    const jobs = [
      {
        title: 'Senior Flutter Developer',
        description:
          'We are looking for an experienced Flutter Developer to join our mobile development team. You will be responsible for building beautiful, performant mobile applications for both iOS and Android platforms. Work with a talented team on cutting-edge projects in the fintech space.',
        requirements:
          '• 3+ years of professional Flutter/Dart development experience\n• Strong understanding of mobile app architecture (BLoC, Provider, Riverpod)\n• Experience with REST APIs and Firebase\n• Knowledge of CI/CD pipelines\n• Excellent problem-solving skills\n• Good communication in English',
        companyName: 'TechViet Solutions',
        techStack: [
          'Flutter',
          'Dart',
          'Firebase',
          'REST API',
          'Git',
          'Mobile Development',
        ],
        location: 'Ho Chi Minh City, Vietnam',
        minSalary: 2000,
        maxSalary: 3000,
        jobType: 'hybrid', // remote | onsite | hybrid
        contractType: 'full-time', // full-time | part-time | freelance | contract
        experienceLevel: 'senior', // entry | mid | senior | lead
        benefits: [
          '13th month salary',
          'Premium health insurance',
          'Flexible working hours',
          'Remote work 2 days/week',
          'Annual company trip',
        ],
        responsibilities: '• Develop high-quality mobile applications\n• Collaborate with cross-functional teams\n• Write clean, maintainable code\n• Participate in code reviews',
        deadline: new Date('2025-12-31'),
      },
      {
        title: 'Full-Stack JavaScript Developer',
        description:
          'Join our dynamic startup as a Full-Stack Developer. Build scalable web applications using modern JavaScript technologies. Work on both frontend (React/Next.js) and backend (Node.js/NestJS) development.',
        requirements:
          '• 2+ years of JavaScript development experience\n• Proficiency in React and Node.js\n• Experience with TypeScript\n• Knowledge of MongoDB or PostgreSQL\n• Understanding of RESTful APIs\n• Familiarity with AWS or GCP',
        companyName: 'Startup Hub Vietnam',
        techStack: [
          'JavaScript',
          'TypeScript',
          'React',
          'Node.js',
          'NestJS',
          'MongoDB',
          'Docker',
        ],
        location: 'Hanoi, Vietnam',
        minSalary: 1500,
        maxSalary: 2500,
        jobType: 'onsite',
        contractType: 'full-time',
        experienceLevel: 'mid',
        benefits: [
          'Competitive salary',
          'Stock options',
          'Health insurance',
          'Learning & Development budget',
          'Modern office with free snacks',
        ],
        responsibilities: '• Build and maintain web applications\n• Work with product team\n• Deploy to cloud infrastructure\n• Mentor junior developers',
        deadline: new Date('2025-11-30'),
      },
      {
        title: 'Junior React Native Developer',
        description:
          'Great opportunity for junior developers to grow their career in mobile app development. You will work alongside senior developers, learning best practices and contributing to real-world projects for international clients.',
        requirements:
          '• 0-1 year of React Native experience (fresh graduates welcome)\n• Understanding of JavaScript/TypeScript basics\n• Familiarity with Git version control\n• Passion for mobile development\n• Willingness to learn and improve\n• Basic English communication',
        companyName: 'Digital Agency Da Nang',
        techStack: [
          'React Native',
          'JavaScript',
          'TypeScript',
          'Git',
          'Mobile Development',
        ],
        location: 'Da Nang, Vietnam',
        minSalary: 800,
        maxSalary: 1200,
        jobType: 'onsite',
        contractType: 'full-time',
        experienceLevel: 'entry',
        benefits: [
          'Mentorship program',
          'Training courses',
          'Health insurance',
          'Free lunch',
          'Young & dynamic team',
        ],
        responsibilities: '• Develop mobile app features\n• Fix bugs and improve performance\n• Learn from senior developers\n• Participate in team meetings',
        deadline: new Date('2025-12-15'),
      },
      {
        title: 'DevOps Engineer',
        description:
          'We are seeking a skilled DevOps Engineer to manage our cloud infrastructure and CI/CD pipelines. You will work on automating deployments, monitoring systems, and ensuring high availability of our services.',
        requirements:
          '• 3+ years of DevOps experience\n• Strong knowledge of AWS/GCP/Azure\n• Experience with Docker and Kubernetes\n• Proficiency in scripting (Bash, Python)\n• Knowledge of monitoring tools (Prometheus, Grafana)\n• Experience with Terraform or CloudFormation',
        companyName: 'Cloud Services International',
        techStack: [
          'DevOps',
          'AWS',
          'Docker',
          'Kubernetes',
          'Terraform',
          'CI/CD',
          'Python',
          'Monitoring',
        ],
        location: 'Remote (Vietnam timezone)',
        minSalary: 2500,
        maxSalary: 3500,
        jobType: 'remote',
        contractType: 'full-time',
        experienceLevel: 'senior',
        benefits: [
          'Fully remote',
          'Flexible hours',
          'Top-tier equipment',
          'Conference allowance',
          'Performance bonuses',
        ],
        responsibilities: '• Manage cloud infrastructure\n• Build CI/CD pipelines\n• Monitor system performance\n• Ensure security best practices',
        deadline: new Date('2025-12-31'),
      },
      {
        title: 'Frontend Developer (React)',
        description:
          'Looking for a talented Frontend Developer to create stunning user interfaces for our SaaS products. You will collaborate with designers and backend developers to deliver exceptional user experiences.',
        requirements:
          '• 2+ years of React development\n• Strong CSS/HTML skills\n• Experience with state management (Redux, MobX)\n• Knowledge of modern build tools (Webpack, Vite)\n• Understanding of responsive design\n• Attention to detail',
        companyName: 'SaaS Product Company',
        techStack: ['React', 'JavaScript', 'TypeScript', 'CSS', 'HTML', 'Redux', 'Tailwind CSS'],
        location: 'Ho Chi Minh City, Vietnam',
        minSalary: 1800,
        maxSalary: 2800,
        jobType: 'hybrid',
        contractType: 'full-time',
        experienceLevel: 'mid',
        benefits: [
          'Modern office',
          'Health insurance',
          'Annual salary review',
          'Team building activities',
          'Free parking',
        ],
        responsibilities: '• Build responsive UI components\n• Optimize application performance\n• Work with design team\n• Write unit tests',
        deadline: new Date('2025-11-25'),
      },
    ];

    console.log('\nCreating sample jobs...');
    for (const job of jobs) {
      try {
        const created = await jobsService.create(employer.user.id, job);
        console.log(`✅ Created: ${created.title}`);
      } catch (e) {
        console.log(`❌ Failed to create ${job.title}:`, e.message);
      }
    }

    console.log('\n✅ Seed completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`- Employer: employer@itjobhub.com / Employer123!`);
    console.log(`- Jobs created: ${jobs.length}`);
    console.log('\n🧪 Test:');
    console.log('  GET http://localhost:3000/api/jobs');
  } catch (error) {
    console.error('❌ Seed failed:', error);
  } finally {
    await app.close();
  }
}

seed();
