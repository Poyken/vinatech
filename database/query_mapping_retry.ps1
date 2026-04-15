Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# Search for Screen mapping by Name (from screenshot)
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT Name, Caption, TCode FROM STB_ScreenInfo WHERE Name LIKE '%MaterialStockList%' OR Name LIKE '%MaterialDoc%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Screen: $($reader['Name']) | Caption: $($reader['Caption'])"
}
$reader.Close()

# Search for Object/Action mapping by Name or Description (Proc name)
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT ScreenName, ObjectName, Caption, Description FROM STB_ScreenObjects WHERE ScreenName LIKE '%MaterialStockList%' OR ScreenName LIKE '%MaterialDoc%' OR Description LIKE '%MaterialLotInfo_get%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Object: $($reader['ScreenName']) | ObjectName: $($reader['ObjectName']) | Proc: $($reader['Description'])"
}
$reader.Close()

$conn.Close()
