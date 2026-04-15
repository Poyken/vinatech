[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Data

$server = "dbserver.hycap.co.kr,5398"
$db = "SmartFactoryV2"
$uid = "vinaadmin"
$pwd = [System.Uri]::EscapeDataString("vina1234%6&8")
$connStr = "Server=$server;Database=$db;User ID=$uid;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;"
$outFile = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\SP_Source_FromDB.md"

$targetSPs = "usp_RawMaterialInputHist_iud","usp_MaterialQcInfo_iud","usp_MaterialWarehouseInOutHist_iud","usp_VVTMaterialWarehouse_validFIFO","pop_Electrode_Coating_iud","pop_Electrode_RollPressing_iud","usp_ElectrodeSlittingResult_iud","usp_ElectrodeWasteInfoNew_iud","usp_DoProcessProdRouteHist","usp_DoProcessProdGIMaterialByBOM","usp_DoProcessProdGRMaterialByOne","usp_InsertDataAgingAndSorting","usp_DefectInfo_iud","usp_Add_VN_SCRAP_WEIGHSCALE_PRODUCTIONS","usp_Vietnam_DoProcessBigBoxPacking_VVT_F3","usp_DivideAndPrintPackagingLabels","usp_VN_FinishGood_BG_StockIn_iud","usp_ExportWarehouseFinshGood_RD_HN_uid","usp_BomDetail_iud","usp_BomHeader_iud","usp_RouteInfo_iud","usp_RouteInfo_get"

Write-Host "Connecting..."
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
Write-Host "Connected OK to $server / $db"

$inClause = ($targetSPs | ForEach-Object { "'" + $_ + "'" }) -join ","
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM sys.procedures WHERE name IN ($inClause) ORDER BY name"
$reader = $cmd.ExecuteReader()
$foundSPs = @()
while ($reader.Read()) { $foundSPs += $reader["name"] }
$reader.Close()

$missingSPs = $targetSPs | Where-Object { $_ -notin $foundSPs }

Write-Host "Found $($foundSPs.Count)/22 SPs"
$foundSPs | ForEach-Object { Write-Host "  OK: $_" }
if ($missingSPs.Count -gt 0) {
    Write-Host "MISSING:"
    $missingSPs | ForEach-Object { Write-Host "  MISS: $_" }
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# VINATECH MES - SOURCE CODE STORED PROCEDURES (Từ Database Thực Tế)")
$lines.Add("> **Server:** ``dbserver.hycap.co.kr,5398`` | **Database:** ``SmartFactoryV2`` | **Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
$lines.Add("")
$lines.Add("## Verification")
$lines.Add("")
$foundSPs | ForEach-Object { $lines.Add("- OK: ``$_``") }
$missingSPs | ForEach-Object { $lines.Add("- MISSING: ``$_``") }
$lines.Add("")
$lines.Add("---")
$lines.Add("")

foreach ($sp in $foundSPs) {
    Write-Host "Fetching $sp..."
    $c = $conn.CreateCommand()
    $c.CommandText = "SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.$sp')) AS def"
    $r = $c.ExecuteReader()
    $def = ""
    if ($r.Read() -and $r["def"] -ne [DBNull]::Value) { $def = $r["def"].ToString() }
    $r.Close()

    $lines.Add("## $sp")
    $lines.Add("")
    if ($def -ne "") {
        $lines.Add('```sql')
        $lines.Add($def)
        $lines.Add('```')
    } else {
        $lines.Add("*Definition not accessible*")
    }
    $lines.Add("")
    $lines.Add("---")
    $lines.Add("")
}

$conn.Close()
[System.IO.File]::WriteAllLines($outFile, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host "DONE - Output: $outFile"
