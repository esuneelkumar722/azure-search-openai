#!/bin/bash
# =============================================================================
# Setup Workload Identity Federation (WIF)
# Run ONCE to configure passwordless authentication between Azure DevOps and Azure.
#
# Prerequisites:
# - Azure CLI logged in with sufficient permissions
# - Azure DevOps organization and project created
# =============================================================================

set -euo pipefail

# Configuration — update these for your environment
AZURE_DEVOPS_ORG="${1:?Usage: $0 <devops-org> <devops-project> <subscription-id>}"
AZURE_DEVOPS_PROJECT="${2:?Usage: $0 <devops-org> <devops-project> <subscription-id>}"
SUBSCRIPTION_ID="${3:?Usage: $0 <devops-org> <devops-project> <subscription-id>}"
APP_NAME="sp-terraform-${AZURE_DEVOPS_PROJECT}"

echo "=== Setting up Workload Identity Federation ==="
echo "  Azure DevOps Org: $AZURE_DEVOPS_ORG"
echo "  Project: $AZURE_DEVOPS_PROJECT"
echo "  Subscription: $SUBSCRIPTION_ID"
echo ""

# Step 1: Create App Registration / Service Principal
echo "Step 1: Creating App Registration..."
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
SP_ID=$(az ad sp create --id "$APP_ID" --query id -o tsv)

echo "  App ID: $APP_ID"
echo "  SP Object ID: $SP_ID"

# Step 2: Create Federated Credential for Azure DevOps
echo ""
echo "Step 2: Creating Federated Credential..."
ISSUER="https://vstoken.dev.azure.com/${AZURE_DEVOPS_ORG}"
SUBJECT="sc://${AZURE_DEVOPS_ORG}/${AZURE_DEVOPS_PROJECT}/terraform-wif"

az ad app federated-credential create \
  --id "$APP_ID" \
  --parameters "{
    \"name\": \"ado-wif-${AZURE_DEVOPS_PROJECT}\",
    \"issuer\": \"${ISSUER}\",
    \"subject\": \"${SUBJECT}\",
    \"description\": \"WIF for Azure DevOps pipeline\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"

# Step 3: Assign roles to the Service Principal
echo ""
echo "Step 3: Assigning roles..."

# Contributor (to create/manage resources)
az role assignment create \
  --assignee "$APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --output none

# User Access Administrator (to create RBAC role assignments)
az role assignment create \
  --assignee "$APP_ID" \
  --role "User Access Administrator" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --output none

# Storage Blob Data Owner (for Terraform state)
az role assignment create \
  --assignee "$APP_ID" \
  --role "Storage Blob Data Owner" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-terraform-state" \
  --output none

echo ""
echo "=== WIF Setup Complete ==="
echo ""
echo "Now create a Service Connection in Azure DevOps:"
echo "  1. Go to Project Settings > Service Connections > New"
echo "  2. Choose 'Azure Resource Manager'"
echo "  3. Choose 'Workload Identity federation (manual)'"
echo "  4. Fill in:"
echo "     - Subscription ID: $SUBSCRIPTION_ID"
echo "     - Service Principal ID: $APP_ID"
echo "     - Tenant ID: $(az account show --query tenantId -o tsv)"
echo "     - Issuer: $ISSUER"
echo "     - Subject: $SUBJECT"
echo "  5. Name it: terraform-wif"
echo ""
echo "Then create a Variable Group 'terraform-dev' with:"
echo "  AZURE_SERVICE_CONNECTION = terraform-wif"
