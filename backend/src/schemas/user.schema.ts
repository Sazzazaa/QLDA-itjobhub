import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type UserDocument = User & Document;

export enum UserRole {
  CANDIDATE = 'candidate',
  EMPLOYER = 'employer',
  ADMIN = 'admin',
}

export enum WorkLocation {
  REMOTE = 'remote',
  ONSITE = 'onsite',
  HYBRID = 'hybrid',
}

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true })
  password: string;

  @Prop({ required: true, enum: UserRole })
  role: UserRole;

  @Prop()
  phone: string;

  @Prop()
  location: string;

  @Prop()
  profileImage: string;

  // Social links
  @Prop()
  githubUrl: string;

  @Prop()
  linkedinUrl: string;

  @Prop()
  portfolioUrl: string;

  // Candidate-specific fields
  @Prop({ type: [String], default: [] })
  skills: string[];

  @Prop()
  desiredSalary: number;

  @Prop({ enum: WorkLocation })
  workLocation: WorkLocation;

  @Prop({ type: Object })
  experience: {
    title: string;
    company: string;
    startDate: string;
    endDate: string;
    description: string;
  }[];

  @Prop({ type: Object })
  education: {
    degree: string;
    major: string;
    institution: string;
    startYear: number;
    endYear: number;
  }[];

  @Prop({ type: Object })
  projects: {
    id: string;
    name: string;
    role: string;
    description: string;
    technologies: string[];
    startDate: string;
    endDate: string;
    projectUrl: string;
  }[];

  // Employer-specific fields
  @Prop()
  companyName: string;

  @Prop()
  companySize: string;

  @Prop()
  companyWebsite: string;

  @Prop()
  industry: string;

  @Prop()
  companyDescription: string;

  // Auth-related
  @Prop({ type: [String], default: [] })
  refreshTokens: string[];

  @Prop({ default: false })
  isEmailVerified: boolean;

  @Prop()
  emailVerificationToken: string;

  @Prop()
  resetPasswordToken: string;

  @Prop()
  resetPasswordExpires: Date;

  // OAuth
  @Prop()
  googleId: string;

  @Prop()
  githubId: string;

  // Points and ranking (for candidate)
  @Prop({ default: 0 })
  points: number;

  @Prop({ type: [String], default: [] })
  badgeIds: string[];

  @Prop({ default: true })
  isActive: boolean;

  @Prop()
  lastLogin: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);

// Indexes
UserSchema.index({ email: 1 });
UserSchema.index({ role: 1 });
UserSchema.index({ skills: 1 });
UserSchema.index({ points: -1 });
