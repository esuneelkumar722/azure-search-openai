#!/bin/sh
# =============================================================================
# prepdocs.sh
# Original azd-hook script — updated to read from .env instead of azd.
#
# NOTE: For Terraform-based deployments, prefer prepdocs-terraform.ps1 (Windows)
# or run prepdocs.py directly after sourcing .env.
# =============================================================================

if [ ! -f .env ]; then
  echo ".env file not found. Copy .env.example to .env and fill in your values."
  exit 1
fi
set -a
. ./.env
set +a

if [ "$USE_CLOUD_INGESTION" = "true" ]; then
  echo "Cloud ingestion is enabled, so we are not running the manual ingestion process."
  exit 0
fi

. ./scripts/load_python_env.sh

echo 'Running "prepdocs.py"'

additionalArgs=""
if [ $# -gt 0 ]; then
  additionalArgs="$@"
fi

./.venv/bin/python ./app/backend/prepdocs.py './data/*' --verbose $additionalArgs
