#!/bin/bash
# =============================================================================
# Build Docker Image, Push to ACR, Update Container App
# =============================================================================

set -euo pipefail

TF_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$TF_DIR/../.." && pwd)"

# Get values from Terraform outputs
ACR_NAME="$(terraform -chdir="$TF_DIR" output -raw azure_container_registry_name)"
ACR_LOGIN_SERVER="$(terraform -chdir="$TF_DIR" output -raw azure_container_registry_endpoint)"
CONTAINER_APP_NAME="$(terraform -chdir="$TF_DIR" output -raw backend_container_app_name)"
RESOURCE_GROUP="$(terraform -chdir="$TF_DIR" output -raw azure_resource_group)"
IMAGE_TAG="${ACR_LOGIN_SERVER}/backend:$(git -C "$PROJECT_ROOT" rev-parse --short HEAD)"

echo "Building and deploying to: $IMAGE_TAG"

# Step 1: Build frontend
echo "Building frontend..."
cd "$PROJECT_ROOT/app/frontend"
npm install
npm run build
cd "$PROJECT_ROOT"

# Step 2: Login to ACR
echo "Logging into ACR: $ACR_NAME"
az acr login --name "$ACR_NAME"

# Step 3: Build Docker image
echo "Building Docker image..."
docker build -t "$IMAGE_TAG" "$PROJECT_ROOT/app/backend"

# Step 4: Push to ACR
echo "Pushing to ACR..."
docker push "$IMAGE_TAG"

# Step 5: Update Container App
echo "Updating Container App: $CONTAINER_APP_NAME"
az containerapp update \
  --name "$CONTAINER_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --image "$IMAGE_TAG"

echo "Deploy complete! Image: $IMAGE_TAG"
