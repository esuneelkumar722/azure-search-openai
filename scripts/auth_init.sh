#!/bin/sh
# =============================================================================
# auth_init.sh
# Sets up Entra ID App Registrations for authentication.
# Updated to read from .env instead of azd.
#
# Prerequisites:
#   - AZURE_USE_AUTHENTICATION=true in .env
#   - Application Administrator role in your Entra ID tenant
#   - Run: az login --tenant <your-tenant-id>
# =============================================================================

if [ ! -f .env ]; then
  echo ".env file not found. Copy .env.example to .env and fill in your values."
  exit 1
fi
set -a
. ./.env
set +a

echo "Checking if authentication should be setup..."

# Note: USE_CHAT_HISTORY_COSMOS is independent of authentication — Cosmos DB
# works with or without auth. No guard needed here.

if [ "$AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS" = "true" ]; then
  if [ "$AZURE_ENFORCE_ACCESS_CONTROL" != "true" ]; then
    echo "AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS is set to true, but AZURE_ENFORCE_ACCESS_CONTROL is not set to true. Please set and retry."
    exit 1
  fi
fi

if [ "$AZURE_USE_AUTHENTICATION" != "true" ]; then
  echo "AZURE_USE_AUTHENTICATION is not set, skipping authentication setup."
  exit 0
fi

echo "AZURE_USE_AUTHENTICATION is set, proceeding with authentication setup..."

. ./scripts/load_python_env.sh

./.venv/bin/python ./scripts/auth_init.py
