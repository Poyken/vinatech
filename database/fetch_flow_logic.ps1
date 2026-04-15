Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

function Get-Def($name) {
    Write-Host "`n--- DEFINITION: $name ---"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('$name')"
    $res = $cmd.ExecuteScalar()
    if ($res) {
        Write-Host $res
    } else {
        Write-Host "NOT FOUND"
    }
}

Get-Def "usp_DoProcessProdRouteHist"
Get-Def "usp_Vietnam_DoProcessProdPacking_VVT"
Get-Def "usp_ProductionOrderRouting_get"

$conn.Close()
