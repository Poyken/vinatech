$sps = @(
"usp_CheckInputRawMaterialCodeForProduct",
"usp_DoMakeRawMaterialInputHist",
"usp_RawMaterialInputHist_iud",
"usp_Vietnam_RawMaterialInputHist_uid",
"usp_DoChangeMaterialForSetInfo",
"usp_DoDeleteMaterialForSetInfo",
"usp_EelctrolyteInputHist_get",
"usp_Electrode_Lot_Transfer",
"usp_ElectrodeLotHist_get",
"usp_ElectrodeRawMaterialInputFullHist_get",
"usp_getInfoLotNoByElectroic",
"usp_GetProdRouteHistForBarcode_VNT",
"usp_List_Electrode_Lot_BG",
"usp_ListElectronNotImported",
"usp_ListMaterialNotImported",
"usp_RawMaterialInputFullHist_get",
"usp_RawMaterialInputHist_get",
"usp_RawMaterialInputHist_popup",
"usp_RawMaterialNotInput_popup",
"usp_UpdateChangeLineMaterialElectron",
"usp_Vietnam_PackPrintTime_get",
"usp_Vietnam_PackPrintTime_GetData"
)

foreach ($sp in $sps) {
    $outFile = ".\$sp.sql"
    if (Test-Path $outFile) { Write-Host "Skipping $sp, already exists."; continue }
    
    Write-Host "Fetching $sp..."
    $success = $false
    for ($i=1; $i -le 3; $i++) {
        sqlcmd -S "dbserver.hycap.co.kr,5398" -U "vinaadmin" -P "vina1234%6&8" -d "SmartFactoryV2" -t 30 -Q "sp_helptext '$sp'" -o "$outFile" -W -C
        if ($LASTEXITCODE -eq 0) {
            $success = $true
            Write-Host "Successfully fetched $sp."
            break
        } else {
            Write-Host "Attempt $i failed for $sp. Retrying..."
            Start-Sleep -Seconds 2
        }
    }
    if (-not $success) { Write-Host "Failed to fetch $sp after 3 attempts." }
}
