import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Application, ApplicationDocument } from '../../schemas/application.schema';
import { Job, JobDocument } from '../../schemas/job.schema';
import { Notification, NotificationDocument } from '../../schemas/notification.schema';
import { GeminiService } from '../ai/gemini.service';

@Injectable()
export class ApplicationsService {
  constructor(
    @InjectModel(Application.name) private applicationModel: Model<ApplicationDocument>,
    @InjectModel(Job.name) private jobModel: Model<JobDocument>,
    @InjectModel(Notification.name) private notificationModel: Model<NotificationDocument>,
    private geminiService: GeminiService,
  ) {}

  async findByUser(userId: string, role: string): Promise<ApplicationDocument[]> {
    const query = role === 'candidate' ? { candidateId: userId } : { employerId: userId };
    return this.applicationModel.find(query).populate('jobId candidateId');
  }

  async findOne(id: string): Promise<ApplicationDocument> {
    return this.applicationModel.findById(id).populate('jobId candidateId');
  }

  async create(candidateId: string, createApplicationDto: any): Promise<ApplicationDocument> {
    // Get job to extract employerId
    const job = await this.jobModel.findById(createApplicationDto.jobId);
    if (!job) {
      throw new NotFoundException('Job not found');
    }

    // Check if already applied
    const existingApplication = await this.applicationModel.findOne({
      jobId: createApplicationDto.jobId,
      candidateId,
    });
    
    if (existingApplication) {
      throw new Error('You have already applied for this job');
    }

    // Calculate match percentage using AI (TODO: implement with GeminiService)
    const matchPercentage = 75;
    
    const application = new this.applicationModel({
      ...createApplicationDto,
      candidateId,
      employerId: job.employerId, // Auto-fill from job
      resumeUrl: createApplicationDto.cvUrl || createApplicationDto.resumeUrl, // Accept both field names
      matchPercentage,
      timeline: [{
        status: 'pending',
        timestamp: new Date(),
        note: 'Application submitted',
      }],
    });
    
    const savedApplication = await application.save();
    
    // Populate to get candidate name
    const populatedApplication = await this.applicationModel
      .findById(savedApplication._id)
      .populate('jobId candidateId');
    
    // Increment job applicants count
    await this.jobModel.findByIdAndUpdate(
      createApplicationDto.jobId,
      { $inc: { applicantsCount: 1 } },
    );
    
    // Create notification for employer
    const candidateData = populatedApplication.candidateId as any;
    const notification = new this.notificationModel({
      userId: job.employerId,
      type: 'application',
      title: 'New Job Application',
      message: `${candidateData?.name || 'A candidate'} has applied for ${job.title}`,
      relatedId: savedApplication._id,
      relatedType: 'application',
      metadata: {
        jobId: job._id,
        jobTitle: job.title,
        candidateId: candidateId,
        candidateName: candidateData?.name,
      },
    });
    await notification.save();
    
    return populatedApplication;
  }

  async updateStatus(id: string, status: string, note?: string): Promise<ApplicationDocument> {
    const application = await this.applicationModel.findById(id).populate('jobId');
    
    if (!application) {
      throw new NotFoundException(`Application ${id} not found`);
    }
    
    // Validate status transitions
    if (application.status === 'rejected' || application.status === 'withdrawn') {
      throw new Error('Cannot change status of closed application');
    }
    
    const updatedApplication = await this.applicationModel.findByIdAndUpdate(
      id,
      {
        status,
        $push: {
          timeline: {
            status,
            timestamp: new Date(),
            note: note || `Status changed to ${status}`,
          },
        },
      },
      { new: true },
    ).populate('jobId candidateId');
    
    // Create notification for candidate
    const jobData = application.jobId as any;
    
    if (status === 'approved') {
      const notification = new this.notificationModel({
        userId: application.candidateId,
        type: 'application',
        title: 'Application Approved! 🎉',
        message: `Your application for ${jobData?.title || 'the position'} has been approved. The employer may contact you for an interview.`,
        relatedId: application._id,
        relatedType: 'application',
        metadata: {
          jobId: application.jobId,
          jobTitle: jobData?.title,
        },
      });
      await notification.save();
    } else if (status === 'rejected') {
      const notification = new this.notificationModel({
        userId: application.candidateId,
        type: 'application',
        title: 'Application Status Update',
        message: `Your application for ${jobData?.title || 'the position'} has been reviewed.`,
        relatedId: application._id,
        relatedType: 'application',
        metadata: {
          jobId: application.jobId,
          jobTitle: jobData?.title,
        },
      });
      await notification.save();
    }
    
    return updatedApplication;
  }

  async withdraw(id: string): Promise<ApplicationDocument> {
    return this.updateStatus(id, 'withdrawn', 'Withdrawn by candidate');
  }

  async delete(id: string): Promise<void> {
    const application = await this.applicationModel.findById(id);
    
    if (!application) {
      throw new NotFoundException(`Application ${id} not found`);
    }
    
    // Decrement job applicants count
    await this.jobModel.findByIdAndUpdate(
      application.jobId,
      { $inc: { applicantsCount: -1 } },
    );
    
    // Delete the application
    await this.applicationModel.findByIdAndDelete(id);
  }
}
