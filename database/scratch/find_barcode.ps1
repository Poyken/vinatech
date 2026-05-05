$txt = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_clean.xml' -Raw
# Remove the SQL column header
$txt = $txt -replace "^Column1\s+[-]+\s+", ""
$txt = $txt.Trim('?') # Remove the BOM if needed
$txt = $txt.Trim()

if ($txt -match "<Item[^>]*ControlType=`"XRBarCode`"[^>]*>") {
    $matches[0]
} else {
    Write-Host "Not found"
}
