@echo off
REM Cloud Run Deployment Script for Cyber Safety Simulator
REM Usage: deploy-cloud-run.bat

setlocal enabledelayedexpansion

set PROJECT_ID=cyber-agent-492615
set SERVICE_NAME=kavach-api
set REGION=us-central1
set IMAGE_NAME=gcr.io/%PROJECT_ID%/%SERVICE_NAME%

echo.
echo ====================================
echo Cyber Safety Simulator - Cloud Run Deployment
echo ====================================
echo Project ID: %PROJECT_ID%
echo Service: %SERVICE_NAME%
echo Region: %REGION%
echo Image: %IMAGE_NAME%
echo.

REM Check if gcloud is installed
gcloud --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: gcloud CLI is not installed.
    echo Please install the Google Cloud SDK from: https://cloud.google.com/sdk/docs/install
    exit /b 1
)

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed.
    echo Please install Docker from: https://www.docker.com/products/docker-desktop
    exit /b 1
)

REM Authenticate with Google Cloud
echo.
echo [1/5] Authenticating with Google Cloud...
call gcloud auth login
call gcloud config set project %PROJECT_ID%

REM Build the Docker image
echo.
echo [2/5] Building Docker image...
call docker build -t %IMAGE_NAME%:latest .
if errorlevel 1 (
    echo ERROR: Docker build failed.
    exit /b 1
)

REM Push to Google Container Registry
echo.
echo [3/5] Pushing image to Google Container Registry...
call docker push %IMAGE_NAME%:latest
if errorlevel 1 (
    echo ERROR: Docker push failed.
    exit /b 1
)

REM Deploy to Cloud Run
echo.
echo [4/5] Deploying to Cloud Run...
echo Please set your GEMINI_API_KEY secret when prompted or add it manually after deployment.
call gcloud run deploy %SERVICE_NAME% ^
  --image=%IMAGE_NAME%:latest ^
  --platform=managed ^
  --region=%REGION% ^
  --allow-unauthenticated ^
  --set-env-vars="ENVIRONMENT=production"

if errorlevel 1 (
    echo ERROR: Cloud Run deployment failed.
    exit /b 1
)

REM Get the service URL
echo.
echo [5/5] Retrieving service URL...
for /f "delims=" %%i in ('gcloud run services describe %SERVICE_NAME% --region=%REGION% --format="value(status.url)"') do (
    set SERVICE_URL=%%i
)

echo.
echo ====================================
echo DEPLOYMENT SUCCESSFUL!
echo ====================================
echo Service URL: %SERVICE_URL%
echo.
echo Next Steps:
echo 1. Add GEMINI_API_KEY to Cloud Run secrets:
echo    gcloud run services update %SERVICE_NAME% --region=%REGION% ^
echo      --set-env-vars="GEMINI_API_KEY=your_api_key_here"
echo 2. Visit the service URL in your browser
echo 3. Monitor logs: gcloud run logs read %SERVICE_NAME% --region=%REGION%
echo.
pause
