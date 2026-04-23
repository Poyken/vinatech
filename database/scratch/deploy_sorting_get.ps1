param([string]$filePath = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\SRT_D00_Step2A_SP_get.sql')

Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)

if (-not (Test-Path $filePath)) { Write-Host "File not found: $filePath"; exit }
$content = Get-Content $filePath -Raw
$blocks = $content -split "(?m)^\s*GO\s*$"

try {
    $conn.Open()
    foreach ($block in $blocks) {
        $trimmedBlock = $block.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmedBlock)) { continue }
        
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $trimmedBlock
        $cmd.ExecuteNonQuery()
    }
    Write-Host "Successfully deployed $(Split-Path $filePath -Leaf) to database."
} catch {
    Write-Host "Error during deployment: $($_.Exception.Message)"
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
