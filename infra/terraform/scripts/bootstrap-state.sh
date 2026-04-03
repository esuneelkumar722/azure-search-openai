#!/bin/bash
# =============================================================================
# Bootstrap Terraform State Storage
# Run this ONCE before the first terraform init.
# This creates the Azure Storage account used for remote state.
# =============================================================================

set -euo pipefail

RESOURCE_GROUP="rg-terraform-state"
LOCATION="${1:-eastus}"
# Generate a unique storage account name
STORAGE_ACCOUNT="stterraformstate$(openssl rand -hex 4)"
CONTAINER="tfstate"

echo "Creating Terraform state storage..."
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Location: $LOCATION"

# Create resource group
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# Create storage account with versioning and soft-delete
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku "Standard_LRS" \
  --kind "StorageV2" \
  --min-tls-version "TLS1_2" \
  --allow-blob-public-access false \
  --output none

# Enable blob versioning
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true \
  --output none

# Create container
az storage container create \
  --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output none

# Lock the resource group to prevent accidental deletion
az lock create \
  --name "terraform-state-lock" \
  --resource-group "$RESOURCE_GROUP" \
  --lock-type CanNotDelete \
  --notes "Protects Terraform state storage from accidental deletion" \
  --output none

echo ""
echo "State storage created successfully!"
echo ""
echo "Update backend.tf with these values:"
echo "  resource_group_name  = \"$RESOURCE_GROUP\""
echo "  storage_account_name = \"$STORAGE_ACCOUNT\""
echo "  container_name       = \"$CONTAINER\""
echo "  key                  = \"azure-search-openai.tfstate\""
