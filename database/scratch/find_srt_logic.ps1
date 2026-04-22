Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=30;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()

Write-Host "--- Searching for T4029 in Stored Procedure source code ---"
$cmd.CommandText = "SELECT DISTINCT OBJECT_NAME(id) as SP_Name FROM syscomments WHERE text LIKE '%T4029%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SP: $($reader['SP_Name'])"
}
$reader.Close()

Write-Host "`n--- Searching for SRT (Sorting) Related SPs ---"
$cmd.CommandText = "SELECT name FROM sys.objects WHERE (name LIKE '%SRT%' OR name LIKE '%Sorting%') AND type = 'P'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "SP: $($reader['name'])"
}
$reader.Close()

$conn.Close()
