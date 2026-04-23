Add-Type -AssemblyName System.Data
$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=5;'
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "
        SELECT COUNT(*) FROM STB_VVT_SortingErrorData;
        SELECT TOP 1 SortingID, SortingDate FROM STB_VVT_SortingErrorData ORDER BY SortingID ASC;
        SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_RawMaterialInputHist_uid')) as SPContent;
    "
    $reader = $cmd.ExecuteReader()
    if ($reader.Read()) { Write-Host "Total Rows: $($reader[0])" }
    $reader.NextResult()
    if ($reader.Read()) { 
        Write-Host "First ID: $($reader[0])"
        Write-Host "First Date Format: $($reader[1])"
    }
    $reader.NextResult()
    if ($reader.Read()) {
        $sp = $reader[0].ToString()
        Write-Host "--- Verification in SP ---"
        $pairs = @(
            "VVQM193R072798",
            "VWQH1520001E05-004",
            "CRCEK0-266",
            "CRYPK0-022"
        )
        foreach ($p in $pairs) {
            if ($sp -like "*$p*") { Write-Host "FOUND: $p" }
            else { Write-Host "MISSING: $p" }
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
} finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
