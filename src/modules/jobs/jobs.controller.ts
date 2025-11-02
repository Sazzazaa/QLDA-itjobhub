import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiResponse, ApiBody } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JobsService } from './jobs.service';
import { CreateJobDto, UpdateJobDto } from './dto';

@ApiTags('jobs')
@Controller('jobs')
export class JobsController {
  constructor(private jobsService: JobsService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Get all jobs with filters',
    description: 'Search and filter jobs by skills, location, job type, and experience level',
  })
  @ApiQuery({ name: 'skills', required: false, description: 'Comma-separated skills (e.g., JavaScript,React)', example: 'JavaScript,React' })
  @ApiQuery({ name: 'location', required: false, description: 'Job location', example: 'Ho Chi Minh City' })
  @ApiQuery({ name: 'jobType', required: false, description: 'Job type', enum: ['full-time', 'part-time', 'contract', 'internship', 'remote'] })
  @ApiQuery({ name: 'experienceLevel', required: false, description: 'Experience level', enum: ['junior', 'mid', 'senior', 'lead'] })
  @ApiResponse({ status: 200, description: 'List of jobs retrieved successfully' })
  async findAll(@Query() query: any) {
    return this.jobsService.findAll(query);
  }

  @Get('my-jobs')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ 
    summary: 'Get my job postings (Employer only)',
    description: 'Get all jobs posted by the current employer',
  })
  @ApiResponse({ status: 200, description: 'Employer jobs retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - JWT token required' })
  async getMyJobs(@Request() req) {
    return this.jobsService.findByEmployer(req.user.userId);
  }

  @Get('recommendations')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ 
    summary: 'Get personalized job recommendations',
    description: 'Get AI-powered job recommendations based on your profile and preferences',
  })
  @ApiResponse({ status: 200, description: 'Recommendations retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - JWT token required' })
  async getRecommendations(@Request() req) {
    return this.jobsService.getRecommendations(req.user.userId);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get job by ID',
    description: 'Get detailed information about a specific job posting',
  })
  @ApiResponse({ status: 200, description: 'Job details retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Job not found' })
  async findOne(@Param('id') id: string) {
    return this.jobsService.findOne(id);
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ 
    summary: 'Create a new job posting (Employer only)',
    description: 'Create a new job posting. Only accessible to users with employer role.',
  })
  @ApiBody({ type: CreateJobDto })
  @ApiResponse({ status: 201, description: 'Job created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - JWT token required' })
  @ApiResponse({ status: 403, description: 'Forbidden - Employer role required' })
  async create(@Request() req, @Body() createJobDto: CreateJobDto) {
    return this.jobsService.create(req.user.userId, createJobDto);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ 
    summary: 'Update job posting',
    description: 'Update an existing job posting. Only the job owner can update.',
  })
  @ApiBody({ type: UpdateJobDto })
  @ApiResponse({ status: 200, description: 'Job updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Job not found' })
  async update(@Param('id') id: string, @Body() updateJobDto: UpdateJobDto) {
    return this.jobsService.update(id, updateJobDto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ 
    summary: 'Delete job posting',
    description: 'Delete a job posting. Only the job owner can delete.',
  })
  @ApiResponse({ status: 200, description: 'Job deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Job not found' })
  async remove(@Param('id') id: string) {
    return this.jobsService.remove(id);
  }

  @Post(':id/increment-views')
  @ApiOperation({ 
    summary: 'Increment job views count',
    description: 'Track when a job is viewed',
  })
  @ApiResponse({ status: 200, description: 'View count incremented' })
  async incrementViews(@Param('id') id: string) {
    return this.jobsService.incrementViews(id);
  }
}
