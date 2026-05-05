$txt = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_full_clean.xml' -Raw
if ($txt -match '<Item[^>]*ControlType="XRBarCode"[^>]*LocationFloat="([^,"]+), ([^"]+)"[^>]*SizeF="([^,"]+), ([^"]+)"') {
    Write-Host "Barcode Found: $($matches[0])"
    Write-Host "X: $($matches[1]) Y: $($matches[2]) W: $($matches[3]) H: $($matches[4])"
} else {
    Write-Host "Barcode Not Found"
}

if ($txt -match '<Item[^>]*Text="Inspector name/Sign"[^>]*LocationFloat="([^,"]+), ([^"]+)"') {
    Write-Host "Inspector Found: $($matches[0])"
    Write-Host "X: $($matches[1]) Y: $($matches[2])"
} else {
    Write-Host "Inspector Not Found"
}
