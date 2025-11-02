import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Notification, NotificationDocument } from '../../schemas/notification.schema';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(Notification.name) private notificationModel: Model<NotificationDocument>,
  ) {}

  // Get all notifications for a user
  async getUserNotifications(userId: string) {
    console.log('🔔 NotificationsService: Getting notifications for user:', userId);
    
    const notifications = await this.notificationModel
      .find({ userId: new Types.ObjectId(userId) })
      .sort({ createdAt: -1 })
      .limit(100); // Limit to last 100 notifications

    console.log(`🔔 NotificationsService: Found ${notifications.length} notifications`);

    return notifications.map((notif) => ({
      id: notif._id.toString(),
      title: notif.title,
      message: notif.message,
      type: notif.type,
      timestamp: notif.createdAt,
      isRead: notif.isRead,
      data: notif.data,
    }));
  }

  // Get unread notifications count
  async getUnreadCount(userId: string) {
    return this.notificationModel.countDocuments({
      userId: new Types.ObjectId(userId),
      isRead: false,
    });
  }

  // Mark notification as read
  async markAsRead(notificationId: string, userId: string) {
    const notification = await this.notificationModel.findOneAndUpdate(
      {
        _id: new Types.ObjectId(notificationId),
        userId: new Types.ObjectId(userId),
      },
      { isRead: true },
      { new: true },
    );

    if (!notification) {
      throw new Error('Notification not found');
    }

    return {
      id: notification._id.toString(),
      isRead: notification.isRead,
    };
  }

  // Mark all notifications as read
  async markAllAsRead(userId: string) {
    await this.notificationModel.updateMany(
      {
        userId: new Types.ObjectId(userId),
        isRead: false,
      },
      { isRead: true },
    );

    return { success: true, message: 'All notifications marked as read' };
  }

  // Delete notification
  async deleteNotification(notificationId: string, userId: string) {
    const result = await this.notificationModel.deleteOne({
      _id: new Types.ObjectId(notificationId),
      userId: new Types.ObjectId(userId),
    });

    if (result.deletedCount === 0) {
      throw new Error('Notification not found');
    }

    return { success: true, message: 'Notification deleted' };
  }

  // Clear all notifications for a user
  async clearAllNotifications(userId: string) {
    await this.notificationModel.deleteMany({
      userId: new Types.ObjectId(userId),
    });

    return { success: true, message: 'All notifications cleared' };
  }

  // Create notification (for internal use by other services)
  async createNotification(
    userId: string,
    title: string,
    message: string,
    type: string,
    data?: any,
  ) {
    const notification = new this.notificationModel({
      userId: new Types.ObjectId(userId),
      title,
      message,
      type,
      data: data || {},
      isRead: false,
    });

    await notification.save();

    console.log(`🔔 Created notification for user ${userId}: ${title}`);

    return {
      id: notification._id.toString(),
      title: notification.title,
      message: notification.message,
      type: notification.type,
      timestamp: notification.createdAt,
      isRead: notification.isRead,
      data: notification.data,
    };
  }
}
