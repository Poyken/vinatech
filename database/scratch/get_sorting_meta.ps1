Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$screens = @("SortingDataError", "ZSRT01_SortingData", "SortingDataError2")

foreach ($s in $screens) {
    Write-Host "--- Metadata for Screen: $s ---"
    $cmd.CommandText = "SELECT Name, Caption, CreateDateTime FROM STB_ScreenInfo WHERE Name = '$s'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption']) | Created: $($reader['CreateDateTime'])"
    }
    $reader.Close()

    Write-Host ("Objects for " + $s + ":")
    $cmd.CommandText = "SELECT ObjectName, ObjectType, Description FROM STB_ScreenObjects WHERE ScreenName = '$s' ORDER BY ObjectType"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "  Type: $($reader['ObjectType']) | Object: $($reader['ObjectName']) | Desc: $($reader['Description'])"
    }
    $reader.Close()
    Write-Host ""
}

$conn.Close()
