$txt = Get-Content 'C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\v2_full_clean.xml' -Raw
$txt = $txt -replace "^\?", ""
[xml]$xml = $txt

function Get-AllItems($node) {
    $results = @()
    if ($node.Name -eq "Item") {
        $results += $node
    }
    foreach ($child in $node.ChildNodes) {
        $results += Get-AllItems $child
    }
    return $results
}

$allItems = Get-AllItems $xml.DocumentElement
foreach ($item in $allItems) {
    if ($item.Attributes["ControlType"].Value -eq "XRBarCode") {
        Write-Host "BARCODE: $($item.Attributes['Name'].Value) | Loc: $($item.Attributes['LocationFloat'].Value) | Size: $($item.Attributes['SizeF'].Value)"
    }
    if ($item.Attributes["Text"].Value -like "*Inspector*") {
        Write-Host "INSPECTOR: $($item.Attributes['Name'].Value) | Loc: $($item.Attributes['LocationFloat'].Value) | Size: $($item.Attributes['SizeF'].Value) | Text: $($item.Attributes['Text'].Value)"
    }
}
