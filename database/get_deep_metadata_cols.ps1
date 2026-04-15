Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

function Get-Cols($tbl) {
    Write-Host "--- Table: $tbl ---"
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT TOP 0 * FROM $tbl"
    $reader = $cmd.ExecuteReader()
    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
        Write-Host $reader.GetName($i)
    }
    $reader.Close()
}

$tables = @('STB_BaseCode', 'STB_ConstCodeInfo', 'STB_LabelInfo')
foreach ($t in $tables) { Get-Cols $t }

$conn.Close()
