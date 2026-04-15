Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$sqlPath = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\usp_vvt_MaterialLotInfo_get.sql'
$sql = Get-Content $sqlPath -Raw

# Replace CREATE with ALTER anywhere in the beginning part of the script
$sql = $sql -replace '(?im)^\s*CREATE\s+PROCEDURE', 'ALTER PROCEDURE'

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
try {
    $cmd.ExecuteNonQuery()
    Write-Host "Successfully updated usp_vvt_MaterialLotInfo_get"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
