Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

# 1. Search for T101_Test (try partial match on caption)
Write-Host "--- Finding Screen Info for T101 (Loi Phe) ---"
$cmd.CommandText = "SELECT Name, Caption FROM STB_ScreenInfo WHERE Caption LIKE N'%lỗi phế%' OR Name LIKE '%T101%'"
$reader = $cmd.ExecuteReader()
$names = New-Object System.Collections.Generic.List[string]
while ($reader.Read()) {
    Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption'])"
    $names.Add($reader['Name'])
}
$reader.Close()

# Add ZSRT01's real name found earlier
$names.Add("SortingDataError")

foreach ($name in $names) {
    Write-Host "`n=== Detailed Structure for: $name ==="
    
    # Get Layout XML
    $cmd.CommandText = "SELECT XmlLayout FROM STB_ScreenLayoutInfo WHERE Name = '$name'"
    $res = $cmd.ExecuteScalar()
    if ($res -ne $null -and $res -ne [DBNull]::Value) {
        Write-Host "XmlLayout found. Saving to folder..."
        $xml = $res.ToString()
        $path = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\layout_$($name).xml"
        $xml | Out-File $path
        Write-Host "Saved to $path"
    } else {
        Write-Host "XmlLayout NOT found."
    }

    # Get Objects
    Write-Host "Objects:"
    $cmd.CommandText = "SELECT ObjectName, ObjectType, Caption FROM STB_ScreenObjects WHERE ScreenName = '$name'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "- Name: $($reader['ObjectName']) | Type: $($reader['ObjectType']) | Caption: $($reader['Caption'])"
    }
    $reader.Close()
}

$conn.Close()
