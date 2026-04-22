Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # 1. Find correct table name
    $cmd.CommandText = "SELECT name FROM sys.tables WHERE name LIKE '%Material%' AND name LIKE '%Lot%'"
    $tableName = $cmd.ExecuteScalar()
    Write-Host "Detected Table Name: $tableName"

    if ($tableName) {
        # 2. Query for PBDM00-186
        $cmd.CommandText = "SELECT TOP 5 MaterialCode, VendorLot, CreateDateTime FROM $tableName WHERE MaterialCode LIKE 'PBDM00-186%' ORDER BY CreateDateTime DESC"
        $reader = $cmd.ExecuteReader()
        while ($reader.Read()) {
            Write-Host "Material: '$($reader['MaterialCode'])' | VendorLot: '$($reader['VendorLot'])' | Created: $($reader['CreateDateTime'])"
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
