import { Controller, Get, Post, Body, Param, Delete, Query, UseGuards, Request } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('reviews')
@UseGuards(JwtAuthGuard)
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post()
  create(@Body() createReviewDto: CreateReviewDto, @Request() req) {
    return this.reviewsService.create(
      createReviewDto,
      req.user.sub,
      req.user.name || req.user.email,
      req.user.role,
    );
  }

  @Get()
  findAll(
    @Query('revieweeId') revieweeId?: string,
    @Query('reviewerId') reviewerId?: string,
    @Query('reviewerRole') reviewerRole?: string,
    @Query('revieweeRole') revieweeRole?: string,
  ) {
    return this.reviewsService.findAll({
      revieweeId,
      reviewerId,
      reviewerRole,
      revieweeRole,
    });
  }

  @Get('stats/:revieweeId')
  getStats(@Param('revieweeId') revieweeId: string) {
    return this.reviewsService.getReviewStats(revieweeId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.reviewsService.findOne(id);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.reviewsService.remove(id, req.user.sub);
  }
}
