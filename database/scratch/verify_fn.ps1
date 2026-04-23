Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$testItems = @(
    @{ Material = 'PBDM00-186'; Lot = '20260423' },
    @{ Material = 'TRAY1320-B015'; Lot = '20260423' },
    @{ Material = 'TRAY1320-B015'; Lot = '260423' }
)

foreach ($item in $testItems) {
    $cmd.CommandText = "SELECT [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('$($item.Material)', '$($item.Lot)', NULL) AS Result"
    $result = $cmd.ExecuteScalar()
    Write-Host "Test [$($item.Material)] with Lot [$($item.Lot)] -> Result: $result"
}

$conn.Close()
