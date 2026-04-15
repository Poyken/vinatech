Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
    SELECT bd.MaterialCode AS ModelCode, bd.ChildMaterialCode, mm.MaterialName 
    FROM STB_BomDetail bd 
    JOIN STB_MaterialMaster mm ON bd.ChildMaterialCode = mm.MaterialCode
    WHERE bd.MaterialCode = 'VEC3R0406QC' AND mm.ProductGroupCode = 'ELECTROLYTE'
"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Model: $($reader['ModelCode']) | BOM Electrolyte: $($reader['ChildMaterialCode']) | Name: $($reader['MaterialName'])"
}
$conn.Close()
