$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared

$ctrl = "ControlNo IN ('20260917000445', '20260917000446', '20260917000447', '20260917000448', '20260917000449', '20260917000450')"

Write-Host "Backing up STB_ProdRouteHist..."
Export-PreflightSnapshot -TableName "STB_ProdRouteHist" -WhereClause "$ctrl AND RouteCode = 'V-22_HY'" -Profile "SmartFactoryV2" -Reason "backup_b782_move_date_18_to_17"

Write-Host "Backing up STB_DefectRepairInfo..."
Export-PreflightSnapshot -TableName "STB_DefectRepairInfo" -WhereClause "$ctrl AND FindRouteCode = 'V-22_HY'" -Profile "SmartFactoryV2" -Reason "backup_b782_move_date_18_to_17"

Write-Host "Backing up STB_SetInfo..."
Export-PreflightSnapshot -TableName "STB_SetInfo" -WhereClause "$ctrl" -Profile "SmartFactoryV2" -Reason "backup_b782_move_date_18_to_17"

Write-Host "All backups completed successfully!"
