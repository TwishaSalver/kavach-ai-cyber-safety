#!/bin/bash

# Cloud Run Deployment Script for Cyber Safety Simulator
# Usage: ./deploy-cloud-run.sh

set -e

PROJECT_ID="cyber-agent-492615"
SERVICE_NAME="kavach-api"
REGION="us-central1"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo ""
echo "===================================="
echo "Cyber Safety Simulator - Cloud Run Deployment"
echo "===================================="
echo "Project ID: $PROJECT_ID"
echo "Service: $SERVICE_NAME"
echo "Region: $REGION"
echo "Image: $IMAGE_NAME"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "ERROR: gcloud CLI is not installed."
    echo "Please install the Google Cloud SDK from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed."
    echo "Please install Docker from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Authenticate with Google Cloud
echo ""
echo "[1/5] Authenticating with Google Cloud..."
gcloud auth login
gcloud config set project $PROJECT_ID

# Build the Docker image
echo ""
echo "[2/5] Building Docker image..."
docker build -t $IMAGE_NAME:latest .

# Push to Google Container Registry
echo ""
echo "[3/5] Pushing image to Google Container Registry..."
docker push $IMAGE_NAME:latest

# Deploy to Cloud Run
echo ""
echo "[4/5] Deploying to Cloud Run..."
echo "Please set your GEMINI_API_KEY secret when prompted or add it manually after deployment."
gcloud run deploy $SERVICE_NAME \
  --image=$IMAGE_NAME:latest \
  --platform=managed \
  --region=$REGION \
  --allow-unauthenticated \
  --set-env-vars="ENVIRONMENT=production"

# Get the service URL
echo ""
echo "[5/5] Retrieving service URL..."
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

echo ""
echo "===================================="
echo "DEPLOYMENT SUCCESSFUL!"
echo "===================================="
echo "Service URL: $SERVICE_URL"
echo ""
echo "Next Steps:"
echo "1. Add GEMINI_API_KEY to Cloud Run:"
echo "   gcloud run services update $SERVICE_NAME --region=$REGION \\"
echo "     --set-env-vars=\"GEMINI_API_KEY=your_api_key_here\""
echo "2. Visit the service URL in your browser"
echo "3. Monitor logs:"
echo "   gcloud run logs read $SERVICE_NAME --region=$REGION"
echo ""
