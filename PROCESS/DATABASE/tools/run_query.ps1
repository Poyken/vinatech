<#
.SYNOPSIS
    Thực thi câu truy vấn SELECT an toàn trên 15 CSDL Vinatech.
#>
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Query,
    [string]$Profile = "SmartFactoryV2",
    [int]$MaxRows = 50,
    [int]$TimeoutSeconds = 15
)

. "$PSScriptRoot\db_shared.ps1"

Write-Host "Connecting to Profile: $Profile..." -ForegroundColor Cyan

try {
    $res = Invoke-SafeSelect -Query $Query -Profile $Profile -MaxRows $MaxRows -TimeoutSeconds $TimeoutSeconds

    if ($res.Success) {
        Write-Host "✅ Query executed successfully on $($res.Server) ($($res.Database))" -ForegroundColor Green
        Write-Host "Rows returned: $($res.RowCount) (Limit: $MaxRows)" -ForegroundColor Yellow
        Write-Host ""
        $res.Data | Format-Table -AutoSize
    } else {
        Write-Host "❌ Error executing query: $($res.Error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}
