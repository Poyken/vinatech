Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Get VVT Menu Hierarchy (Fix bit column and search more broadly)
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT Name, Caption, ParentName, TCode FROM STB_ScreenInfo WHERE (Name LIKE 'VVT%' OR Name LIKE 'Vietnam%') AND IsDelete = 0 ORDER BY ParentName, Name"
$reader = $cmd.ExecuteReader()
Write-Host "--- VVT / VIETNAM MENUS ---"
while ($reader.Read()) {
    Write-Host "Menu: $($reader['Name']) | Parent: $($reader['ParentName']) | Caption: $($reader['Caption'])"
}
$reader.Close()

# 2. Map SPs for key VVT screens (including some common ones)
$screens = @('VVT_MaterialStockList', 'VVT_RawMaterialInputHist', 'VVT_MaterialQcInfo', 'Vietnam_BigBoxPacking', 'Vietnam_DividPackaging')
foreach ($screen in $screens) {
    Write-Host "`n--- SP Mapping for: $screen ---"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT ObjectName, Caption, Description FROM STB_ScreenObjects WHERE ScreenName = '$screen'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "Object: $($reader['ObjectName']) | Caption: $($reader['Caption']) | Proc: $($reader['Description'])"
    }
    $reader.Close()
}

$conn.Close()
