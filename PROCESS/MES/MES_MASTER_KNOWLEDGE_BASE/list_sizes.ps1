$files = Get-ChildItem "$PSScriptRoot\KB_*.md" | Sort-Object Name
foreach($f in $files) {
    $kb = [math]::Round($f.Length/1024)
    Write-Output "$($f.Name) = $kb KB"
}
$total = ($files | Measure-Object -Property Length -Sum).Sum
Write-Output "TOTAL = $([math]::Round($total/1024)) KB ($($files.Count) files)"
