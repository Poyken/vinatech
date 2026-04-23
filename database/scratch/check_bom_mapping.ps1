Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sql = "
SELECT DISTINCT bd.MaterialCode as ModelCode, mbi.ModelName, bd.ChildMaterialCode
FROM STB_BomDetail bd
JOIN STB_ModelBasicInfo mbi ON bd.MaterialCode = mbi.ModelCode
WHERE bd.ChildMaterialCode IN ('PBDM00-184', 'PBDM00-186', 'PBDM00-171')
"

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null

if ($dt.Rows.Count -gt 0) {
    $dt | Format-Table -AutoSize
} else {
    Write-Host "No BOM mapping found for these materials."
}

$conn.Close()
