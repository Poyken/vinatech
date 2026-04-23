Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Data
$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Data sorting.xlsx"
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=120;'

function Get-SharedStrings($zip) {
    try {
        $entry = $zip.Entries | Where-Object { $_.FullName -eq "xl/sharedStrings.xml" }
        if ($entry) {
            $stream = $entry.Open()
            $txt = (New-Object System.IO.StreamReader($stream)).ReadToEnd()
            $stream.Close()
            $xml = [xml]$txt
            return $xml.sst.si.t | ForEach-Object { if ($_ -is [string]) { $_ } else { $_."#text" } }
        }
    } catch {}
    return @()
}

function Get-CellValue($c, $ss) {
    if (-not $c) { return $null }
    $v = $c.v
    if ($c.t -eq "s") { return $ss[[int]$v] }
    return $v
}

function Convert-ExcelDate($val) {
    if ([string]::IsNullOrWhiteSpace($val)) { return $null }
    if ($val -as [double]) {
        try { return [datetime]::FromOADate([double]$val) } catch { return $null }
    }
    return $null
}

function Safe-Int($val) {
    if ([string]::IsNullOrWhiteSpace($val)) { return 0 }
    $clean = $val -replace '[^0-9-]', ''
    if ($clean -as [int]) { return [int]$clean }
    return 0
}

$zip = [System.IO.Compression.ZipFile]::OpenRead($xlsxPath)
$ss = Get-SharedStrings $zip

# -----------------------------------------------------------------------------
# AL CASE
# -----------------------------------------------------------------------------
Write-Host "Reading AL Case data (Sheet 2)..."
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet2.xml" }
$stream = $sheetEntry.Open()
$sheetXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
$stream.Close()

$dtAl = New-Object System.Data.DataTable
# Bỏ SortingErrorNo vì là IDENTITY
[void]$dtAl.Columns.Add("SortingDate", [datetime])
[void]$dtAl.Columns.Add("Shift")
[void]$dtAl.Columns.Add("PersonName")
[void]$dtAl.Columns.Add("VendorCode")
[void]$dtAl.Columns.Add("FactoryName")
[void]$dtAl.Columns.Add("MaterialCode")
[void]$dtAl.Columns.Add("LotNo")
[void]$dtAl.Columns.Add("QtyCheck", [int])
[void]$dtAl.Columns.Add("QtyOK", [int])
[void]$dtAl.Columns.Add("ALBuiDust", [int])
[void]$dtAl.Columns.Add("ALMoDent", [int])
[void]$dtAl.Columns.Add("ALMepDeform", [int])
[void]$dtAl.Columns.Add("ALXuocScratch", [int])
[void]$dtAl.Columns.Add("ALBongNBPlating", [int])
[void]$dtAl.Columns.Add("ALSanRoughFace", [int])
[void]$dtAl.Columns.Add("ALBanDirty", [int])
[void]$dtAl.Columns.Add("ALBanBoDentGroup", [int])
[void]$dtAl.Columns.Add("ALBienSacDiscolor", [int])
[void]$dtAl.Columns.Add("ALLoiKhacOther", [int])
[void]$dtAl.Columns.Add("CreateUserID")
[void]$dtAl.Columns.Add("CreateDateTime", [datetime])

$rows = $sheetXml.worksheet.sheetData.row | Where-Object { [int]$_.r -ge 4 }
foreach ($row in $rows) {
    $cols = $row.c
    $data = @{}
    foreach ($c in $cols) { $colKey = $c.r -replace '[0-9]', ''; $data[$colKey] = Get-CellValue $c $ss }
    $d = Convert-ExcelDate $data["A"]
    if (-not $d) { continue }

    $nr = $dtAl.NewRow()
    $nr["SortingDate"] = $d
    $nr["Shift"] = [string]$data["B"]
    $nr["PersonName"] = [string]$data["C"]
    $nr["VendorCode"] = [string]$data["D"]
    $nr["FactoryName"] = [string]$data["E"]
    $nr["MaterialCode"] = [string]$data["F"]
    $nr["LotNo"] = [string]$data["G"]
    $nr["QtyCheck"] = Safe-Int $data["H"]
    $nr["QtyOK"] = Safe-Int $data["I"]
    $nr["ALBuiDust"] = Safe-Int $data["J"]
    $nr["ALMoDent"] = Safe-Int $data["K"]
    $nr["ALMepDeform"] = Safe-Int $data["L"]
    $nr["ALXuocScratch"] = Safe-Int $data["M"]
    $nr["ALBongNBPlating"] = Safe-Int $data["N"]
    $nr["ALSanRoughFace"] = Safe-Int $data["O"]
    $nr["ALBanDirty"] = Safe-Int $data["P"]
    $nr["ALBanBoDentGroup"] = Safe-Int $data["Q"]
    $nr["ALBienSacDiscolor"] = Safe-Int $data["R"]
    $nr["ALLoiKhacOther"] = Safe-Int $data["S"]
    $nr["CreateUserID"] = "BulkImport"
    $nr["CreateDateTime"] = [datetime]::Now
    $dtAl.Rows.Add($nr)
}

# -----------------------------------------------------------------------------
# PLATE
# -----------------------------------------------------------------------------
Write-Host "Reading Plate data (Sheet 1)..."
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet1.xml" }
$stream = $sheetEntry.Open()
$sheetXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
$stream.Close()

