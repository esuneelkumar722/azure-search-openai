# =============================================================================
# auth_init.ps1
# Sets up Entra ID App Registrations for authentication.
# Updated to read from .env instead of azd.
#
# Prerequisites:
#   - AZURE_USE_AUTHENTICATION=true in .env
#   - Application Administrator role in your Entra ID tenant
#   - Run: az login --tenant <your-tenant-id>
# =============================================================================

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

Write-Host "Checking if authentication should be setup..."

$AZURE_USE_AUTHENTICATION            = $env:AZURE_USE_AUTHENTICATION
$AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS = $env:AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS
$AZURE_ENFORCE_ACCESS_CONTROL        = $env:AZURE_ENFORCE_ACCESS_CONTROL

# Note: USE_CHAT_HISTORY_COSMOS is independent of authentication — Cosmos DB
# works with or without auth. No guard needed here.

if ($AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS -eq "true") {
  if ($AZURE_ENFORCE_ACCESS_CONTROL -ne "true") {
    Write-Host "AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS is set to true, but AZURE_ENFORCE_ACCESS_CONTROL is not set to true. Please set it and retry."
    Exit 1
  }
}

if ($AZURE_USE_AUTHENTICATION -ne "true") {
  Write-Host "AZURE_USE_AUTHENTICATION is not set, skipping authentication setup."
  Exit 0
}

. ./scripts/load_python_env.ps1

$venvPythonPath = "./.venv/scripts/python.exe"
if (Test-Path -Path "/usr") {
  # fallback to Linux venv path
  $venvPythonPath = "./.venv/bin/python"
}

Start-Process -FilePath $venvPythonPath -ArgumentList "./scripts/auth_init.py" -Wait -NoNewWindow
