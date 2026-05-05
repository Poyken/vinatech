$txt = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_full_clean.xml' -Raw
$txt = $txt -replace "^\?", ""
[xml]$xml = $txt
$items = $xml.GetElementsByTagName("Item")
Write-Host "Found $($items.Count) items"
foreach ($item in $items) {
    Write-Host "Item: $($item.Attributes['Name'].Value) | Type: $($item.Attributes['ControlType'].Value) | Loc: $($item.Attributes['LocationFloat'].Value)"
}
