$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"

$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

$sqlPath = "sql\procedures\usp_MaterialQcSampleResult_get.sql"
if (Test-Path $sqlPath) {
    $sqlText = Get-Content -Raw -Path $sqlPath
    
    # Clean SQL text for ADO.NET execution (strip USE and GO statements)
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
    
    Write-Host "Deploy stored procedure successfully!" -ForegroundColor Green
} else {
    Write-Error "File not found: $sqlPath"
}

$connection.Close()
