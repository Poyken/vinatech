param()
$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared
$conn = Get-DbConnection -Profile "POP"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT Format FROM VINA_LABEL_INFO WHERE FormatName LIKE '%VietNam%'"
$format = $cmd.ExecuteScalar()
$conn.Close()
$outPath = Join-Path $PSScriptRoot "pop_box_label_format.xml"
[System.IO.File]::WriteAllText($outPath, $format, [System.Text.Encoding]::UTF8)
Write-Host "Exported POP label format, length: $($format.Length)"
