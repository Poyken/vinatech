[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=15;"

$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.usp_Vietnam_RawMaterialInputHist_uid'))"

$reader = $cmd.ExecuteReader()
if ($reader.Read()) {
    $content = $reader[0].ToString()
    if ($content -match "DUNG D\?CH" -or $content -match "DUNG D.CH") {
        Write-Host "Warning: Found corrupted characters in SP!"
        $matches = [regex]::matches($content, ".{0,20}DUNG D.{0,20}")
        foreach ($m in $matches) { Write-Host $m.Value }
    } else {
        Write-Host "Fonts look OK. Searching for the exact string:"
        $matches = [regex]::matches($content, ".{0,20}DUNG DỊCH.{0,20}")
        foreach ($m in $matches) { Write-Host $m.Value }
    }
}
$reader.Close()
$conn.Close()
