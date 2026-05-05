Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\temp.xlsx"

function Get-SharedStrings($zip) {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq 'xl/sharedStrings.xml' }
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
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq 'xl/worksheets/sheet1.xml' }
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

$masterData = @{}

foreach ($row in $rows) {
    if ($row.r -eq "1") { continue } # Skip header
    
    $vals = @{}
    foreach ($c in $row.c) {
        $v = $c.v
        if ($c.t -eq 's') { $v = $ss[[int]$v] }
        $col = $c.r -replace '\d+', ''
        $vals[$col] = $v
    }

    # Find ALL codes in this row
    $codesInRow = @()
    foreach ($v in $vals.Values) {
        if ($v -match '^[0-9A-Z-]{8,}$' -and $v -notmatch 'PLATE|FOIL|Cap|Routing|Unit') {
            $codesInRow += $v
        }
    }

    foreach ($code in $codesInRow) {
        if (-not $masterData.ContainsKey($code)) {
            $masterData[$code] = @{
                Name = ""; Unit = "EA"; Type = "ROH"; Group = ""; Spec = ""
            }
        }
        
        $entry = $masterData[$code]

        # Name Logic: If code is in A, Name is B. If code is in L, Name is A. 
        # Generally, find the longest text in A, B, or L that isn't the code.
        foreach ($col in @('B', 'L', 'A', 'I')) {
            $v = $vals[$col]
            if ($v -and $v -ne $code -and $v.Length -gt 5 -and $v -notmatch '^[0-9.-]+$') {
                if ($entry.Name.Length -lt $v.Length) { $entry.Name = $v }
            }
        }

        # Unit/Type/Group Logic: Search all columns
        foreach ($v in $vals.Values) {
            if ($v -match '^(EA|M2|PCS|SET|ROLL)$') { $entry.Unit = $v }
            if ($v -match '^(ROH|FERT|HALB|WIP)$') { $entry.Type = $v }
            if ($v -match '^(SMD|BASE-PLATE|ANODE-FOIL|ANODE-LEAD|CATHODE-FOIL|CATHODE-LEAD)$') { $entry.Group = $v }
        }

        # Spec Logic
        if ($vals['I'] -and $vals['I'] -ne $entry.Name) { $entry.Spec = $vals['I'] }
    }
}

Write-Host "Total unique codes to sync: $($masterData.Count)"

foreach ($code in $masterData.Keys) {
    $item = $masterData[$code]
    $name = $item.Name -replace "'", "''"
    $spec = $item.Spec -replace "'", "''"
    $unit = $item.Unit
    $type = $item.Type
    $group = $item.Group

    Write-Host "Syncing $code : $name ($unit)"

    $sql = @"
IF NOT EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = '$code')
BEGIN
    INSERT INTO STB_MaterialMaster (
        MaterialCode, MaterialName, MaterialTypeCode, ProductGroupCode,
        MaterialUnit, MaterialSpec,
        IsProdPlan, IsPurchase, IsOrder, 
        CreateDateTime, CreateUserID, VNcode
    ) VALUES (
        '$code', N'$name', '$type', '$group',
        '$unit', N'$spec',
        1, 1, 1, 
        GETDATE(), '$user', 'VVT'
    )
END
ELSE
BEGIN
    UPDATE STB_MaterialMaster SET
        MaterialName = N'$name',
        MaterialTypeCode = '$type',
        ProductGroupCode = '$group',
        MaterialUnit = '$unit',
        MaterialSpec = N'$spec',
        ChangeDateTime = GETDATE(),
        ChangeUserID = '$user'
    WHERE MaterialCode = '$code'
END
"@
    Invoke-Sqlcmd -ServerInstance $server -Database $database -Username $user -Password $pass -Query $sql
}
