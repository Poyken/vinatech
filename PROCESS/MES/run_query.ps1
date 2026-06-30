param (
    [string]$Query,
    [string]$SqlPath,
    [ValidateSet("Table", "JSON", "CSV")]
    [string]$Format = "Table"
)

# Load shared database utilities
. (Join-Path $PSScriptRoot "db_shared.ps1")

$sqlText = ""

if (![string]::IsNullOrEmpty($Query)) {
    $sqlText = $Query
} elseif (![string]::IsNullOrEmpty($SqlPath)) {
    if (!(Test-Path $SqlPath)) {
        Write-Error "SQL file not found at $SqlPath"
        exit 1
    }
    $sqlText = [System.IO.File]::ReadAllText($SqlPath, [System.Text.Encoding]::UTF8)
} else {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\run_query.ps1 -Query ""SELECT TOP 5 * FROM STB_SetInfo WITH(NOLOCK)""" -ForegroundColor Yellow
    Write-Host "  .\run_query.ps1 -SqlPath C:\path\to\query.sql -Format JSON" -ForegroundColor Yellow
    exit 1
}

# Run safety checks
$safetyResult = Test-SqlReadOnlySafety -SqlText $sqlText
if (!$safetyResult.IsValid) {
    Write-Error $safetyResult.Error
    exit 1
}

# Get NOLOCK warnings
$noLockWarnings = Get-NoLockWarnings -SqlText $sqlText
foreach ($warning in $noLockWarnings) {
    Write-Host $warning -ForegroundColor Yellow
}

# Scan local documentation for query components
Invoke-ProactiveKbSearch -SqlText $sqlText

# Execute query
$conn = Get-DbConnection
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sqlText
    
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dataTable = New-Object System.Data.DataTable
    $adapter.Fill($dataTable) | Out-Null
    
    if ($dataTable.Rows.Count -eq 0) {
        Write-Host "Query executed successfully. 0 rows returned." -ForegroundColor Gray
        exit 0
    }
    
    switch ($Format) {
        "JSON" {
            $dataTable | ConvertTo-Json -Depth 5
        }
        "CSV" {
            $dataTable | ConvertTo-Csv -NoTypeInformation
        }
        Default {
            $dataTable | Format-Table -AutoSize | Out-String -Width 1000
        }
    }
} catch {
    Write-Error "Query execution failed: $_"
    exit 1
} finally {
    $conn.Close()
}
