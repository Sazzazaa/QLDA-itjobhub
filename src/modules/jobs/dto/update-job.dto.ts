import { PartialType, ApiPropertyOptional } from '@nestjs/swagger';
import { CreateJobDto } from './create-job.dto';

export class UpdateJobDto extends PartialType(CreateJobDto) {
  @ApiPropertyOptional({
    description: 'Job status',
    example: 'active',
    enum: ['active', 'closed', 'draft'],
    type: String,
  })
  status?: 'active' | 'closed' | 'draft';
}
