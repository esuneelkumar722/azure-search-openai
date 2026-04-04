# =============================================================================
# auth_update.ps1
# Registers Container App redirect URIs with Entra ID App Registrations.
# Updated to read from .env instead of azd.
#
# Run after auth_init.ps1 and after terraform apply (when BACKEND_URI is known).
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

if ($env:AZURE_USE_AUTHENTICATION -ne "true") {
  Exit 0
}

. ./scripts/load_python_env.ps1

$venvPythonPath = "./.venv/scripts/python.exe"
if (Test-Path -Path "/usr") {
  # fallback to Linux venv path
  $venvPythonPath = "./.venv/bin/python"
}

Start-Process -FilePath $venvPythonPath -ArgumentList "./scripts/auth_update.py" -Wait -NoNewWindow
