Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$name = 'Test_D40325'
Write-Host "--- Checking metadata for Screen: $name ---"
$cmd.CommandText = "SELECT Name, Caption, XmlLayout FROM STB_ScreenInfo i JOIN STB_ScreenLayoutInfo l ON i.Name = l.Name WHERE i.Name = '$name'"
$reader = $cmd.ExecuteReader()
if ($reader.Read()) {
    Write-Host "Found: $($reader['Name']) | Caption: $($reader['Caption'])"
    $xml = $reader['XmlLayout']
    if ($xml -ne [DBNull]::Value) {
        $xml.ToString() | Out-File "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\layout_Test_D40325.xml"
        Write-Host "Saved XML to layout_Test_D40325.xml"
    }
} else {
    Write-Host "Not found. Searching by caption 'Test Thuc'..."
    $reader.Close()
    $cmd.CommandText = "SELECT Name, Caption FROM STB_ScreenInfo WHERE Caption LIKE N'%Test Thuc%'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Potential Name: $($reader['Name']) | Caption: $($reader['Caption'])"
    }
}
$conn.Close()
