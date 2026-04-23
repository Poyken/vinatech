# Continue Export All SPs - Background Process
# Reads all_sps_list.txt, skips already-exported ones, exports the rest
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server  = "dbserver.hycap.co.kr,5398"
$db      = "SmartFactoryV2"
$uid     = "vinaadmin"
$pwd     = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=30;"
$outDir  = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\source_from_db"
$listFile = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\all_sps_list.txt"
$logFile = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\source_from_db\_export_progress.log"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

# Read full SP list
$allSPs = Get-Content $listFile | Where-Object { $_.Trim() -ne "" } | ForEach-Object { $_.Trim() }
$totalCount = $allSPs.Count

# Find which ones are already exported
$existingFiles = Get-ChildItem "$outDir\*.sql" | ForEach-Object { $_.BaseName }
$existingSet = @{}
foreach ($f in $existingFiles) { $existingSet[$f] = $true }

$remaining = $allSPs | Where-Object { -not $existingSet.ContainsKey($_) }
$remainingCount = @($remaining).Count
$alreadyDone = $totalCount - $remainingCount

Write-Host "=== SP EXPORT RESUME ===" -ForegroundColor Cyan
Write-Host "Total SPs: $totalCount" -ForegroundColor White
Write-Host "Already exported: $alreadyDone" -ForegroundColor Green
Write-Host "Remaining: $remainingCount" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Cyan

# Log start
$startMsg = "$(Get-Date) - RESUME EXPORT: $remainingCount remaining out of $totalCount total"
Add-Content -Path $logFile -Value $startMsg

$exported = 0
$failed = 0
$failedList = @()

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Host "Connected to $server / $db" -ForegroundColor Green

    $batchSize = 50
    $batchCount = 0

    foreach ($sp in $remaining) {
        $exported++
        $progress = $alreadyDone + $exported
        $pct = [math]::Round(($progress / $totalCount) * 100, 1)
        Write-Host "[$progress/$totalCount] ($pct%) Fetching: $sp ..." -NoNewline

        try {
            $cmd = $conn.CreateCommand()
            $cmd.CommandTimeout = 30
            $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.$sp')) AS def"
            $reader = $cmd.ExecuteReader()
            
            if ($reader.Read() -and $reader["def"] -ne [DBNull]::Value) {
                $def = $reader["def"].ToString()
                $fileName = "$outDir\$sp.sql"
                [System.IO.File]::WriteAllText($fileName, $def, [System.Text.Encoding]::UTF8)
                $sizeKB = [math]::Round($def.Length / 1024, 1)
                Write-Host " OK ($sizeKB KB)" -ForegroundColor Green
            } else {
                Write-Host " NOT FOUND (may be system SP)" -ForegroundColor Yellow
                $failed++
                $failedList += $sp
            }
            $reader.Close()
            $cmd.Dispose()
        } catch {
            Write-Host " ERROR: $($_.Exception.Message)" -ForegroundColor Red
            $failed++
            $failedList += $sp
            
            # Try to reconnect if connection lost
            if ($conn.State -ne 'Open') {
                Write-Host "  Reconnecting..." -ForegroundColor Yellow
                Start-Sleep -Seconds 3
                try {
                    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
                    $conn.Open()
                    Write-Host "  Reconnected!" -ForegroundColor Green
                } catch {
                    Write-Host "  Reconnect FAILED. Waiting 10s..." -ForegroundColor Red
                    Start-Sleep -Seconds 10
                    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
                    $conn.Open()
                }
            }
        }

        # Log progress every 50 SPs
        $batchCount++
        if ($batchCount -ge $batchSize) {
            $batchCount = 0
            $logMsg = "$(Get-Date) - Progress: $progress/$totalCount ($pct%) | Exported: $exported | Failed: $failed"
            Add-Content -Path $logFile -Value $logMsg
        }
    }

    $conn.Close()
} catch {
    Write-Error "Connection error: $($_.Exception.Message)"
}

# Final summary
$finalCount = (Get-ChildItem "$outDir\*.sql").Count
Write-Host "`n=== EXPORT COMPLETE ===" -ForegroundColor Cyan
Write-Host "Total files in output: $finalCount / $totalCount" -ForegroundColor Green
Write-Host "This session exported: $exported" -ForegroundColor Green
Write-Host "Failed/Not Found: $failed" -ForegroundColor Yellow

$summaryMsg = @"
$(Get-Date) - EXPORT COMPLETE
Total SPs in list: $totalCount
Total files exported: $finalCount
This session: $exported new, $failed failed
Failed list: $($failedList -join ', ')
"@
Add-Content -Path $logFile -Value $summaryMsg

if ($failedList.Count -gt 0) {
    Write-Host "`nFailed SPs:" -ForegroundColor Yellow
    $failedList | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}

Write-Host "`nLog saved to: $logFile" -ForegroundColor Cyan
