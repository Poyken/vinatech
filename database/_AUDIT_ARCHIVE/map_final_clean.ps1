$bytes = [System.IO.File]::ReadAllBytes('C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_full_clean.xml')
# Remove UTF-8 BOM if present
if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $bytes = $bytes[3..($bytes.Length-1)]
}
# Remove leading '?' (0x3F) if any
while ($bytes[0] -eq 0x3F) {
    $bytes = $bytes[1..($bytes.Length-1)]
}

$xmlText = [System.Text.Encoding]::UTF8.GetString($bytes)
[xml]$xml = $xmlText
$items = $xml.SelectNodes("//Item")
foreach ($item in $items) {
    if ($item.Name -and $item.LocationFloat) {
        Write-Host "$($item.Name) | $($item.ControlType) | $($item.LocationFloat) | $($item.SizeF) | $($item.Text)"
    }
}
