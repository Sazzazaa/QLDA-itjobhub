import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Job, JobDocument } from '../../schemas/job.schema';
import { User, UserDocument } from '../../schemas/user.schema';
import { GeminiService } from '../ai/gemini.service';

@Injectable()
export class JobsService {
  constructor(
    @InjectModel(Job.name) private jobModel: Model<JobDocument>,
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private geminiService: GeminiService,
  ) {}

  async findAll(filters: any): Promise<JobDocument[]> {
    const query: any = { status: 'active' };

    if (filters.skills) {
      query.techStack = { $in: filters.skills.split(',') };
    }
    if (filters.location) {
      query.location = { $regex: filters.location, $options: 'i' };
    }
    if (filters.jobType) {
      query.jobType = filters.jobType;
    }
    if (filters.experienceLevel) {
      query.experienceLevel = filters.experienceLevel;
    }

    return this.jobModel.find(query).sort({ createdAt: -1 });
  }

  async findByEmployer(employerId: string): Promise<JobDocument[]> {
    return this.jobModel
      .find({ employerId })
      .sort({ createdAt: -1 })
      .exec();
  }

  async findOne(id: string): Promise<JobDocument> {
    return this.jobModel.findById(id);
  }

  async create(employerId: string, createJobDto: any): Promise<JobDocument> {
    // Get employer details
    const employer = await this.userModel.findById(employerId);
    if (!employer) {
      throw new NotFoundException('Employer not found');
    }

    // Extract company name from employer profile
    const companyName = (employer as any).companyName || (employer as any).name || 'Unknown Company';
    
    // Map skills to techStack and add required fields
    const jobData = {
      ...createJobDto,
      employerId,
      companyName,
      techStack: createJobDto.skills, // Map skills -> techStack
      contractType: createJobDto.contractType || createJobDto.jobType, // Use contractType or fallback to jobType
    };
    
    // Remove the skills field as schema uses techStack
    delete jobData.skills;

    const job = new this.jobModel(jobData);
    return job.save();
  }

  async update(id: string, updateJobDto: any): Promise<JobDocument> {
    return this.jobModel.findByIdAndUpdate(id, updateJobDto, { new: true });
  }

  async remove(id: string): Promise<void> {
    await this.jobModel.findByIdAndDelete(id);
  }

  async incrementViews(id: string): Promise<void> {
    await this.jobModel.findByIdAndUpdate(id, { $inc: { viewsCount: 1 } });
  }

  async getRecommendations(userId: string): Promise<any[]> {
    // Fetch user profile and available jobs
    // Use GeminiService to get recommendations
    const jobs = await this.jobModel.find({ status: 'active' }).limit(20);
    // This would integrate with user profile
    return jobs;
  }
}
