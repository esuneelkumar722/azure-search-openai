# =============================================================================
# prepdocs.ps1
# Original azd-hook script — updated to read from .env instead of azd.
#
# NOTE: For Terraform-based deployments, prefer:
#   .\scripts\prepdocs-terraform.ps1
# which is purpose-built for this workflow.
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

if ($env:USE_CLOUD_INGESTION -eq "true") {
  Write-Host "Cloud ingestion is enabled, so we are not running the manual ingestion process."
  Exit 0
}

./scripts/load_python_env.ps1

$venvPythonPath = "./.venv/scripts/python.exe"
if (Test-Path -Path "/usr") {
  # fallback to Linux venv path
  $venvPythonPath = "./.venv/bin/python"
}

Write-Host 'Running "prepdocs.py"'

$cwd = (Get-Location)
$dataArg = "`"$cwd/data/*`""
$additionalArgs = ""
if ($args) {
  $additionalArgs = "$args"
}

$argumentList = "./app/backend/prepdocs.py $dataArg --verbose $additionalArgs"
$argumentList

Start-Process -FilePath $venvPythonPath -ArgumentList $argumentList -Wait -NoNewWindow
