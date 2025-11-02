import {
  Controller,
  Get,
  Put,
  Body,
  Param,
  UseGuards,
  Request,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UsersService } from './users.service';

@ApiTags('candidates', 'employers')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Get current user profile' })
  async getProfile(@Request() req) {
    return this.usersService.findById(req.user.userId);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Update user profile' })
  async updateProfile(@Request() req, @Body() updateDto: any) {
    return this.usersService.updateProfile(req.user.userId, updateDto);
  }

  @Post('profile/avatar')
  @ApiOperation({ summary: 'Upload profile avatar' })
  @UseInterceptors(FileInterceptor('avatar'))
  async uploadAvatar(
    @Request() req,
    @UploadedFile() file: Express.Multer.File,
  ) {
    // File upload logic would go here
    return { message: 'Avatar uploaded successfully', file: file.filename };
  }

  @Put('profile/skills')
  @ApiOperation({ summary: 'Update user skills' })
  async updateSkills(@Request() req, @Body() body: { skills: string[] }) {
    return this.usersService.updateSkills(req.user.userId, body.skills);
  }

  @Post('profile/projects')
  @ApiOperation({ summary: 'Add experience project' })
  async addProject(@Request() req, @Body() project: any) {
    return this.usersService.addProject(req.user.userId, project);
  }

  @Put('profile/projects/:projectId')
  @ApiOperation({ summary: 'Update experience project' })
  async updateProject(
    @Request() req,
    @Param('projectId') projectId: string,
    @Body() project: any,
  ) {
    return this.usersService.updateProject(req.user.userId, projectId, project);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  async getUserById(@Param('id') id: string) {
    return this.usersService.findById(id);
  }
}
