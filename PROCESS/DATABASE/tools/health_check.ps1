<#
.SYNOPSIS
    Kiem tra suc khoe va do tre phan hoi cua toan bo 15 CSDL Vinatech.
#>
param (
    [switch]$Detail
)

. "$PSScriptRoot\db_shared.ps1"

$config = Get-DBConfig
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  VINATECH 15-DATABASE MORNING HEALTH CHECK (Server: $($config.Server))" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$results = @()
$profiles = $config.Profiles.PSObject.Properties

foreach ($p in $profiles) {
    $pName = $p.Name
    $dbName = $p.Value.Database
    $desc = $p.Value.Description

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $status = "OK"
    $latency = 0
    $tableCount = "N/A"
    $errDetail = ""

    try {
        $dbObj = Get-DBConnection -Profile $pName
        $conn = $dbObj.Connection

        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT COUNT(*) FROM sys.tables WITH(NOLOCK);"
        $cmd.CommandTimeout = 10
        $tableCount = $cmd.ExecuteScalar()
        $conn.Close()
        $sw.Stop()
        $latency = [math]::Round($sw.Elapsed.TotalMilliseconds, 1)
    } catch {
        $sw.Stop()
        $status = "ERROR"
        $latency = [math]::Round($sw.Elapsed.TotalMilliseconds, 1)
        $errDetail = $_.Exception.Message
    }

    $results += [PSCustomObject]@{
        Profile     = $pName
        Database    = $dbName
        Status      = $status
        LatencyMs   = $latency
        TableCount  = $tableCount
        Description = if ($Detail -and $errDetail) { "ERR: $errDetail" } else { $desc }
    }
}

$results | Format-Table -AutoSize -Property Profile, Database, Status, LatencyMs, TableCount, Description

$onlineCount = ($results | Where-Object { $_.Status -eq "OK" }).Count
$totalCount = $results.Count
Write-Host "--------------------------------------------------------------------------------"
if ($onlineCount -eq $totalCount) {
    Write-Host "  [OK] ALL 15 DATABASES ARE HEALTHY & ONLINE ($onlineCount/$totalCount)" -ForegroundColor Green
} else {
    Write-Host "  [WARN] WARNING: $onlineCount/$totalCount DATABASES ONLINE" -ForegroundColor Yellow
}
Write-Host "================================================================================" -ForegroundColor Cyan
