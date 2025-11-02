import { Controller, Post, UseInterceptors, UploadedFile, UseGuards, Request, Get, Param, Delete, Body } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FilesService } from './files.service';

@ApiTags('files')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('files')
export class FilesController {
  constructor(private filesService: FilesService) {}

  @Post('cv/upload')
  @ApiOperation({ summary: 'Upload and parse CV' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file'))
  async uploadCV(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.filesService.uploadAndParseCV(req.user.userId, file);
  }

  @Get('cv/:id/status')
  @ApiOperation({ summary: 'Get CV parsing status' })
  async getCVStatus(@Param('id') id: string) {
    return this.filesService.getCVStatus(id);
  }

  @Get('cv/:id/parsed')
  @ApiOperation({ summary: 'Get parsed CV data' })
  async getParsedData(@Param('id') id: string) {
    return this.filesService.getParsedData(id);
  }

  @Get('cv/my-cvs')
  @ApiOperation({ summary: 'Get all CVs uploaded by current user' })
  async getMyCVs(@Request() req) {
    return this.filesService.getUserCVs(req.user.userId);
  }

  @Delete('cv/:id')
  @ApiOperation({ summary: 'Delete a CV' })
  async deleteCV(@Request() req, @Param('id') id: string) {
    return this.filesService.deleteCV(req.user.userId, id);
  }

  @Post('cv/generate-cover-letter')
  @ApiOperation({ summary: 'Generate cover letter using AI based on CV and job' })
  async generateCoverLetter(
    @Request() req,
    @Body() body: { cvId: string; jobId: string },
  ) {
    return this.filesService.generateCoverLetter(
      req.user.userId,
      body.cvId,
      body.jobId,
    );
  }
}
