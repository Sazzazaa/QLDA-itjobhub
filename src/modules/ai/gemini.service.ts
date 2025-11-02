import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI } from '@google/generative-ai';

@Injectable()
export class GeminiService {
  private readonly logger = new Logger(GeminiService.name);
  private genAI: GoogleGenerativeAI;
  private model: any;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (!apiKey) {
      this.logger.warn('GEMINI_API_KEY not found. AI features will be disabled.');
      return;
    }
    this.genAI = new GoogleGenerativeAI(apiKey);
    this.model = this.genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
  }

  /**
   * Parse CV content using Gemini AI
   * Extracts structured data from CV text
   */
  async parseCVContent(cvText: string): Promise<any> {
    try {
      const prompt = `
You are an expert CV parser. Extract the following information from the CV text below and return it in JSON format.

Required fields:
- name (string)
- email (string)
- phone (string)
- location (string)
- summary (string): A brief professional summary
- skills (array of strings): Technical skills
- experience (array of objects):
  - title (string)
  - company (string)
  - startDate (string in YYYY-MM format)
  - endDate (string in YYYY-MM format or "Present")
  - description (string)
  - technologies (array of strings)
- education (array of objects):
  - degree (string)
  - major (string)
  - institution (string)
  - startYear (number)
  - endYear (number or null if ongoing)
- projects (array of objects):
  - name (string)
  - role (string)
  - description (string)
  - technologies (array of strings)
  - startDate (string)
  - endDate (string or "Present")
  - projectUrl (string or null)
- certifications (array of objects):
  - name (string)
  - issuer (string)
  - issueDate (string)
  - expiryDate (string or null)
- languages (array of strings)
- githubUrl (string or null)
- linkedinUrl (string or null)
- portfolioUrl (string or null)

Return ONLY valid JSON without any markdown formatting or code blocks.

CV Text:
${cvText}
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      let text = response.text();

      // Clean up the response - remove markdown code blocks if present
      text = text.replace(/```json\s*/g, '').replace(/```\s*/g, '').trim();

      const parsedData = JSON.parse(text);
      this.logger.log('CV parsed successfully');
      return parsedData;
    } catch (error) {
      this.logger.error('Error parsing CV with Gemini:', error);
      throw new Error('Failed to parse CV content');
    }
  }

  /**
   * Calculate job-candidate match percentage
   * Uses semantic understanding to match candidate skills with job requirements
   */
  async calculateMatchPercentage(
    candidateSkills: string[],
    candidateExperience: any[],
    jobRequirements: string,
    jobTechStack: string[],
  ): Promise<number> {
    try {
      const prompt = `
You are an expert IT recruiter. Calculate the match percentage between a candidate and a job posting.

Candidate Skills: ${candidateSkills.join(', ')}
Candidate Experience: ${JSON.stringify(candidateExperience)}

Job Requirements: ${jobRequirements}
Job Tech Stack: ${jobTechStack.join(', ')}

Analyze:
1. Skills overlap (40% weight)
2. Experience relevance (30% weight)
3. Technology match (30% weight)

Return ONLY a number between 0 and 100 representing the match percentage. No explanation, just the number.
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const text = response.text().trim();
      const percentage = parseInt(text);

      return Math.min(100, Math.max(0, percentage));
    } catch (error) {
      this.logger.error('Error calculating match percentage:', error);
      return 50; // Default fallback
    }
  }

  /**
   * Generate personalized job recommendations
   */
  async getJobRecommendations(
    candidateProfile: any,
    availableJobs: any[],
  ): Promise<string[]> {
    try {
      const prompt = `
You are an AI job matching assistant. Given a candidate profile and available jobs, recommend the top 5 most suitable jobs.

Candidate Profile:
- Skills: ${candidateProfile.skills?.join(', ')}
- Experience: ${candidateProfile.experience?.map((e) => e.title).join(', ')}
- Desired Salary: ${candidateProfile.desiredSalary}
- Work Location Preference: ${candidateProfile.workLocation}

Available Jobs:
${availableJobs.map((job, index) => `${index}. ${job.title} at ${job.companyName} - ${job.techStack?.join(', ')}`).join('\n')}

Return ONLY a JSON array of job indices (0-based) for the top 5 recommendations, ordered by relevance.
Example: [2, 5, 1, 8, 3]
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      let text = response.text().trim();
      
      text = text.replace(/```json\s*/g, '').replace(/```\s*/g, '').trim();
      const indices = JSON.parse(text);

      return indices.map((i: number) => availableJobs[i]?._id?.toString()).filter(Boolean);
    } catch (error) {
      this.logger.error('Error generating job recommendations:', error);
      return [];
    }
  }

  /**
   * Semantic search for candidates based on natural language query
   */
  async searchCandidates(query: string, candidates: any[]): Promise<string[]> {
    try {
      const prompt = `
You are an AI recruitment assistant. Find the most relevant candidates based on the search query.

Search Query: "${query}"

Available Candidates:
${candidates.map((c, index) => `${index}. ${c.name} - Skills: ${c.skills?.join(', ')} - Experience: ${c.experience?.map((e) => e.title).join(', ')}`).join('\n')}

Return ONLY a JSON array of candidate indices (0-based) ordered by relevance to the query (top 10 max).
Example: [3, 7, 1, 9, 2]
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      let text = response.text().trim();
      
      text = text.replace(/```json\s*/g, '').replace(/```\s*/g, '').trim();
      const indices = JSON.parse(text);

      return indices.map((i: number) => candidates[i]?._id?.toString()).filter(Boolean);
    } catch (error) {
      this.logger.error('Error in semantic candidate search:', error);
      return [];
    }
  }

  /**
   * Generate personalized cover letter based on CV and job posting
   */
  async generateCoverLetter(
    parsedCVData: any,
    jobTitle: string,
    companyName: string,
    jobDescription: string,
    jobRequirements: string,
  ): Promise<string> {
    try {
      const prompt = `
You are a professional career advisor. Write a compelling, personalized cover letter for a job application.

Candidate Information (from CV):
- Name: ${parsedCVData.name || 'the candidate'}
- Skills: ${parsedCVData.skills?.join(', ') || 'N/A'}
- Experience: ${parsedCVData.experience?.map((e: any) => `${e.title} at ${e.company}`).join(', ') || 'N/A'}
- Education: ${parsedCVData.education?.map((e: any) => `${e.degree} in ${e.major} from ${e.institution}`).join(', ') || 'N/A'}

Job Information:
- Position: ${jobTitle}
- Company: ${companyName}
- Description: ${jobDescription}
- Requirements: ${jobRequirements}

Instructions:
1. Write a professional cover letter that is STRICTLY between 100-1000 characters (NOT words, characters!)
2. Highlight how the candidate's experience matches the job requirements
3. Mention specific skills that align with the position
4. Show enthusiasm for the role and company
5. Use professional yet personable tone
6. Write in first person from the candidate's perspective
7. Be concise and impactful - every sentence must count

CRITICAL: The output MUST be between 100-1000 characters. This is a hard requirement.

Return ONLY the cover letter text without any formatting, greetings like "Dear Hiring Manager" (we'll add that), or signature (we'll add that too). Just the main body paragraphs.
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const text = response.text().trim();
      
      this.logger.log('Cover letter generated successfully');
      return text;
    } catch (error) {
      this.logger.error('Error generating cover letter:', error);
      throw new Error('Failed to generate cover letter');
    }
  }

  /**
   * Generate CV improvement suggestions
   */
  async getCVImprovementSuggestions(cvData: any): Promise<string[]> {
    try {
      const prompt = `
You are a professional CV consultant. Analyze this CV data and provide 5-7 specific, actionable improvement suggestions.

CV Data:
${JSON.stringify(cvData, null, 2)}

Return ONLY a JSON array of suggestion strings.
Example: ["Add quantifiable achievements to your experience descriptions", "Include more technical details in project descriptions"]
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      let text = response.text().trim();
      
      text = text.replace(/```json\s*/g, '').replace(/```\s*/g, '').trim();
      return JSON.parse(text);
    } catch (error) {
      this.logger.error('Error generating CV suggestions:', error);
      return ['Unable to generate suggestions at this time'];
    }
  }

  /**
   * Generate interview questions based on job requirements
   */
  async generateInterviewQuestions(
    jobTitle: string,
    techStack: string[],
    experienceLevel: string,
  ): Promise<string[]> {
    try {
      const prompt = `
Generate 10 relevant interview questions for the following position:

Job Title: ${jobTitle}
Tech Stack: ${techStack.join(', ')}
Experience Level: ${experienceLevel}

Include a mix of technical, behavioral, and problem-solving questions.
Return ONLY a JSON array of question strings.
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      let text = response.text().trim();
      
      text = text.replace(/```json\s*/g, '').replace(/```\s*/g, '').trim();
      return JSON.parse(text);
    } catch (error) {
      this.logger.error('Error generating interview questions:', error);
      return [];
    }
  }

  /**
   * Analyze job market trends
   */
  async analyzeJobTrends(jobs: any[]): Promise<any> {
    try {
      const prompt = `
Analyze these job postings and provide insights on current IT job market trends.

Jobs:
${jobs.map((j) => `${j.title} - ${j.techStack?.join(', ')} - ${j.experienceLevel}`).join('\n')}

Return a JSON object with:
- topSkills: array of most in-demand skills
- averageSalary: estimated average salary range
- popularRoles: array of most common job titles
- emergingTechnologies: array of emerging tech mentioned
- insights: array of 3-5 key trend insights

Return ONLY valid JSON.
`;

      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      let text = response.text().trim();
      
      text = text.replace(/```json\s*/g, '').replace(/```\s*/g, '').trim();
      return JSON.parse(text);
    } catch (error) {
      this.logger.error('Error analyzing job trends:', error);
      return {
        topSkills: [],
        averageSalary: 'N/A',
        popularRoles: [],
        emergingTechnologies: [],
        insights: [],
      };
    }
  }
}
