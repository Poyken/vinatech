Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # 1. Search for all objects referencing the function
    $cmd.CommandText = "
        SELECT DISTINCT o.name, o.type_desc 
        FROM sys.sql_modules m 
        JOIN sys.objects o ON m.object_id = o.object_id 
        WHERE m.definition LIKE '%fn_VVT_getdatebyVendorLot%'
    "
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Callers of fn_VVT_getdatebyVendorLot ---"
    while ($reader.Read()) {
        Write-Host "$($reader['type_desc']): $($reader['name'])"
    }
    $reader.Close()

    # 2. Check for PBDM00-186 in any other logic (to find overrides)
    $cmd.CommandText = "
        SELECT name, type_desc FROM sys.sql_modules m 
        JOIN sys.objects o ON m.object_id = o.object_id 
        WHERE m.definition LIKE '%PBDM00-186%' 
        AND o.name <> 'fn_VVT_getdatebyVendorLot'
    "
    $reader = $cmd.ExecuteReader()
    Write-Host "`n--- Potential Overrides or Special Logic for PBDM00-186 ---"
    while ($reader.Read()) {
        Write-Host "$($reader['type_desc']): $($reader['name'])"
    }
    $reader.Close()

    # 3. Verify exactly how the material code string looks
    $cmd.CommandText = "
        SELECT TOP 1 MaterialCode, LEN(MaterialCode) as CodeLen, ASCII(SUBSTRING(MaterialCode, LEN(MaterialCode), 1)) as LastChar 
        FROM STB_MaterialDocLotInfo 
        WHERE MaterialCode LIKE 'PBDM00-186%'
    "
    $reader = $cmd.ExecuteReader()
    Write-Host "`n--- Material Code String Verification ---"
    while ($reader.Read()) {
        Write-Host "Code: '$($reader['MaterialCode'])' | Length: $($reader['CodeLen']) | LastChar ASCII: $($reader['LastChar'])"
    }
    $reader.Close()

} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
