param()
$shared = Join-Path $PSScriptRoot "db_shared.ps1"
. $shared
$conn = Get-DbConnection -Profile "SmartFactoryV2"
$cmd = $conn.CreateCommand()
foreach($trg in @('tgMaterialLotInfoForInsert', 'tgMaterialLotInfoForUpdate', 'tgMaterialLotInfoForDelete')) {
    $cmd.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('$trg'))"
    $res = $cmd.ExecuteScalar()
    $out = Join-Path $PSScriptRoot "$trg.sql"
    $res | Out-File -FilePath $out -Encoding UTF8
    Write-Host "Exported $trg ($($res.Length) chars)"
}
$conn.Close()
