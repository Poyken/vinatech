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
    SI.Barcode IN (
        SELECT SI2.Barcode 
        FROM STB_ProdRouteHist PRH2 
        JOIN STB_SetInfo SI2 ON PRH2.ControlNo = SI2.ControlNo
        LEFT JOIN STB_MachineMaster MM2 ON PRH2.MachineCode = MM2.MachineCode
        WHERE PRH2.RouteCode = 'V-23_BG' AND PRH2.ProdDateTime >= '2026-04-15' AND MM2.MachineName LIKE '%Winding%'
    )
    AND PRH.RouteCode = 'V-23_BG'
ORDER BY 
    SI.Barcode, PRH.ProdDateTime ASC
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
