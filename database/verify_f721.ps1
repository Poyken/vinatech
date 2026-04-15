Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$testCodes = @('GBAKAC-608', 'GBAKAC-048', 'GBAKAC-039', 'GBAKAC-050', 'GBAKAC-033')

Write-Host "Verifying logic in SQL (simulating SP output)..."
foreach ($code in $testCodes) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT MaterialName, 
                               CASE 
                                   WHEN MaterialCode = 'GBAKAC-608' THEN REPLACE(MaterialName, '(', '-600F(')
                                   WHEN MaterialCode = 'GBAKAC-048' THEN REPLACE(MaterialName, '(', '-VPC(')
                                   WHEN MaterialCode = 'GBAKAC-039' THEN REPLACE(MaterialName, '(', '-VPC(')
                                   WHEN MaterialCode = 'GBAKAC-050' THEN REPLACE(MaterialName, '(', '-VPC(')
                                   WHEN MaterialCode = 'GBAKAC-033' THEN REPLACE(MaterialName, '(', '-500F(')
                                   ELSE MaterialName 
                               END AS NewName
                        FROM STB_MaterialMaster 
                        WHERE MaterialCode = '$code'"
    $reader = $cmd.ExecuteReader()
    if ($reader.Read()) {
        Write-Host "Code: $code | Result: $($reader['NewName'])"
    } else {
        Write-Host "Code: $code | NOT FOUND"
    }
    $reader.Close()
}

$conn.Close()
