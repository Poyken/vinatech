# ==============================================================================
# db.ps1 — PROCESS Root Proxy to DATABASE CLI Hub
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetScript = Join-Path $PSScriptRoot "DATABASE\db.ps1"
if (-not (Test-Path $targetScript)) {
    Write-Error "Cannot find DATABASE CLI Hub at: $targetScript"
    exit 1
}

& $targetScript @args
