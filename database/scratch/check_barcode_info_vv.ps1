Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=5;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT MBI.ModelName, MBI.MBISizeH, MBI.MBISizeW, MBI.MBIExtText05 FROM STB_ModelBasicInfo MBI JOIN STB_SetInfo SI ON MBI.ModelCode = SI.MaterialCode WHERE SI.Barcode = 'VVQM193R072798'"
    $reader = $cmd.ExecuteReader()
    while($reader.Read()){
        Write-Host "ModelName: $($reader['ModelName'])"
        Write-Host "MBISizeH: $($reader['MBISizeH'])"
        Write-Host "MBISizeW: $($reader['MBISizeW'])"
        Write-Host "Farad (Text05): $($reader['MBIExtText05'])"
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
