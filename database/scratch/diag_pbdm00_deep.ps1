Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # 1. Read fn_VVT_AccountTypeWarehouseType
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('fn_VVT_AccountTypeWarehouseType'))"
    $res = $cmd.ExecuteScalar()
    if ($res) {
        $res.ToString() | Out-File -FilePath "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\fn_VVT_AccountTypeWarehouseType.sql" -Encoding UTF8
        Write-Host "Extracted fn_VVT_AccountTypeWarehouseType"
    }

    # 2. Check exact MaterialCode for these PCB codes
    $cmd.CommandText = "SELECT MaterialCode, MaterialName, MaterialType FROM STB_MaterialDocLotInfo WHERE MaterialCode LIKE 'PBDM00-18%' OR MaterialCode LIKE 'PBDM00-17%'"
    # Wait, STB_MaterialDocLotInfo might not have MaterialType. Try to find the Material table.
    $cmd.CommandText = "
        SELECT TOP 10 MaterialCode, MaterialName 
        FROM STB_MaterialDocLotInfo 
        WHERE MaterialCode IN ('PBDM00-184', 'PBDM00-186', 'PBDM00-171')
    "
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Material Verification ---"
    while ($reader.Read()) {
        Write-Host "Found Code: '$($reader['MaterialCode'])' | Name: $($reader['MaterialName'])"
    }
    $reader.Close()

} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
