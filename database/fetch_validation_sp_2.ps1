Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_jud')) AS def"
$reader = $cmd.ExecuteReader()
if ($reader.Read() -and $reader['def'] -ne [DBNull]::Value) {
    [System.IO.File]::WriteAllText('c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_jud.sql', $reader['def'].ToString())
    Write-Host "Fetched usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_jud.sql"
} else {
    Write-Host "Procedure not found or has no definition."
}
$conn.Close()
