$backupDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\source_from_db"
if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir }

$listFile = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\all_sps_list.txt"
if (!(Test-Path $listFile)) { Write-Error "List file not found."; return }

$sps = Get-Content $listFile
$total = $sps.Count
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'

Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

Write-Host "Starting backup of $total Stored Procedures..."
$count = 0
$utf8NoBom = New-Object System.Text.UTF8Encoding($true)

foreach ($sp in $sps) {
    $count++
    if ($count % 50 -eq 0) { Write-Host "Progress: $count / $total" }
    
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 60
        $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('$sp'))"
        $definition = $cmd.ExecuteScalar()
        
        if ($definition -ne [DBNull]::Value -and $null -ne $definition) {
            # Replace invalid filename characters just in case
            $safeName = $sp -replace '[\\\/\:\*\?\"\<\>\|]', '_'
            $outputPath = "$backupDir\$safeName.sql"
            [System.IO.File]::WriteAllText($outputPath, $definition, $utf8NoBom)
        }
    } catch {
        Write-Warning "Failed to fetch $($sp): $($_.Exception.Message)"
    }
}

$conn.Close()
Write-Host "Backup completed. All files saved to $backupDir"
