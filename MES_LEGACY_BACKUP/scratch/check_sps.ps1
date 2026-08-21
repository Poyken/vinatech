. "$PSScriptRoot\..\db_shared.ps1"
$conn = Get-DbConnection
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "
SELECT 
    OBJECT_DEFINITION(OBJECT_ID('usp_SanminaShipmentPlan_get')) AS sp_plan_get,
    OBJECT_DEFINITION(OBJECT_ID('usp_SanminaShipmentPlan_iud')) AS sp_plan_iud,
    OBJECT_DEFINITION(OBJECT_ID('usp_SanminaLabelPrint_get_Vietnam')) AS sp_print_get
"
$r = $cmd.ExecuteReader()
if ($r.Read()) {
    $r["sp_plan_get"] | Out-File -FilePath "$PSScriptRoot\sp_plan_get.sql" -Encoding utf8
    $r["sp_plan_iud"] | Out-File -FilePath "$PSScriptRoot\sp_plan_iud.sql" -Encoding utf8
    $r["sp_print_get"] | Out-File -FilePath "$PSScriptRoot\sp_print_get.sql" -Encoding utf8
    Write-Output "Successfully exported SP definitions."
}
$conn.Close()
