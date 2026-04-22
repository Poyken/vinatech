Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # 1. Detailed Inspection for PBDM00-186 (Show all Lot related columns)
    $cmd.CommandText = "SELECT TOP 5 MaterialCode, MaterialLotNo, LotNo, VendorLotNo, LotAttr10, CreateDateTime FROM STB_MaterialDocLotInfo WHERE MaterialCode = 'PBDM00-186' ORDER BY CreateDateTime DESC"
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Detailed Lot Data for PBDM00-186 ---"
    while ($reader.Read()) {
        Write-Host "Code: '$($reader['MaterialCode'])' | MatLotNo: '$($reader['MaterialLotNo'])' | LotNo: '$($reader['LotNo'])' | VendorLotNo: '$($reader['VendorLotNo'])' | Date (Attr10): '$($reader['LotAttr10'])' | Created: $($reader['CreateDateTime'])"
    }
    $reader.Close()

    # 2. Check if a very recent lot (post-fix) exists
    $cmd.CommandText = "SELECT TOP 1 [dbo].[fn_VVT_getdatebyVendorLot]('PBDM00-186', '20260421') as TestResult"
    $res = $cmd.ExecuteScalar()
    Write-Host "Manual Function Test Result: $res"

} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
