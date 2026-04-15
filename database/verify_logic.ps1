Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$testCodes = @('GBAKAC-608', 'GBAKAC-048', 'GBAKAC-039')

# We need a sample MaterialDocDetailNo that has these codes to test the procedures fully, 
# or we can just check if they are in the database first.
# For verification, we can just run a query that selects with the CASE statement or check the SP definition again.

foreach ($code in $testCodes) {
    Write-Host "Verifying MaterialName for code: $code"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT MaterialName, 
                               CASE 
                                   WHEN MaterialCode = 'GBAKAC-608' THEN MaterialName + ' 600F'
                                   WHEN MaterialCode = 'GBAKAC-048' THEN MaterialName + ' VPC'
                                   WHEN MaterialCode = 'GBAKAC-039' THEN MaterialName + ' VPC'
                                   ELSE MaterialName 
                               END AS ExpectedName
                        FROM STB_MaterialMaster 
                        WHERE MaterialCode = '$code'"
    $reader = $cmd.ExecuteReader()
    if ($reader.Read()) {
        Write-Host "Original: $($reader['MaterialName'])"
        Write-Host "Expected: $($reader['ExpectedName'])"
    }
    $reader.Close()
}

$conn.Close()
