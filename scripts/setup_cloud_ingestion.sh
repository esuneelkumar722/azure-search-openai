#!/bin/sh
# =============================================================================
# setup_cloud_ingestion.sh  — FOR FUTURE USE
#
# Cloud Ingestion is an alternative document pipeline using Azure Functions +
# ADLS Gen2 storage with ACL support. It enables per-user document permissions
# without requiring manual prepdocs runs.
#
# This deployment uses Integrated Vectorization (USE_FEATURE_INT_VECTORIZATION=true)
# and does NOT use cloud ingestion. To enable cloud ingestion in the future:
#   1. Set use_cloud_ingestion = true in dev.tfvars
#   2. Run terraform apply (provisions Azure Functions)
#   3. Set USE_CLOUD_INGESTION=true in .env
#   4. Run this script
#
# Note: This script still uses azd env get-value. Update to read from .env
# (see prepdocs.sh for the pattern) before using.
# =============================================================================

USE_CLOUD_INGESTION=$(azd env get-value USE_CLOUD_INGESTION)
if [ "$USE_CLOUD_INGESTION" != "true" ]; then
  exit 0
fi

. ./scripts/load_python_env.sh

./.venv/bin/python ./app/backend/setup_cloud_ingestion.py
