$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared

$ctrl = "ControlNo IN ('20260911000619', '20260910000370', '20260911000617', '20260910000055', '20260907000380', '20260907000154', '20260902000417', '20260902000178', '20260911000606', '20260902000177', '20260902000424', '20260902000165', '20260831000089', '20260907000139', '20260907000141', '20260904000095', '20260902000168')"

Write-Host "Backing up STB_ProdRouteHist for V-24_HY..." -ForegroundColor Cyan
Export-PreflightSnapshot -TableName "STB_ProdRouteHist" -WhereClause "$ctrl AND RouteCode = 'V-24_HY'" -Profile "SmartFactoryV2" -Reason "backup_b782_17lots_v24_move_to_18"

Write-Host "Backing up STB_DefectRepairInfo for V-24_HY..." -ForegroundColor Cyan
Export-PreflightSnapshot -TableName "STB_DefectRepairInfo" -WhereClause "$ctrl AND FindRouteCode = 'V-24_HY'" -Profile "SmartFactoryV2" -Reason "backup_b782_17lots_v24_move_to_18"

Write-Host "Backup completed successfully!" -ForegroundColor Green
