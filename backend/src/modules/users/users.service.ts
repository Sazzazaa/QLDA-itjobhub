import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from '../../schemas/user.schema';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async findById(id: string): Promise<UserDocument> {
    return this.userModel.findById(id).select('-password');
  }

  async findByEmail(email: string): Promise<UserDocument> {
    return this.userModel.findOne({ email });
  }

  async updateProfile(userId: string, updateDto: any): Promise<UserDocument> {
    return this.userModel.findByIdAndUpdate(userId, updateDto, { new: true });
  }

  async updateSkills(userId: string, skills: string[]): Promise<UserDocument> {
    return this.userModel.findByIdAndUpdate(
      userId,
      { skills },
      { new: true },
    );
  }

  async addProject(userId: string, project: any): Promise<UserDocument> {
    return this.userModel.findByIdAndUpdate(
      userId,
      { $push: { projects: project } },
      { new: true },
    );
  }

  async updateProject(
    userId: string,
    projectId: string,
    project: any,
  ): Promise<UserDocument> {
    const user = await this.userModel.findById(userId);
    const projectIndex = user.projects.findIndex((p) => p.id === projectId);
    if (projectIndex !== -1) {
      user.projects[projectIndex] = { ...user.projects[projectIndex], ...project };
      await user.save();
    }
    return user;
  }

  async deleteProject(userId: string, projectId: string): Promise<UserDocument> {
    return this.userModel.findByIdAndUpdate(
      userId,
      { $pull: { projects: { id: projectId } } },
      { new: true },
    );
  }

  async addPoints(userId: string, points: number): Promise<void> {
    await this.userModel.findByIdAndUpdate(userId, {
      $inc: { points },
    });
  }

  async getLeaderboard(limit: number = 10): Promise<UserDocument[]> {
    return this.userModel
      .find({ role: 'candidate' })
      .sort({ points: -1 })
      .limit(limit)
      .select('-password');
  }
}
