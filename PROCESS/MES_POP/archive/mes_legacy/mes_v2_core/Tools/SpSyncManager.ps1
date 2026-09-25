# ==============================================================================
# SpSyncManager.ps1 — Dynamic Stored Procedure Sync & Clean Manager for MES_V2
# ==============================================================================

class MesSpSyncManager {
    [object]$ConnManager
    [string]$ProcDir

    MesSpSyncManager([object]$connManager, [string]$procDir) {
        $this.ConnManager = $connManager
        $this.ProcDir = $procDir
        if (-not (Test-Path $this.ProcDir)) {
            New-Item -ItemType Directory -Force -Path $this.ProcDir | Out-Null
        }
    }

    [bool] ExportProcedure([string]$spName) {
        $cleanSp = $spName.Trim().Replace("'", "''")
        $conn = $this.ConnManager.GetConnection("Production")
        try {
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('$cleanSp');"
            $defn = $cmd.ExecuteScalar()

            if ($defn) {
                $outPath = Join-Path $this.ProcDir "$cleanSp.sql"
                [System.IO.File]::WriteAllText($outPath, $defn, (New-Object System.Text.UTF8Encoding $true))
                return $true
            }
            return $false
        } finally {
            if ($conn -ne $null -and $conn.State -eq [System.Data.ConnectionState]::Open) {
                $conn.Close()
            }
        }
    }

    [int] CleanProcedures() {
        if (Test-Path $this.ProcDir) {
            $files = Get-ChildItem -Path $this.ProcDir -Filter "*.sql"
            $count = $files.Count
            if ($count -gt 0) {
                $files | Remove-Item -Force
            }
            return $count
        }
        return 0
    }
}
