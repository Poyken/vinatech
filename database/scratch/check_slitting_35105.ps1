Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=5;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT * FROM STB_SLITTINGLOCATIONCONFIG_VVT WHERE PartNo = '35105'"
    $reader = $cmd.ExecuteReader()
    while($reader.Read()){
        Write-Host "ID: $($reader['id']) | PartNo: $($reader['PartNo']) | Farad: $($reader['Farad']) | Width: $($reader['Width']) | Code: $($reader['SlittingCode'])"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
