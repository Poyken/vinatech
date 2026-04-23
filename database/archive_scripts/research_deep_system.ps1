Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFramework;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Investigate BaseCodes (Common Enums)
Write-Host "--- TOP BaseCode Groups ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 20 Category, COUNT(*) as Count FROM STB_BaseCode GROUP BY Category ORDER BY Count DESC"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Category: $($reader['Category']) | Count: $($reader['Count'])"
}
$reader.Close()

# 2. Investigate Constants
Write-Host "`n--- Important Constants ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 10 ConstID, ConstValue, Description FROM STB_ConstCodeInfo"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "ConstID: $($reader['ConstID']) | Value: $($reader['ConstValue']) | Desc: $($reader['Description'])"
}
$reader.Close()

# 3. Investigate Label Printing Templates
Write-Host "`n--- Label Templates ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT TOP 5 LabelName, Description FROM STB_LabelInfo WHERE LabelName LIKE '%VVT%' OR LabelName LIKE '%Vietnam%'"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Host "Label: $($reader['LabelName']) | Desc: $($reader['Description'])"
}
$reader.Close()

$conn.Close()
