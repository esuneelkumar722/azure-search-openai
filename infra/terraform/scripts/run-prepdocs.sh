#!/bin/bash
# =============================================================================
# Run Document Ingestion (prepdocs.py)
# Parses PDFs, generates embeddings, indexes into Azure AI Search.
# =============================================================================

set -euo pipefail

TF_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(cd "$TF_DIR/../.." && pwd)"

# Load Terraform outputs as environment variables
echo "Loading Terraform outputs..."
eval "$(terraform -chdir="$TF_DIR" output -json | jq -r 'to_entries[] | "export \(.key | ascii_upcase)=\(.value.value)"')"

# Setup Python virtual environment
echo "Setting up Python environment..."
cd "$PROJECT_ROOT"
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate
pip install -q -r app/backend/requirements.txt

# Run document ingestion
echo "Running document ingestion..."
python ./app/backend/prepdocs.py './data/*' --verbose

echo "Document ingestion complete!"
