Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$screenId = "T4029"

Write-Host "--- Searching for Screen: $screenId ---"
$cmd.CommandText = "SELECT Name, Caption, ClassName, AssemblyName, Description FROM STB_ScreenInfo WHERE Name = '$screenId' OR Caption LIKE '%$screenId%'"
$reader = $cmd.ExecuteReader()
if ($reader.HasRows) {
    while ($reader.Read()) {
        Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption']) | Class: $($reader['ClassName'])"
    }
} else {
    Write-Host "No screen found with ID or Caption like $screenId"
}
$reader.Close()

Write-Host "`n--- Objects/Functions for Screen: $screenId ---"
$cmd.CommandText = "SELECT ScreenName, ObjectName, ObjectType, Description FROM STB_ScreenObjects WHERE ScreenName = '$screenId' ORDER BY ObjectType"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Type: $($reader['ObjectType']) | Object: $($reader['ObjectName']) | Desc: $($reader['Description'])"
}
$reader.Close()

$conn.Close()
