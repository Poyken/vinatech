# ==============================================================================
# ksys.ps1 — PROCESS Root Proxy to K-SYSTEM ACE ERP CLI Hub (FINAL)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetScript = Join-Path $PSScriptRoot "FINAL\ksys.ps1"
if (-not (Test-Path $targetScript)) {
    Write-Error "Cannot find K-SYSTEM CLI Hub at: $targetScript"
    exit 1
}

& $targetScript @args
