import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type CVDataDocument = CVData & Document;

export enum CVParseStatus {
  PENDING = 'pending',
  PARSING = 'parsing',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

@Schema({ timestamps: true })
export class CVData {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ required: true })
  fileName: string;

  @Prop({ required: true })
  fileUrl: string;

  @Prop()
  fileSize: number;

  @Prop({ enum: CVParseStatus, default: CVParseStatus.PENDING })
  status: CVParseStatus;

  // Parsed data from Gemini AI
  @Prop({ type: Object })
  parsedData: {
    name: string;
    email: string;
    phone: string;
    location: string;
    summary: string;
    skills: string[];
    experience: {
      title: string;
      company: string;
      startDate: string;
      endDate: string;
      description: string;
      technologies: string[];
    }[];
    education: {
      degree: string;
      major: string;
      institution: string;
      startYear: number;
      endYear: number;
    }[];
    projects: {
      name: string;
      role: string;
      description: string;
      technologies: string[];
      startDate: string;
      endDate: string;
      projectUrl: string;
    }[];
    certifications: {
      name: string;
      issuer: string;
      issueDate: string;
      expiryDate: string;
    }[];
    languages: string[];
    githubUrl: string;
    linkedinUrl: string;
    portfolioUrl: string;
  };

  @Prop()
  parseError: string;

  @Prop({ default: false })
  isAppliedToProfile: boolean;
}

export const CVDataSchema = SchemaFactory.createForClass(CVData);

// Indexes
CVDataSchema.index({ userId: 1 });
CVDataSchema.index({ status: 1 });
