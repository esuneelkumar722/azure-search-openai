# =============================================================================
# setup_cloud_ingestion.ps1  — FOR FUTURE USE
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
# (see prepdocs.ps1 for the pattern) before using.
# =============================================================================

$USE_CLOUD_INGESTION = (azd env get-value USE_CLOUD_INGESTION)
if ($USE_CLOUD_INGESTION -ne "true") {
  Exit 0
}

. ./scripts/load_python_env.ps1

$venvPythonPath = "./.venv/scripts/python.exe"
if (Test-Path -Path "/usr") {
  # fallback to Linux venv path
  $venvPythonPath = "./.venv/bin/python"
}

Start-Process -FilePath $venvPythonPath -ArgumentList "./app/backend/setup_cloud_ingestion.py" -Wait -NoNewWindow
