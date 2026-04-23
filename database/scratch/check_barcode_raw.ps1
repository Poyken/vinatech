Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=5;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT * FROM STB_SetInfo WHERE Barcode = 'WQM193R072798'"
    $reader = $cmd.ExecuteReader()
    while($reader.Read()){
        for($i=0; $i -lt $reader.FieldCount; $i++){
            Write-Host "$($reader.GetName($i)): $($reader.GetValue($i))"
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
