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

$zip = [System.IO.Compression.ZipFile]::OpenRead($xlsxPath)
$ss = Get-SharedStrings $zip
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet1.xml" }
$stream = $sheetEntry.Open()
$sheetXml = [xml](New-Object System.IO.StreamReader($stream)).ReadToEnd()
$stream.Close()
$zip.Dispose()

$rows = $sheetXml.worksheet.sheetData.row | Select-Object -First 5
foreach ($row in $rows) {
    $vals = @()
    foreach ($c in $row.c) {
        $v = $c.v
        if ($c.t -eq "s") { $v = $ss[[int]$v] }
        $vals += $v
    }
    Write-Host ($vals -join " | ")
}
