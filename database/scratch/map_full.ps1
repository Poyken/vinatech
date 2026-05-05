[xml]$xml = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_full_clean.xml' -Raw
$items = $xml.SelectNodes("//Item")
foreach ($item in $items) {
    Write-Host "$($item.Name) | $($item.ControlType) | $($item.LocationFloat) | $($item.SizeF) | $($item.Text)"
}
