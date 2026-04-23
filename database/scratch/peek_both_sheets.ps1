Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Data sorting.xlsx"

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

function Peek-Sheet($zip, $ss, $sheetName) {
    Write-Host "--- Sheet: $sheetName ---"
    $sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/$sheetName" }
    if (-not $sheetEntry) { Write-Host "Not found $sheetName"; return }
    $stream = $sheetEntry.Open()
    $sheetXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
    $stream.Close()
    
    $rows = $sheetXml.worksheet.sheetData.row | Select-Object -First 2
    foreach ($row in $rows) {
        $vals = @()
        foreach ($c in $row.c) {
            $v = $c.v
            if ($c.t -eq "s") { $v = $ss[[int]$v] }
            $vals += $v
        }
        Write-Host ($vals -join " | ")
    }
}

$zip = [System.IO.Compression.ZipFile]::OpenRead($xlsxPath)
$ss = Get-SharedStrings $zip
Peek-Sheet $zip $ss "sheet1.xml"
Peek-Sheet $zip $ss "sheet2.xml"
$zip.Dispose()
