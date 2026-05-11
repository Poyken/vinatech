$path = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\fn_VVT_getdatebyVendorLot_MergeCode.sql"
$bytes = [System.IO.File]::ReadAllBytes($path)
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

# Fix double encoding if detected
if ($text -like "*Chuyá»ƒn*" -or $text -like "*ngÃ y*") {
    $bytes = [System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes($text)
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
}

# Remove excessive blank lines
$lines = $text -split "\r?\n"
$cleaned = New-Object System.Collections.Generic.List[string]
$lastEmpty = $false

foreach ($line in $lines) {
    if ($line.Trim() -eq "") {
        if (-not $lastEmpty) {
            $cleaned.Add("")
            $lastEmpty = $true
        }
    } else {
        $cleaned.Add($line)
        $lastEmpty = $false
    }
}

# Save as UTF-8 with BOM
[System.IO.File]::WriteAllText($path, ($cleaned -join "`r`n"), [System.Text.Encoding]::UTF8)
Write-Host "Cleaned and fixed encoding for $path"