$dtPl = New-Object System.Data.DataTable
# Bỏ SortingErrorNo vì là IDENTITY
[void]$dtPl.Columns.Add("SortingDate", [datetime])
[void]$dtPl.Columns.Add("Shift")
[void]$dtPl.Columns.Add("PersonName")
[void]$dtPl.Columns.Add("VendorCode")
[void]$dtPl.Columns.Add("FactoryName")
[void]$dtPl.Columns.Add("MaterialCode")
[void]$dtPl.Columns.Add("LotNo")
[void]$dtPl.Columns.Add("QtyCheck", [int])
[void]$dtPl.Columns.Add("QtyOK", [int])
[void]$dtPl.Columns.Add("PLBuuNhom", [int])
[void]$dtPl.Columns.Add("PLBuuNhua", [int])
[void]$dtPl.Columns.Add("PLBuuRandom", [int])
[void]$dtPl.Columns.Add("PLBongTamNhieu", [int])
[void]$dtPl.Columns.Add("PLXuocScratch", [int])
[void]$dtPl.Columns.Add("PLBienDangDeform", [int])
[void]$dtPl.Columns.Add("PLMoDongExposed", [int])
[void]$dtPl.Columns.Add("PLBienDangCamSu", [int])
[void]$dtPl.Columns.Add("PLNutGoCrackWood", [int])
[void]$dtPl.Columns.Add("PLBienSacDiscolor", [int])
[void]$dtPl.Columns.Add("PLOther", [int])
[void]$dtPl.Columns.Add("CreateUserID")
[void]$dtPl.Columns.Add("CreateDateTime", [datetime])

$rows = $sheetXml.worksheet.sheetData.row | Where-Object { [int]$_.r -ge 5 }
foreach ($row in $rows) {
    $cols = $row.c
    $data = @{}
    foreach ($c in $cols) { $colKey = $c.r -replace '[0-9]', ''; $data[$colKey] = Get-CellValue $c $ss }
    $d = Convert-ExcelDate $data["B"]
    if (-not $d) { continue }

    $nr = $dtPl.NewRow()
    $nr["SortingDate"] = $d
    $nr["Shift"] = [string]$data["C"]
    $nr["PersonName"] = [string]$data["D"]
    $nr["VendorCode"] = [string]$data["E"]
    $nr["FactoryName"] = [string]$data["F"]
    $nr["MaterialCode"] = [string]$data["G"]
    $nr["LotNo"] = [string]$data["H"]
    $nr["QtyCheck"] = Safe-Int $data["I"]
    $nr["QtyOK"] = Safe-Int $data["J"]
    $nr["PLBuuNhom"] = Safe-Int $data["K"]
    $nr["PLBuuNhua"] = Safe-Int $data["L"]
    $nr["PLBuuRandom"] = Safe-Int $data["M"]
    $nr["PLBongTamNhieu"] = Safe-Int $data["N"]
    $nr["PLXuocScratch"] = Safe-Int $data["O"]
    $nr["PLBienDangDeform"] = Safe-Int $data["P"]
    $nr["PLMoDongExposed"] = Safe-Int $data["Q"]
    $nr["PLBienDangCamSu"] = Safe-Int $data["R"]
    $nr["PLNutGoCrackWood"] = Safe-Int $data["S"]
    $nr["PLBienSacDiscolor"] = Safe-Int $data["T"]
    $nr["PLOther"] = Safe-Int $data["U"]
    $nr["CreateUserID"] = "BulkImport"
    $nr["CreateDateTime"] = [datetime]::Now
    $dtPl.Rows.Add($nr)
}

# -----------------------------------------------------------------------------
# BULK COPY TO DATABASE
# -----------------------------------------------------------------------------
Write-Host "Connecting to DB for Bulk Copy..."
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "TRUNCATE TABLE STB_VVT_SortingErrorData_ALCase; TRUNCATE TABLE STB_VVT_SortingErrorData_Plate;"
    $cmd.ExecuteNonQuery()
    
    # AL Case
    $bcAl = New-Object System.Data.SqlClient.SqlBulkCopy($connStr)
    $bcAl.DestinationTableName = "STB_VVT_SortingErrorData_ALCase"
    $bcAl.BulkCopyTimeout = 300
    foreach($col in $dtAl.Columns) { [void]$bcAl.ColumnMappings.Add($col.ColumnName, $col.ColumnName) }
    
    Write-Host "Bulk Copying AL Case ($($dtAl.Rows.Count) rows)..."
    $bcAl.WriteToServer($dtAl)
    
    # Plate
    $bcPl = New-Object System.Data.SqlClient.SqlBulkCopy($connStr)
    $bcPl.DestinationTableName = "STB_VVT_SortingErrorData_Plate"
    $bcPl.BulkCopyTimeout = 300
    foreach($col in $dtPl.Columns) { [void]$bcPl.ColumnMappings.Add($col.ColumnName, $col.ColumnName) }

    Write-Host "Bulk Copying Plate ($($dtPl.Rows.Count) rows)..."
    $bcPl.WriteToServer($dtPl)
    
    $conn.Close()
    Write-Host "BULK IMPORT COMPLETED!"
} catch {
    Write-Host "Error during Bulk Copy: $($_.Exception.Message)"
} finally {
    $zip.Dispose()
}
