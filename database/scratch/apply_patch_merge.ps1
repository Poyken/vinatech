Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    
    $sql = Get-Content "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\patch_merge_code_fn.sql" -Raw
    $cmd.CommandText = $sql
    $cmd.ExecuteNonQuery()
    Write-Host "Successfully patched fn_VVT_getdatebyVendorLot_MergeCode!"

    # Test the function with PBDM00-186
    $cmd.CommandText = "SELECT dbo.fn_VVT_getdatebyVendorLot_MergeCode('PBDM00-186', '20260421', 'VV034')"
    $res = $cmd.ExecuteScalar()
    Write-Host "Test fn_VVT_getdatebyVendorLot_MergeCode('PBDM00-186', '20260421', 'VV034') -> $res"

} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
