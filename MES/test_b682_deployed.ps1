$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"
$cs = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"

$conn = New-Object System.Data.SqlClient.SqlConnection($cs)
$conn.Open()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "EXEC usp_Get_VVT_Prod_Bad_Status @pProcessUserID='vinaadmin', @pProcessLanguage='vi', @pUtcOffset=420, @pCompanyCode='VVT', @pWorkCenterCode='VVT_F1', @pFromDate='2026-05-28', @pToDate='2026-06-04';"

try {
    $reader = $cmd.ExecuteReader()
    Write-Host "=== Deployed usp_Get_VVT_Prod_Bad_Status test ==="
    $count = 0
    $nonCellFound = 0
    while ($reader.Read()) {
        $jobDate = $reader.GetValue(0)
        $lineCode = $reader.GetValue(1)
        $routeCode = $reader.GetValue(2)
        $routeName = $reader.GetValue(3)
        $matCode = $reader.GetValue(4)
        $defectCode = $reader.GetValue(6)
        $qty = $reader.GetValue(8)
        
        if ($routeCode -notlike "V-*") {
            $nonCellFound++
            Write-Host "WARNING: Found non-cell route: $routeCode for jobDate $jobDate" -ForegroundColor Yellow
        }
        
        if ($count -lt 15) {
            Write-Host ("JobDate: {0} | RouteCode: {1} | RouteName: {2} | Material: {3} | DefectCode: {4} | Qty: {5}" -f $jobDate, $routeCode, $routeName, $matCode, $defectCode, $qty)
        }
        $count++
    }
    $reader.Close()
    Write-Host "`nTotal records returned: $count"
    Write-Host "Non-cell routes found: $nonCellFound"
} catch {
    Write-Host "Error: $_"
}

$conn.Close()
