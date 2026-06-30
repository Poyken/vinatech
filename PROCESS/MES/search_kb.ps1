param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Query
)

$KbPath = Join-Path $PSScriptRoot "MES_MASTER_KNOWLEDGE_BASE"
$ConfigPath = Join-Path $PSScriptRoot "AI_AGENT_CONFIG"

Write-Host "=== [SEARCH] Searching Vinatech MES KBs for: '$Query' ===" -ForegroundColor Cyan

# Gather markdown files
if (Test-Path $KbPath) {
    $files = Get-ChildItem -Path $KbPath -Filter "*.md" -Recurse
} else {
    $files = @()
}

if (Test-Path $ConfigPath) {
    $files += Get-ChildItem -Path $ConfigPath -Filter "*.md" -Recurse
}

# Search through files
$matchesFound = 0
foreach ($file in $files) {
    # Resolve relative path for cleaner display
    $relative = $file.FullName.Replace($PSScriptRoot, ".").Replace("\", "/")
    
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    
    $lineNum = 1
    foreach ($line in $content) {
        # Perform case-insensitive match
        if ($line -match $Query) {
            # Highlight matching line with file reference
            Write-Host ("[" + $relative + ":" + $lineNum + "] ") -NoNewline -ForegroundColor Yellow
            Write-Host $line.Trim()
            $matchesFound++
        }
        $lineNum++
    }
}

Write-Host "--------------------------------------------------" -ForegroundColor Gray
if ($matchesFound -eq 0) {
    Write-Host "[INFO] No matching records found in local documentation." -ForegroundColor Red
} else {
    Write-Host "[OK] Found $matchesFound match(es) in local files." -ForegroundColor Green
}
