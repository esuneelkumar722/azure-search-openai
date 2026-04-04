# =============================================================================
# prepdocs-terraform.ps1
# Run document ingestion for Terraform-based deployments (no azd required).
#
# Prerequisites:
#   1. Copy .env.example to .env and fill in your values
#   2. Run: pip install -r app/backend/requirements.txt
#   3. Ensure you are logged in: az login --tenant <your-tenant-id>
#
# Usage:
#   # Ingest documents (integrated vectorization — creates indexer/skillset)
#   .\scripts\prepdocs-terraform.ps1
#
#   # Remove all documents and reset index
#   .\scripts\prepdocs-terraform.ps1 --removeall
# =============================================================================

# Load .env file into current session
$envFile = Join-Path (Get-Location) ".env"
if (-Not (Test-Path $envFile)) {
    Write-Error ".env file not found. Copy .env.example to .env and fill in your values."
    exit 1
}

Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)="?([^"]*)"?\s*$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        if ($name -and -not $name.StartsWith('#')) {
            [System.Environment]::SetEnvironmentVariable($name, $value, 'Process')
        }
    }
}

$venvPythonPath = ".\.venv\Scripts\python.exe"
if (Test-Path -Path "/usr") {
    $venvPythonPath = "./.venv/bin/python"
}

if (-Not (Test-Path $venvPythonPath)) {
    Write-Error "Virtual environment not found at $venvPythonPath. Run: python -m venv .venv && pip install -r app/backend/requirements.txt"
    exit 1
}

$cwd = (Get-Location)
$dataArg = "`"$cwd/data/*`""
$additionalArgs = if ($args) { "$args" } else { "" }

$argumentList = "app/backend/prepdocs.py $dataArg --verbose $additionalArgs"
Write-Host "Running: python $argumentList"

Start-Process -FilePath $venvPythonPath -ArgumentList $argumentList -Wait -NoNewWindow
