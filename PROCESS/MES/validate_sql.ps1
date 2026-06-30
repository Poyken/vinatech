param (
    [string]$SqlPath,
    [switch]$AllowDangerous
)

if ([string]::IsNullOrEmpty($SqlPath)) {
    Write-Host "Usage: .\validate_sql.ps1 -SqlPath <path_to_sql_file>" -ForegroundColor Yellow
    exit 1
}

if (!(Test-Path $SqlPath)) {
    Write-Error "File not found: $SqlPath"
    exit 1
}

# Load shared database utilities
. (Join-Path $PSScriptRoot "db_shared.ps1")

$sqlText = [System.IO.File]::ReadAllText($SqlPath, [System.Text.Encoding]::UTF8)

# Run safety validation via shared functions
$safety = Test-SqlDeploySafety -SqlText $sqlText -AllowDangerous:$AllowDangerous

# Output results
if ($safety.Errors.Count -gt 0) {
    Write-Host "--- SQL Safety Validation FAILED for: $SqlPath ---" -ForegroundColor Red
    foreach ($err in $safety.Errors) {
        Write-Host "  [X] $err" -ForegroundColor Red
    }
}

if ($safety.Warnings.Count -gt 0) {
    Write-Host "--- SQL Safety Warnings for: $SqlPath ---" -ForegroundColor Yellow
    foreach ($warn in $safety.Warnings) {
        Write-Host "  [!] $warn" -ForegroundColor Yellow
    }
}

if ($safety.IsValid) {
    Write-Host "SQL Safety Validation PASSED for: $SqlPath" -ForegroundColor Green
    exit 0
} else {
    exit 1
}
