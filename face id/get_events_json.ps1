param(
    [int]$Top = 500
)

$server = "192.168.184.250,1433"
$database = "HCP_DATA"
$user = "hikcentral"
$password = "vinatech@2026"

$connStr = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Connect Timeout=5;"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandTimeout = 10
    $cmd.CommandText = "SELECT TOP $Top RecordID, EmployeeID, PersonName, Department, AccessDateTime, AccessDate, AccessTime, AuthenticationType, AuthenticationResult, DeviceName, DeviceSerialNo, ResourceName, ReaderName, CardNumber, Direction, CreatedAt FROM dbo.HCP_AccessRecord ORDER BY AccessDateTime DESC"
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $null = $adapter.Fill($dt)
    $conn.Close()

    $rows = @()
    foreach ($r in $dt.Rows) {
        $obj = [ordered]@{}
        foreach ($col in $dt.Columns) {
            $obj[$col.ColumnName] = [string]$r[$col.ColumnName]
        }
        $rows += $obj
    }
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $rows | ConvertTo-Json -Compress
} catch {
    Write-Output "[]"
}
