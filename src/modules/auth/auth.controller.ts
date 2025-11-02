import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBody } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { RegisterDto, LoginDto } from './dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  @ApiOperation({ 
    summary: 'Register a new user',
    description: 'Create a new account as either a candidate or employer. After registration, use the login endpoint to get access token.',
  })
  @ApiResponse({ 
    status: 201, 
    description: 'User successfully registered',
    schema: {
      example: {
        message: 'User registered successfully',
        user: {
          id: '507f1f77bcf86cd799439011',
          email: 'john.doe@example.com',
          name: 'John Doe',
          role: 'candidate',
        },
      },
    },
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Invalid input or email already exists',
  })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @UseGuards(LocalAuthGuard)
  @Post('login')
  @ApiOperation({ 
    summary: 'Login with email and password',
    description: 'Authenticate user and receive JWT access token.',
  })
  @ApiBody({ type: LoginDto })
  @ApiResponse({ 
    status: 200, 
    description: 'Login successful',
    schema: {
      example: {
        access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        user: {
          _id: '507f1f77bcf86cd799439011',
          email: 'john.doe@example.com',
          name: 'John Doe',
          role: 'candidate',
        },
      },
    },
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Invalid credentials',
  })
  async login(@Request() req) {
    return this.authService.login(req.user);
  }
}
