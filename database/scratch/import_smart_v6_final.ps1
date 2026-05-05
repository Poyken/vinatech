Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\temp.xlsx"

function Get-SharedStrings($zip) {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq "xl/sharedStrings.xml" }
    if ($entry) {
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $xmlText = $reader.ReadToEnd()
        $xml = [xml]$xmlText
        $reader.Close()
        $stream.Close()
        return $xml.sst.si | ForEach-Object { 
            if ($_.t) { if ($_.t -is [string]) { $_.t } else { $_.t."#text" } }
            elseif ($_.r) { ($_.r.t | ForEach-Object { if ($_ -is [string]) { $_ } else { $_."#text" } }) -join "" }
        }
    }
    return @()
}

$fs = [System.IO.File]::Open($xlsxPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
$zip = New-Object System.IO.Compression.ZipArchive($fs)
$ss = Get-SharedStrings $zip
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet1.xml" }
$stream = $sheetEntry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$sheetXml = [xml]$reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()
$fs.Dispose()

$rows = $sheetXml.worksheet.sheetData.row
$server = 'dbserver.hycap.co.kr,5398'
$database = 'SmartFactoryV2'
$user = 'vinaadmin'
$pass = 'vina1234%6&8'

$processedCodes = @()

foreach ($row in $rows) {
    $vals = @{}
    foreach ($c in $row.c) {
        $v = $c.v
        if ($c.t -eq 's') { $v = $ss[[int]$v] }
        $col = $c.r -replace '\d+', ''
        $vals[$col] = $v
    }

    # Smart Identification
    $matCode = ""
    $matName = ""
    $matUnit = "EA"
    $matType = "ROH"
    $matGroup = ""
    $matSpec = ""

    # Priority columns for Code: A, L, AI
    foreach ($col in @('A', 'L', 'AI')) {
        $v = $vals[$col]
        if ($v -match '^[0-9A-Z-]{8,}$' -and $v -notmatch 'PLATE|FOIL|Cap|Routing') {
            $matCode = $v
            break
        }
    }

    if (-not $matCode) { continue }
    if ($processedCodes -contains $matCode) { continue }
    $processedCodes += $matCode

    # Identify Name (The one that is long and contains text)
    foreach ($col in @('B', 'L', 'A', 'I')) {
        $v = $vals[$col]
        if ($v -and $v -ne $matCode -and $v.Length -gt 5 -and $v -notmatch '^[0-9.-]+$') {
            $matName = $v
            break
        }
    }

    # Identify Unit
    foreach ($v in $vals.Values) {
        if ($v -match '^(EA|M2|PCS|SET|ROLL)$') { $matUnit = $v; break }
    }

    # Identify Type
    foreach ($v in $vals.Values) {
        if ($v -match '^(ROH|FERT|HALB|WIP)$') { $matType = $v; break }
    }

    # Identify Group
    foreach ($v in $vals.Values) {
        if ($v -match '^(SMD|BASE-PLATE|ANODE-FOIL|ANODE-LEAD|CATHODE-FOIL|CATHODE-LEAD)$') { $matGroup = $v; break }
    }

    # Identify Spec (often in I or J)
    if ($vals['I'] -and $vals['I'] -ne $matName) { $matSpec = $vals['I'] }
    elseif ($vals['J'] -and $vals['J'] -ne $matUnit) { $matSpec = $vals['J'] }

    Write-Host "Row $($row.r): Syncing $matCode | Name: $matName | Unit: $matUnit | Type: $matType"

    $matNameSql = $matName -replace "'", "''"
    $matSpecSql = $matSpec -replace "'", "''"

    $sql = @"
IF NOT EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = '$matCode')
BEGIN
    INSERT INTO STB_MaterialMaster (
        MaterialCode, MaterialName, MaterialTypeCode, ProductGroupCode,
        MaterialUnit, MaterialSpec,
        IsProdPlan, IsPurchase, IsOrder, 
        CreateDateTime, CreateUserID, VNcode
    ) VALUES (
        '$matCode', N'$matNameSql', '$matType', '$matGroup',
        '$matUnit', N'$matSpecSql',
        1, 1, 1, 
        GETDATE(), '$user', 'VVT'
    )
END
ELSE
BEGIN
    UPDATE STB_MaterialMaster SET
        MaterialName = N'$matNameSql',
        MaterialTypeCode = '$matType',
        ProductGroupCode = '$matGroup',
        MaterialUnit = '$matUnit',
        MaterialSpec = N'$matSpecSql',
        ChangeDateTime = GETDATE(),
        ChangeUserID = '$user'
    WHERE MaterialCode = '$matCode'
END
"@
    try {
        Invoke-Sqlcmd -ServerInstance $server -Database $database -Username $user -Password $pass -Query $sql -ErrorAction Stop
    } catch {
        Write-Error "Failed for ${matCode}: $($_.Exception.Message)"
    }
}

Write-Host "Finished. Total unique codes processed: $($processedCodes.Count)"
