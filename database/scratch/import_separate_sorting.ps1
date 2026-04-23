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
        try {
            return [datetime]::FromOADate([double]$val).ToString("yyyy-MM-dd")
        } catch { return $null }
    }
    return $val
}

function Safe-Int($val) {
    if ([string]::IsNullOrWhiteSpace($val)) { return 0 }
    $clean = $val -replace '[^0-9-]', ''
    if ($clean -as [int]) { return [int]$clean }
    return 0
}

$zip = [System.IO.Compression.ZipFile]::OpenRead($xlsxPath)
$ss = Get-SharedStrings $zip

$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# -----------------------------------------------------------------------------
# IMPORT AL CASE (Sheet 2)
# -----------------------------------------------------------------------------
Write-Host "Importing AL Case (Sheet 2)..."
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet2.xml" }
$stream = $sheetEntry.Open()
$sheetXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
$stream.Close()

$cmdClean = $conn.CreateCommand()
$cmdClean.CommandTimeout = 120
$cmdClean.CommandText = "TRUNCATE TABLE STB_VVT_SortingErrorData_ALCase;"
$cmdClean.ExecuteNonQuery()

$transaction = $conn.BeginTransaction()
$rows = $sheetXml.worksheet.sheetData.row | Where-Object { [int]$_.r -ge 4 }
$count = 0

foreach ($row in $rows) {
    $cols = $row.c
    $data = @{}
    foreach ($c in $cols) {
        $colKey = $c.r -replace '[0-9]', ''
        $data[$colKey] = Get-CellValue $c $ss
    }

    $sortingDate = Convert-ExcelDate $data["A"]
    if (-not $sortingDate) { continue }

    try {
        $cmd = $conn.CreateCommand()
        $cmd.Transaction = $transaction
        $cmd.CommandTimeout = 120
        $cmd.CommandText = @"
            INSERT INTO STB_VVT_SortingErrorData_ALCase (
                SortingErrorNo, SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK,
                ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
                CreateUserID
            ) VALUES (
                'AL' + LEFT(REPLACE(NEWID(), '-', ''), 18), @Date, @Shift, @Person, @Vendor, @Factory, @Material, @Lot, @QtyCheck, @QtyOK,
                @E1, @E2, @E3, @E4, @E5, @E6, @E7, @E8, @E9, @E10, 'ImportScript'
            )
"@
        $_p = $cmd.Parameters.AddWithValue("@Date", $sortingDate)
        $_p = $cmd.Parameters.AddWithValue("@Shift", [string]$data["B"])
        $_p = $cmd.Parameters.AddWithValue("@Person", [string]$data["C"])
        $_p = $cmd.Parameters.AddWithValue("@Vendor", [string]$data["D"])
        $_p = $cmd.Parameters.AddWithValue("@Factory", [string]$data["E"])
        $_p = $cmd.Parameters.AddWithValue("@Material", [string]$data["F"])
        $_p = $cmd.Parameters.AddWithValue("@Lot", [string]$data["G"])
        $_p = $cmd.Parameters.AddWithValue("@QtyCheck", (Safe-Int $data["H"]))
        $_p = $cmd.Parameters.AddWithValue("@QtyOK", (Safe-Int $data["I"]))
        $_p = $cmd.Parameters.AddWithValue("@E1", (Safe-Int $data["J"]))
        $_p = $cmd.Parameters.AddWithValue("@E2", (Safe-Int $data["K"]))
        $_p = $cmd.Parameters.AddWithValue("@E3", (Safe-Int $data["L"]))
        $_p = $cmd.Parameters.AddWithValue("@E4", (Safe-Int $data["M"]))
        $_p = $cmd.Parameters.AddWithValue("@E5", (Safe-Int $data["N"]))
        $_p = $cmd.Parameters.AddWithValue("@E6", (Safe-Int $data["O"]))
        $_p = $cmd.Parameters.AddWithValue("@E7", (Safe-Int $data["P"]))
        $_p = $cmd.Parameters.AddWithValue("@E8", (Safe-Int $data["Q"]))
        $_p = $cmd.Parameters.AddWithValue("@E9", (Safe-Int $data["R"]))
        $_p = $cmd.Parameters.AddWithValue("@E10", (Safe-Int $data["S"]))
        $cmd.ExecuteNonQuery() | Out-Null
        $count++
        if ($count % 500 -eq 0) { Write-Host "Imported $count rows to AL CASE..." }
    } catch {
        Write-Host "Error at Row $($row.r): $($_.Exception.Message)"
        break
    }
}
$transaction.Commit()
Write-Host "Imported $count rows to AL Case."

