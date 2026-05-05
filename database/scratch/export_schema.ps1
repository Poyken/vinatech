## ============================================================
## EXPORT FULL SCHEMA (NO DATA) - SmartFactoryV2 & SmartFramework
## Output: Desktop\database\schema_export\
## ============================================================

$server = 'dbserver.hycap.co.kr,5398'
$user = 'vinaadmin'
$pass = 'vina1234%6&8'
$databases = @('SmartFactoryV2', 'SmartFramework')
$baseDir = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\schema_export'

if (!(Test-Path $baseDir)) { New-Item -Path $baseDir -ItemType Directory -Force | Out-Null }

function Run-SqlQuery {
    param($conn, $sql)
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.CommandTimeout = 120
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    return $ds.Tables[0]
}

function Get-SqlScalar {
    param($conn, $sql)
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.CommandTimeout = 120
    return $cmd.ExecuteScalar()
}

foreach ($db in $databases) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  EXPORTING: $db"
    Write-Host "========================================"

    $dbDir = Join-Path $baseDir $db
    $subDirs = @('Tables','StoredProcedures','Functions','Views','Triggers')
    foreach ($sub in $subDirs) {
        $p = Join-Path $dbDir $sub
        if (!(Test-Path $p)) { New-Item -Path $p -ItemType Directory -Force | Out-Null }
    }

    $connStr = "Server=$server;Database=$db;User ID=$user;Password=$pass;TrustServerCertificate=True;Connect Timeout=30;"
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    try {
        $conn.Open()
        Write-Host "  Connected OK"
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)"
        continue
    }

    # ── 1. TABLES ──
    Write-Host "  [1/5] Tables..."
    $tablesSql = @'
