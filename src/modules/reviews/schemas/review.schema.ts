import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ReviewDocument = Review & Document;

@Schema({ timestamps: true })
export class Review {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  reviewerId: Types.ObjectId;

  @Prop({ required: true })
  reviewerName: string;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  revieweeId: Types.ObjectId;

  @Prop({ required: true })
  revieweeName: string;

  @Prop({ required: true, enum: ['candidate', 'employer'] })
  reviewerRole: string;

  @Prop({ required: true, enum: ['candidate', 'employer'] })
  revieweeRole: string;

  @Prop({ required: true })
  companyName: string;

  @Prop({ required: true })
  jobTitle: string;

  @Prop({ type: Number, required: true, min: 1, max: 5 })
  overallRating: number;

  @Prop({ type: Number, min: 1, max: 5 })
  cultureRating?: number;

  @Prop({ type: Number, min: 1, max: 5 })
  compensationRating?: number;

  @Prop({ type: Number, min: 1, max: 5 })
  workLifeBalanceRating?: number;

  @Prop({ type: Number, min: 1, max: 5 })
  managementRating?: number;

  @Prop({ type: Number, min: 1, max: 5 })
  skillsRating?: number;

  @Prop({ type: Number, min: 1, max: 5 })
  communicationRating?: number;

  @Prop({ type: Number, min: 1, max: 5 })
  professionalismRating?: number;

  @Prop({ type: Number, min: 1, max: 5 })
  punctualityRating?: number;

  @Prop()
  reviewTitle?: string;

  @Prop({ required: true })
  reviewText: string;

  @Prop({ type: Boolean })
  wouldWorkAgain?: boolean;

  @Prop({ type: Boolean, default: false })
  isVerified: boolean;

  @Prop({ type: Boolean, default: true })
  isPublished: boolean;
}

export const ReviewSchema = SchemaFactory.createForClass(Review);

// Indexes
ReviewSchema.index({ reviewerId: 1 });
ReviewSchema.index({ revieweeId: 1 });
ReviewSchema.index({ reviewerRole: 1, revieweeRole: 1 });
ReviewSchema.index({ overallRating: -1 });
ReviewSchema.index({ createdAt: -1 });
