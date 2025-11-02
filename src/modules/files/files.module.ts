import { Module } from '@nestjs/common';
import { MulterModule } from '@nestjs/platform-express';
import { FilesController } from './files.controller';
import { FilesService } from './files.service';
import { MongooseModule } from '@nestjs/mongoose';
import { CVData, CVDataSchema } from '../../schemas/cv-data.schema';
import { Job, JobSchema } from '../../schemas/job.schema';
import { AiModule } from '../ai/ai.module';

@Module({
  imports: [
    MulterModule.register({
      dest: './uploads',
    }),
    MongooseModule.forFeature([
      { name: CVData.name, schema: CVDataSchema },
      { name: Job.name, schema: JobSchema },
    ]),
    AiModule,
  ],
  controllers: [FilesController],
  providers: [FilesService],
  exports: [FilesService],
})
export class FilesModule {}
