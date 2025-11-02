import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Delete,
  Body, 
  Param, 
  Query,
  UseGuards, 
  Request 
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { MessagesService } from './messages.service';

@ApiTags('messages')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('messages')
export class MessagesController {
  constructor(private messagesService: MessagesService) {}

  @Get('conversations')
  @ApiOperation({ summary: 'Get all conversations for current user' })
  async getConversations(@Request() req) {
    return this.messagesService.getUserConversations(req.user.userId);
  }

  @Post('conversations')
  @ApiOperation({ summary: 'Get or create conversation with another user' })
  async getOrCreateConversation(
    @Request() req,
    @Body() body: { participantId: string; jobId?: string },
  ) {
    return this.messagesService.getOrCreateConversation(
      req.user.userId,
      body.participantId,
      body.jobId,
    );
  }

  @Get('conversations/:conversationId/messages')
  @ApiOperation({ summary: 'Get messages for a conversation' })
  async getMessages(
    @Request() req,
    @Param('conversationId') conversationId: string,
  ) {
    return this.messagesService.getConversationMessages(
      conversationId,
      req.user.userId,
    );
  }

  @Post('conversations/:conversationId/messages')
  @ApiOperation({ summary: 'Send a message in a conversation' })
  async sendMessage(
    @Request() req,
    @Param('conversationId') conversationId: string,
    @Body() body: { text: string },
  ) {
    return this.messagesService.sendMessage(
      conversationId,
      req.user.userId,
      body.text,
    );
  }

  @Put('conversations/:conversationId/read')
  @ApiOperation({ summary: 'Mark conversation messages as read' })
  async markAsRead(
    @Request() req,
    @Param('conversationId') conversationId: string,
  ) {
    return this.messagesService.markAsRead(conversationId, req.user.userId);
  }

  @Delete('conversations/:conversationId')
  @ApiOperation({ summary: 'Delete (deactivate) a conversation' })
  async deleteConversation(
    @Request() req,
    @Param('conversationId') conversationId: string,
  ) {
    return this.messagesService.deleteConversation(
      conversationId,
      req.user.userId,
    );
  }
}
