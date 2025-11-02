import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { InterviewsService } from './interviews.service';
import { CreateInterviewDto } from './dto/create-interview.dto';
import { UpdateInterviewDto } from './dto/update-interview.dto';

@Controller('interviews')
@UseGuards(JwtAuthGuard)
export class InterviewsController {
  constructor(private readonly interviewsService: InterviewsService) {}

  @Get()
  async findAll(@Request() req) {
    return this.interviewsService.findByUser(req.user.userId);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.interviewsService.findOne(id);
  }

  @Post()
  async create(@Body() createInterviewDto: CreateInterviewDto, @Request() req) {
    return this.interviewsService.create(createInterviewDto, req.user.userId);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() updateInterviewDto: UpdateInterviewDto) {
    return this.interviewsService.update(id, updateInterviewDto);
  }

  @Put(':id/cancel')
  async cancel(@Param('id') id: string) {
    return this.interviewsService.cancel(id);
  }

  @Put(':id/reschedule')
  async reschedule(@Param('id') id: string, @Body('scheduledAt') scheduledAt: Date) {
    return this.interviewsService.reschedule(id, scheduledAt);
  }

  @Put(':id/complete')
  async complete(@Param('id') id: string) {
    return this.interviewsService.complete(id);
  }

  @Put(':id/confirm')
  async confirm(@Param('id') id: string) {
    return this.interviewsService.confirm(id);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return this.interviewsService.remove(id);
  }
}
