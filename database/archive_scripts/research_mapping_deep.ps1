Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Recent POs
Write-Host "--- Recent POs ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 5 PONo, CompanyCode, WorkCenterCode, CreateDateTime FROM STB_ProductionOrderInfo ORDER BY CreateDateTime DESC"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "PO: $($reader['PONo']) | Co: $($reader['CompanyCode']) | WC: $($reader['WorkCenterCode'])"
}
$reader.Close()

# 2. Route Codes for VVT (WorkCenterCode = 'VVT' or 'VVT_F3')
Write-Host "`n--- Route Codes (VVT) ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT RouteCode, RouteName FROM STB_RouteInfo WHERE WorkCenterCode LIKE 'VVT%' ORDER BY RouteCode"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Code: $($reader['RouteCode']) | Name: $($reader['RouteName'])"
}
$reader.Close()

# 3. Barcode Logic - Find if usp_DoCreateSerial is used for ControlNo
Write-Host "`n--- Search for 'usp_DoCreateSerial' usages in SPs ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_NAME(m.object_id) AS SPName FROM sys.sql_modules m JOIN sys.procedures p ON m.object_id = p.object_id WHERE m.definition LIKE '%usp_DoCreateSerial%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Usage: $($reader['SPName'])"
}
$reader.Close()

$conn.Close()
