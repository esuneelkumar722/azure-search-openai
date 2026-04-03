#!/bin/bash
# =============================================================================
# Full Deployment Script (replaces azd up)
# For local development. In production, use the Azure DevOps pipeline.
# =============================================================================

set -euo pipefail

ENV="${1:-dev}"
TF_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$TF_DIR/../.." && pwd)"

echo "=== Deploying environment: $ENV ==="

# Step 1: Terraform apply
echo ""
echo "--- Step 1: Terraform Apply ---"
cd "$TF_DIR"
terraform init
terraform apply -var-file="environments/${ENV}.tfvars" -auto-approve

# Step 2: Export Terraform outputs as environment variables
echo ""
echo "--- Step 2: Loading outputs ---"
eval "$(terraform output -json | jq -r 'to_entries[] | "export \(.key | ascii_upcase)=\(.value.value)"')"

# Step 3: Build and push Docker image
echo ""
echo "--- Step 3: Docker build & push ---"
"$TF_DIR/scripts/docker-build-push.sh"

# Step 4: Run document ingestion
echo ""
echo "--- Step 4: Document ingestion ---"
"$TF_DIR/scripts/run-prepdocs.sh"

echo ""
echo "=== Deployment complete ==="
echo "Application URL: $(terraform output -raw backend_uri)"
