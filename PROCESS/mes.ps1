# ==============================================================================
# mes.ps1 — PROCESS Root Proxy to MES_POP CLI Hub
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetScript = Join-Path $PSScriptRoot "MES_POP\mes.ps1"
if (-not (Test-Path $targetScript)) {
    Write-Error "Cannot find MES_POP CLI Hub at: $targetScript"
    exit 1
}

& $targetScript @args
