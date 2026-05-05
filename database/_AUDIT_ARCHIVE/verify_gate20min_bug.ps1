$connStr = 'Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;Connect Timeout=15;'
$conn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn.Open()

Write-Host "===== GATE 20 MIN BUG VERIFICATION =====" -ForegroundColor Yellow

# Step 1: Confirm bug exists in live SP
$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
DECLARE @SPText NVARCHAR(MAX)
SET @SPText = OBJECT_DEFINITION(OBJECT_ID('usp_DoProcessProdRouteHistForCalc_SmartApp_VNT'))

SELECT 
    CASE 
        WHEN CHARINDEX('@SIExtInt01 = Null', @SPText) > 0 THEN 'BUG_CONFIRMED'
        WHEN CHARINDEX('@SIExtInt01 IS Null', @SPText) > 0 THEN 'ALREADY_FIXED'
        ELSE 'UNKNOWN'
    END AS BugStatus,
    LEN(@SPText) AS SPLength
"@
$cmd.CommandTimeout = 15
$rdr = $cmd.ExecuteReader()
if ($rdr.Read()) {
    $status = $rdr["BugStatus"].ToString()
    $len = $rdr["SPLength"].ToString()
    Write-Host "`nBug Status: $status (SP Length: $len chars)" -ForegroundColor $(if ($status -eq 'BUG_CONFIRMED') { 'Red' } else { 'Green' })
}
$rdr.Close()

# Step 2: Impact analysis
$cmd2 = $conn.CreateCommand()
$cmd2.CommandText = @"
SELECT 
    SUM(CASE WHEN SIExtInt01 IS NULL THEN 1 ELSE 0 END) AS NullCount,
    SUM(CASE WHEN SIExtInt01 = 1 THEN 1 ELSE 0 END) AS FlaggedCount,
    COUNT(*) AS Total
FROM STB_SetInfo
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
"@
$cmd2.CommandTimeout = 15
$rdr2 = $cmd2.ExecuteReader()
if ($rdr2.Read()) {
    Write-Host "`nImpact Analysis (7 days):"
    Write-Host "  SIExtInt01 = NULL: $($rdr2['NullCount']) (would be checked after fix)"
    Write-Host "  SIExtInt01 = 1:    $($rdr2['FlaggedCount']) (already flagged)"
    Write-Host "  Total SetInfo:     $($rdr2['Total'])"
}
$rdr2.Close()

$conn.Close()
Write-Host "`n===== DONE =====" -ForegroundColor Yellow
