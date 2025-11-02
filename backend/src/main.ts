import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable CORS - Allow all origins for development
  app.enableCors({
    origin: true, // Allow all origins in dev
    credentials: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: 'Content-Type, Accept, Authorization',
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  // API prefix
  app.setGlobalPrefix('api');

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('ITJobHub API')
    .setDescription('IT Job Finder Application API with Gemini AI Integration')
    .setVersion('1.0')
    .addBearerAuth()
    .addServer('http://localhost:3000', 'Local Development')
    .addServer('http://10.0.2.2:3000', 'Android Emulator')
    .addTag('auth', 'Authentication endpoints')
    .addTag('jobs', 'Job management')
    .addTag('applications', 'Job applications')
    .addTag('candidates', 'Candidate profiles')
    .addTag('employers', 'Employer profiles')
    .addTag('interviews', 'Interview scheduling')
    .addTag('messages', 'Real-time messaging')
    .addTag('reviews', 'Reviews and ratings')
    .addTag('forum', 'Community forum')
    .addTag('badges', 'Badges and rankings')
    .addTag('notifications', 'Notifications')
    .addTag('ai', 'AI-powered features with Gemini')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true, // Keep auth tokens between refreshes
      tagsSorter: 'alpha',
      operationsSorter: 'alpha',
    },
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);

  console.log(`🚀 Application is running on: http://localhost:${port}`);
  console.log(`📚 API Documentation: http://localhost:${port}/api/docs`);
}

bootstrap();
