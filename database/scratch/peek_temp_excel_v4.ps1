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
$reader = [System.IO.StreamReader]::new($stream)
$xmlText = $reader.ReadToEnd()
$sheetXml = [xml]$xmlText
$reader.Close()
$stream.Close()
$zip.Dispose()

$rows = $sheetXml.worksheet.sheetData.row
foreach ($row in $rows) {
    $vals = @{}
    foreach ($c in $row.c) {
        $colName = $c.r -replace '\d+', ''
        $v = $c.v
        if ($c.t -eq "s") { $v = $ss[[int]$v] }
        $vals[$colName] = $v
    }
    
    $out = "Row $($row.r) : "
    foreach ($k in ($vals.Keys | Sort-Object)) {
        $out += "[$k]: $($vals[$k]) | "
    }
    Write-Host $out
}
