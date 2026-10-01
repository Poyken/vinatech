# ==============================================================================
# ops.ps1 — Sub-Workspace Proxy to Master Enterprise Orchestrator
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetScript = Join-Path $PSScriptRoot "..\ops.ps1"
if (-not (Test-Path $targetScript)) {
    $targetScript = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\ops.ps1"
}
if (-not (Test-Path $targetScript)) {
    Write-Error "Cannot find Master ops.ps1 at: $targetScript"
    exit 1
}

& $targetScript @args
