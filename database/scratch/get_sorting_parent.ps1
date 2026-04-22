Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT Name, ParentName, SystemCode FROM STB_ScreenInfo WHERE Name LIKE 'SortingData%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Name: $($reader['Name']) | Parent: $($reader['ParentName']) | SystemCode: $($reader['SystemCode'])"
}
$reader.Close()
$conn.Close()
