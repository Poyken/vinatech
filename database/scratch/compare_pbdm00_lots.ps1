Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # 1. Inspect recent lots for PBDM00-186 using correct columns
    $cmd.CommandText = "SELECT TOP 10 MaterialCode, VendorLotNo, LotAttr10, CreateDateTime FROM STB_MaterialDocLotInfo WHERE MaterialCode LIKE 'PBDM00-186%' ORDER BY CreateDateTime DESC"
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Recent Lots for PBDM00-186 ---"
    while ($reader.Read()) {
        Write-Host "Material: '$($reader['MaterialCode'])' | VendorLot: '$($reader['VendorLotNo'])' | Date (Attr10): '$($reader['LotAttr10'])' | Created: $($reader['CreateDateTime'])"
    }
    $reader.Close()

    # 2. Compare with PBDM00-184 to see why it worked
    $cmd.CommandText = "SELECT TOP 3 MaterialCode, VendorLotNo, LotAttr10, CreateDateTime FROM STB_MaterialDocLotInfo WHERE MaterialCode LIKE 'PBDM00-184%' ORDER BY CreateDateTime DESC"
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Recent Lots for PBDM00-184 ---"
    while ($reader.Read()) {
        Write-Host "Material: '$($reader['MaterialCode'])' | VendorLot: '$($reader['VendorLotNo'])' | Date (Attr10): '$($reader['LotAttr10'])' | Created: $($reader['CreateDateTime'])"
    }
    $reader.Close()

} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
