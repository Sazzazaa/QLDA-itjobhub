# 🚀 ITJobHub Backend API

A comprehensive NestJS backend with **Google Gemini AI integration** for the ITJobHub mobile application. This backend provides intelligent CV parsing, job matching, semantic search, and all core features for the IT job platform.

[![NestJS](https://img.shields.io/badge/NestJS-10.3-E0234E?logo=nestjs)](https://nestjs.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-3178C6?logo=typescript)](https://www.typescriptlang.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-8.1-47A248?logo=mongodb)](https://www.mongodb.com/)
[![Gemini AI](https://img.shields.io/badge/Gemini_AI-1.5-4285F4?logo=google)](https://ai.google.dev/)

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Database Setup](#-database-setup)
- [Running the Application](#-running-the-application)
- [API Documentation](#-api-documentation)
- [AI Features with Gemini](#-ai-features-with-gemini)
- [Project Structure](#-project-structure)
- [API Endpoints](#-api-endpoints)
- [Testing](#-testing)
- [Deployment](#-deployment)

## ✨ Features

### 🤖 AI-Powered Features (Google Gemini)
- **CV Parsing**: Intelligent extraction of structured data from PDF/DOC resumes
- **Job Matching**: Semantic matching between candidates and jobs with percentage scores
- **Personalized Recommendations**: AI-driven job suggestions based on candidate profile
- **Semantic Candidate Search**: Natural language search for employers
- **CV Improvement Suggestions**: AI-generated recommendations for CV enhancement
- **Interview Question Generation**: Auto-generate relevant interview questions
- **Market Trend Analysis**: Insights on IT job market trends

### 🔐 Authentication & Authorization
- JWT-based authentication
- Role-based access control (Candidate/Employer/Admin)
- Passport.js strategies (Local, JWT, Google OAuth, GitHub OAuth)
- Password hashing with bcrypt
- Email verification (planned)
- Social login integration (Google, GitHub, LinkedIn)

### 💼 Core Features
- **User Management**: Candidate and Employer profiles with comprehensive data
- **Job Management**: CRUD operations for job postings with advanced filters
- **Application System**: Job applications with timeline tracking
- **Interview Scheduling**: Calendar-based interview management
- **Real-time Messaging**: WebSocket-based chat (Socket.IO)
- **Reviews & Ratings**: Company and candidate reviews
- **Forum/Community**: Discussion posts and comments
- **Badges & Rankings**: Gamification with points and achievements
- **Notifications**: Real-time and push notifications
- **File Uploads**: CV and profile image handling with validation

### 📊 Additional Features
- Search and filtering with multiple criteria
- Pagination for large datasets
- Analytics and reporting
- Email notifications
- Activity logging

## 🛠 Tech Stack

### Backend Framework
- **NestJS** 10.3 - Progressive Node.js framework
- **TypeScript** 5.3 - Type-safe JavaScript
- **Express** - HTTP server

### Database
- **MongoDB** 8.1 - NoSQL database
- **Mongoose** 8.1 - ODM for MongoDB

### AI/ML
- **Google Gemini AI** (gemini-1.5-flash) - LLM for intelligent features
- **@google/generative-ai** 0.21 - Official Gemini SDK

### Authentication
- **Passport** - Authentication middleware
- **JWT** (jsonwebtoken) - Token-based auth
- **bcrypt** - Password hashing

### Real-time
- **Socket.IO** 4.6 - WebSocket for chat and notifications

### File Processing
- **Multer** - File upload handling
- **pdf-parse** - PDF text extraction
- **mammoth** - Word document processing

### Documentation
- **Swagger/OpenAPI** - Auto-generated API docs

### DevTools
- **ESLint** - Code linting
- **Prettier** - Code formatting
- **Jest** - Testing framework

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v18 or higher) - [Download](https://nodejs.org/)
- **npm** or **yarn** - Comes with Node.js
- **MongoDB** (v5.0 or higher) - [Install Guide](https://docs.mongodb.com/manual/installation/)
- **Google Gemini API Key** - [Get one here](https://ai.google.dev/)

Optional:
- **MongoDB Compass** - GUI for MongoDB
- **Postman** - API testing tool

## 🚀 Installation

### 1. Clone the Repository

```bash
cd backend
```

### 2. Install Dependencies

```bash
npm install
```

Or with yarn:

```bash
yarn install
```

### 3. Create Environment File

Copy the example environment file:

```bash
cp .env.example .env
```

### 4. Configure Environment Variables

Edit `.env` with your configuration (see [Configuration](#-configuration) section below).

## ⚙️ Configuration

Open `.env` and configure the following variables:

### Server Configuration
```env
PORT=3000
NODE_ENV=development
```

### MongoDB Connection
```env
MONGODB_URI=mongodb://localhost:27017/itjobhub
```

**For MongoDB Atlas (cloud):**
```env
MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/itjobhub?retryWrites=true&w=majority
```

### JWT Configuration
```env
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION=7d
```

**Important:** Generate a strong JWT secret:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Google Gemini AI API

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Add to `.env`:

```env
GEMINI_API_KEY=AIzaSy...your_actual_key_here
```

### OAuth Providers (Optional)

**Google OAuth:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project and enable Google+ API
3. Create OAuth 2.0 credentials

```env
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=http://localhost:3000/api/auth/google/callback
```

**GitHub OAuth:**
1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Create a new OAuth App

```env
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret
GITHUB_CALLBACK_URL=http://localhost:3000/api/auth/github/callback
```

### Firebase (for Push Notifications)
```env
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
```

### CORS Configuration
```env
FRONTEND_URL=http://localhost:3001
```

For Flutter app during development:
```env
FRONTEND_URL=*
```

## 🗄️ Database Setup

### Local MongoDB

1. **Install MongoDB** (if not already installed)
   - Windows: [Download Installer](https://www.mongodb.com/try/download/community)
   - Mac: `brew install mongodb-community`
   - Linux: Follow [official guide](https://docs.mongodb.com/manual/administration/install-on-linux/)

2. **Start MongoDB Service**
   
   ```bash
   # Windows
   net start MongoDB
   
   # Mac
   brew services start mongodb-community
   
   # Linux
   sudo systemctl start mongod
   ```

3. **Verify Connection**
   
   ```bash
   mongosh
   ```

### MongoDB Atlas (Cloud - Recommended)

1. Create free account at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a new cluster (free tier available)
3. Create a database user
4. Whitelist your IP address (or use `0.0.0.0/0` for development)
5. Get connection string and update `.env`

### Create Upload Directory

```bash
mkdir uploads
```

## 🏃 Running the Application

### Development Mode (with hot-reload)

```bash
npm run start:dev
```

### Production Mode

```bash
# Build the application
npm run build

# Start production server
npm run start:prod
```

### Debug Mode

```bash
npm run start:debug
```

The API will be available at:
- **API**: http://localhost:3000/api
- **Swagger Docs**: http://localhost:3000/api/docs

## 📚 API Documentation

### Swagger UI

Once the server is running, visit:

```
http://localhost:3000/api/docs
```

This provides an interactive API documentation where you can:
- View all available endpoints
- Test API calls directly
- See request/response schemas
- Understand authentication requirements

### API Overview

The API is organized into the following modules:

| Module | Base Route | Description |
|--------|-----------|-------------|
| **Auth** | `/api/auth` | Authentication & registration |
| **Users** | `/api/users` | User profile management |
| **Jobs** | `/api/jobs` | Job postings CRUD |
| **Applications** | `/api/applications` | Job applications |
| **Interviews** | `/api/interviews` | Interview scheduling |
| **Messages** | `/api/messages` | Real-time messaging |
| **Reviews** | `/api/reviews` | Reviews & ratings |
| **Forum** | `/api/forum` | Community posts |
| **Badges** | `/api/badges` | Achievements system |
| **Notifications** | `/api/notifications` | User notifications |
| **Files** | `/api/files` | File uploads (CV, images) |
| **AI** | `/api/ai` | AI-powered features |

## 🤖 AI Features with Gemini

### CV Parsing

**Endpoint:** `POST /api/files/cv/upload`

Upload a PDF or Word document, and Gemini AI will extract:
- Personal information (name, email, phone, location)
- Professional summary
- Skills and technologies
- Work experience with dates and descriptions
- Education history
- Projects and achievements
- Certifications
- Social links (GitHub, LinkedIn, Portfolio)

**Example:**
```bash
curl -X POST http://localhost:3000/api/files/cv/upload \
  -H "Authorization: Bearer <token>" \
  -F "file=@/path/to/resume.pdf"
```

### Job Matching

**Algorithm:** Uses Gemini AI to calculate semantic similarity between:
- Candidate skills vs. Job requirements
- Experience level matching
- Technology stack overlap

Returns a match percentage (0-100%) for each application.

### Personalized Recommendations

**Endpoint:** `GET /api/jobs/recommendations`

Gemini analyzes:
- User's skills and experience
- Job preferences (salary, location, type)
- Historical applications
- Job availability

Returns top 5-10 recommended jobs ranked by relevance.

### Semantic Candidate Search

**Feature:** Employers can search candidates using natural language queries like:
- "Senior React developer with 5+ years experience"
- "Full-stack engineer familiar with AWS and microservices"
- "Junior developer interested in machine learning"

Gemini processes the query and returns the most relevant candidates.

### CV Improvement Suggestions

**Endpoint:** `GET /api/ai/cv-suggestions?cvId=<id>`

Provides actionable suggestions:
- Add quantifiable achievements
- Improve technical skill descriptions
- Highlight relevant experience
- Format recommendations
- Missing sections

### Interview Question Generation

**Endpoint:** `GET /api/ai/interview-questions?jobTitle=<title>&techStack=<stack>&level=<level>`

Auto-generates relevant interview questions based on:
- Job title
- Required technologies
- Experience level

Returns 10 questions (mix of technical, behavioral, and problem-solving).

## 📁 Project Structure

```
backend/
├── src/
│   ├── main.ts                 # Application entry point
│   ├── app.module.ts           # Root module
│   ├── schemas/                # Mongoose schemas
│   │   ├── user.schema.ts
│   │   ├── job.schema.ts
│   │   ├── application.schema.ts
│   │   └── cv-data.schema.ts
│   └── modules/
│       ├── auth/               # Authentication module
│       │   ├── auth.module.ts
│       │   ├── auth.controller.ts
│       │   ├── auth.service.ts
│       │   ├── strategies/
│       │   │   ├── jwt.strategy.ts
│       │   │   └── local.strategy.ts
│       │   └── guards/
│       │       ├── jwt-auth.guard.ts
│       │       └── local-auth.guard.ts
│       ├── users/              # User management
│       │   ├── users.module.ts
│       │   ├── users.controller.ts
│       │   └── users.service.ts
│       ├── jobs/               # Job postings
│       │   ├── jobs.module.ts
│       │   ├── jobs.controller.ts
│       │   └── jobs.service.ts
│       ├── applications/       # Job applications
│       │   ├── applications.module.ts
│       │   ├── applications.controller.ts
│       │   └── applications.service.ts
│       ├── files/              # File uploads & CV parsing
│       │   ├── files.module.ts
│       │   ├── files.controller.ts
│       │   └── files.service.ts
│       ├── ai/                 # Gemini AI integration
│       │   ├── ai.module.ts
│       │   ├── ai.controller.ts
│       │   └── gemini.service.ts
│       ├── interviews/         # Interview scheduling
│       ├── messages/           # Real-time messaging
│       ├── reviews/            # Reviews & ratings
│       ├── forum/              # Community forum
│       ├── badges/             # Badges & rankings
│       └── notifications/      # Notifications
├── uploads/                    # Uploaded files directory
├── test/                       # Test files
├── .env                        # Environment variables
├── .env.example                # Environment template
├── package.json                # Dependencies
├── tsconfig.json               # TypeScript config
├── nest-cli.json               # NestJS CLI config
└── README.md                   # This file
```

## 📡 API Endpoints

### Authentication

```http
POST   /api/auth/register       # Register new user
POST   /api/auth/login          # Login with credentials
POST   /api/auth/google         # Google OAuth login
POST   /api/auth/github         # GitHub OAuth login
```

### Users

```http
GET    /api/users/profile       # Get current user profile
PUT    /api/users/profile       # Update profile
POST   /api/users/profile/avatar  # Upload avatar
PUT    /api/users/profile/skills # Update skills
POST   /api/users/profile/projects # Add project
PUT    /api/users/profile/projects/:id # Update project
GET    /api/users/:id           # Get user by ID
```

### Jobs

```http
GET    /api/jobs                # Get all jobs (with filters)
GET    /api/jobs/recommendations # Get personalized recommendations
GET    /api/jobs/:id            # Get job by ID
POST   /api/jobs                # Create job (employer)
PUT    /api/jobs/:id            # Update job
DELETE /api/jobs/:id            # Delete job
POST   /api/jobs/:id/increment-views # Increment views
```

### Applications

```http
GET    /api/applications        # Get all applications
GET    /api/applications/:id    # Get application by ID
POST   /api/applications        # Submit application
PUT    /api/applications/:id/status # Update status
PUT    /api/applications/:id/withdraw # Withdraw application
```

### Files & CV Parsing

```http
POST   /api/files/cv/upload     # Upload & parse CV
GET    /api/files/cv/:id/status # Get parsing status
GET    /api/files/cv/:id/parsed # Get parsed data
```

### AI Features

```http
GET    /api/ai/cv-suggestions   # Get CV improvement suggestions
GET    /api/ai/interview-questions # Generate interview questions
GET    /api/ai/job-trends       # Analyze job market trends
```

## 🧪 Testing

### Run Unit Tests

```bash
npm run test
```

### Run E2E Tests

```bash
npm run test:e2e
```

### Test Coverage

```bash
npm run test:cov
```

### Manual API Testing

Use **Postman** or **Thunder Client** (VS Code extension):

1. Import Swagger/OpenAPI spec from http://localhost:3000/api/docs-json
2. Set environment variables
3. Test endpoints

**Example cURL:**

```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"candidate@test.com","password":"test123","name":"John Doe","role":"candidate"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"candidate@test.com","password":"test123"}'

# Get Profile (with token)
curl -X GET http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer <your_jwt_token>"
```

## 🚢 Deployment

### Environment Setup

For production, ensure:
- Set `NODE_ENV=production`
- Use strong `JWT_SECRET`
- Use MongoDB Atlas or production MongoDB
- Enable HTTPS
- Configure proper CORS
- Set up proper logging
- Use environment variables for all secrets

### Deploy to Heroku

```bash
# Install Heroku CLI
# Login
heroku login

# Create app
heroku create itjobhub-backend

# Set environment variables
heroku config:set MONGODB_URI=<your_mongodb_atlas_uri>
heroku config:set JWT_SECRET=<your_secret>
heroku config:set GEMINI_API_KEY=<your_key>

# Deploy
git push heroku main
```

### Deploy to AWS/DigitalOcean

1. Build the application: `npm run build`
2. Copy `dist/` folder and `package.json` to server
3. Install dependencies: `npm install --production`
4. Use PM2 for process management: `pm2 start dist/main.js`
5. Configure Nginx as reverse proxy
6. Set up SSL with Let's Encrypt

### Docker Deployment

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY dist ./dist
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

```bash
docker build -t itjobhub-backend .
docker run -p 3000:3000 --env-file .env itjobhub-backend
```

## 🔧 Troubleshooting

### MongoDB Connection Issues

```
Error: connect ECONNREFUSED 127.0.0.1:27017
```

**Solution:** Ensure MongoDB is running:
```bash
# Check status
mongosh

# Start service (if stopped)
sudo systemctl start mongod  # Linux
brew services start mongodb-community  # Mac
```

### Gemini API Errors

```
Error: API key not found
```

**Solution:** 
1. Verify `GEMINI_API_KEY` is set in `.env`
2. Check API key is valid at https://makersuite.google.com/app/apikey
3. Ensure no quota limits reached

### TypeScript Compilation Errors

```bash
# Clear build cache
rm -rf dist/

# Rebuild
npm run build
```

### Port Already in Use

```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution:**
```bash
# Find process using port 3000
# Windows
netstat -ano | findstr :3000

# Mac/Linux
lsof -i :3000

# Kill the process or change PORT in .env
```

## 📞 Support

For issues, questions, or contributions:

- **GitHub Issues**: [Create an issue](https://github.com/your-repo/issues)
- **Email**: support@itjobhub.com
- **Documentation**: [Full API Docs](http://localhost:3000/api/docs)

## 📄 License

This project is licensed under the MIT License.

---

## 🎉 Next Steps

1. ✅ Install dependencies: `npm install`
2. ✅ Configure `.env` file
3. ✅ Start MongoDB
4. ✅ Get Gemini API key
5. ✅ Run the app: `npm run start:dev`
6. ✅ Visit API docs: http://localhost:3000/api/docs
7. ✅ Test CV upload with Gemini AI
8. ✅ Integrate with Flutter frontend
9. ✅ Deploy to production

**Happy Coding! 🚀**
