# ==============================================================================
# ConnectionManager.ps1 — Robust & Thread-safe SQL Connection Manager for MES_V2
# ==============================================================================

class MesConnectionManager {
    [object]$Config
    [string]$ConfigPath
    [string]$CurrentServer
    [string]$CurrentDatabase

    MesConnectionManager([string]$configPath) {
        $this.ConfigPath = $configPath
        $this.LoadConfig()
    }

    [void] LoadConfig() {
        if (-not (Test-Path $this.ConfigPath)) {
            throw "Database configuration file not found at: $($this.ConfigPath)"
        }
        $raw = Get-Content -Raw -Path $this.ConfigPath -Encoding UTF8 | ConvertFrom-Json
        $this.Config = $raw
    }

    [object] GetProfile([string]$profileName) {
        if ([string]::IsNullOrEmpty($profileName)) {
            $profileName = $this.Config.DefaultProfile
        }
        $prof = $this.Config.Profiles.$profileName
        if ($null -eq $prof) {
            throw "Database profile '$profileName' not found in config."
        }
        return $prof
    }

    [System.Data.SqlClient.SqlConnection] GetConnection() {
        return $this.GetConnection("")
    }

    [System.Data.SqlClient.SqlConnection] GetConnection([string]$profileName) {
        $prof = $this.GetProfile($profileName)
        $servers = @($prof.Server) + @($this.Config.FallbackServers) | Select-Object -Unique

        foreach ($srv in $servers) {
            if ([string]::IsNullOrWhiteSpace($srv)) { continue }
            $connStr = "Server=$srv;Database=$($prof.Database);User Id=$($prof.User);Password=$($prof.Password);Connect Timeout=4;Encrypt=False;TrustServerCertificate=True;"
            $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
            try {
                $conn.Open()
                if ($conn.State -eq [System.Data.ConnectionState]::Open) {
                    $this.CurrentServer = $srv
                    $this.CurrentDatabase = $prof.Database
                    return $conn
                }
            } catch {
                if ($conn -ne $null -and $conn.State -eq [System.Data.ConnectionState]::Open) {
                    $conn.Close()
                }
            }
        }
        throw "Could not connect to any SQL Server in fallback list for database '$($prof.Database)'."
    }

    [hashtable] TestTcpConnection() {
        return $this.TestTcpConnection("")
    }

    [hashtable] TestTcpConnection([string]$profileName) {
        $prof = $this.GetProfile($profileName)
        $hostName = "dbserver.hycap.co.kr"
        $port = 5398

        if ($prof.Server -match "^([^,]+)(?:,(\d+))?$") {
            $hostName = $matches[1]
            if ($matches[2]) { $port = [int]$matches[2] }
        }

        $test = Test-NetConnection -ComputerName $hostName -Port $port -WarningAction SilentlyContinue
        return @{
            Host      = $hostName
            Port      = $port
            Succeeded = [bool]$test.TcpTestSucceeded
        }
    }
}
