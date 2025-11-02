import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Conversation, ConversationDocument } from '../../schemas/conversation.schema';
import { Message, MessageDocument, MessageStatus } from '../../schemas/message.schema';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class MessagesService {
  constructor(
    @InjectModel(Conversation.name) private conversationModel: Model<ConversationDocument>,
    @InjectModel(Message.name) private messageModel: Model<MessageDocument>,
    private notificationsService: NotificationsService,
  ) {}

  // Get all conversations for a user
  async getUserConversations(userId: string) {
    console.log('📩 MessagesService: Getting conversations for user:', userId);
    
    const conversations = await this.conversationModel
      .find({
        $or: [
          { user1Id: new Types.ObjectId(userId) },
          { user2Id: new Types.ObjectId(userId) },
        ],
        isActive: true,
      })
      .populate('user1Id', 'name email profileImage role companyName')
      .populate('user2Id', 'name email profileImage role companyName')
      .populate('jobId', 'title')
      .populate('lastMessageId')
      .sort({ lastActivity: -1 });

    console.log(`📩 MessagesService: Found ${conversations.length} conversations`);

    // Transform conversations to include participant info
    const result = conversations.map((conv) => {
      const user1 = conv.user1Id as any;
      const user2 = conv.user2Id as any;
      const isUser1 = user1._id.toString() === userId;
      const participant = isUser1 ? user2 : user1;
      
      const transformed = {
        id: conv._id.toString(),
        participantId: participant._id.toString(),
        participantName: participant.companyName || participant.name,
        participantRole: participant.role,
        participantAvatarUrl: participant.profileImage,
        jobId: conv.jobId ? (conv.jobId as any)._id.toString() : null,
        jobTitle: conv.jobId ? (conv.jobId as any).title : null,
        lastMessage: conv.lastMessageId,
        lastActivity: conv.lastActivity,
        isActive: conv.isActive,
        unreadCount: 0, // TODO: Calculate from messages
      };
      
      console.log(`  - Conversation with ${transformed.participantName} (${transformed.participantRole})`);
      return transformed;
    });
    
    return result;
  }

  // Get or create conversation between two users
  async getOrCreateConversation(user1Id: string, user2Id: string, jobId?: string) {
    console.log('📩 MessagesService: Getting/creating conversation between', user1Id, 'and', user2Id);
    
    // Ensure consistent ordering (smaller ID first)
    const [smallerId, largerId] = [user1Id, user2Id].sort();

    let conversation = await this.conversationModel.findOne({
      user1Id: new Types.ObjectId(smallerId),
      user2Id: new Types.ObjectId(largerId),
      ...(jobId ? { jobId: new Types.ObjectId(jobId) } : {}),
    });

    if (!conversation) {
      console.log('📩 MessagesService: Creating new conversation');
      conversation = new this.conversationModel({
        user1Id: new Types.ObjectId(smallerId),
        user2Id: new Types.ObjectId(largerId),
        jobId: jobId ? new Types.ObjectId(jobId) : null,
        lastActivity: new Date(),
      });
      await conversation.save();
    } else {
      console.log('📩 MessagesService: Found existing conversation:', conversation._id);
    }

    await conversation.populate('user1Id user2Id jobId');
    
    const user1 = conversation.user1Id as any;
    const user2 = conversation.user2Id as any;
    const isUser1 = user1._id.toString() === user1Id;
    const participant = isUser1 ? user2 : user1;

    return {
      id: conversation._id.toString(),
      participantId: participant._id.toString(),
      participantName: participant.companyName || participant.name,
      participantRole: participant.role,
      participantAvatarUrl: participant.profileImage,
      jobId: conversation.jobId ? (conversation.jobId as any)._id.toString() : null,
      jobTitle: conversation.jobId ? (conversation.jobId as any).title : null,
      lastActivity: conversation.lastActivity,
      isActive: conversation.isActive,
    };
  }

  // Get messages for a conversation
  async getConversationMessages(conversationId: string, userId: string) {
    // Verify user is part of conversation
    const conversation = await this.conversationModel.findOne({
      _id: new Types.ObjectId(conversationId),
      $or: [
        { user1Id: new Types.ObjectId(userId) },
        { user2Id: new Types.ObjectId(userId) },
      ],
    });

    if (!conversation) {
      throw new Error('Conversation not found or access denied');
    }

    const messages = await this.messageModel
      .find({ conversationId: new Types.ObjectId(conversationId) })
      .populate('senderId', 'name email profileImage role companyName')
      .sort({ createdAt: 1 });

    return messages.map((msg) => {
      const sender = msg.senderId as any;
      return {
        id: msg._id.toString(),
        conversationId: msg.conversationId.toString(),
        senderId: sender._id.toString(),
        senderName: sender.companyName || sender.name,
        senderAvatarUrl: sender.profileImage,
        text: msg.text,
        timestamp: (msg as any).createdAt,
        status: msg.status,
        isRead: msg.isRead,
      };
    });
  }

  // Send a message
  async sendMessage(conversationId: string, senderId: string, text: string) {
    // Verify user is part of conversation
    const conversation = await this.conversationModel.findOne({
      _id: new Types.ObjectId(conversationId),
      $or: [
        { user1Id: new Types.ObjectId(senderId) },
        { user2Id: new Types.ObjectId(senderId) },
      ],
    });

    if (!conversation) {
      throw new Error('Conversation not found or access denied');
    }

    const message = new this.messageModel({
      conversationId: new Types.ObjectId(conversationId),
      senderId: new Types.ObjectId(senderId),
      text,
      status: MessageStatus.SENT,
      isRead: false,
    });

    await message.save();

    // Update conversation's last activity and last message
    await this.conversationModel.findByIdAndUpdate(conversationId, {
      lastActivity: new Date(),
      lastMessageId: message._id,
    });

    await message.populate('senderId', 'name email profileImage role companyName');

    // Get recipient ID (the other user in conversation)
    const recipientId = conversation.user1Id.toString() === senderId 
      ? conversation.user2Id.toString() 
      : conversation.user1Id.toString();

    // Create notification for recipient
    const sender = message.senderId as any;
    const senderName = sender.companyName || sender.name;
    
    try {
      await this.notificationsService.createNotification(
        recipientId,
        'New Message',
        `${senderName}: ${text.substring(0, 50)}${text.length > 50 ? '...' : ''}`,
        'message',
        {
          conversationId: conversationId,
          messageId: message._id.toString(),
          senderId: senderId,
        }
      );
      console.log(`📩 MessagesService: Created notification for recipient ${recipientId}`);
    } catch (notifErr) {
      console.warn('Failed to create message notification:', notifErr);
    }

    const result = {
      id: message._id.toString(),
      conversationId: message.conversationId.toString(),
      senderId: sender._id.toString(),
      senderName: sender.companyName || sender.name,
      senderAvatarUrl: sender.profileImage,
      text: message.text,
      timestamp: (message as any).createdAt,
      status: message.status,
      isRead: message.isRead,
    };

    return result;
  }

  // Mark messages as read
  async markAsRead(conversationId: string, userId: string) {
    const conversation = await this.conversationModel.findOne({
      _id: new Types.ObjectId(conversationId),
      $or: [
        { user1Id: new Types.ObjectId(userId) },
        { user2Id: new Types.ObjectId(userId) },
      ],
    });

    if (!conversation) {
      throw new Error('Conversation not found or access denied');
    }

    await this.messageModel.updateMany(
      {
        conversationId: new Types.ObjectId(conversationId),
        senderId: { $ne: new Types.ObjectId(userId) },
        isRead: false,
      },
      {
        isRead: true,
        status: MessageStatus.READ,
        readBy: new Types.ObjectId(userId),
        readAt: new Date(),
      },
    );

    return { success: true };
  }

  // Delete conversation
  async deleteConversation(conversationId: string, userId: string) {
    const conversation = await this.conversationModel.findOne({
      _id: new Types.ObjectId(conversationId),
      $or: [
        { user1Id: new Types.ObjectId(userId) },
        { user2Id: new Types.ObjectId(userId) },
      ],
    });

    if (!conversation) {
      throw new Error('Conversation not found or access denied');
    }

    await this.conversationModel.findByIdAndUpdate(conversationId, {
      isActive: false,
    });

    return { success: true };
  }
}
