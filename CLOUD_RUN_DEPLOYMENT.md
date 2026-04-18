# Cyber Safety Simulator - Cloud Run Deployment Guide

## Prerequisites

Before deploying to Cloud Run, ensure you have:

1. **Google Cloud Account** with:
   - Active billing enabled
   - Project ID: `cyber-agent-492615`
   
2. **Local Tools Installed**:
   - Google Cloud SDK (gcloud CLI)
   - Docker Desktop
   - Git

3. **API Keys**:
   - Google Gemini API key (from https://ai.google.dev)

## Setup Instructions

### 1. Install Google Cloud SDK

**Windows:**
- Download from: https://cloud.google.com/sdk/docs/install-gcloud-on-windows
- Run the installer
- Verify: `gcloud --version`

**Mac/Linux:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

### 2. Install Docker

Download and install from: https://www.docker.com/products/docker-desktop

### 3. Create .env File (Local Development)

```bash
cp kavach_backend/.env.example kavach_backend/.env
# Edit kavach_backend/.env and add your GEMINI_API_KEY
```

## Local Testing

### Build and Test Locally

```bash
# Build frontend
cd kavach_frontend
npm install
npm run build

# Copy built files to backend
cd ..
# Windows:
xcopy kavach_frontend\dist kavach_backend\static /E /I /Y
# Mac/Linux:
cp -r kavach_frontend/dist/* kavach_backend/static/

# Install backend dependencies
cd kavach_backend
pip install -r requirements.txt
pip install -r agents/requirements.txt

# Run the application
python main.py
```

Then visit: http://localhost:8000

### Using Docker Locally

```bash
# Build Docker image locally
docker build -t kavach-api:latest .

# Run container
docker run -p 8080:8080 \
  -e GEMINI_API_KEY="your_api_key_here" \
  -e ENVIRONMENT="development" \
  kavach-api:latest
```

Then visit: http://localhost:8080

## Deploy to Google Cloud Run

### Option 1: Automated Deployment (Recommended)

**Windows:**
```bash
deploy-cloud-run.bat
```

**Mac/Linux:**
```bash
chmod +x deploy-cloud-run.sh
./deploy-cloud-run.sh
```

### Option 2: Manual Deployment

```bash
# Set your project
gcloud config set project cyber-agent-492615

# Authenticate
gcloud auth login

# Build and push image
docker build -t gcr.io/cyber-agent-492615/kavach-api:latest .
docker push gcr.io/cyber-agent-492615/kavach-api:latest

# Deploy to Cloud Run
gcloud run deploy kavach-api \
  --image=gcr.io/cyber-agent-492615/kavach-api:latest \
  --platform=managed \
  --region=us-central1 \
  --allow-unauthenticated \
  --set-env-vars="ENVIRONMENT=production"

# Get the service URL
gcloud run services describe kavach-api --region=us-central1 --format="value(status.url)"
```

## Configure Secrets (After Deployment)

```bash
gcloud run services update kavach-api \
  --region=us-central1 \
  --set-env-vars="GEMINI_API_KEY=your_api_key_here"
```

## Verify Deployment

```bash
# Check service status
gcloud run services describe kavach-api --region=us-central1

# View logs (last 50 lines)
gcloud run logs read kavach-api --region=us-central1 --limit=50

# Test health endpoint
curl https://<YOUR_SERVICE_URL>/health
```

## Project Structure

```
Cyber_Safety_Simulator-main/
├── kavach_backend/          # FastAPI backend
│   ├── main.py             # Main FastAPI application
│   ├── database.py         # SQLite database layer
│   ├── models.py           # Data models
│   ├── schemas.py          # Pydantic schemas
│   ├── requirements.txt    # Python dependencies
│   ├── agents/             # AI agents for detection
│   │   ├── agent_manager.py
│   │   ├── agent_prompts.py
│   │   └── requirements.txt
│   └── static/             # Built frontend (auto-populated)
├── kavach_frontend/         # React + TypeScript + Vite frontend
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   └── vite.config.ts
├── Dockerfile              # Multi-stage Docker build
├── deploy-cloud-run.bat   # Windows deployment script
├── deploy-cloud-run.sh    # Unix deployment script
└── README.md
```

## API Endpoints

### Health Check
```bash
GET /health
```

### Scam Detection
```bash
POST /detect
Content-Type: application/json

{"text": "Your message to analyze"}
```

### Explain Indicators
```bash
POST /explain
Content-Type: application/json

{"text": "Your message to analyze"}
```

### Get Actions
```bash
POST /action
Content-Type: application/json

{"text": "Your message to analyze"}
```

### Generate Simulation
```bash
POST /simulate
```

### View History
```bash
GET /history
```

## Troubleshooting

### Docker Build Fails
- Ensure both frontend and backend are properly structured
- Check that all required files exist
- Verify Node.js and Python versions in Dockerfile match your system

### Cloud Run Deployment Fails
- Verify gcloud authentication: `gcloud auth list`
- Check project ID: `gcloud config get-value project`
- View deployment logs: `gcloud run logs read kavach-api --region=us-central1 --limit=100`

### API Returns 500 Errors
- Check that GEMINI_API_KEY is properly set
- View logs: `gcloud run logs read kavach-api --region=us-central1`
- Ensure the key has proper permissions in Google AI Studio

### Frontend Not Loading
- Check that frontend was built and copied to static folder
- Verify StaticFiles mount in main.py
- Check browser console for network errors

## Environment Variables

| Variable | Required | Default | Notes |
|----------|----------|---------|-------|
| GEMINI_API_KEY | Yes | N/A | Google Gemini API key |
| PORT | No | 8080 | Server port (Cloud Run uses 8080) |
| ENVIRONMENT | No | development | Set to 'production' for Cloud Run |

## Support & Monitoring

### View Application Logs
```bash
gcloud run logs read kavach-api --region=us-central1 --follow
```

### Check Resource Usage
```bash
gcloud run metrics list kavach-api --region=us-central1
```

### Update Service (after code changes)
```bash
# Rebuild and redeploy
docker build -t gcr.io/cyber-agent-492615/kavach-api:latest .
docker push gcr.io/cyber-agent-492615/kavach-api:latest
gcloud run deploy kavach-api \
  --image=gcr.io/cyber-agent-492615/kavach-api:latest \
  --region=us-central1
```

## Security Notes

1. **Never commit .env files** - use .env.example as template
2. **Use Cloud Run Secrets** for sensitive data like API keys
3. **Enable IAM authentication** if backend should be private
4. **Monitor logs regularly** for suspicious activity
5. **Keep dependencies updated** for security patches
