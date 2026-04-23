$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT COUNT(*) FROM sys.procedures"
    $count = $cmd.ExecuteScalar()
    Write-Host "Total SPs: $count"
    
    # Also list top 100 to see naming conventions
    $cmd.CommandText = "SELECT TOP 100 name FROM sys.procedures ORDER BY name"
    $reader = $cmd.ExecuteReader()
    Write-Host "Sample SP names:"
    while($reader.Read()){
        Write-Host "- $($reader[0])"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
