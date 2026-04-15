Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# Search for Screen mapping
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT Name, Caption, TCode FROM STB_ScreenInfo WHERE Name LIKE '%F721%' OR Name LIKE '%F330%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Screen: $($reader['Name']) | Caption: $($reader['Caption']) | TCode: $($reader['TCode'])"
}
$reader.Close()

# Search for Object/Action mapping
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT ScreenName, ObjectName, Caption, Description FROM STB_ScreenObjects WHERE ScreenName LIKE '%F721%' OR ScreenName LIKE '%F330%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Object: $($reader['ScreenName']) | ObjectName: $($reader['ObjectName']) | Proc: $($reader['Description'])"
}
$reader.Close()

$conn.Close()
