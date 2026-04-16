[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=30;"

$query = @"
select top 1 si.MaterialCode, mm.MaterialName, mm.MaterialSource, mm.MaterialThickness 
from STB_SetInfo si
left join STB_MaterialMaster mm on si.MaterialCode = mm.MaterialCode
where si.Barcode like 'VJQM1320001E01-008%'
"@

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $query
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $da.Fill($dt) | Out-Null
    $dt | ConvertTo-Csv -NoTypeInformation
    $conn.Close()
} catch {
    Write-Error $_.Exception.Message
}