# -----------------------------------------------------------------------------
# IMPORT PLATE (Sheet 1)
# -----------------------------------------------------------------------------
Write-Host "Importing Plate (Sheet 1)..."
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet1.xml" }
$stream = $sheetEntry.Open()
$sheetXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
$stream.Close()

$cmdClean.CommandText = "TRUNCATE TABLE STB_VVT_SortingErrorData_Plate;"
$cmdClean.ExecuteNonQuery()

$transaction = $conn.BeginTransaction()
$rows = $sheetXml.worksheet.sheetData.row | Where-Object { [int]$_.r -ge 5 }
$count = 0

foreach ($row in $rows) {
    $cols = $row.c
    $data = @{}
    foreach ($c in $cols) {
        $colKey = $c.r -replace '[0-9]', ''
        $data[$colKey] = Get-CellValue $c $ss
    }

    $sortingDate = Convert-ExcelDate $data["B"]
    if (-not $sortingDate) { continue }

    try {
        $cmd = $conn.CreateCommand()
        $cmd.Transaction = $transaction
        $cmd.CommandTimeout = 120
        $cmd.CommandText = @"
            INSERT INTO STB_VVT_SortingErrorData_Plate (
                SortingErrorNo, SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK,
                PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch, PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood, PLBienSacDiscolor, PLOther,
                CreateUserID
            ) VALUES (
                'PL' + LEFT(REPLACE(NEWID(), '-', ''), 18), @Date, @Shift, @Person, @Vendor, @Factory, @Material, @Lot, @QtyCheck, @QtyOK,
                @E1, @E2, @E3, @E4, @E5, @E6, @E7, @E8, @E9, @E10, @E11, 'ImportScript'
            )
"@
        $_p = $cmd.Parameters.AddWithValue("@Date", $sortingDate)
        $_p = $cmd.Parameters.AddWithValue("@Shift", [string]$data["C"])
        $_p = $cmd.Parameters.AddWithValue("@Person", [string]$data["D"])
        $_p = $cmd.Parameters.AddWithValue("@Vendor", [string]$data["E"])
        $_p = $cmd.Parameters.AddWithValue("@Factory", [string]$data["F"])
        $_p = $cmd.Parameters.AddWithValue("@Material", [string]$data["G"])
        $_p = $cmd.Parameters.AddWithValue("@Lot", [string]$data["H"])
        $_p = $cmd.Parameters.AddWithValue("@QtyCheck", (Safe-Int $data["I"]))
        $_p = $cmd.Parameters.AddWithValue("@QtyOK", (Safe-Int $data["J"]))
        $_p = $cmd.Parameters.AddWithValue("@E1", (Safe-Int $data["K"]))
        $_p = $cmd.Parameters.AddWithValue("@E2", (Safe-Int $data["L"]))
        $_p = $cmd.Parameters.AddWithValue("@E3", (Safe-Int $data["M"]))
        $_p = $cmd.Parameters.AddWithValue("@E4", (Safe-Int $data["N"]))
        $_p = $cmd.Parameters.AddWithValue("@E5", (Safe-Int $data["O"]))
        $_p = $cmd.Parameters.AddWithValue("@E6", (Safe-Int $data["P"]))
        $_p = $cmd.Parameters.AddWithValue("@E7", (Safe-Int $data["Q"]))
        $_p = $cmd.Parameters.AddWithValue("@E8", (Safe-Int $data["R"]))
        $_p = $cmd.Parameters.AddWithValue("@E9", (Safe-Int $data["S"]))
        $_p = $cmd.Parameters.AddWithValue("@E10", (Safe-Int $data["T"]))
        $_p = $cmd.Parameters.AddWithValue("@E11", (Safe-Int $data["U"]))
        $cmd.ExecuteNonQuery() | Out-Null
        $count++
        if ($count % 500 -eq 0) { Write-Host "Imported $count rows to PLATE..." }
    } catch {
        Write-Host "Error at Row $($row.r): $($_.Exception.Message)"
        break
    }
}
$transaction.Commit()
Write-Host "Imported $count rows to Plate."

$conn.Close()
$zip.Dispose()
Write-Host "IMPORT COMPLETED!"
