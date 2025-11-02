import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, MinLength, IsIn } from 'class-validator';

export class RegisterDto {
  @ApiProperty({
    description: 'Email address of the user',
    example: 'john.doe@example.com',
    type: String,
  })
  @IsEmail({}, { message: 'Please provide a valid email address' })
  @IsNotEmpty({ message: 'Email is required' })
  email: string;

  @ApiProperty({
    description: 'Password (minimum 6 characters)',
    example: 'Password123!',
    type: String,
    minLength: 6,
  })
  @IsNotEmpty({ message: 'Password is required' })
  @MinLength(6, { message: 'Password must be at least 6 characters long' })
  password: string;

  @ApiProperty({
    description: 'Full name of the user',
    example: 'John Doe',
    type: String,
  })
  @IsNotEmpty({ message: 'Name is required' })
  name: string;

  @ApiProperty({
    description: 'User role: candidate or employer',
    example: 'candidate',
    enum: ['candidate', 'employer'],
    type: String,
  })
  @IsNotEmpty({ message: 'Role is required' })
  @IsIn(['candidate', 'employer'], {
    message: 'Role must be either candidate or employer',
  })
  role: 'candidate' | 'employer';
}
