$connStr = "Server=dbserver.hycap.co.kr,5398;Database=SmartFactoryV2;User ID=vinaadmin;Password=vina1234%6&8;TrustServerCertificate=True;"
$targetFile = "c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\sample_factory_data.sql"
$materialCode = 'GCMDPT-621'

function Get-InsertScript($tableName, $sql) {
    try {
        $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
        $conn.Open()
        $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $adapter.Fill($dt) | Out-Null
        $conn.Close()

        if ($dt.Rows.Count -eq 0) { return "-- No data for ${tableName}`r`n" }

        $scripts = @()
        foreach ($row in $dt.Rows) {
            $cols = @()
            $vals = @()
            foreach ($col in $dt.Columns) {
                $cols += "[$($col.ColumnName)]"
                $val = $row[$col.ColumnName]
                if ($val -is [System.DBNull]) {
                    $vals += "NULL"
                } elseif ($val -is [System.DateTime]) {
                    $vals += "'$($val.ToString('yyyy-MM-dd HH:mm:ss'))'"
                } elseif ($val -is [System.Boolean]) {
                    $vals += if ($val) { "1" } else { "0" }
                } elseif ($val -is [System.ValueType]) {
                    $vals += $val.ToString().Replace(',', '.')
                } else {
                    $vals += "N'" + $val.ToString().Replace("'", "''") + "'"
                }
            }
            $scripts += "INSERT INTO [dbo].[$tableName] ($( $cols -join ', ' )) VALUES ($( $vals -join ', ' ));"
        }
        return $scripts -join "`r`n"
    } catch {
        $msg = $_.Exception.Message
        return "-- Error extracting ${tableName}: ${msg}`r`n"
    }
}

$finalScript = @"
-- ============================================================
-- VINATECH MES SAMPLE FACTORY DATA (FOR EDUCATIONAL TOUR)
-- Model: $materialCode
-- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- ============================================================

USE [SmartFactoryV2];
GO

-- 1. MATERIAL MASTER
$(Get-InsertScript "STB_MaterialMaster" "SELECT * FROM STB_MaterialMaster WHERE MaterialCode = '$materialCode'")

-- 2. ROUTING
$(Get-InsertScript "STB_BasicRoutingInfo" "SELECT * FROM STB_BasicRoutingInfo WHERE BasicRoutingCode IN (SELECT BasicRoutingCode FROM STB_MaterialMaster WHERE MaterialCode = '$materialCode')")
$(Get-InsertScript "STB_BasicRoutingDetail" "SELECT * FROM STB_BasicRoutingDetail WHERE BasicRoutingCode IN (SELECT BasicRoutingCode FROM STB_MaterialMaster WHERE MaterialCode = '$materialCode')")

-- 3. BOM
$(Get-InsertScript "STB_BomHeader" "SELECT * FROM STB_BomHeader WHERE MaterialCode = '$materialCode'")
$(Get-InsertScript "STB_BomDetail" "SELECT * FROM STB_BomDetail WHERE MaterialCode = '$materialCode'")

-- 4. LINES & PROCESSES
$(Get-InsertScript "STB_LineInfo" "SELECT TOP 10 * FROM STB_LineInfo WHERE IsUsed = 1")
$(Get-InsertScript "STB_MaterialType" "SELECT TOP 10 * FROM STB_MaterialType")

GO
"@

$finalScript | Out-File $targetFile -Encoding UTF8
Write-Host "Sample data exported to $targetFile" -ForegroundColor Green
