# Read the XML and extract the logic for Search Panel rendering
[xml]$xml = Get-Content -Path "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\scratch\layout_Test_040826.xml" -Encoding Unicode

Write-Host "=== Root Properties ==="
$xml.ScreenInfo | Select-Object UseSearch, UseReport, UseSaveAll, IsDirectSearch, UseSearchPanel | Format-List

Write-Host "`n=== Search Function Properties ==="
foreach($func in $xml.ScreenInfo.SearchFunctions.GUIFunction) {
    Write-Host "Function: $($func.Name)"
    Write-Host "  Parameters with IsVisible=True:"
    foreach($param in $func.Parameters.GUIParameter) {
        if($param.IsVisible -eq "true") {
            Write-Host "    - $($param.Name) | EditorType: $($param.EditorType) | Caption: $($param.Caption)"
        }
    }
}

Write-Host "`n=== Layout Hierarchy ==="
# Recursively print Layout structure
function Print-Layout($node, $indent) {
    Write-Host ("  " * $indent + "NodeType: $($node.LocalName) | Name: $($node.Name) | Caption: $($node.Caption)")
    foreach($child in $node.ChildNodes) {
        Print-Layout $child ($indent + 1)
    }
}
# Only print relevant Layout parts
$xml.ScreenInfo.LayoutTab | Select-Object -Property *
$xml.ScreenInfo.LayoutView | Select-Object -Property *
