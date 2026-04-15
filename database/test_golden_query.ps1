Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$controlNo = '20260409000089' # Sample from previous trace result

Write-Host "--- Golden Query Test for Barcode: $controlNo ---"

$sql = @"
SELECT 
    PRH.ControlNo, 
    PRH.PONo, 
    PRH.RouteCode, 
    RI.RouteName,
    POI.MaterialCode, 
    DP.PackingID, 
    DP.BoxID,
    PRH.CreateDateTime
FROM STB_ProdRouteHist PRH WITH(NOLOCK)
LEFT JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON PRH.PONo = POI.PONo
LEFT JOIN STB_RouteInfo RI WITH(NOLOCK) ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_DividePackaging DP WITH(NOLOCK) ON PRH.ControlNo = DP.LotNo
WHERE PRH.ControlNo = '$controlNo' 
ORDER BY PRH.CreateDateTime ASC
"@

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Time: $($reader['CreateDateTime']) | Route: $($reader['RouteCode']) ($($reader['RouteName'])) | PO: $($reader['PONo']) | Pack: $($reader['PackingID'])"
}
$reader.Close()

$conn.Close()
