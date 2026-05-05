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
            return $xml.sst.si | ForEach-Object { 
                if ($_.t) { 
                    if ($_.t -is [string]) { $_.t } else { $_.t."#text" }
                } elseif ($_.r) {
                    ($_.r.t | ForEach-Object { if ($_ -is [string]) { $_ } else { $_."#text" } }) -join ""
                }
            }
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

$processedCodes = @()

foreach ($row in $rows) {
    $vals = @{}
    foreach ($c in $row.c) {
        $colName = $c.r -replace '\d+', ''
        $colIdx = 0
        $pow = 1
        for ($j = $colName.Length - 1; $j -ge 0; $j--) {
            $colIdx += ([int][char]$colName[$j] - 64) * $pow
            $pow *= 26
        }
        $colIdx-- 
        $v = $c.v
        if ($c.t -eq "s") { $v = $ss[[int]$v] }
        $vals[$colIdx] = $v
    }

    # Find ANY cell that looks like a MaterialCode
    $matCode = ""
    foreach ($v in $vals.Values) {
        if ($v -match '^[0-9A-Z]{8,}$' -and $v -notmatch 'PLATE' -and $v -notmatch 'FOIL') {
            $matCode = $v
            break
        }
    }

    if (-not $matCode -or $processedCodes -contains $matCode) { continue }
    $processedCodes += $matCode

    $matName = if ($vals[1]) { $vals[1] -replace "'", "''" } else { "Imported Item" }
    $matType = "ROH"
    $unit = "EA"

    Write-Host "Syncing Code: $matCode"

    $sql = @"
IF NOT EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = '$matCode')
BEGIN
    INSERT INTO STB_MaterialMaster (
        MaterialCode, MaterialName, MaterialTypeCode, 
        MaterialUnit, IsProdPlan, IsPurchase, IsOrder, 
        CreateDateTime, CreateUserID, VNcode
    ) VALUES (
        '$matCode', N'$matName', '$matType', 
        '$unit', 1, 1, 1, 
        GETDATE(), '$user', 'VVT'
    )
    SELECT 'INSERTED' as Result
END
ELSE
BEGIN
    SELECT 'EXISTS' as Result
END
"@
    try {
        $res = Invoke-Sqlcmd -ServerInstance $server -Database $database -Username $user -Password $pass -Query $sql -ErrorAction Stop
        Write-Host "Result for $matCode : $($res.Result)"
    } catch {
        Write-Host "Error for $matCode : $($_.Exception.Message)"
    }
}

Write-Host "Total processed unique codes: $($processedCodes.Count)"
