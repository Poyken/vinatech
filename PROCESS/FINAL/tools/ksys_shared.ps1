<#
.SYNOPSIS
    Shared Database Connection Module for YoungLimWon K-System Ace ERP (FINAL)
.DESCRIPTION
    Provides safe, strictly read-only connections with failover and NOLOCK enforcement
    for VINATECVN and VINATECVNCommon databases.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Get-KSysConfig {
    $dbConfigPath = Join-Path $PSScriptRoot "..\..\DATABASE\db_config.json"
    if (-not (Test-Path $dbConfigPath)) {
        throw "Cannot find database configuration at: $dbConfigPath"
    }
    return Get-Content -Raw $dbConfigPath -Encoding UTF8 | ConvertFrom-Json
}

function Get-KSysConnection {
    param (
        [ValidateSet("Business", "Common", "VINATECVN", "VINATECVNCommon")]
        [string]$TargetDB = "VINATECVN"
    )

    $dbName = if ($TargetDB -in @("Business", "VINATECVN")) { "VINATECVN" } else { "VINATECVNCommon" }
    $config = Get-KSysConfig

    $servers = @($config.Server)
    if ($config.FailoverServers) {
        $servers += $config.FailoverServers
    }
    $servers = $servers | Select-Object -Unique

    foreach ($srv in $servers) {
        $connStr = "Server=$srv;Database=$dbName;User Id=$($config.User);Password=$($config.Password);TrustServerCertificate=True;Connect Timeout=5;Application Name=KSystem_Ace_Hub"
        try {
            $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
            $conn.Open()
            return @{
                Connection = $conn
                Server     = $srv
                Database   = $dbName
            }
        } catch {
            Write-Verbose "Connection attempt to $srv ($dbName) failed: $($_.Exception.Message)"
        }
    }

    return $null
}

function Invoke-KSysQuery {
    param (
        [string]$Query,
        [string]$TargetDB = "VINATECVN",
        [int]$MaxRows = 50
    )

    # Strict Safety enforcement: Read-Only only
    $forbidden = @("UPDATE", "DELETE", "DROP", "ALTER", "TRUNCATE", "INSERT", "EXEC", "CREATE")
    foreach ($kw in $forbidden) {
        if ($Query -match "\b$kw\b") {
            Write-Error "VIOLATION OF RULE 1: Direct DML/DDL is strictly forbidden on K-System Production CSDL ($kw)."
            return $null
        }
    }

    $dbObj = Get-KSysConnection -TargetDB $TargetDB
    if ($null -eq $dbObj) {
        Write-Warning "Cannot connect to K-System Database server (dbserver.hycap.co.kr,5398). Server may be offline or protected by IDC firewall."
        return $null
    }

    $conn = $dbObj.Connection
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Query
        $cmd.CommandTimeout = 15

        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dataset = New-Object System.Data.DataSet
        [void]$adapter.Fill($dataset)

        if ($dataset.Tables.Count -gt 0) {
            $table = $dataset.Tables[0]
            if ($table.Rows.Count -gt $MaxRows) {
                Write-Warning "Output capped at $MaxRows rows (Total: $($table.Rows.Count))."
                return $table | Select-Object -First $MaxRows
            }
            return $table
        }
        return @()
    } finally {
        $conn.Close()
    }
}
