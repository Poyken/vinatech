Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$filePath = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\db_live_fn_VVT_getdatebyVendorLot_MergeCode.sql'
$sql = Get-Content $filePath -Encoding UTF8 -Raw

# Ensure it uses ALTER FUNCTION if it doesn't already
if ($sql -match 'CREATE FUNCTION') {
    $sql = $sql -replace 'CREATE FUNCTION', 'ALTER FUNCTION'
}

$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
try {
    $cmd.ExecuteNonQuery()
    Write-Host "Successfully deployed fn_VVT_getdatebyVendorLot_MergeCode to database."
} catch {
    Write-Host "Failed to deploy: $($_.Exception.Message)"
}
$conn.Close()
