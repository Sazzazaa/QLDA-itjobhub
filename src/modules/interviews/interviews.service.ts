import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Interview } from '../../schemas/interview.schema';
import { Application } from '../../schemas/application.schema';
import { Notification } from '../../schemas/notification.schema';
import { CreateInterviewDto } from './dto/create-interview.dto';
import { UpdateInterviewDto } from './dto/update-interview.dto';

@Injectable()
export class InterviewsService {
  constructor(
    @InjectModel(Interview.name) private interviewModel: Model<Interview>,
    @InjectModel(Application.name) private applicationModel: Model<Application>,
    @InjectModel(Notification.name) private notificationModel: Model<Notification>,
  ) {}

  async findByUser(userId: string): Promise<Interview[]> {
    return this.interviewModel
      .find({
        $or: [
          { candidateId: userId },
          { employerId: userId },
        ],
      })
      .populate('jobId')
      .populate('candidateId', 'name email')
      .populate('employerId', 'name email')
      .sort({ scheduledAt: -1 })
      .exec();
  }

  async findOne(id: string): Promise<Interview> {
    const interview = await this.interviewModel
      .findById(id)
      .populate('jobId')
      .populate('candidateId', 'name email')
      .populate('employerId', 'name email')
      .exec();
    
    if (!interview) {
      throw new NotFoundException(`Interview with ID ${id} not found`);
    }
    
    return interview;
  }

  async create(createInterviewDto: CreateInterviewDto, userId: string): Promise<Interview> {
    // Prevent scheduling more than one interview for the same application
    if (createInterviewDto.applicationId) {
      const existing = await this.interviewModel.findOne({
        applicationId: createInterviewDto.applicationId,
        status: { $in: ['scheduled', 'rescheduled'] },
      }).exec();

      if (existing) {
        // Return a clear error so frontend can handle it and avoid duplicate scheduling
        throw new BadRequestException('An interview has already been scheduled for this application');
      }
    }

    const newInterview = new this.interviewModel({
      ...createInterviewDto,
      employerId: userId,
      status: 'scheduled',
    });

    const savedInterview = await newInterview.save();
    
    // Auto-update application status to interview_scheduled
    if (createInterviewDto.applicationId) {
      const application = await this.applicationModel
        .findByIdAndUpdate(
          createInterviewDto.applicationId,
          {
            status: 'interview_scheduled',
            $push: {
              timeline: {
                status: 'interview_scheduled',
                timestamp: new Date(),
                note: `Interview scheduled for ${new Date(createInterviewDto.scheduledAt).toLocaleDateString()}`,
              },
            },
          },
          { new: true },
        )
        .populate('jobId');
      
      if (application) {
        const jobData = application.jobId as any;

        // Notify candidate about interview. Wrap in try/catch so notification failures
        // don't cause the whole request to fail.
        try {
          const notification = new this.notificationModel({
            userId: application.candidateId,
            type: 'interview',
            title: 'Interview Scheduled! 📅',
            message: `You have an interview scheduled for ${jobData?.title || 'the position'} on ${new Date(createInterviewDto.scheduledAt).toLocaleString()}`,
            relatedId: savedInterview._id,
            relatedType: 'interview',
            data: {
              jobId: application.jobId,
              jobTitle: jobData?.title,
              scheduledAt: createInterviewDto.scheduledAt,
              interviewType: createInterviewDto.type,
            },
          });
          await notification.save();
        } catch (notifErr) {
          // Log and continue — we don't want notification problems to block interview creation
          // eslint-disable-next-line no-console
          console.warn('Failed to create interview notification:', notifErr);
        }
      }
    }
    
    return savedInterview;
  }

  async update(id: string, updateInterviewDto: UpdateInterviewDto): Promise<Interview> {
    const interview = await this.interviewModel
      .findByIdAndUpdate(id, updateInterviewDto, { new: true })
      .exec();
    
    if (!interview) {
      throw new NotFoundException(`Interview with ID ${id} not found`);
    }
    
    return interview;
  }

  async cancel(id: string): Promise<Interview> {
    return this.update(id, { status: 'cancelled' } as any);
  }

  async reschedule(id: string, scheduledAt: Date): Promise<Interview> {
    return this.update(id, { scheduledAt, status: 'rescheduled' } as any);
  }

  async complete(id: string): Promise<Interview> {
    const interview = await this.interviewModel.findById(id);
    
    if (!interview) {
      throw new NotFoundException(`Interview with ID ${id} not found`);
    }

    // Update interview status to completed
    const updatedInterview = await this.interviewModel.findByIdAndUpdate(
      id,
      { status: 'completed' },
      { new: true },
    );

    // Update application status to interview_completed
    if (interview.applicationId) {
      const application = await this.applicationModel
        .findByIdAndUpdate(
          interview.applicationId,
          {
            status: 'interview_completed',
            $push: {
              timeline: {
                status: 'interview_completed',
                timestamp: new Date(),
                note: 'Interview completed',
              },
            },
          },
          { new: true },
        )
        .populate('jobId');

      if (application) {
        const jobData = application.jobId as any;

        try {
          // Notify candidate about completed interview
          const notification = new this.notificationModel({
            userId: application.candidateId,
            type: 'interview',
            title: 'Interview Completed',
            message: `Your interview for ${jobData?.title || 'the position'} has been completed. Waiting for final decision.`,
            relatedId: interview._id,
            relatedType: 'interview',
            data: {
              jobId: application.jobId,
              jobTitle: jobData?.title,
              applicationId: interview.applicationId,
            },
          });
          await notification.save();
        } catch (notifErr) {
          // Log and continue — notification failures should not cause a 500
          // eslint-disable-next-line no-console
          console.warn('Failed to create completion notification:', notifErr);
        }
      }
    }

    return updatedInterview;
  }

  async confirm(id: string): Promise<Interview> {
    const interview = await this.interviewModel.findById(id);
    
    if (!interview) {
      throw new NotFoundException(`Interview with ID ${id} not found`);
    }

    // Update interview confirmed status
    const updatedInterview = await this.interviewModel.findByIdAndUpdate(
      id,
      { confirmed: true },
      { new: true },
    );

    // Notify employer that candidate confirmed
    if (interview.applicationId) {
      const application = await this.applicationModel
        .findById(interview.applicationId)
        .populate('jobId')
        .populate('candidateId', 'name');

      if (application) {
        const jobData = application.jobId as any;
        const candidateData = application.candidateId as any;

        try {
          const notification = new this.notificationModel({
            userId: interview.employerId,
            type: 'interview',
            title: 'Interview Confirmed! ✅',
            message: `${candidateData?.name || 'Candidate'} confirmed the interview for ${jobData?.title || 'the position'}`,
            relatedId: interview._id,
            relatedType: 'interview',
            data: {
              jobId: application.jobId,
              jobTitle: jobData?.title,
              candidateId: application.candidateId,
              candidateName: candidateData?.name,
            },
          });
          await notification.save();
        } catch (notifErr) {
          console.warn('Failed to create confirmation notification:', notifErr);
        }
      }
    }

    return updatedInterview;
  }

  async remove(id: string): Promise<void> {
    const result = await this.interviewModel.findByIdAndDelete(id).exec();
    if (!result) {
      throw new NotFoundException(`Interview with ID ${id} not found`);
    }
  }
}
