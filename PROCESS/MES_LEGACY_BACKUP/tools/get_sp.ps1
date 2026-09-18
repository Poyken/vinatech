param([string]$SpName = "usp_PackingReaminQtyLabelInfo_get")
. "$PSScriptRoot\db_shared.ps1"
$conn = Get-DbConnection -Profile "SmartFactoryV2"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT definition, modify_date FROM sys.sql_modules m JOIN sys.objects o ON m.object_id = o.object_id WHERE m.object_id = OBJECT_ID('$SpName')"
$reader = $cmd.ExecuteReader()
if ($reader.Read()) {
    $def = $reader["definition"].ToString()
    $mDate = $reader["modify_date"]
    $target = "$PSScriptRoot\$SpName.sql"
    [System.IO.File]::WriteAllText($target, $def, [System.Text.Encoding]::UTF8)
    Write-Host "Live SP $SpName pulled successfully! Saved to $target"
    Write-Host "Modify Date: $mDate"
    Write-Host "Length: $($def.Length)"
} else {
    Write-Host "SP $SpName not found!"
}
$conn.Close()
