[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=30;"

$query = @"
select ModelCode, MBISizeW, MBISizeH, MBISizeD, 
    CASE WHEN MBISizeW IS NOT NULL
    THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
    ELSE CONVERT(VARCHAR(10), CONVERT(INT,MBISizeD) ) END as ExtractedSize
from STB_ModelBasicInfo mbi
where ModelName like '%35105%'
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
