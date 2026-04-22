Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$screenNames = @('T101_Test', 'ZSRT01')

foreach ($name in $screenNames) {
    Write-Host "`n=== Metadata for Screen: $name ==="
    
    # 1. Screen Info
    $cmd.CommandText = "SELECT Name, Caption, ParentName FROM STB_ScreenInfo WHERE Name = '$name'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Name: $($reader['Name']) | Caption: $($reader['Caption']) | Parent: $($reader['ParentName'])"
    }
    $reader.Close()

    # 2. Layout Info (XmlLayout)
    $cmd.CommandText = "SELECT XmlLayout FROM STB_ScreenLayoutInfo WHERE Name = '$name'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "`nXmlLayout Preview (first 500 chars):"
        $xml = $reader['XmlLayout']
        if ($xml -ne [DBNull]::Value) {
            Write-Host $xml.ToString().Substring(0, [Math]::Min(500, $xml.ToString().Length))
        } else {
            Write-Host "[NULL]"
        }
    }
    $reader.Close()

    # 3. Screen Objects
    $cmd.CommandText = "SELECT ObjectName, ObjectType, Caption FROM STB_ScreenObjects WHERE ScreenName = '$name'"
    $reader = $cmd.ExecuteReader()
    Write-Host "`nObjects:"
    while ($reader.Read()) {
        Write-Host "- Name: $($reader['ObjectName']) | Type: $($reader['ObjectType']) | Caption: $($reader['Caption'])"
    }
    $reader.Close()
}

$conn.Close()
