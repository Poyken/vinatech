. "$PSScriptRoot\db_shared.ps1"
$conn = Get-DbConnection -Profile "SmartFactoryV2"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT definition, modify_date FROM sys.sql_modules m JOIN sys.objects o ON m.object_id = o.object_id WHERE m.object_id = OBJECT_ID('usp_ProdInspectionHist_get')"
$reader = $cmd.ExecuteReader()
if ($reader.Read()) {
    $def = $reader["definition"].ToString()
    $mDate = $reader["modify_date"]
    [System.IO.File]::WriteAllText("$PSScriptRoot\usp_ProdInspectionHist_get_live.sql", $def, [System.Text.Encoding]::UTF8)
    Write-Host "Live SP pulled successfully!"
    Write-Host "Modify Date: $mDate"
    Write-Host "Length: $($def.Length)"
} else {
    Write-Host "SP not found!"
}
$conn.Close()
