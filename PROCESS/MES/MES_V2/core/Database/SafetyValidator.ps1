# ==============================================================================
# SafetyValidator.ps1 — Static Safety Validation Engine for MES_V2
# ==============================================================================

class MesSafetyValidator {
    static [hashtable] ValidateReadOnly([string]$sqlText) {
        if ([string]::IsNullOrWhiteSpace($sqlText)) {
            return @{ IsValid = $true }
        }

        $restrictedKeywords = @(
            "\bINSERT\b", "\bUPDATE\b", "\bDELETE\b", "\bMERGE\b",
            "\bDROP\b", "\bALTER\b", "\bTRUNCATE\b", "\bCREATE\b",
            "\bGRANT\b", "\bREVOKE\b"
        )

        foreach ($kw in $restrictedKeywords) {
            if ($sqlText -match "(?mi)$kw") {
                return @{
                    IsValid = $false
                    Error   = "Safety Rule #1 Violation: Modifying keyword '$kw' detected. Read-only commands only."
                }
            }
        }
        return @{ IsValid = $true }
    }

    static [hashtable] ValidateDeployment([string]$sqlText, [bool]$allowDangerous = $false) {
        $isValid = $true
        $errors = [System.Collections.Generic.List[string]]::new()
        $warnings = [System.Collections.Generic.List[string]]::new()

        # 1. DML Transaction Safety Check
        $hasDML = $sqlText -match "(?mi)\b(INSERT|UPDATE|DELETE|MERGE)\b"
        if ($hasDML) {
            if ($sqlText -notmatch "(?mi)\bBEGIN\s+(TRAN|TRANSACTION)\b") {
                $errors.Add("Missing 'BEGIN TRAN/TRANSACTION': All DML statements must be wrapped in a transaction.")
                $isValid = $false
            }
            if ($sqlText -notmatch "(?mi)\bROLLBACK\s+(TRAN|TRANSACTION)?\b") {
                $errors.Add("Missing 'ROLLBACK': Rule #2 requires test scripts to rollback by default.")
                $isValid = $false
            }
            if ($sqlText -match "(?mi)\b(UPDATE|DELETE)\b" -and $sqlText -notmatch "(?mi)\bWHERE\b") {
                $errors.Add("Missing WHERE clause in UPDATE/DELETE statement! High risk action blocked.")
                $isValid = $false
            }
        }

        # 2. Dangerous DDL checks
        $dangerousDDL = @("\bDROP\s+TABLE\b", "\bDROP\s+DATABASE\b", "\bTRUNCATE\s+TABLE\b", "\bALTER\s+TABLE\b")
        foreach ($ddl in $dangerousDDL) {
            if ($sqlText -match "(?mi)$ddl") {
                if ($allowDangerous) {
                    $warnings.Add("Warning: Dangerous DDL keyword detected ($ddl) - allowed via override flag.")
                } else {
                    $errors.Add("Dangerous DDL keyword detected ($ddl). Requires -AllowDangerous to run.")
                    $isValid = $false
                }
            }
        }

        # 3. WITH(NOLOCK) checks on key transaction tables
        $tables = @("STB_ProdRouteHist", "STB_MaterialLotInfo", "STB_SetInfo", "STB_MaterialDocDetail", "STB_SlittingStock_VVT")
        foreach ($tbl in $tables) {
            if ($sqlText -match "(?mi)\b$tbl\b" -and $sqlText -notmatch "(?mi)\b$tbl\b.*\bNOLOCK\b" -and $sqlText -notmatch "(?mi)\bNOLOCK\b.*\b$tbl\b") {
                $warnings.Add("Performance Warning: Transactional table '$tbl' accessed without WITH(NOLOCK).")
            }
        }

        return @{
            IsValid  = $isValid
            Errors   = $errors.ToArray()
            Warnings = $warnings.ToArray()
        }
    }
}
