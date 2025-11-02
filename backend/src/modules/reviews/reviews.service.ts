import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Review, ReviewDocument } from './schemas/review.schema';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  constructor(
    @InjectModel(Review.name) private reviewModel: Model<ReviewDocument>,
  ) {}

  async create(createReviewDto: CreateReviewDto, userId: string, userName: string, userRole: string) {
    // Prevent self-review
    if (userId === createReviewDto.revieweeId) {
      throw new BadRequestException('You cannot review yourself');
    }

    // Create review
    const review = new this.reviewModel({
      ...createReviewDto,
      reviewerId: new Types.ObjectId(userId),
      reviewerName: userName,
      reviewerRole: userRole,
    });

    return review.save();
  }

  async findAll(filters?: {
    revieweeId?: string;
    reviewerId?: string;
    reviewerRole?: string;
    revieweeRole?: string;
  }) {
    const query: any = {};

    if (filters?.revieweeId) {
      query.revieweeId = new Types.ObjectId(filters.revieweeId);
    }
    if (filters?.reviewerId) {
      query.reviewerId = new Types.ObjectId(filters.reviewerId);
    }
    if (filters?.reviewerRole) {
      query.reviewerRole = filters.reviewerRole;
    }
    if (filters?.revieweeRole) {
      query.revieweeRole = filters.revieweeRole;
    }

    return this.reviewModel
      .find(query)
      .sort({ createdAt: -1 })
      .exec();
  }

  async findOne(id: string) {
    const review = await this.reviewModel.findById(id).exec();
    if (!review) {
      throw new NotFoundException(`Review with ID ${id} not found`);
    }
    return review;
  }

  async getReviewStats(revieweeId: string) {
    const reviews = await this.reviewModel
      .find({ revieweeId: new Types.ObjectId(revieweeId) })
      .exec();

    if (reviews.length === 0) {
      return {
        totalReviews: 0,
        averageRating: 0,
        ratingDistribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
      };
    }

    const totalRating = reviews.reduce((sum, review) => sum + review.overallRating, 0);
    const averageRating = totalRating / reviews.length;

    const ratingDistribution = reviews.reduce((acc, review) => {
      const rating = Math.round(review.overallRating);
      acc[rating] = (acc[rating] || 0) + 1;
      return acc;
    }, {} as Record<number, number>);

    return {
      totalReviews: reviews.length,
      averageRating: Math.round(averageRating * 10) / 10,
      ratingDistribution,
    };
  }

  async remove(id: string, userId: string) {
    const review = await this.reviewModel.findById(id).exec();
    
    if (!review) {
      throw new NotFoundException(`Review with ID ${id} not found`);
    }

    // Only allow the reviewer to delete their own review
    if (review.reviewerId.toString() !== userId) {
      throw new BadRequestException('You can only delete your own reviews');
    }

    await review.deleteOne();
    return { message: 'Review deleted successfully' };
  }
}
