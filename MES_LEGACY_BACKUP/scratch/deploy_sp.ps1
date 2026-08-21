. "$PSScriptRoot\..\db_shared.ps1"
$conn = Get-DbConnection
$conn.Open()
$sql = Get-Content -Path "$PSScriptRoot\..\sql\procedures\usp_SanminaLabelPrint_get_Vietnam.sql" -Raw -Encoding UTF8
$cmd = $conn.CreateCommand()
$cmd.CommandText = $sql
try {
    $cmd.ExecuteNonQuery() | Out-Null
    Write-Output "Successfully updated stored procedure usp_SanminaLabelPrint_get_Vietnam."
} catch {
    Write-Error $_.Exception.Message
} finally {
    $conn.Close()
}
