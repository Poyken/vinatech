Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsxPath = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\temp.xlsx"

function Get-SharedStrings($zip) {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq "xl/sharedStrings.xml" }
    if ($entry) {
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
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

$zip = [System.IO.Compression.ZipFile]::OpenRead($xlsxPath)
$ss = Get-SharedStrings $zip
$sheetEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/worksheets/sheet1.xml" }
$stream = $sheetEntry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$sheetXml = [xml]$reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

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

$data | Select-Object -First 10 | Format-Table -AutoSize
