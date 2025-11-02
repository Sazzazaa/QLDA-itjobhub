import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApplicationsService } from './applications.service';

@ApiTags('applications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('applications')
export class ApplicationsController {
  constructor(private applicationsService: ApplicationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all applications for current user' })
  async findAll(@Request() req) {
    return this.applicationsService.findByUser(req.user.userId, req.user.role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get application by ID' })
  async findOne(@Param('id') id: string) {
    return this.applicationsService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Submit a job application' })
  async create(@Request() req, @Body() createApplicationDto: any) {
    return this.applicationsService.create(req.user.userId, createApplicationDto);
  }

  @Put(':id/status')
  @ApiOperation({ summary: 'Update application status' })
  async updateStatus(@Param('id') id: string, @Body() body: { status: string; note?: string }) {
    return this.applicationsService.updateStatus(id, body.status, body.note);
  }

  @Put(':id/withdraw')
  @ApiOperation({ summary: 'Withdraw application' })
  async withdraw(@Param('id') id: string) {
    return this.applicationsService.withdraw(id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete application' })
  async delete(@Param('id') id: string) {
    return this.applicationsService.delete(id);
  }
}
