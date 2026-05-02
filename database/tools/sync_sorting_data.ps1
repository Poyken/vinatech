$ErrorActionPreference = 'Stop'
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$workbook = $null

$sql = "USE SmartFactoryV2;`r`nGO`r`n"
$sql += "TRUNCATE TABLE STB_VVT_SortingErrorData_ALCase;`r`n"
$sql += "TRUNCATE TABLE STB_VVT_SortingErrorData_Plate;`r`nGO`r`n"

function DumpSheet {
    param (
        [string]$tableName,
        [bool]$isAL,
        $worksheet
    )
    
    $range = $worksheet.UsedRange
    $rows = $range.Rows.Count
    $cols = $range.Columns.Count

    for ($r = 5; $r -le $rows; $r++) {
        if ($isAL) {
            $colDate = 2; $colShift = 3; $colPerson = 4; $colVendor = 5; $colFactory = 6; $colMat = 7; $colLot = 8; $colChk = 9; $colOk = 10; $defStart = 11; $defCount = 11
        } else {
            $colDate = 1; $colShift = 2; $colPerson = 3; $colVendor = 4; $colFactory = 5; $colMat = 6; $colLot = 7; $colChk = 8; $colOk = 9; $defStart = 10; $defCount = 10
        }

        $dVal = $range.Cells.Item($r, $colDate).Text
        if ([string]::IsNullOrWhiteSpace($dVal)) { continue }
        if ($dVal.Trim().ToLower() -eq "total") { continue }
        
        $parsedDate = ''
        try {
            $parsedateObj = [datetime]::Parse($dVal)
            $parsedDate = $parsedateObj.ToString("yyyy-MM-dd")
        } catch {
            continue
        }

        $shiftVal = $range.Cells.Item($r, $colShift).Text.Trim()
        $personVal = $range.Cells.Item($r, $colPerson).Text.Trim()
        $vendorVal = $range.Cells.Item($r, $colVendor).Text.Trim()
        $factoryVal = $range.Cells.Item($r, $colFactory).Text.Trim()
        $matCodeVal = $range.Cells.Item($r, $colMat).Text.Trim()
        $lotNoVal = $range.Cells.Item($r, $colLot).Text.Trim()
        
        $chkStr = $range.Cells.Item($r, $colChk).Text -replace '[^\d]', ''
        $okStr = $range.Cells.Item($r, $colOk).Text -replace '[^\d]', ''
        $qtyChk = if ([string]::IsNullOrEmpty($chkStr)) { '0' } else { $chkStr }
        $qtyOk = if ([string]::IsNullOrEmpty($okStr)) { '0' } else { $okStr }

        $defects = @()
        for ($i = 0; $i -lt $defCount; $i++) {
            $dv = $range.Cells.Item($r, $defStart + $i).Text -replace '[^\d]', ''
            if ([string]::IsNullOrWhiteSpace($dv)) { $dv = 'NULL' }
            $defects += $dv
        }
        
        $shift = if ($shiftVal -eq '-' -or [string]::IsNullOrEmpty($shiftVal)) { 'NULL' } else { "'$shiftVal'" }
        $person = if ($personVal -eq '-' -or [string]::IsNullOrEmpty($personVal)) { 'NULL' } else { "N'$personVal'" }
        $vendor = if ($vendorVal -eq '-' -or [string]::IsNullOrEmpty($vendorVal)) { 'NULL' } else { "'$vendorVal'" }
        $factory = if ($factoryVal -eq '-' -or [string]::IsNullOrEmpty($factoryVal)) { 'NULL' } else { "N'$factoryVal'" }
        $matCode = if ($matCodeVal -eq '-' -or [string]::IsNullOrEmpty($matCodeVal)) { 'NULL' } else { "'$matCodeVal'" }
        $lotNo = if ($lotNoVal -eq '-' -or [string]::IsNullOrEmpty($lotNoVal)) { 'NULL' } else { "'$lotNoVal'" }
        
        $defJoin = $defects -join ", "
        
        $script:sql += "INSERT INTO $tableName (SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK"
        if ($isAL) {
            $script:sql += ", ALBurrNhom, ALBurrNhua, ALBurrCaoSu, ALBongTamNhua, ALXuocScratch, ALBienDangDeform, ALHoDongExposed, ALBienDangCaoSu, ALNutGoCrackWood, ALBienSacDiscolor, ALOther) "
        } else {
            $script:sql += ", PLBurr, PLMoDent, PLMepDeform, PLXuocScratch, PLBongMaNG, PLSanRoughFace, PLBanDirty, PLLomDayDentBottom, PLBienSacDiscolor, PLOther) "
        }
        $script:sql += "VALUES ('$parsedDate', $shift, $person, $vendor, $factory, $matCode, $lotNo, $qtyChk, $qtyOk, $defJoin);`r`n"
    }
}

try {
    $workbook = $excel.Workbooks.Open("c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Data sorting.xlsx")
    DumpSheet -tableName "STB_VVT_SortingErrorData_ALCase" -isAL $true -worksheet $workbook.Sheets.Item(1)
    DumpSheet -tableName "STB_VVT_SortingErrorData_Plate" -isAL $false -worksheet $workbook.Sheets.Item(2)
    $script:sql | Out-File "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\insert_sorting_fixed.sql" -Encoding UTF8
    Write-Host "Success"
} catch {
    Write-Host "Error: $_"
} finally {
    if ($workbook) { $workbook.Close($false) }
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
}
