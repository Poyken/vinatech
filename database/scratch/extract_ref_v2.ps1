Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- Searching for reference screen metadata ---"
# Search for screens with caption like 'Test Thuc' or 'T0429'
$cmd.CommandText = "SELECT Name, Caption FROM STB_ScreenInfo WHERE Caption LIKE N'%Test Thuc%' OR TCode = 'T0429'"
$reader = $cmd.ExecuteReader()
$names = New-Object System.Collections.Generic.List[string]
while ($reader.Read()) {
    Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption'])"
    $names.Add($reader['Name'])
}
$reader.Close()

foreach ($name in $names) {
    Write-Host "`n--- Extraction for $name ---"
    $cmd.CommandText = "SELECT XmlLayout FROM STB_ScreenLayoutInfo WHERE Name = '$name'"
    $res = $cmd.ExecuteScalar()
    if ($res -ne $null -and $res -ne [DBNull]::Value) {
        $xml = $res.ToString()
        $xml | Out-File "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\layout_$($name).xml"
        Write-Host "Saved XML to layout_$($name).xml"
        # Print first 2000 chars
        Write-Host "XML Start: $($xml.Substring(0, [Math]::Min(2000, $xml.Length)))"
    } else {
        Write-Host "No XmlLayout found for $name"
    }
}
$conn.Close()
