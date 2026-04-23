param (
    [Parameter(Mandatory=$true)]
    [string]$spName,
    [string]$outputPath = ""
)

$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
if ($outputPath -eq "") {
    $outputPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\$spName.sql"
}

Write-Host "Fetching latest source for $spName from database..."
Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandTimeout = 120 # Increase timeout for large SPs
    # Using OBJECT_DEFINITION to get the clean source
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('$spName'))"
    $definition = $cmd.ExecuteScalar()
    
    if ($definition -eq [DBNull]::Value -or $null -eq $definition) {
        Write-Error "Stored Procedure '$spName' not found or has no definition."
        return
    }

    # Save as UTF8 with BOM to ensure Vietnamese characters are preserved
    $utf8NoBom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($outputPath, $definition, $utf8NoBom)
    
    Write-Host "Successfully saved latest source to: $outputPath"
} catch {
    Write-Error "Error: $($_.Exception.Message)"
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
