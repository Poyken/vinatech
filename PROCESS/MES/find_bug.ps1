param (
    [Parameter(Mandatory=$true)]
    [string]$ScreenId
)

$kbPath = Join-Path $PSScriptRoot "MES_MASTER_KNOWLEDGE_BASE"
if (!(Test-Path $kbPath)) {
    Write-Host "Error: MES_MASTER_KNOWLEDGE_BASE directory not found!" -ForegroundColor Red
    exit 1
}

$mdFiles = Get-ChildItem -Path $kbPath -Filter "*.md" -Recurse
$totalFound = 0

foreach ($file in $mdFiles) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    
    $found = $false
    $resultLines = @()
    
    foreach ($line in $content) {
        # Match header like "## B523" or "### B523" or "## [B523]" or "### [B523]"
        if ($line -match "^(##|###)\s+\[?$([regex]::Escape($ScreenId))\]?\b") {
            $found = $true
            $resultLines += $line
            continue
        }
        
        if ($found) {
            # Stop if we hit a sibling or parent header or horizontal line
            if ($line -match "^##\s+" -or $line -match "^###\s+" -or $line -match "^---") {
                $found = $false
                if ($resultLines.Count -gt 1) {
                    $relative = $file.FullName.Replace($PSScriptRoot, ".").Replace("\", "/")
                    Write-Host "`n[File: $relative]" -ForegroundColor Cyan
                    foreach ($rLine in $resultLines) {
                        Write-Host $rLine
                    }
                    $totalFound++
                }
                $resultLines = @()
                continue
            }
            $resultLines += $line
        }
    }
    
    # Handle end of file boundary
    if ($found -and $resultLines.Count -gt 1) {
        $relative = $file.FullName.Replace($PSScriptRoot, ".").Replace("\", "/")
        Write-Host "`n[File: $relative]" -ForegroundColor Cyan
        foreach ($rLine in $resultLines) {
            Write-Host $rLine
        }
        $totalFound++
    }
}

if ($totalFound -eq 0) {
    Write-Host "`nNo documented bug sections found for screen [$ScreenId]." -ForegroundColor Yellow
}
