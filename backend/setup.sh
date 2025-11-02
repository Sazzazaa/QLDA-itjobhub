#!/bin/bash

echo "========================================"
echo " ITJobHub Backend - Setup Script"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR] Node.js is not installed!${NC}"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

echo -e "${GREEN}[OK] Node.js is installed${NC}"
node --version

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}[ERROR] npm is not installed!${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] npm is installed${NC}"
npm --version
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}[INFO] Creating .env file from template...${NC}"
    cp .env.example .env
    echo ""
    echo -e "${YELLOW}[IMPORTANT] Please edit .env file and add your:${NC}"
    echo "  - GEMINI_API_KEY (Get from: https://makersuite.google.com/app/apikey)"
    echo "  - MONGODB_URI (if not using local MongoDB)"
    echo "  - JWT_SECRET (generate a random string)"
    echo ""
    read -p "Press enter to continue after editing .env file..."
else
    echo -e "${GREEN}[OK] .env file exists${NC}"
fi

# Install dependencies
echo ""
echo -e "${YELLOW}[INFO] Installing dependencies...${NC}"
npm install

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Failed to install dependencies!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}[OK] Dependencies installed successfully!${NC}"

# Create uploads directory
if [ ! -d "uploads" ]; then
    echo -e "${YELLOW}[INFO] Creating uploads directory...${NC}"
    mkdir uploads
    echo -e "${GREEN}[OK] Uploads directory created${NC}"
fi

echo ""
echo "========================================"
echo " Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Edit .env file with your API keys"
echo "  2. Start MongoDB (if using local)"
echo "  3. Run: npm run start:dev"
echo ""
echo "API will be available at:"
echo "  http://localhost:3000/api"
echo "  http://localhost:3000/api/docs (Swagger)"
echo ""
