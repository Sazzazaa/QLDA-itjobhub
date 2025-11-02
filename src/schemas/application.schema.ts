import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ApplicationDocument = Application & Document;

export enum ApplicationStatus {
  PENDING = 'pending',
  REVIEWING = 'reviewing',
  INTERVIEW = 'interview',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  WITHDRAWN = 'withdrawn',
}

@Schema({ timestamps: true })
export class Application {
  @Prop({ type: Types.ObjectId, ref: 'Job', required: true })
  jobId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  candidateId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  employerId: Types.ObjectId;

  @Prop({ enum: ApplicationStatus, default: ApplicationStatus.PENDING })
  status: ApplicationStatus;

  @Prop()
  coverLetter: string;

  @Prop()
  resumeUrl: string;

  @Prop({ type: Number, min: 0, max: 100 })
  matchPercentage: number;

  @Prop({ type: Object })
  timeline: {
    status: ApplicationStatus;
    timestamp: Date;
    note: string;
  }[];

  @Prop()
  employerNote: string;

  @Prop()
  rejectionReason: string;

  @Prop({ default: false })
  isViewed: boolean;

  @Prop()
  viewedAt: Date;
}

export const ApplicationSchema = SchemaFactory.createForClass(Application);

// Indexes
ApplicationSchema.index({ jobId: 1, candidateId: 1 }, { unique: true });
ApplicationSchema.index({ candidateId: 1 });
ApplicationSchema.index({ employerId: 1 });
ApplicationSchema.index({ status: 1 });
