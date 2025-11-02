import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Job, JobSchema } from '../../schemas/job.schema';
import { User, UserSchema } from '../../schemas/user.schema';
import { JobsController } from './jobs.controller';
import { JobsService } from './jobs.service';
import { AiModule } from '../ai/ai.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Job.name, schema: JobSchema },
      { name: User.name, schema: UserSchema },
    ]),
    AiModule,
  ],
  controllers: [JobsController],
  providers: [JobsService],
  exports: [JobsService],
})
export class JobsModule {}
