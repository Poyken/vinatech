# ==============================================================================
# DeployEngine.ps1 — Safe Multi-Batch SQL Deployment Runner for MES_V2
# ==============================================================================

class MesDeployEngine {
    [object]$ConnManager

    MesDeployEngine([object]$connManager) {
        $this.ConnManager = $connManager
    }

    [hashtable] DeploySqlFile([string]$sqlPath, [bool]$allowDangerous = $false) {
        if (-not (Test-Path $sqlPath)) {
            throw "SQL deployment file not found at: $sqlPath"
        }

        $sqlText = [System.IO.File]::ReadAllText($sqlPath, [System.Text.Encoding]::UTF8)

        # 1. Run Static Safety Validation
        $validation = [MesSafetyValidator]::ValidateDeployment($sqlText, $allowDangerous)
        if (-not $validation.IsValid) {
            return @{
                Success  = $false
                Errors   = $validation.Errors
                Warnings = $validation.Warnings
            }
        }

        # 2. Execute Deployment Batch
        $conn = $this.ConnManager.GetConnection("Production")
        try {
            # Strip USE statements for ADO.NET
            $cleaned = $sqlText -replace "(?mi)^\s*USE\s+\[?\w+\]?\s*(\r?\n|$)", ""
            $batches = [System.Text.RegularExpressions.Regex]::Split($cleaned, "(?mi)^\s*GO\s*(\r?\n|$)")

            foreach ($b in $batches) {
                $trimmed = $b.Trim()
                if ($trimmed.Length -gt 0) {
                    $cmd = $conn.CreateCommand()
                    $cmd.CommandTimeout = 300
                    $cmd.CommandText = $trimmed
                    $null = $cmd.ExecuteNonQuery()
                }
            }

            return @{
                Success  = $true
                Errors   = @()
                Warnings = $validation.Warnings
            }
        } finally {
            if ($conn -ne $null -and $conn.State -eq [System.Data.ConnectionState]::Open) {
                $conn.Close()
            }
        }
    }
}
