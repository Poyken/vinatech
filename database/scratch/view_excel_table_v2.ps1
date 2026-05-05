Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\temp.xlsx"

function Get-SharedStrings($zip) {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq "xl/sharedStrings.xml" }
    if ($entry) {
        $stream = $entry.Open()
        $reader = [System.IO.StreamReader]::new($stream)
        $xml = [xml]$reader.ReadToEnd()
        $reader.Close()
        $stream.Close()
        return $xml.sst.si | ForEach-Object { 
            if ($_.t) { if ($_.t -is [string]) { $_.t } else { $_.t."#text" } }
            elseif ($_.r) { ($_.r.t | ForEach-Object { if ($_ -is [string]) { $_ } else { $_."#text" } }) -join "" }
        }
    }
    return @()
}

$fs = [System.IO.File]::Open($xlsxPath, 'Open', 'Read', 'ReadWrite')
$zip = [System.IO.Compression.ZipArchive]::new($fs)
$ss = Get-SharedStrings $zip
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet1.xml" }
$stream = $sheetEntry.Open()
$reader = [System.IO.StreamReader]::new($stream)
$sheetXml = [xml]$reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()
$fs.Dispose()

$rows = $sheetXml.worksheet.sheetData.row
$data = foreach ($row in $rows) {
    $obj = [PSCustomObject]@{ Row = $row.r }
    foreach ($c in $row.c) {
        $v = $c.v
        if ($c.t -eq 's') { $v = $ss[[int]$v] }
        $col = $c.r -replace '\d+', ''
        $obj | Add-Member -MemberType NoteProperty -Name $col -Value $v -Force
    }
    $obj
}

$data | Select-Object -First 20 | Format-Table -AutoSize
