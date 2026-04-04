#!/bin/sh
# =============================================================================
# auth_update.sh
# Registers Container App redirect URIs with Entra ID App Registrations.
# Updated to read from .env instead of azd.
#
# Run after auth_init.sh and after terraform apply (when BACKEND_URI is known).
# =============================================================================

if [ ! -f .env ]; then
  echo ".env file not found. Copy .env.example to .env and fill in your values."
  exit 1
fi
set -a
. ./.env
set +a

if [ "$AZURE_USE_AUTHENTICATION" != "true" ]; then
  exit 0
fi

. ./scripts/load_python_env.sh

./.venv/bin/python ./scripts/auth_update.py
