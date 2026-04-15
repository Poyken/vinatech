Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$screens = @('Vietnam_MaterialGrFromOrder', 'VvtProductionOrderInfo', 'Vietnam_ProductionResult', 'Vietnam_Donggoi')
foreach ($screen in $screens) {
    Write-Host "`n--- ALL Objects for: $screen ---"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT * FROM STB_ScreenObjects WHERE ScreenName = '$screen'"
    $reader = $cmd.ExecuteReader()
    $cols = $reader.FieldCount
    while ($reader.Read()) {
        Write-Host "---"
        for ($i = 0; $i -lt $cols; $i++) {
            Write-Host "$($reader.GetName($i)) : $($reader.GetValue($i))"
        }
    }
    $reader.Close()
}

$conn.Close()
