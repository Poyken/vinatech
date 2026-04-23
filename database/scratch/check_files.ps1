$files = Get-ChildItem .\usp_*.sql
foreach ($f in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ($text -match 'DUNG D.CH|s.n ph.m n.y') {
        Write-Host "File $($f.Name):"
        $m = [regex]::match($text, '.{0,15}DUNG D.{0,15}')
        Write-Host "  $($m.Value)"
    }
}
