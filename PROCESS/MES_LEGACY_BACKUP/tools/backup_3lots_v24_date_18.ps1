$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared

$ctrl = "ControlNo IN ('20260915000222', '20260915000225', '20260915000619')"

Write-Host "Backing up STB_ProdRouteHist for V-24_HY..." -ForegroundColor Cyan
Export-PreflightSnapshot -TableName "STB_ProdRouteHist" -WhereClause "$ctrl AND RouteCode = 'V-24_HY'" -Profile "SmartFactoryV2" -Reason "backup_b782_3lots_v24_move_to_18"

Write-Host "Backup completed successfully!" -ForegroundColor Green
