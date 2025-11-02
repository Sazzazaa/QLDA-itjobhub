import { IsString, IsNumber, IsOptional, IsBoolean, Min, Max, MinLength, IsEnum } from 'class-validator';

export class CreateReviewDto {
  @IsString()
  revieweeId: string;

  @IsString()
  revieweeName: string;

  @IsString()
  @IsEnum(['candidate', 'employer'])
  revieweeRole: string;

  @IsString()
  companyName: string;

  @IsString()
  jobTitle: string;

  @IsNumber()
  @Min(1)
  @Max(5)
  overallRating: number;

  // Employer review ratings (when reviewing companies)
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  cultureRating?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  compensationRating?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  workLifeBalanceRating?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  managementRating?: number;

  // Candidate review ratings (when reviewing candidates)
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  skillsRating?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  communicationRating?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  professionalismRating?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  punctualityRating?: number;

  @IsOptional()
  @IsString()
  reviewTitle?: string;

  @IsString()
  @MinLength(50, { message: 'Review must be at least 50 characters long' })
  reviewText: string;

  @IsOptional()
  @IsBoolean()
  wouldWorkAgain?: boolean;
}
