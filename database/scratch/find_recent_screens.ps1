Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- Recently Created Screens in SmartFramework ---"
$cmd.CommandText = "SELECT Name, Caption, CreateDateTime FROM STB_ScreenInfo WHERE CreateDateTime > '2026-04-20'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption']) | Created: $($reader['CreateDateTime'])"
}
$reader.Close()

$conn.ChangeDatabase("SmartFactoryV2")
Write-Host "`n--- Recently Created Screens in SmartFactoryV2 (if table exists) ---"
try {
    $cmd.CommandText = "SELECT Name, Caption, CreateDateTime FROM STB_ScreenInfo WHERE CreateDateTime > '2026-04-20'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption']) | Created: $($reader['CreateDateTime'])"
    }
    $reader.Close()
} catch {
    Write-Host "[STB_ScreenInfo not in SmartFactoryV2]"
}

$conn.Close()
