$xmlText = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\sanmina_label_v2_new.xml' -Raw
# Remove truncation artifacts if any
if ($xmlText -match "Column1") {
    $xmlText = $xmlText -replace "Column1\s+-+", "" -replace "-+", ""
}

[xml]$xml = $xmlText
$items = $xml.SelectNodes("//Item")
foreach ($item in $items) {
    Write-Host "$($item.Name) | $($item.ControlType) | $($item.LocationFloat) | $($item.SizeF) | $($item.Text)"
}
