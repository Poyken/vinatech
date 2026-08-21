. "$PSScriptRoot\..\db_shared.ps1"
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('usp_SanminaIndiaLabelPrintHist_iud')) AS def"
$r = $cmd.ExecuteReader()
if ($r.Read()) {
    $r["def"] | Out-File -FilePath "$PSScriptRoot\sp_hist_iud.sql" -Encoding utf8
    Write-Output "Exported usp_SanminaIndiaLabelPrintHist_iud successfully."
}
$conn.Close()
