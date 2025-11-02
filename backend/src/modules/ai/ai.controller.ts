import { Controller, Post, Body, UseGuards, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { GeminiService } from './gemini.service';

@ApiTags('ai')
@Controller('ai')
export class AiController {
  constructor(private readonly geminiService: GeminiService) {}

  @Get('cv-suggestions')
  @ApiOperation({ summary: 'Get CV improvement suggestions' })
  async getCVSuggestions(@Query('cvId') cvId: string) {
    // This would fetch CV data from database
    // For now, returning a placeholder
    const suggestions = await this.geminiService.getCVImprovementSuggestions({
      name: 'Sample',
      skills: ['JavaScript', 'React'],
    });
    return { suggestions };
  }

  @Get('interview-questions')
  @ApiOperation({ summary: 'Generate interview questions for a job' })
  async getInterviewQuestions(
    @Query('jobTitle') jobTitle: string,
    @Query('techStack') techStack: string,
    @Query('level') level: string,
  ) {
    const questions = await this.geminiService.generateInterviewQuestions(
      jobTitle,
      techStack.split(','),
      level,
    );
    return { questions };
  }

  @Get('job-trends')
  @ApiOperation({ summary: 'Analyze current job market trends' })
  async getJobTrends() {
    // This would fetch recent jobs from database
    const trends = await this.geminiService.analyzeJobTrends([]);
    return trends;
  }
}
