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
for ($i = 0; $i -lt $rows.Count; $i++) {
    $row = $rows[$i]
    $vals = @()
    foreach ($c in $row.c) {
        $v = $c.v
        if ($c.t -eq "s") { $v = $ss[[int]$v] }
        $vals += $v
    }
    Write-Host "Row $i : $($vals -join ' | ')"
}
