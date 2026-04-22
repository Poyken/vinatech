param(
    [string]$Server = "dbserver.hycap.co.kr,5398",
    [string]$Database = "SmartFactoryV2",
    [string]$FilePath
)

Add-Type -AssemblyName System.Data
$connStr = "Server=$Server;Database=$Database;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=60;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)

try {
    $conn.Open()
    $sql = Get-Content -Path $FilePath -Raw
    $commands = $sql -split "(?m)^\s*GO\s*$"
    
    foreach ($cmdText in $commands) {
        if ([string]::IsNullOrWhiteSpace($cmdText)) { continue }
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $cmdText
        $cmd.ExecuteNonQuery() | Out-Null
    }
    Write-Host "Successfully executed: $FilePath"
} catch {
    Write-Error "Failed to execute: $FilePath. Error: $_"
    exit 1
} finally {
    $conn.Close()
}
