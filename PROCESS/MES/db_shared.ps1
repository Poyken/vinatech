# db_shared.ps1 — Shared Database Functions & Configuration Loader for Vinatech MES

# Load database configuration
$configPath = Join-Path $PSScriptRoot "db_config.json"
if (!(Test-Path $configPath)) {
    Write-Error "Configuration file not found at: $configPath"
    exit 1
}

try {
    $config = Get-Content -Raw -Path $configPath | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse db_config.json: $_"
    exit 1
}

# Construct the standard connection string
function Get-ConnectionString {
    return "Server=$($config.Server);Database=$($config.Database);User Id=$($config.User);Password=$($config.Password);TrustServerCertificate=True;Timeout=$($config.Timeout);"
}

# Create a new SQL connection instance
function Get-DbConnection {
    $cs = Get-ConnectionString
    return New-Object System.Data.SqlClient.SqlConnection($cs)
}

# Validate SQL read-only safety rules (for run_query.ps1)
function Test-SqlReadOnlySafety {
    param (
        [string]$SqlText
    )
    
    $restrictedKeywords = @(
        "\bINSERT\b", "\bUPDATE\b", "\bDELETE\b", "\bMERGE\b",
        "\bDROP\b", "\bALTER\b", "\bTRUNCATE\b", "\bCREATE\b"
    )
    
    foreach ($keyword in $restrictedKeywords) {
        if ($SqlText -match "(?mi)$keyword") {
            return @{
                IsValid = $false
                Error = "Safety violation: Modifying command detected ($keyword). run_query.ps1 only allows read-only queries."
            }
        }
    }
    
    return @{ IsValid = $true }
}

# Generate warnings if queries access key transactional tables without NOLOCK
function Get-NoLockWarnings {
    param (
        [string]$SqlText
    )
    
    $warnings = @()
    $transactionTables = @("STB_ProdRouteHist", "STB_MaterialLotInfo", "STB_SetInfo", "STB_MaterialDocDetail")
    
    foreach ($table in $transactionTables) {
        if ($SqlText -match "(?mi)\b$table\b" -and $SqlText -notmatch "(?mi)\b$table\b.*\bNOLOCK\b") {
            $warnings += "Warning: Query accesses transactional table '$table' without WITH(NOLOCK). This could cause locks."
        }
    }
    
    return $warnings
}

# Validate SQL deployment safety rules (for validate_sql.ps1 & deploy_tool.ps1)
function Test-SqlDeploySafety {
    param (
        [string]$SqlText,
        [bool]$AllowDangerous = $false
    )
    
    $isValid = $true
    $errors = @()
    $warnings = @()
    
    # 1. Safety Checks for DML operations
    $hasDML = $SqlText -match "(?mi)\b(INSERT|UPDATE|DELETE|MERGE)\b"
    if ($hasDML) {
        # Require transaction block
        if ($SqlText -notmatch "(?mi)\bBEGIN\s+(TRAN|TRANSACTION)\b") {
            $errors += "Validation Error: SQL contains DML (INSERT/UPDATE/DELETE/MERGE) but is missing 'BEGIN TRANSACTION' or 'BEGIN TRAN'."
            $isValid = $false
        }
        
        # Require rollback statement
        if ($SqlText -notmatch "(?mi)\bROLLBACK\s+(TRAN|TRANSACTION)?\b") {
            $errors += "Validation Error: SQL contains DML but is missing 'ROLLBACK' or 'ROLLBACK TRANSACTION'. Under Rule #1, scripts must rollback by default."
            $isValid = $false
        }
        
        # Enforce WHERE clause for update/delete operations
        if ($SqlText -match "(?mi)\b(UPDATE|DELETE)\b" -and $SqlText -notmatch "(?mi)\bWHERE\b") {
            $errors += "Validation Error: SQL contains UPDATE/DELETE but has no WHERE clause! This is extremely dangerous."
            $isValid = $false
        }
    }
    
    # 2. Safety Checks for Dangerous DDL statements
    $dangerousDDLKeywords = @(
        "\bDROP\s+TABLE\b",
        "\bDROP\s+DATABASE\b",
        "\bTRUNCATE\s+TABLE\b",
        "\bALTER\s+TABLE\b"
    )
    
    foreach ($keyword in $dangerousDDLKeywords) {
        if ($SqlText -match "(?mi)$keyword") {
            if ($AllowDangerous) {
                $warnings += "Warning: Dangerous DDL statement detected ($keyword) but allowed via -AllowDangerous."
            } else {
                $errors += "Validation Error: Dangerous DDL statement detected ($keyword). Running this requires explicit override."
                $isValid = $false
            }
        }
    }
    
    # 3. Check for NOLOCK on transaction tables
    $transactionTables = @("STB_ProdRouteHist", "STB_MaterialLotInfo", "STB_SetInfo", "STB_MaterialDocDetail")
    foreach ($table in $transactionTables) {
        if ($SqlText -match "(?mi)\b$table\b") {
            if ($SqlText -notmatch "(?mi)\b$table\b.*\bNOLOCK\b" -and $SqlText -notmatch "(?mi)\bNOLOCK\b.*\b$table\b") {
                $warnings += "Warning: Query references transactional table '$table' but 'NOLOCK' keyword was not detected in the script. Verify if WITH(NOLOCK) is applied."
            }
        }
    }
    
    return @{
        IsValid  = $isValid
        Errors   = $errors
        Warnings = $warnings
    }
}
