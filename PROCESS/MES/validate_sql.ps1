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

$sqlText = [System.IO.File]::ReadAllText($SqlPath, [System.Text.Encoding]::UTF8)

$isValid = $true
$errors = @()
$warnings = @()

# 1. Check for DML keywords: INSERT, UPDATE, DELETE, MERGE
$hasDML = $sqlText -match "(?mi)\b(INSERT|UPDATE|DELETE|MERGE)\b"

if ($hasDML) {
    # Check for Transaction Block (BEGIN TRAN / BEGIN TRANSACTION)
    if ($sqlText -notmatch "(?mi)\bBEGIN\s+(TRAN|TRANSACTION)\b") {
        $errors += "Validation Error: SQL contains DML (INSERT/UPDATE/DELETE/MERGE) but is missing 'BEGIN TRANSACTION' or 'BEGIN TRAN'."
        $isValid = $false
    }
    
    # Check for ROLLBACK
    if ($sqlText -notmatch "(?mi)\bROLLBACK\s+(TRAN|TRANSACTION)?\b") {
        $errors += "Validation Error: SQL contains DML but is missing 'ROLLBACK' or 'ROLLBACK TRANSACTION'. Under Rule #1, scripts must rollback by default."
        $isValid = $false
    }
    
    # Check for UPDATE/DELETE without WHERE clause
    if ($sqlText -match "(?mi)\b(UPDATE|DELETE)\b" -and $sqlText -notmatch "(?mi)\bWHERE\b") {
        $errors += "Validation Error: SQL contains UPDATE/DELETE but has no WHERE clause! This is extremely dangerous."
        $isValid = $false
    }
}

# 2. Check for dangerous DDL: DROP TABLE, DROP DATABASE, TRUNCATE TABLE, ALTER TABLE
$dangerousDDLKeywords = @(
    "\bDROP\s+TABLE\b",
    "\bDROP\s+DATABASE\b",
    "\bTRUNCATE\s+TABLE\b",
    "\bALTER\s+TABLE\b"
)

foreach ($keyword in $dangerousDDLKeywords) {
    if ($sqlText -match "(?mi)$keyword") {
        if ($AllowDangerous) {
            $warnings += "Warning: Dangerous DDL statement detected ($keyword) but allowed via -AllowDangerous."
        } else {
            $errors += "Validation Error: Dangerous DDL statement detected ($keyword). Running this requires explicit override."
            $isValid = $false
        }
    }
}

# 3. Check for NOLOCK hint on major transactional tables
$transactionTables = @(
    "STB_ProdRouteHist",
    "STB_MaterialLotInfo",
    "STB_SetInfo",
    "STB_MaterialDocDetail"
)

foreach ($table in $transactionTables) {
    if ($sqlText -match "(?mi)\b$table\b") {
        if ($sqlText -notmatch "(?mi)\b$table\b.*\bNOLOCK\b" -and $sqlText -notmatch "(?mi)\bNOLOCK\b.*\b$table\b") {
            $warnings += "Warning: Query references transactional table '$table' but 'NOLOCK' keyword was not detected in the script. Verify if WITH(NOLOCK) is applied."
        }
    }
}

# Output results
if ($errors.Count -gt 0) {
    Write-Host "--- SQL Safety Validation FAILED for: $SqlPath ---" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "  [X] $err" -ForegroundColor Red
    }
    $isValid = $false
}

if ($warnings.Count -gt 0) {
    Write-Host "--- SQL Safety Warnings for: $SqlPath ---" -ForegroundColor Yellow
    foreach ($warn in $warnings) {
        Write-Host "  [!] $warn" -ForegroundColor Yellow
    }
}

if ($isValid) {
    Write-Host "SQL Safety Validation PASSED for: $SqlPath" -ForegroundColor Green
    exit 0
} else {
    exit 1
}
