param (
    [string]$SqlPath
)

if ([string]::IsNullOrEmpty($SqlPath)) {
    Write-Host "Usage: .\deploy_tool.ps1 -SqlPath <path_to_sql_file>" -ForegroundColor Yellow
    exit
}

if (!(Test-Path $SqlPath)) {
    Write-Host "File not found: $SqlPath" -ForegroundColor Red
    exit
}

$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"
$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"

$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

try {
    $sqlText = Get-Content -Raw -Path $SqlPath -Encoding UTF8
    
    # Clean SQL text for ADO.NET execution (strip USE statements)
    $sqlText = $sqlText -replace "(?mi)^\s*USE\s+\[?\w+\]?\s*(\r?\n|$)", ""
    
    # Split by GO and run each batch
    $batches = [System.Text.RegularExpressions.Regex]::Split($sqlText, "(?mi)^\s*GO\s*(\r?\n|$)")
    
    foreach ($batch in $batches) {
        $cleanBatch = $batch.Trim()
        if ($cleanBatch.Length -gt 0) {
            $command = New-Object System.Data.SqlClient.SqlCommand($cleanBatch, $connection)
            $command.ExecuteNonQuery() | Out-Null
        }
    }
    
    Write-Host "Deployed successfully: $SqlPath" -ForegroundColor Green
} catch {
    Write-Error "Deployment failed for $SqlPath : $_"
} finally {
    $connection.Close()
}
