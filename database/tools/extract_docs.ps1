Add-Type -AssemblyName System.IO.Compression.FileSystem

$docDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Document"
$outDir = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\doc_extracted"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

function Extract-ZipXml($zipPath, $xmlInternalPath) {
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
        $entry = $zip.Entries | Where-Object { $_.FullName -like $xmlInternalPath }
        if ($entry) {
            $stream = $entry.Open()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
            $reader.Close(); $stream.Close()
            $zip.Dispose()
            return $content
        }
        $zip.Dispose()
    } catch {}
    return ""
}

function Get-TextFromXml($xml) {
    # Remove XML tags, keep text
    $text = [System.Text.RegularExpressions.Regex]::Replace($xml, '<[^>]+>', ' ')
    # Collapse whitespace
    $text = [System.Text.RegularExpressions.Regex]::Replace($text, '\s+', ' ')
    return $text.Trim()
}

function Extract-PptxText($filePath) {
    $zip = $null
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($filePath)
        $slideEntries = $zip.Entries | Where-Object { $_.FullName -match '^ppt/slides/slide\d+\.xml$' } | Sort-Object FullName
        $allText = @()
        foreach ($entry in $slideEntries) {
            $stream = $entry.Open()
            $reader = New-Object System.IO.StreamReader($stream)
            $xml = $reader.ReadToEnd()
            $reader.Close(); $stream.Close()
            $text = Get-TextFromXml $xml
            if ($text.Length -gt 10) { $allText += "--- $($entry.FullName) ---`n$text" }
        }
        $zip.Dispose()
        return $allText -join "`n`n"
    } catch {
        if ($zip) { $zip.Dispose() }
        return "ERROR: $_"
    }
}

function Extract-DocxText($filePath) {
    try {
        $xml = Extract-ZipXml $filePath "word/document.xml"
        return Get-TextFromXml $xml
    } catch { return "ERROR: $_" }
}

function Extract-XlsxText($filePath) {
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($filePath)
        $sharedStrings = ""
        $ssEntry = $zip.Entries | Where-Object { $_.FullName -eq "xl/sharedStrings.xml" }
        if ($ssEntry) {
            $stream = $ssEntry.Open()
            $reader = New-Object System.IO.StreamReader($stream)
            $sharedStrings = $reader.ReadToEnd()
            $reader.Close(); $stream.Close()
        }
        $sheetEntries = $zip.Entries | Where-Object { $_.FullName -match "^xl/worksheets/sheet\d+\.xml$" } | Sort-Object FullName
        $allText = @()
        if ($sharedStrings) { $allText += "=SharedStrings=`n" + (Get-TextFromXml $sharedStrings) }
        foreach ($entry in $sheetEntries) {
            $stream = $entry.Open()
            $reader = New-Object System.IO.StreamReader($stream)
            $xml = $reader.ReadToEnd()
            $reader.Close(); $stream.Close()
            $allText += "--- $($entry.FullName) ---`n" + (Get-TextFromXml $xml)
        }
        $zip.Dispose()
        return $allText -join "`n`n"
    } catch { return "ERROR: $_" }
}

$files = Get-ChildItem $docDir -File | Where-Object { $_.Extension -in @('.pptx','.docx','.xlsx') }

foreach ($file in $files) {
    Write-Host "Processing: $($file.Name) ..."
    $outFile = Join-Path $outDir ($file.BaseName + ".txt")
    
    $text = switch ($file.Extension) {
        '.pptx' { Extract-PptxText $file.FullName }
        '.docx' { Extract-DocxText $file.FullName }
        '.xlsx' { Extract-XlsxText $file.FullName }
    }
    
    [System.IO.File]::WriteAllText($outFile, "=== $($file.Name) ===`n`n$text", [System.Text.Encoding]::UTF8)
    Write-Host "  -> Saved $([math]::Round($text.Length/1024,1)) KB"
}

Write-Host "`nDONE. Extracted $($files.Count) files to $outDir"
