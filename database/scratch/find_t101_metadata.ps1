Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$potentialNames = @('ThongTinLoiPhe', 'T101_Test', 'InformationWaste')

foreach ($name in $potentialNames) {
    Write-Host "`n--- Checking potential name: $name ---"
    $cmd.CommandText = "SELECT Name, Caption FROM STB_ScreenInfo WHERE Name = '$name' OR Name LIKE '%$name%'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Found in ScreenInfo -> Name: $($reader['Name']) | Caption: $($reader['Caption'])"
    }
    $reader.Close()

    $cmd.CommandText = "SELECT XmlLayout FROM STB_ScreenLayoutInfo WHERE Name = '$name' OR Name LIKE '%$name%'"
    $res = $cmd.ExecuteScalar()
    if ($res -ne $null -and $res -ne [DBNull]::Value) {
        Write-Host "XmlLayout found for $name. Saving to folder..."
        $xml = $res.ToString()
        $xml | Out-File "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\layout_$($name).xml"
    }
}

$conn.Close()
