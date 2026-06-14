param (
    [string]$Query,
    [string]$SqlPath,
    [ValidateSet("Table", "JSON", "CSV")]
    [string]$Format = "Table"
)

# Connect to database using standard credentials
$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"
$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"

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

# Simple security check to block modifying DDL/DML statements
$restrictedKeywords = @(
    "\bINSERT\b", "\bUPDATE\b", "\bDELETE\b", "\bMERGE\b",
    "\bDROP\b", "\bALTER\b", "\bTRUNCATE\b", "\bCREATE\b"
)

foreach ($keyword in $restrictedKeywords) {
    if ($sqlText -match "(?mi)$keyword") {
        Write-Error "Safety violation: Modifying command detected ($keyword). run_query.ps1 only allows read-only queries."
        exit 1
    }
}

# Force warning if query doesn't use NOLOCK on major transactional tables
$transactionTables = @("STB_ProdRouteHist", "STB_MaterialLotInfo", "STB_SetInfo", "STB_MaterialDocDetail")
foreach ($table in $transactionTables) {
    if ($sqlText -match "(?mi)\b$table\b" -and $sqlText -notmatch "(?mi)\b$table\b.*\bNOLOCK\b") {
        Write-Host "Warning: Query accesses transactional table '$table' without WITH(NOLOCK). This could cause locks." -ForegroundColor Yellow
    }
}

$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
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
