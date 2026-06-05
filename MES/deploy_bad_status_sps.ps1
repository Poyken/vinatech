$server = "dbserver.hycap.co.kr,5398"
$database = "SmartFactoryV2"
$user = "vinaadmin"
$password = "vina1234%6&8"
$cs = "Server=$server;Database=$database;User Id=$user;Password=$password;TrustServerCertificate=True;Timeout=30;"

$conn = New-Object System.Data.SqlClient.SqlConnection($cs)
$conn.Open()

function Deploy-SP($sqlPath) {
    if (Test-Path $sqlPath) {
        $sqlText = Get-Content -Raw -Path $sqlPath -Encoding UTF8
        
        # Clean SQL text for ADO.NET execution (strip USE and GO statements)
        $sqlText = $sqlText -replace "(?mi)^\s*USE\s+\[?\w+\]?\s*(\r?\n|$)", ""
        
        # If it starts with CREATE PROCEDURE, replace it with ALTER PROCEDURE (or CREATE OR ALTER)
        # Note: CREATE OR ALTER is supported in SQL Server 2016+
        # Let's do CREATE OR ALTER to be robust, or we can just replace CREATE PROCEDURE with ALTER PROCEDURE
        # or we can drop it first or use ALTER. Since they exist, replacing CREATE with ALTER is safe.
        $sqlText = [System.Text.RegularExpressions.Regex]::Replace($sqlText, "(?i)\bCREATE\s+PROCEDURE\b", "ALTER PROCEDURE")
        
        # Split by GO and run each batch
        $batches = [System.Text.RegularExpressions.Regex]::Split($sqlText, "(?mi)^\s*GO\s*(\r?\n|$)")
        
        foreach ($batch in $batches) {
            $cleanBatch = $batch.Trim()
            if ($cleanBatch.Length -gt 0) {
                $command = New-Object System.Data.SqlClient.SqlCommand($cleanBatch, $conn)
                $command.ExecuteNonQuery() | Out-Null
            }
        }
        
        Write-Host "Deployed SP successfully: $sqlPath" -ForegroundColor Green
    } else {
        Write-Host "File not found: $sqlPath" -ForegroundColor Red
    }
}

Deploy-SP "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES\sql\procedures\usp_Get_VVT_Prod_Bad_Status.sql"
Deploy-SP "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES\sql\procedures\usp_Get_VVT_Prod_Bad_Stat_tail.sql"

$conn.Close()
