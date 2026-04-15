Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 1 MaterialCode, MaterialName, MaterialSpec 
                    FROM STB_MaterialMaster 
                    WHERE MaterialCode = 'GBAKAC-608'"
$reader = $cmd.ExecuteReader()
if ($reader.Read()) {
    Write-Host "Code: $($reader['MaterialCode'])"
    Write-Host "Name: $($reader['MaterialName'])"
    Write-Host "Spec: $($reader['MaterialSpec'])"
}
$reader.Close()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 1 MaterialCode, LotAttr01 
                    FROM STB_MaterialDocLotInfo 
                    WHERE MaterialCode = 'GBAKAC-608'"
$reader = $cmd.ExecuteReader()
if ($reader.Read()) {
    Write-Host "LotAttr01 (MODEL): $($reader['LotAttr01'])"
}
$reader.Close()

$conn.Close()
