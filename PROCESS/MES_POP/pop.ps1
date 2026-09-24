# ==============================================================================
# pop.ps1 — POP Kiosk & Production Command Hub (Direct Alias to mes.ps1)
# Cho phep dung song song: .\pop.ps1 trace <=> .\mes.ps1 trace
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$targetScript = Join-Path $PSScriptRoot "mes.ps1"
if (-not (Test-Path $targetScript)) {
    Write-Error "Cannot find MES CLI Hub at: $targetScript"
    exit 1
}

& $targetScript @args
