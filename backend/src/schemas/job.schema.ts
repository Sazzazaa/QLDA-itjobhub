import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type JobDocument = Job & Document;

export enum JobType {
  REMOTE = 'remote',
  ONSITE = 'onsite',
  HYBRID = 'hybrid',
}

export enum ExperienceLevel {
  ENTRY = 'entry',
  MID = 'mid',
  SENIOR = 'senior',
  LEAD = 'lead',
}

export enum ContractType {
  FULL_TIME = 'full-time',
  PART_TIME = 'part-time',
  FREELANCE = 'freelance',
  CONTRACT = 'contract',
}

export enum JobStatus {
  ACTIVE = 'active',
  PAUSED = 'paused',
  CLOSED = 'closed',
}

@Schema({ timestamps: true })
export class Job {
  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  description: string;

  @Prop({ required: true })
  requirements: string;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  employerId: Types.ObjectId;

  @Prop({ required: true })
  companyName: string;

  @Prop()
  companyLogo: string;

  @Prop({ required: true })
  location: string;

  @Prop({ required: true, enum: JobType })
  jobType: JobType;

  @Prop({ required: true, enum: ExperienceLevel })
  experienceLevel: ExperienceLevel;

  @Prop({ required: true, enum: ContractType })
  contractType: ContractType;

  @Prop({ type: [String], required: true })
  techStack: string[];

  @Prop()
  minSalary: number;

  @Prop()
  maxSalary: number;

  @Prop({ default: 0 })
  applicantsCount: number;

  @Prop({ default: 0 })
  viewsCount: number;

  @Prop({ enum: JobStatus, default: JobStatus.ACTIVE })
  status: JobStatus;

  @Prop()
  deadline: Date;

  @Prop({ default: false })
  isFeatured: boolean;

  @Prop({ type: Object })
  benefits: string[];

  @Prop()
  responsibilities: string;

  // For AI matching
  @Prop({ type: [Number] })
  embedding: number[];
}

export const JobSchema = SchemaFactory.createForClass(Job);

// Indexes
JobSchema.index({ employerId: 1 });
JobSchema.index({ status: 1 });
JobSchema.index({ techStack: 1 });
JobSchema.index({ experienceLevel: 1 });
JobSchema.index({ createdAt: -1 });
