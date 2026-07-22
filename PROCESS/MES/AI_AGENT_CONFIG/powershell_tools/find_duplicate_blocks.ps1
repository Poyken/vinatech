$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES"
$mdFiles = Get-ChildItem -Path $baseDir -Filter "*.md" -Recurse

Write-Host "================ DUPLICATE CONTENT BLOCK AUDIT ================"

$codeBlocks = @{}

foreach ($file in $mdFiles) {
    $relPath = $file.FullName.Substring($baseDir.Length + 1)
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    $codeMatches = [regex]::Matches($content, '```(?:sql|powershell|javascript|json)?\s*([\s\S]+?)\s*```')
    foreach ($m in $codeMatches) {
        $codeText = $m.Groups[1].Value.Trim()
        if ($codeText.Length -gt 30) {
            $normalized = $codeText -replace '\s+', ' '
            if ($codeBlocks.ContainsKey($normalized)) {
                $orig = $codeBlocks[$normalized]
                $firstLine = ($codeText -split "`n")[0]
                Write-Host "[DUPLICATE CODE BLOCK] '$firstLine'"
                Write-Host "  1) $orig"
                Write-Host "  2) $relPath"
                Write-Host "---"
            } else {
                $codeBlocks[$normalized] = $relPath
            }
        }
    }
}

Write-Host "================ AUDIT COMPLETE ================"
