# Script nâng cấp & sửa 100% broken links + legacy file references trong workspace

$baseDir = "C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES"

$legacyMap = @{
    "KB_02_01_NVL_WMS.md" = "MES_MASTER_KNOWLEDGE_BASE/KB_02/KB_02_01_WMS_CORE.md"
    "KB_01_UI_PHAN_QUYEN.md" = "MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md"
    "KB_03_SAN_XUAT.md" = "MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_02_CELL_LINE.md"
    "KB_03_01_OVERVIEW.md" = "MES_MASTER_KNOWLEDGE_BASE/KB_03/KB_03_01_OVERVIEW.md"
    "KB_10_FACTORY_WORKCENTER_MATRIX.md" = "MES_MASTER_KNOWLEDGE_BASE/KB_10_FACTORY_WORKCENTER_MATRIX.md"
    "SYSTEM_MASTER_KNOWLEDGE_BASE/README.md" = "MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md"
}

$mdFiles = Get-ChildItem -Path $baseDir -Filter "*.md" -Recurse

foreach ($file in $mdFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $dir = $file.DirectoryName
    $changed = $false

    # Fix legacy references first
    foreach ($key in $legacyMap.Keys) {
        if ($content.Contains($key)) {
            $newPath = "file:///" + ($baseDir + "/" + $legacyMap[$key]).Replace('\', '/').Replace(' ', '%20')
            $content = $content.Replace($key, $newPath)
            $changed = $true
        }
    }

    # Fix relative paths in markdown links
    $newContent = [regex]::Replace($content, '\[([^\]]+)\]\((?!(file:///|http://|https://|#))([^)]+)\)', {
        param($match)
        $label = $match.Groups[1].Value
        $target = $match.Groups[2].Value + $match.Groups[3].Value
        
        $parts = $target -split '#', 2
        $relPath = $parts[0].Trim()
        $anchor = if ($parts.Count -gt 1) { "#" + $parts[1] } else { "" }

        if ([string]::IsNullOrWhiteSpace($relPath)) {
            return $match.Value
        }

        try {
            $combined = [System.IO.Path]::Combine($dir, $relPath)
            $fullPath = [System.IO.Path]::GetFullPath($combined)
            $uriPath = $fullPath.Replace('\', '/')
            $escapedUri = [System.Uri]::EscapeUriString($uriPath)
            $fileUrl = "file:///" + $escapedUri + $anchor
            $script:changed = $true
            return "[$label]($fileUrl)"
        } catch {
            return $match.Value
        }
    })

    if ($changed) {
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        Write-Host "Updated links in: $($file.FullName)"
    }
}

Write-Host "Complete link audit finished!"
