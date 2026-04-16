[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = "vina1234%6&8"
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=$pwd;TrustServerCertificate=True;Connect Timeout=30;"

$query = @"
SELECT 
    SI.Barcode, 
    PRH.ControlNo,
    SI.MaterialCode,
    PRH.RouteCode, 
    PRH.MachineCode,
    MM.MachineName,
    PRH.ProdQty,
    PRH.ProdDateTime
FROM STB_ProdRouteHist PRH WITH (NOLOCK)
INNER JOIN STB_SetInfo SI WITH (NOLOCK) 
    ON PRH.ControlNo = SI.ControlNo
LEFT JOIN STB_MachineMaster MM WITH (NOLOCK) 
    ON PRH.MachineCode = MM.MachineCode
WHERE 
    SI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE '%35105%')
    AND PRH.RouteCode = 'V-23_BG' 
    AND PRH.ProdDateTime >= '2026-04-15' 
    AND PRH.ProdDateTime < '2026-04-17'
    AND MM.MachineName LIKE '%Winding%'
ORDER BY 
    PRH.ProdDateTime DESC
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
