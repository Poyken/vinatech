Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $sql = Get-Content -Path "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\patch_parsing_fn.sql" -Raw
    
    # Split by GO
    $commands = $sql -split "(?m)^\s*GO\s*$"
    foreach ($cmdStr in $commands) {
        if ($cmdStr.Trim().Length -gt 0) {
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $cmdStr
            $cmd.ExecuteNonQuery()
        }
    }
    Write-Host "Success: Function fn_VVT_getdatebyVendorLot has been updated."
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
