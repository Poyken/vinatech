Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.usp_Vietnam_RawMaterialInputHist_uid')) AS def"
$reader = $cmd.ExecuteReader()
if ($reader.Read() -and $reader['def'] -ne [DBNull]::Value) {
    $def = $reader['def'].ToString()
    if ($def -like "*VEC3R0406QC*") {
        Write-Host "Verification Success: Model VEC3R0406QC found in deployed procedure."
    } else {
        Write-Host "Verification Failure: Model VEC3R0406QC not found in deployed procedure."
    }
}
$conn.Close()
