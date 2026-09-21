<#
.SYNOPSIS
    Module PowerShell chia sẻ kết nối cơ sở dữ liệu cho hệ sinh thái 15 CSDL Vinatech.
.DESCRIPTION
    Cung cấp kết nối an toàn, cơ chế Failover, quản lý Profile, và thực thi câu lệnh an toàn (Readonly enforcement).
#>

function Get-DBConfig {
    param (
        [string]$ConfigPath = "$PSScriptRoot\..\db_config.json"
    )
    if (-not (Test-Path $ConfigPath)) {
        throw "Khong tim thay file cau hinh: $ConfigPath"
    }
    return Get-Content -Raw $ConfigPath -Encoding UTF8 | ConvertFrom-Json
}

function Get-DBConnection {
    param (
        [string]$Profile = "SmartFactoryV2",
        [string]$CustomDB = $null
    )
    $config = Get-DBConfig
    $targetDB = $config.Database
    
    if ($CustomDB) {
        $targetDB = $CustomDB
    } elseif ($Profile) {
        if ($config.Profiles.$Profile) {
            $targetDB = $config.Profiles.$Profile.Database
        } else {
            # Check if $Profile matches a Database property directly in Profiles
            $matched = $false
            foreach ($pKey in $config.Profiles.PSObject.Properties.Name) {
                if ($config.Profiles.$pKey.Database -ieq $Profile) {
                    $targetDB = $config.Profiles.$pKey.Database
                    $matched = $true
                    break
                }
            }
            if (-not $matched) {
                # Fallback: assume $Profile is the exact database name
                $targetDB = $Profile
            }
        }
    }

    $servers = @($config.Server)
    if ($config.FailoverServers) {
        $servers += $config.FailoverServers
    }
    $servers = $servers | Select-Object -Unique

    foreach ($srv in $servers) {
        $connStr = "Server=$srv;Database=$targetDB;User Id=$($config.User);Password=$($config.Password);TrustServerCertificate=True;Connect Timeout=$($config.Timeout);Application Name=Vinatech_DB_Hub"
        try {
            $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
            $conn.Open()
            return @{
                Connection = $conn
                Server     = $srv
                Database   = $targetDB
                Profile    = $Profile
            }
        } catch {
            Write-Warning "Khong the ket noi toi $srv ($targetDB): $($_.Exception.Message)"
        }
    }
    throw "Ket noi that bai toi tat ca cac may chu cho database: $targetDB"
}

function Invoke-SafeSelect {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Query,
        [string]$Profile = "SmartFactoryV2",
        [int]$MaxRows = 50,
        [int]$TimeoutSeconds = 15
    )

    # 1. Kiem tra tinh an toan (Read-only check)
    # Loai bo noi dung ben trong dau nhay don truoc khi kiem tra tu khoa cam
    $cleanQueryForCheck = [regex]::Replace($Query, "''|'[^']*'", "''")
    $forbiddenWords = @('INSERT', 'UPDATE', 'DELETE', 'DROP', 'ALTER', 'TRUNCATE', 'EXEC', 'EXECUTE', 'CREATE', 'GRANT', 'REVOKE')
    foreach ($word in $forbiddenWords) {
        if ($cleanQueryForCheck -match "\b$word\b") {
            throw "LENH BI CHAN: Chi duoc phep thuc hien SELECT tren Production. Phat hien tu khoa cam: $word"
        }
    }

    # 2. Canh bao WITH(NOLOCK)
    if ($Query -notmatch "WITH\s*\(\s*NOLOCK\s*\)") {
        Write-Verbose "Chu y: Cau truy van khong co WITH(NOLOCK). Khuyen nghi bo sung de tranh giu khoa doc."
    }

    $dbObj = Get-DBConnection -Profile $Profile
    $conn = $dbObj.Connection

    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Query
        $cmd.CommandTimeout = $TimeoutSeconds

        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dataset = New-Object System.Data.DataSet
        [void]$adapter.Fill($dataset, 0, $MaxRows, "Result")

        $table = $dataset.Tables["Result"]
        return @{
            Success   = $true
            RowCount  = $table.Rows.Count
            Data      = $table
            Server    = $dbObj.Server
            Database  = $dbObj.Database
            Profile   = $Profile
        }
    } catch {
        return @{
            Success   = $false
            Error     = $_.Exception.Message
            Server    = $dbObj.Server
            Database  = $dbObj.Database
            Profile   = $Profile
        }
    } finally {
        if ($conn.State -eq [System.Data.ConnectionState]::Open) {
            $conn.Close()
            $conn.Dispose()
        }
    }
}
