import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsArray,
  IsNumber,
  IsOptional,
  IsEnum,
  Min,
} from 'class-validator';

export class CreateJobDto {
  @ApiProperty({
    description: 'Job title',
    example: 'Senior Full-Stack Developer',
    type: String,
  })
  @IsNotEmpty({ message: 'Job title is required' })
  @IsString()
  title: string;

  @ApiProperty({
    description: 'Detailed job description',
    example:
      'We are looking for an experienced Full-Stack Developer to join our team...',
    type: String,
  })
  @IsNotEmpty({ message: 'Job description is required' })
  @IsString()
  description: string;

  @ApiProperty({
    description: 'Job requirements',
    example:
      '3+ years of experience with React and Node.js, strong problem-solving skills',
    type: String,
  })
  @IsNotEmpty({ message: 'Job requirements are required' })
  @IsString()
  requirements: string;

  @ApiProperty({
    description: 'Required skills',
    example: ['JavaScript', 'TypeScript', 'React', 'Node.js', 'MongoDB'],
    type: [String],
  })
  @IsNotEmpty({ message: 'Skills are required' })
  @IsArray()
  @IsString({ each: true })
  skills: string[];

  @ApiProperty({
    description: 'Contract type',
    example: 'full-time',
    enum: ['full-time', 'part-time', 'contract', 'freelance'],
    type: String,
  })
  @IsNotEmpty({ message: 'Contract type is required' })
  @IsEnum(['full-time', 'part-time', 'contract', 'freelance'], {
    message: 'Invalid contract type',
  })
  contractType: string;

  @ApiProperty({
    description: 'Job location',
    example: 'Ho Chi Minh City, Vietnam',
    type: String,
  })
  @IsNotEmpty({ message: 'Location is required' })
  @IsString()
  location: string;

  @ApiProperty({
    description: 'Salary range',
    example: '$2000 - $3000/month',
    type: String,
  })
  @IsNotEmpty({ message: 'Salary is required' })
  @IsString()
  salary: string;

  @ApiProperty({
    description: 'Job type',
    example: 'remote',
    enum: ['remote', 'onsite', 'hybrid'],
    type: String,
  })
  @IsNotEmpty({ message: 'Job type is required' })
  @IsEnum(['remote', 'onsite', 'hybrid'], {
    message: 'Invalid job type',
  })
  jobType: string;

  @ApiProperty({
    description: 'Experience level required',
    example: 'mid',
    enum: ['entry', 'mid', 'senior', 'lead'],
    type: String,
  })
  @IsNotEmpty({ message: 'Experience level is required' })
  @IsEnum(['entry', 'mid', 'senior', 'lead'], {
    message: 'Invalid experience level',
  })
  experienceLevel: string;

  @ApiPropertyOptional({
    description: 'Benefits offered',
    example: ['Health insurance', 'Flexible hours', 'Remote work', '13th month salary'],
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  benefits?: string[];

  @ApiPropertyOptional({
    description: 'Application deadline',
    example: '2025-12-31T23:59:59.000Z',
    type: Date,
  })
  @IsOptional()
  deadline?: Date;
}
