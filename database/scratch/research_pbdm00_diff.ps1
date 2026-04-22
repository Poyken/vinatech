Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    # 1. Search for PBDM00-184 in all SQL modules
    $cmd.CommandText = "
        SELECT o.name, o.type_desc 
        FROM sys.sql_modules m 
        JOIN sys.objects o ON m.object_id = o.object_id 
        WHERE m.definition LIKE '%PBDM00-184%'
    "
    $reader = $cmd.ExecuteReader()
    Write-Host "--- Objects containing 'PBDM00-184' ---"
    while ($reader.Read()) {
        Write-Host "$($reader['type_desc']): $($reader['name'])"
    }
    $reader.Close()

    # 2. Extract usp_Vietnam_RawMaterialInputHist_uid
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid'))"
    $res = $cmd.ExecuteScalar()
    if ($res) {
        $res.ToString() | Out-File -FilePath "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\usp_Vietnam_RawMaterialInputHist_uid.sql" -Encoding UTF8
        Write-Host "Extracted usp_Vietnam_RawMaterialInputHist_uid"
    }

} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