SELECT 
    t.TABLE_NAME,
    STUFF((
        SELECT CHAR(13) + CHAR(10) + '    [' + c.COLUMN_NAME + '] ' + 
            UPPER(c.DATA_TYPE) + 
            CASE 
                WHEN c.DATA_TYPE IN ('varchar','nvarchar','char','nchar','varbinary','binary') THEN 
                    CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN '(MAX)' ELSE '(' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) + ')' END
                WHEN c.DATA_TYPE IN ('decimal','numeric') THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR) + ',' + CAST(c.NUMERIC_SCALE AS VARCHAR) + ')'
                ELSE ''
            END +
            CASE WHEN COLUMNPROPERTY(OBJECT_ID(t.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') = 1 THEN ' IDENTITY(1,1)' ELSE '' END +
            CASE WHEN c.IS_NULLABLE = 'YES' THEN ' NULL' ELSE ' NOT NULL' END +
            CASE WHEN c.COLUMN_DEFAULT IS NOT NULL THEN ' DEFAULT ' + c.COLUMN_DEFAULT ELSE '' END
        FROM INFORMATION_SCHEMA.COLUMNS c 
        WHERE c.TABLE_NAME = t.TABLE_NAME AND c.TABLE_SCHEMA = 'dbo'
        ORDER BY c.ORDINAL_POSITION
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS ColumnDefs,
    STUFF((
        SELECT ', ' + kcu.COLUMN_NAME
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME AND tc.TABLE_NAME = kcu.TABLE_NAME
        WHERE tc.TABLE_NAME = t.TABLE_NAME AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
        ORDER BY kcu.ORDINAL_POSITION
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS PKColumns
FROM INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_TYPE = 'BASE TABLE' AND t.TABLE_SCHEMA = 'dbo'
ORDER BY t.TABLE_NAME
'@

    $tables = Run-SqlQuery -conn $conn -sql $tablesSql
    $tblCount = 0
    $allTblFile = Join-Path $dbDir "ALL_TABLES.sql"
    "-- DATABASE: $db - ALL TABLES" | Out-File $allTblFile -Encoding UTF8
    "-- Exported: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Add-Content $allTblFile -Encoding UTF8
    "-- Total: $($tables.Rows.Count) tables" | Add-Content $allTblFile -Encoding UTF8
    "" | Add-Content $allTblFile -Encoding UTF8

    foreach ($row in $tables.Rows) {
        $tblName = $row["TABLE_NAME"]
        $colDefs = $row["ColumnDefs"]
        $pkCols = $row["PKColumns"]
        $tblCount++

        $script = "CREATE TABLE [dbo].[$tblName] (" + [Environment]::NewLine
        $script += $colDefs
        if ($pkCols -and $pkCols.ToString() -ne '') {
            $pkFormatted = ($pkCols.ToString().Split(',') | ForEach-Object { "[$($_.Trim())]" }) -join ', '
            $script += "," + [Environment]::NewLine + "    CONSTRAINT [PK_$tblName] PRIMARY KEY CLUSTERED ($pkFormatted)"
        }
        $script += [Environment]::NewLine + ");" + [Environment]::NewLine + "GO" + [Environment]::NewLine

        $script | Out-File (Join-Path $dbDir "Tables\$tblName.sql") -Encoding UTF8
        "" | Add-Content $allTblFile -Encoding UTF8
        "-- Table: $tblName" | Add-Content $allTblFile -Encoding UTF8
        $script | Add-Content $allTblFile -Encoding UTF8

        if ($tblCount % 50 -eq 0) { Write-Host "    ... $tblCount tables" }
    }
    Write-Host "    Done: $tblCount tables"

    # ── 2. STORED PROCEDURES ──
    Write-Host "  [2/5] Stored Procedures..."
    $spList = Run-SqlQuery -conn $conn -sql "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE' AND ROUTINE_SCHEMA='dbo' ORDER BY ROUTINE_NAME"
    $spCount = 0
    $allSpFile = Join-Path $dbDir "ALL_STORED_PROCEDURES.sql"
    "-- DATABASE: $db - ALL STORED PROCEDURES ($($spList.Rows.Count) total)" | Out-File $allSpFile -Encoding UTF8
    "" | Add-Content $allSpFile -Encoding UTF8

    foreach ($row in $spList.Rows) {
        $spName = $row["ROUTINE_NAME"]
        $spCount++
        try {
            $def = Get-SqlScalar -conn $conn -sql "SELECT OBJECT_DEFINITION(OBJECT_ID('$spName'))"
            if ($def) {
                $spScript = "-- SP: $spName" + [Environment]::NewLine + $def + [Environment]::NewLine + "GO" + [Environment]::NewLine
                $spScript | Out-File (Join-Path $dbDir "StoredProcedures\$spName.sql") -Encoding UTF8
                $spScript | Add-Content $allSpFile -Encoding UTF8
            }
        } catch {}
        if ($spCount % 200 -eq 0) { Write-Host "    ... $spCount SPs" }
    }
    Write-Host "    Done: $spCount stored procedures"

    # ── 3. FUNCTIONS ──
    Write-Host "  [3/5] Functions..."
    $fnList = Run-SqlQuery -conn $conn -sql "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='FUNCTION' AND ROUTINE_SCHEMA='dbo' ORDER BY ROUTINE_NAME"
    $fnCount = 0
    $allFnFile = Join-Path $dbDir "ALL_FUNCTIONS.sql"
    "-- DATABASE: $db - ALL FUNCTIONS ($($fnList.Rows.Count) total)" | Out-File $allFnFile -Encoding UTF8

    foreach ($row in $fnList.Rows) {
        $fnName = $row["ROUTINE_NAME"]
        $fnCount++
        try {
            $def = Get-SqlScalar -conn $conn -sql "SELECT OBJECT_DEFINITION(OBJECT_ID('$fnName'))"
            if ($def) {
                $fnScript = "-- FN: $fnName" + [Environment]::NewLine + $def + [Environment]::NewLine + "GO" + [Environment]::NewLine
                $fnScript | Out-File (Join-Path $dbDir "Functions\$fnName.sql") -Encoding UTF8
                $fnScript | Add-Content $allFnFile -Encoding UTF8
            }
        } catch {}
    }
    Write-Host "    Done: $fnCount functions"

    # ── 4. VIEWS ──
    Write-Host "  [4/5] Views..."
    $vwList = Run-SqlQuery -conn $conn -sql "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA='dbo' ORDER BY TABLE_NAME"
    $vwCount = 0
    $allVwFile = Join-Path $dbDir "ALL_VIEWS.sql"
    "-- DATABASE: $db - ALL VIEWS ($($vwList.Rows.Count) total)" | Out-File $allVwFile -Encoding UTF8

    foreach ($row in $vwList.Rows) {
        $vwName = $row["TABLE_NAME"]
        $vwCount++
        try {
            $def = Get-SqlScalar -conn $conn -sql "SELECT OBJECT_DEFINITION(OBJECT_ID('$vwName'))"
            if ($def) {
                $vwScript = "-- View: $vwName" + [Environment]::NewLine + $def + [Environment]::NewLine + "GO" + [Environment]::NewLine
                $vwScript | Out-File (Join-Path $dbDir "Views\$vwName.sql") -Encoding UTF8
                $vwScript | Add-Content $allVwFile -Encoding UTF8
            }
        } catch {}
    }
    Write-Host "    Done: $vwCount views"

    # ── 5. TRIGGERS ──
    Write-Host "  [5/5] Triggers..."
    $trgList = Run-SqlQuery -conn $conn -sql "SELECT t.name AS TriggerName, OBJECT_NAME(t.parent_id) AS TableName FROM sys.triggers t WHERE t.is_ms_shipped = 0 ORDER BY t.name"
    $trgCount = 0
    $allTrgFile = Join-Path $dbDir "ALL_TRIGGERS.sql"
    "-- DATABASE: $db - ALL TRIGGERS ($($trgList.Rows.Count) total)" | Out-File $allTrgFile -Encoding UTF8

    foreach ($row in $trgList.Rows) {
        $trgName = $row["TriggerName"]
        $tblName = $row["TableName"]
        $trgCount++
        try {
            $def = Get-SqlScalar -conn $conn -sql "SELECT OBJECT_DEFINITION(OBJECT_ID('$trgName'))"
            if ($def) {
                $trgScript = "-- Trigger: $trgName (on $tblName)" + [Environment]::NewLine + $def + [Environment]::NewLine + "GO" + [Environment]::NewLine
                $trgScript | Out-File (Join-Path $dbDir "Triggers\$trgName.sql") -Encoding UTF8
                $trgScript | Add-Content $allTrgFile -Encoding UTF8
            }
        } catch {}
    }
    Write-Host "    Done: $trgCount triggers"

    # ── Summary ──
    $summaryText = "# Schema Export: $db" + [Environment]::NewLine
    $summaryText += "Exported: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" + [Environment]::NewLine
    $summaryText += "Tables: $tblCount | SPs: $spCount | Functions: $fnCount | Views: $vwCount | Triggers: $trgCount" + [Environment]::NewLine
    $summaryText += "TOTAL: $($tblCount + $spCount + $fnCount + $vwCount + $trgCount) objects" + [Environment]::NewLine
    $summaryText | Out-File (Join-Path $dbDir "EXPORT_SUMMARY.md") -Encoding UTF8

    Write-Host ""
    Write-Host "  === $db SUMMARY ==="
    Write-Host "  Tables:    $tblCount"
    Write-Host "  SPs:       $spCount"
    Write-Host "  Functions: $fnCount"
    Write-Host "  Views:     $vwCount"
    Write-Host "  Triggers:  $trgCount"
    Write-Host "  TOTAL:     $($tblCount + $spCount + $fnCount + $vwCount + $trgCount)"

    $conn.Close()
}

Write-Host ""
Write-Host "========================================"
Write-Host "  ALL DONE! Output: $baseDir"
Write-Host "========================================"
