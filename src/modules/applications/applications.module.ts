import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Application, ApplicationSchema } from '../../schemas/application.schema';
import { Job, JobSchema } from '../../schemas/job.schema';
import { Notification, NotificationSchema } from '../../schemas/notification.schema';
import { ApplicationsController } from './applications.controller';
import { ApplicationsService } from './applications.service';
import { AiModule } from '../ai/ai.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Application.name, schema: ApplicationSchema },
      { name: Job.name, schema: JobSchema },
      { name: Notification.name, schema: NotificationSchema },
    ]),
    AiModule,
  ],
  controllers: [ApplicationsController],
  providers: [ApplicationsService],
  exports: [ApplicationsService],
})
export class ApplicationsModule {}
