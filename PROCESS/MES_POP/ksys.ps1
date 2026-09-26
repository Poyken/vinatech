# ==============================================================================
# ksys.ps1 — MES_POP Proxy to Root K-SYSTEM ACE CLI Hub
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetScript = Join-Path $PSScriptRoot "..\ksys.ps1"
if (-not (Test-Path $targetScript)) {
    $targetScript = Join-Path $PSScriptRoot "..\FINAL\ksys.ps1"
}
if (-not (Test-Path $targetScript)) {
    Write-Error "Cannot find K-SYSTEM CLI Hub at: $targetScript"
    exit 1
}

& $targetScript @args
