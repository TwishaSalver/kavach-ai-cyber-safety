# =====================================================
# Google Cloud Run Deployment - Step by Step Guide
# Project: cyber-agent-492615
# =====================================================

## PHASE 1: PREREQUISITE SETUP (One-time setup)

### Step 1: Install Required Tools

#### A. Install Docker Desktop
- Visit: https://www.docker.com/products/docker-desktop
- Download and install for your OS (Windows/Mac/Linux)
- Verify installation:
  ```
  docker --version
  ```

#### B. Google Cloud SDK (Already Installed ✓)
- You have gcloud CLI v565.0.0 installed
- Verify: `gcloud --version`

#### C. Git (for version control)
- Visit: https://git-scm.com/download/win (or your OS)
- Verify: `git --version`

### Step 2: Authenticate with Google Cloud

Already done! But verify with:
```
gcloud config list
gcloud auth list
```

You should see:
- project = cyber-agent-492615 ✓
- account = twishasalver1234@gmail.com ✓

## PHASE 2: PREPARE THE APPLICATION

### Step 3: Create Environment Configuration

```powershell
cd c:\Users\Twisha Salver\OneDrive\Desktop\Cyber_Safety_Simulator-main\kavach_backend

# Copy example to .env
Copy-Item .env.example .env

# Edit .env and add your GEMINI_API_KEY
# Get API key from: https://ai.google.dev
# Open .env and replace:
# GEMINI_API_KEY=your_gemini_api_key_here
```

### Step 4: Verify File Integration

All integration files are properly configured:
✓ Dockerfile - Multi-stage build
✓ .dockerignore - Optimized layers
✓ kavach_backend/main.py - Uses 0.0.0.0:8080
✓ kavach_backend/agents/requirements.txt - Cleaned up
✓ kavach_frontend/package.json - All deps installed

## PHASE 3: LOCAL TESTING (OPTIONAL but RECOMMENDED)

### Step 5: Test Locally with Docker

Once Docker Desktop is running:

```powershell
cd c:\Users\Twisha Salver\OneDrive\Desktop\Cyber_Safety_Simulator-main

# Build the Docker image locally
docker build -t kavach-api:latest .

# Run the container
docker run -p 8080:8080 `
  -e GEMINI_API_KEY="your_actual_api_key_here" `
  -e ENVIRONMENT="development" `
  kavach-api:latest

# Test in browser:
# http://localhost:8080
# http://localhost:8080/health (should return {"success":true,...})
```

## PHASE 4: DEPLOY TO GOOGLE CLOUD RUN

### Step 6: Enable Required Google Cloud APIs

```powershell
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### Step 7: Deploy to Cloud Run

#### Option A: Automated Deployment (PowerShell)

```powershell
cd c:\Users\Twisha Salver\OneDrive\Desktop\Cyber_Safety_Simulator-main

# Run the deployment script
.\deploy-cloud-run.bat
```

#### Option B: Manual Step-by-Step Deployment

```powershell
# Set variables
$PROJECT_ID = "cyber-agent-492615"
$SERVICE_NAME = "kavach-api"
$REGION = "us-central1"
$IMAGE_NAME = "gcr.io/$PROJECT_ID/$SERVICE_NAME"

# Build Docker image
docker build -t $IMAGE_NAME`:latest .

# Push to Google Container Registry
docker push $IMAGE_NAME`:latest

# Deploy to Cloud Run
gcloud run deploy $SERVICE_NAME `
  --image=$IMAGE_NAME`:latest `
  --platform=managed `
  --region=$REGION `
  --allow-unauthenticated `
  --set-env-vars="ENVIRONMENT=production"

# Get service URL (copy this!)
gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)"
```

### Step 8: Configure GEMINI_API_KEY as Secret

```powershell
$PROJECT_ID = "cyber-agent-492615"
$SERVICE_NAME = "kavach-api"
$REGION = "us-central1"

gcloud run services update $SERVICE_NAME `
  --region=$REGION `
  --set-env-vars="GEMINI_API_KEY=your_api_key_here"
```

## PHASE 5: VERIFICATION & TESTING

### Step 9: Verify Deployment

```powershell
# Get the service URL
$SERVICE_URL = gcloud run services describe kavach-api --region=us-central1 --format="value(status.url)"

# Test health endpoint
curl "$SERVICE_URL/health"

# Should return:
# {"success":true,"data":{"status":"ok"},"message":"Server healthy"}
```

### Step 10: Test Scam Detection API

```powershell
$SERVICE_URL = "https://your-service-url"  # Replace with actual URL

# Test detect endpoint
curl -X POST "$SERVICE_URL/detect" `
  -H "Content-Type: application/json" `
  -d '{\"text\": \"You have won a lottery prize! Click here to claim.\"}'
```

## MONITORING & MAINTENANCE

### View Live Logs

```powershell
gcloud run logs read kavach-api --region=us-central1 --follow
```

### Check Service Status

```powershell
gcloud run services describe kavach-api --region=us-central1
```

### Update Service (After Code Changes)

```powershell
# After modifying code:
docker build -t gcr.io/cyber-agent-492615/kavach-api:latest .
docker push gcr.io/cyber-agent-492615/kavach-api:latest
gcloud run deploy kavach-api --image=gcr.io/cyber-agent-492615/kavach-api:latest --region=us-central1
```

## TROUBLESHOOTING

### Issue: "docker: The term 'docker' is not recognized"
- Solution: Install Docker Desktop from https://www.docker.com/products/docker-desktop

### Issue: "Authentication required"
- Solution: Run `gcloud auth login` and follow browser prompt

### Issue: "Cloud Build could not resolve source in external location"
- Solution: Ensure Dockerfile and all source files are in the project root

### Issue: "502 Bad Gateway"
- Solution: Check GEMINI_API_KEY is set correctly
- Run: `gcloud run logs read kavach-api --region=us-central1`

### Issue: Frontend not showing
- Solution: Verify frontend was built and static folder is properly mounted
- Check: `gcloud run logs read kavach-api --region=us-central1 --limit=50`

## CLEANUP (If needed)

```powershell
# Delete the Cloud Run service
gcloud run services delete kavach-api --region=us-central1

# Delete container image
gcloud container images delete gcr.io/cyber-agent-492615/kavach-api

# Remove local Docker image
docker rmi gcr.io/cyber-agent-492615/kavach-api:latest
```

## QUICK REFERENCE

| Task | Command |
|------|---------|
| Deploy | `.\deploy-cloud-run.bat` |
| View logs | `gcloud run logs read kavach-api --region=us-central1 --follow` |
| Get URL | `gcloud run services describe kavach-api --region=us-central1 --format="value(status.url)"` |
| Update service | `gcloud run deploy kavach-api --image=gcr.io/cyber-agent-492615/kavach-api:latest --region=us-central1` |
| Set API key | `gcloud run services update kavach-api --region=us-central1 --set-env-vars="GEMINI_API_KEY=key_here"` |
| Delete service | `gcloud run services delete kavach-api --region=us-central1` |

---

**Status Check:**
✓ gcloud CLI installed
✓ Project configured (cyber-agent-492615)
✓ Authentication setup
⏳ Waiting for Docker installation
⏳ Ready for deployment

Next step: Install Docker Desktop, then run deployment script!
