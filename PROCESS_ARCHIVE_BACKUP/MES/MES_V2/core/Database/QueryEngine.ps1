# ==============================================================================
# QueryEngine.ps1 — High-Performance Streaming Query Executor for MES_V2
# ==============================================================================

class MesQueryEngine {
    [object]$ConnManager

    MesQueryEngine([object]$connManager) {
        $this.ConnManager = $connManager
    }

    [System.Data.DataTable] ExecuteQuery([string]$sqlText) {
        return $this.ExecuteQuery($sqlText, "", 120)
    }

    [System.Data.DataTable] ExecuteQuery([string]$sqlText, [string]$profile) {
        return $this.ExecuteQuery($sqlText, $profile, 120)
    }

    [System.Data.DataTable] ExecuteQuery([string]$sqlText, [string]$profile, [int]$timeout) {
        if ([string]::IsNullOrWhiteSpace($sqlText)) {
            return New-Object System.Data.DataTable
        }

        # Validate Read-Only Safety
        $safety = [MesSafetyValidator]::ValidateReadOnly($sqlText)
        if (-not $safety.IsValid) {
            throw $safety.Error
        }

        $conn = $this.ConnManager.GetConnection($profile)
        try {
            $cmd = $conn.CreateCommand()
            $cmd.CommandTimeout = $timeout
            $cmd.CommandText = $sqlText

            $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
            $dt = New-Object System.Data.DataTable
            $null = $adapter.Fill($dt)
            return $dt
        } finally {
            if ($conn -ne $null -and $conn.State -eq [System.Data.ConnectionState]::Open) {
                $conn.Close()
            }
        }
    }

    [string] FormatResult([System.Data.DataTable]$dt) {
        return $this.FormatResult($dt, "Table")
    }

    [string] FormatResult([System.Data.DataTable]$dt, [string]$format) {
        if ($dt -eq $null -or $dt.Rows.Count -eq 0) {
            return "(0 rows returned)"
        }

        if ($format -eq "Json" -or $format -eq "json") {
            $rows = @()
            foreach ($r in $dt.Rows) {
                $rowHash = [ordered]@{}
                foreach ($col in $dt.Columns) {
                    $val = $r[$col.ColumnName]
                    if ($val -is [System.DBNull]) {
                        $rowHash[$col.ColumnName] = $null
                    } else {
                        $rowHash[$col.ColumnName] = $val
                    }
                }
                $rows += $rowHash
            }
            return ($rows | ConvertTo-Json -Depth 5)
        }

        if ($format -eq "Csv" -or $format -eq "csv") {
            $lines = [System.Collections.Generic.List[string]]::new()
            $headers = ($dt.Columns | ForEach-Object { '"' + $_.ColumnName.Replace('"', '""') + '"' }) -join ","
            $lines.Add($headers)

            foreach ($r in $dt.Rows) {
                $vals = foreach ($col in $dt.Columns) {
                    $v = $r[$col.ColumnName]
                    if ($v -is [System.DBNull] -or $v -eq $null) {
                        '""'
                    } else {
                        '"' + $v.ToString().Replace('"', '""') + '"'
                    }
                }
                $lines.Add($vals -join ",")
            }
            return ($lines -join [System.Environment]::NewLine)
        }

        return ($dt | Format-Table -AutoSize | Out-String -Width 4000)
    }
}
