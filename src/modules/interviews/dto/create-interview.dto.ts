import { IsNotEmpty, IsDateString, IsOptional, IsString, IsNumber } from 'class-validator';

export class CreateInterviewDto {
  @IsNotEmpty()
  @IsString()
  jobId: string;

  @IsNotEmpty()
  @IsString()
  candidateId: string;

  @IsOptional()
  @IsString()
  applicationId?: string;

  @IsNotEmpty()
  @IsDateString()
  scheduledAt: Date;

  @IsOptional()
  @IsNumber()
  duration?: number;

  @IsOptional()
  @IsString()
  type?: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsString()
  meetingLink?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  interviewerDetails?: {
    name: string;
    position: string;
    email: string;
  };
}
