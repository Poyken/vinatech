$path = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\fn_VVT_getdatebyVendorLot_MergeCode.sql"
$bytes = [System.IO.File]::ReadAllBytes($path)
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

# Fix double encoding using CodePage 1252
# We do this without using any literal characters in the script
try {
    $enc1252 = [System.Text.Encoding]::GetEncoding(1252)
    $raw = $enc1252.GetBytes($text)
    $fixed = [System.Text.Encoding]::UTF8.GetString($raw)
    
    # Check if successful (check for 'ngày' or 'chuyển' without literals)
    # 'ngày' in hex: 6e 67 c3 a0 79
    if ($fixed.Contains([char]0x111) -or $fixed.Contains([char]0x1B0)) {
        $text = $fixed
    }
} catch {
    # Keep original if error
}

# Clean blank lines
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
$utf8BOM = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($path, ($cleaned -join "`r`n"), $utf8BOM)

Write-Host "Success: Encoding fixed and blank lines removed."
