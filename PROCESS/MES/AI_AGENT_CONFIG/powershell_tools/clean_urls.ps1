$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES"
$mdFiles = Get-ChildItem -Path $baseDir -Filter "*.md" -Recurse

foreach ($file in $mdFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Fix double prefixed file:/// URLs
    $newContent = [regex]::Replace($content, '\((?:(?:\.\./)+|[^(\s)]+/)(file:///[^)]+)\)', '($1)')
    
    if ($newContent -ne $content) {
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        Write-Host "Cleaned URLs in: $($file.FullName)"
    }
}
