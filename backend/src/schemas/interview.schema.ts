import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

@Schema({ timestamps: true })
export class Interview extends Document {
  @Prop({ type: Types.ObjectId, ref: 'Job', required: true })
  jobId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  candidateId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  employerId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Application' })
  applicationId?: Types.ObjectId;

  @Prop({ required: true })
  scheduledAt: Date;

  @Prop()
  duration: number; // in minutes

  @Prop({ enum: ['scheduled', 'rescheduled', 'completed', 'cancelled', 'no-show'], default: 'scheduled' })
  status: string;

  @Prop({ default: false })
  confirmed: boolean; // Candidate confirmed the interview

  @Prop()
  type: string; // 'online', 'onsite'

  @Prop()
  location: string;

  @Prop()
  meetingLink: string;

  @Prop()
  notes: string;

  @Prop()
  feedback: string;

  @Prop({ type: Object })
  interviewerDetails: {
    name: string;
    position: string;
    email: string;
  };
}

export const InterviewSchema = SchemaFactory.createForClass(Interview);
