Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Data sorting.xlsx"
$zip = [System.IO.Compression.ZipFile]::OpenRead($xlsxPath)

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

$ss = Get-SharedStrings $zip

function Process-Sheet($sheetName, $type) {
    Write-Host "Processing $sheetName ($type)..."
    $sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/$sheetName" }
    $stream = $sheetEntry.Open()
    $sheetXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
    $stream.Close()

    $rows = $sheetXml.worksheet.sheetData.row
    $sqlLines = @()
    foreach ($row in $rows) {
        $vals = New-Object 'System.Collections.Generic.List[string]'
        # Pre-fill with empty strings for at least 25 columns
        for($i=0; $i -lt 25; $i++) { $vals.Add("") }
        
        foreach ($c in $row.c) {
            $colName = $c.r -replace '\d+', ''
            # simple A=0, B=1 mapping for typical data
            $colIdx = 0
            if ($colName.Length -eq 1) { $colIdx = [int][char]$colName[0] - 65 }
            elseif ($colName.Length -eq 2) { $colIdx = ([int][char]$colName[0] - 64) * 26 + ([int][char]$colName[1] - 65) }
            
            $v = $c.v
            if ($c.t -eq "s") { $v = $ss[[int]$v] }
            
            if ($colIdx -lt $vals.Count) { $vals[$colIdx] = $v }
            else { while($vals.Count -le $colIdx) { $vals.Add("") }; $vals[$colIdx] = $v }
        }
        
        # Skip header/empty rows
        if ($vals[0] -eq "STT" -or [string]::IsNullOrWhiteSpace($vals[1])) { continue }
        if ($vals[1] -match "^\d+$") {
            # Convert Excel date
            try {
                $days = [int]$vals[1]
                $dt = (Get-Date "1899-12-30").AddDays($days)
                $dateStr = $dt.ToString("yyyy-MM-dd")
            } catch { $dateStr = "2026-01-01" } # fallback
            
            $sql = "INSERT INTO STB_VVT_SortingErrorData (SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, MaterialType, QtyCheck, QtyOK"
            if ($type -eq "PLATE") {
                $sql += ", PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch, PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood, PLBienSacDiscolor, PLOther"
            } else {
                $sql += ", ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther"
            }
            $sql += ") VALUES ('$dateStr', '$($vals[2])', N'$($vals[3])', '$($vals[4])', N'$($vals[5])', '$($vals[6])', '$($vals[7])', '$type', $([int]$vals[8]), $([int]$vals[9])"
            
            for ($i=10; $i -lt 20; $i++) {
                $v = if ([string]::IsNullOrWhiteSpace($vals[$i])) { "0" } else { [int]$vals[$i] }
                $sql += ", $v"
            }
            if ($type -eq "PLATE") {
                $v = if ([string]::IsNullOrWhiteSpace($vals[20])) { "0" } else { [int]$vals[20] }
                $sql += ", $v"
            }
            $sql += ");"
            $sqlLines += $sql
        }
    }
    return $sqlLines
}

$allSql = @("USE SmartFactoryV2;", "GO", "TRUNCATE TABLE STB_VVT_SortingErrorData;", "GO")
$allSql += Process-Sheet "sheet1.xml" "PLATE"
# If there's a sheet2, assume it's ALCASE (or just skip if it fails)
try { $allSql += Process-Sheet "sheet2.xml" "ALCASE" } catch {}

$allSql | Out-File "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\insert_sorting_v2.sql" -Encoding UTF8
Write-Host "Generated insert_sorting_v2.sql"
$zip.Dispose()
