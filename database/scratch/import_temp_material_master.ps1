Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\temp.xlsx"

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

$zip = [System.IO.Compression.ZipFile]::OpenRead($xlsxPath)
$ss = Get-SharedStrings $zip
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet1.xml" }
$stream = $sheetEntry.Open()
$sheetXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
$stream.Close()
$zip.Dispose()

$rows = $sheetXml.worksheet.sheetData.row
$server = 'dbserver.hycap.co.kr,5398'
$database = 'SmartFactoryV2'
$user = 'vinaadmin'
$pass = 'vina1234%6&8'

for ($i = 6; $i -lt $rows.Count; $i++) {
    $row = $rows[$i]
    $vals = @{}
    foreach ($c in $row.c) {
        # Parse cell reference like 'A7' to get column index
        $colName = $c.r -replace '\d+', ''
        $colIdx = 0
        $pow = 1
        for ($j = $colName.Length - 1; $j -ge 0; $j--) {
            $colIdx += ([int][char]$colName[$j] - 64) * $pow
            $pow *= 26
        }
        $colIdx-- # 0-indexed
        
        $v = $c.v
        if ($c.t -eq "s") { $v = $ss[[int]$v] }
        $vals[$colIdx] = $v
    }

    $matCode = $vals[0]
    if (-not $matCode) { continue }

    $matName = $vals[1] -replace "'", "''"
    $matNameL = $vals[2] -replace "'", "''"
    $matType = $vals[5]
    $prodGroup = $vals[8]
    $matSpec = $vals[9] -replace "'", "''"
    $unit = $vals[11]
    $grQty = if ($vals[39]) { $vals[39] } else { 0 }

    $sql = @"
IF NOT EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = '$matCode')
BEGIN
    INSERT INTO STB_MaterialMaster (
        MaterialCode, MaterialName, MaterialNameL, MaterialTypeCode, ProductGroupCode,
        MaterialUnit, BasicGrQty, MaterialSpec, 
        IsDelegate, IsInternalProd, IsProdPlan, IsPurchase, IsOrder, 
        IsUseFlush, IsUseBackFlush, IsClosed, IsRequireOqc,
        CreateDateTime, CreateUserID, VNcode
    ) VALUES (
        '$matCode', N'$matName', N'$matNameL', '$matType', '$prodGroup',
        '$unit', $grQty, N'$matSpec',
        0, 0, 1, 1, 1,
        0, 0, 0, 0,
        GETDATE(), '$user', 'VVT'
    )
    PRINT 'Inserted: $matCode'
END
ELSE
BEGIN
    PRINT 'Skipped: $matCode (Exists)'
END
"@
    try {
        Invoke-Sqlcmd -ServerInstance $server -Database $database -Username $user -Password $pass -Query $sql -ErrorAction Stop
    } catch {
        Write-Error "Failed to insert ${matCode} : $($_.Exception.Message)"
    }
}
