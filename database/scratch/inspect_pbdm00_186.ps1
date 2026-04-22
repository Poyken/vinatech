Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT TOP 10 MaterialCode, VendorLot, CreateDateTime FROM STB_MaterialLot WHERE MaterialCode LIKE 'PBDM00-186%' ORDER BY CreateDateTime DESC"
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Recent Lots for PBDM00-186 ---"
    while ($reader.Read()) {
        Write-Host "Material: $($reader['MaterialCode']) | VendorLot: '$($reader['VendorLot'])' | Created: $($reader['CreateDateTime'])"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
