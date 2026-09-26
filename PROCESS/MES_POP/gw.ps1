# ==============================================================================
# gw.ps1 — MES_POP Proxy to Root GROUPWARE CLI Hub
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetScript = Join-Path $PSScriptRoot "..\gw.ps1"
if (-not (Test-Path $targetScript)) {
    $targetScript = Join-Path $PSScriptRoot "..\GROUPWARE\gw.ps1"
}
if (-not (Test-Path $targetScript)) {
    Write-Error "Cannot find GROUPWARE CLI Hub at: $targetScript"
    exit 1
}

& $targetScript @args
