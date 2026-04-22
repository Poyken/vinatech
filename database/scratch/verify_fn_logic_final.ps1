Add-Type -AssemblyName System.Data
$connStr = "Server=dbserver.hycap.co.kr,5398;Initial Catalog=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    
    # 1. Check Function Definition
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('fn_VVT_getdatebyVendorLot')"
    $def = $cmd.ExecuteScalar()
    if ($def -like "*PBDM00-184*") {
        Write-Host "Logic for PBDM00-184 found in definition."
    } else {
        Write-Host "CRITICAL: Logic for PBDM00-184 NOT found in definition!"
    }

    # 2. Run Test Cases
    $testCases = @(
        @('PBDM00-184', '20260421', '2026-04-21'),
        @('PBDM00-186', '20260421', '2026-04-21'),
        @('PBDM00-171', '20260421', '2026-04-21'),
        @('PBDM00-187', '21A01', '2021-10-01') # Original logic for -187: 20 + 21 + '-' + A(10) + '-' + charindex('z')?? No, charindex('z') was used in my check.
    )

    foreach ($test in $testCases) {
        $mCode = $test[0]
        $vLot = $test[1]
        $expected = $test[2]

        $cmdTest = $conn.CreateCommand()
        $cmdTest.CommandText = "SELECT [dbo].[fn_VVT_getdatebyVendorLot]('$mCode', '$vLot') as Result"
        $actual = $cmdTest.ExecuteScalar()
        
        if ($actual -eq $expected) {
            Write-Host "PASS: Material $mCode | Lot $vLot | Result $actual"
        } else {
            Write-Host "FAIL: Material $mCode | Lot $vLot | Expected $expected | Actual $actual"
        }
    }

} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    $conn.Close()
}
