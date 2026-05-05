$txt = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_full_clean.xml' -Raw
$txt = $txt -replace "^\?", ""
[xml]$xml = $txt
$items = $xml.GetElementsByTagName("Item")
foreach ($item in $items) {
    if ($item.Name -and $item.LocationFloat) {
        Write-Host "$($item.Name) | $($item.ControlType) | $($item.LocationFloat) | $($item.SizeF) | $($item.Text)"
    }
}
