Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

$screens = @('Vietnam_MaterialGrFromOrder', 'VvtProductionOrderInfo', 'Vietnam_ProductionResult', 'Vietnam_Donggoi', 'Vietnam_TonBanThanhPham', 'VvtProdBadStatus')
foreach ($screen in $screens) {
    Write-Host "`n--- SP Mapping for: $screen ---"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT ObjectName, Caption, Description FROM STB_ScreenObjects WHERE ScreenName = '$screen' AND ObjectType = 'Function'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Object: $($reader['ObjectName']) | Caption: $($reader['Caption']) | Proc: $($reader['Description'])"
    }
    $reader.Close()
}

$conn.Close()
