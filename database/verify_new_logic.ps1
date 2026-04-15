Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$testItems = @(
    @{ Code = 'GBAKAC-608'; Suffix = '-600F' },
    @{ Code = 'GBAKAC-048'; Suffix = '-VPC' },
    @{ Code = 'GBAKAC-039'; Suffix = '-VPC' },
    @{ Code = 'GBAKAC-050'; Suffix = '-VPC' },
    @{ Code = 'GBAKAC-033'; Suffix = '-500F' }
)

foreach ($item in $testItems) {
    $code = $item.Code
    $suffix = $item.Suffix
    Write-Host "Verifying MaterialName for code: $code"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT MaterialName, 
                               REPLACE(MaterialName, '(', '$suffix(') AS NewName
                        FROM STB_MaterialMaster 
                        WHERE MaterialCode = '$code'"
    $reader = $cmd.ExecuteReader()
    if ($reader.Read()) {
        Write-Host "Original: $($reader['MaterialName'])"
        Write-Host "New Name: $($reader['NewName'])"
    } else {
        Write-Host "Code $code not found in MaterialMaster"
    }
    $reader.Close()
}

$conn.Close()
