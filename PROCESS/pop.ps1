# ==============================================================================
# pop.ps1 — PROCESS Root Proxy to POP Kiosk CLI Hub
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetScript = Join-Path $PSScriptRoot "MES_POP\pop.ps1"
if (-not (Test-Path $targetScript)) {
    Write-Error "Cannot find POP Kiosk CLI Hub at: $targetScript"
    exit 1
}

& $targetScript @args
