param()
$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared
$conn = Get-DbConnection -Profile "SmartFramework"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT Format FROM STB_LabelInfo WHERE LabelType = 'BoxLabel' AND FormatName = (SELECT TOP 1 FormatName FROM SmartFactoryV2.dbo.STB_ModelLabelInfo WHERE ModelCode = 'ECVT30-357' AND LabelType = 'BoxLabel')"
$format = $cmd.ExecuteScalar()
$conn.Close()
$outPath = Join-Path $PSScriptRoot "box_label_format.xml"
[System.IO.File]::WriteAllText($outPath, $format, [System.Text.Encoding]::UTF8)
Write-Host "Exported box_label_format.xml, Length: $($format.Length)"
