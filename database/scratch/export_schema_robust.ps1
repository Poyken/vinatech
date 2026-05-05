## ============================================================
## EXPORT FULL SCHEMA (NO DATA) - SmartFactoryV2 & SmartFramework
## Robust ADO.NET version (No STRING_AGG or XML PATH)
## Output: Desktop\database\schema_export\
## ============================================================

$server = 'dbserver.hycap.co.kr,5398'
$user = 'vinaadmin'
$pass = 'vina1234%6&8'
$databases = @('SmartFactoryV2', 'SmartFramework')
$baseDir = 'c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\schema_export'

if (!(Test-Path $baseDir)) { New-Item -Path $baseDir -ItemType Directory -Force | Out-Null }

function Get-DataSet {
    param($conn, $sql)
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.CommandTimeout = 120
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    return @($ds.Tables[0].Rows)
}

function Get-Scalar {
    param($conn, $sql)
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.CommandTimeout = 120
    return $cmd.ExecuteScalar()
}

foreach ($db in $databases) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  EXPORTING: $db" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

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
        Write-Host "  Connected to $db OK" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR connecting to $($db): $($_.Exception.Message)" -ForegroundColor Red
        continue
    }

    # ── 1. TABLES ──
    Write-Host "  [1/5] Exporting Tables..." -ForegroundColor Yellow
    $tables = Get-DataSet -conn $conn -sql "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo' ORDER BY TABLE_NAME"
    $tblCount = 0
    $allTblFile = Join-Path $dbDir "ALL_TABLES.sql"
    "-- DATABASE: $db - ALL TABLES" | Out-File $allTblFile -Encoding UTF8

    foreach ($row in $tables) {
        $tblName = $row["TABLE_NAME"]
        $tblCount++

        # Get Columns
        $cols = Get-DataSet -conn $conn -sql @"
SELECT c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, c.NUMERIC_SCALE, c.IS_NULLABLE, c.COLUMN_DEFAULT,
       COLUMNPROPERTY(OBJECT_ID('$tblName'), c.COLUMN_NAME, 'IsIdentity') AS IsIdentity
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = '$tblName' AND c.TABLE_SCHEMA = 'dbo'
ORDER BY c.ORDINAL_POSITION
"@
        $script = "CREATE TABLE [dbo].[$tblName] (`r`n"
        $colLines = @()
        foreach ($c in $cols) {
            $cName = $c["COLUMN_NAME"]
            $dType = $c["DATA_TYPE"].ToString().ToUpper()
            $maxLen = $c["CHARACTER_MAXIMUM_LENGTH"]
            $nPrec = $c["NUMERIC_PRECISION"]
            $nScale = $c["NUMERIC_SCALE"]
            
            $typeStr = $dType
            if ($dType -match 'VARCHAR|CHAR|BINARY') {
                $lenStr = if ($maxLen.ToString() -eq '-1') { 'MAX' } else { $maxLen }
                $typeStr += "($lenStr)"
            } elseif ($dType -match 'DECIMAL|NUMERIC') {
                $typeStr += "($nPrec,$nScale)"
            }

            $idStr = if ($c["IsIdentity"].ToString() -eq '1') { ' IDENTITY(1,1)' } else { '' }
            $nullStr = if ($c["IS_NULLABLE"].ToString() -eq 'YES') { ' NULL' } else { ' NOT NULL' }
            $defStr = if ($c["COLUMN_DEFAULT"]) { " DEFAULT $($c['COLUMN_DEFAULT'])" } else { '' }

            $colLines += "    [$cName] $typeStr$idStr$nullStr$defStr"
        }

        # Get PK
        $pks = Get-DataSet -conn $conn -sql @"
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = '$tblName' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
ORDER BY kcu.ORDINAL_POSITION
"@
        $script += ($colLines -join ",`r`n")
        
        if ($pks.Count -gt 0) {
            $pkList = ($pks | ForEach-Object { "[$($_.COLUMN_NAME)]" }) -join ', '
            $script += ",`r`n    CONSTRAINT [PK_$tblName] PRIMARY KEY CLUSTERED ($pkList)"
        }
        $script += "`r`n);`r`nGO`r`n"

        $script | Out-File (Join-Path $dbDir "Tables\$tblName.sql") -Encoding UTF8
        # "" | Add-Content $allTblFile -Encoding UTF8
        # "-- Table: $tblName" | Add-Content $allTblFile -Encoding UTF8
        # $script | Add-Content $allTblFile -Encoding UTF8

        if ($tblCount % 50 -eq 0) { Write-Host "    ... $tblCount tables exported" }
    }
    Write-Host "    Done: $tblCount tables" -ForegroundColor Green

    # ── 2. STORED PROCEDURES ──
    Write-Host "  [2/5] Exporting Stored Procedures..." -ForegroundColor Yellow
    $sps = Get-DataSet -conn $conn -sql "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE' AND ROUTINE_SCHEMA='dbo' ORDER BY ROUTINE_NAME"
    $spCount = 0
    $allSpFile = Join-Path $dbDir "ALL_STORED_PROCEDURES.sql"
    "-- DATABASE: $db - ALL STORED PROCEDURES" | Out-File $allSpFile -Encoding UTF8

    foreach ($row in $sps) {
        $spName = $row["ROUTINE_NAME"]
        $spCount++
        try {
            $def = Get-Scalar -conn $conn -sql "SELECT OBJECT_DEFINITION(OBJECT_ID('$spName'))"
            if ($def) {
                $spScript = "-- Procedure: $spName`r`n$def`r`nGO`r`n"
                $spScript | Out-File (Join-Path $dbDir "StoredProcedures\$spName.sql") -Encoding UTF8
                # $spScript | Add-Content $allSpFile -Encoding UTF8
            }
        } catch {}
        if ($spCount % 100 -eq 0) { Write-Host "    ... $spCount SPs exported" }
    }
    Write-Host "    Done: $spCount stored procedures" -ForegroundColor Green

    # ── 3. FUNCTIONS ──
    Write-Host "  [3/5] Exporting Functions..." -ForegroundColor Yellow
    $fns = Get-DataSet -conn $conn -sql "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='FUNCTION' AND ROUTINE_SCHEMA='dbo' ORDER BY ROUTINE_NAME"
    $fnCount = 0
    $allFnFile = Join-Path $dbDir "ALL_FUNCTIONS.sql"
    "-- DATABASE: $db - ALL FUNCTIONS" | Out-File $allFnFile -Encoding UTF8

    foreach ($row in $fns) {
        $fnName = $row["ROUTINE_NAME"]
        $fnCount++
        try {
            $def = Get-Scalar -conn $conn -sql "SELECT OBJECT_DEFINITION(OBJECT_ID('$fnName'))"
            if ($def) {
                $fnScript = "-- Function: $fnName`r`n$def`r`nGO`r`n"
                $fnScript | Out-File (Join-Path $dbDir "Functions\$fnName.sql") -Encoding UTF8
                # $fnScript | Add-Content $allFnFile -Encoding UTF8
            }
        } catch {}
    }
    Write-Host "    Done: $fnCount functions" -ForegroundColor Green

    # ── 4. VIEWS ──
    Write-Host "  [4/5] Exporting Views..." -ForegroundColor Yellow
    $views = Get-DataSet -conn $conn -sql "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA='dbo' ORDER BY TABLE_NAME"
    $vwCount = 0
    $allVwFile = Join-Path $dbDir "ALL_VIEWS.sql"
    "-- DATABASE: $db - ALL VIEWS" | Out-File $allVwFile -Encoding UTF8

    foreach ($row in $views) {
        $vwName = $row["TABLE_NAME"]
        $vwCount++
        try {
            $def = Get-Scalar -conn $conn -sql "SELECT OBJECT_DEFINITION(OBJECT_ID('$vwName'))"
            if ($def) {
                $vwScript = "-- View: $vwName`r`n$def`r`nGO`r`n"
                $vwScript | Out-File (Join-Path $dbDir "Views\$vwName.sql") -Encoding UTF8
                # $vwScript | Add-Content $allVwFile -Encoding UTF8
            }
        } catch {}
    }
    Write-Host "    Done: $vwCount views" -ForegroundColor Green

    # ── 5. TRIGGERS ──
    Write-Host "  [5/5] Exporting Triggers..." -ForegroundColor Yellow
    $trgs = Get-DataSet -conn $conn -sql "SELECT t.name AS TriggerName, OBJECT_NAME(t.parent_id) AS TableName FROM sys.triggers t WHERE t.is_ms_shipped = 0 ORDER BY t.name"
    $trgCount = 0
    $allTrgFile = Join-Path $dbDir "ALL_TRIGGERS.sql"
    "-- DATABASE: $db - ALL TRIGGERS" | Out-File $allTrgFile -Encoding UTF8

    foreach ($row in $trgs) {
        $trgName = $row["TriggerName"]
        $trgCount++
        try {
            $def = Get-Scalar -conn $conn -sql "SELECT OBJECT_DEFINITION(OBJECT_ID('$trgName'))"
            if ($def) {
                $trgScript = "-- Trigger: $trgName`r`n$def`r`nGO`r`n"
                $trgScript | Out-File (Join-Path $dbDir "Triggers\$trgName.sql") -Encoding UTF8
                # $trgScript | Add-Content $allTrgFile -Encoding UTF8
            }
        } catch {}
    }
    Write-Host "    Done: $trgCount triggers" -ForegroundColor Green

    # ── SUMMARY ──
    $summary = @"
# Schema Export Summary: $db
Exported: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Server: $server

- Tables: $tblCount
- Stored Procedures: $spCount
- Functions: $fnCount
- Views: $vwCount
- Triggers: $trgCount
TOTAL OBJECTS: $($tblCount + $spCount + $fnCount + $vwCount + $trgCount)
"@
    $summary | Out-File (Join-Path $dbDir "EXPORT_SUMMARY.md") -Encoding UTF8
    $conn.Close()
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ALL EXPORTS COMPLETED!" -ForegroundColor Cyan
Write-Host "  Location: $baseDir" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
