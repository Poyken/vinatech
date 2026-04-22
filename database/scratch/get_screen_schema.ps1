Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

$tables = @('STB_ScreenInfo', 'STB_ScreenLayoutInfo', 'STB_ScreenObjects')

foreach ($table in $tables) {
    Write-Host "--- Schema for $table ---"
    $cmd.CommandText = "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$table'"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "$($reader['COLUMN_NAME']) ($($reader['DATA_TYPE']))"
    }
    $reader.Close()
    Write-Host ""
}

$conn.Close()
