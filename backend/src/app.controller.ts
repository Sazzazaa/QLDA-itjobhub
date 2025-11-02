import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('health')
@Controller()
export class AppController {
  @Get()
  @ApiOperation({ summary: 'API root - Health check' })
  getRoot() {
    return {
      message: 'ITJobHub API is running',
      version: '1.0.0',
      docs: '/api/docs',
      endpoints: {
        auth: '/api/auth',
        users: '/api/users',
        jobs: '/api/jobs',
        applications: '/api/applications',
        files: '/api/files',
        ai: '/api/ai',
      },
    };
  }

  @Get('health')
  @ApiOperation({ summary: 'Health check endpoint' })
  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    };
  }
}
