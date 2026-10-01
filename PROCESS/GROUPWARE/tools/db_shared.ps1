# ==============================================================================
# GROUPWARE/tools/db_shared.ps1 — Sub-pillar Proxy to Unified Master DB Engine
# Single Source of Truth: PROCESS/tools/shared/db_shared.ps1 (v4.0)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$masterShared = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "tools\shared\db_shared.ps1"
if (-not (Test-Path $masterShared)) {
    $masterShared = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\tools\shared\db_shared.ps1"
}

if (Test-Path $masterShared) {
    . $masterShared
} else {
    Write-Error "Cannot locate master db_shared.ps1 at $masterShared"
    exit 1
}
