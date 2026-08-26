# ==============================================================================
# mes.ps1 — Unified CLI Controller for Vinatech MES_V2
# ==============================================================================

param(
    [Parameter(Position=0)]
    [string]$Command = "help",

    [Parameter(Position=1)]
    [string]$Target = "",

    [string]$Query = "",
    [string]$Format = "Table",
    [string]$Screen = "",
    [string]$Barcode = "",
    [string]$Path = "",
    [string]$Name = "",
    [string]$TCode = "",
    [string]$Symptom = "",
    [string]$Cause = "",
    [string]$Patch = "",
    [switch]$AllowDangerous,
    [switch]$Html
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path $PSScriptRoot -Parent
$modulePath = Join-Path $root "core\Vinatech.MES.psm1"

Import-Module $modulePath -Force
$ctx = Initialize-MesContext

switch ($Command.ToLower()) {
    "check" {
        Write-Host "`n=== VINATECH MES V2 -- DATABASE DIAGNOSTIC ===" -ForegroundColor Cyan
        $tcp = $ctx.ConnectionManager.TestTcpConnection()
        if ($tcp.Succeeded) {
            Write-Host " [OK] TCP Connection to $($tcp.Host):$($tcp.Port) Succeeded." -ForegroundColor Green
        } else {
            Write-Host " [FAILED] Cannot reach $($tcp.Host):$($tcp.Port). Please check VPN connection." -ForegroundColor Red
            exit 1
        }

        Write-Host " Testing Live SQL Query..." -ForegroundColor Cyan
        $dt = $ctx.QueryEngine.ExecuteQuery("SELECT @@SERVERNAME AS ServerName, DB_NAME() AS DatabaseName, GETDATE() AS CurrentTime")
        Write-Host ($ctx.QueryEngine.FormatResult($dt, "Table")) -ForegroundColor Green
        Write-Host "=== DATABASE CONNECTION READY ===" -ForegroundColor Green
    }

    "query" {
        $sql = if ($Query) { $Query } else { $Target }
        if ([string]::IsNullOrWhiteSpace($sql)) {
            Write-Host "Usage: .\mes.ps1 query 'SELECT TOP 10 * FROM ...' [-Format Table|Json|Csv]" -ForegroundColor Yellow
            exit 1
        }
        try {
            $dt = $ctx.QueryEngine.ExecuteQuery($sql)
            $formatted = $ctx.QueryEngine.FormatResult($dt, $Format)
            Write-Host $formatted
        } catch {
            Write-Host "ERROR: $_" -ForegroundColor Red
        }
    }

    "debug" {
        $key = if ($Barcode) { $Barcode } elseif ($Target) { $Target } else { $Screen }
        if ([string]::IsNullOrWhiteSpace($key)) {
            Write-Host "Usage: .\mes.ps1 debug -Barcode 'VVQL033R...' [-Html]" -ForegroundColor Yellow
            Write-Host "       .\mes.ps1 debug -Screen 'B523'" -ForegroundColor Yellow
            exit 1
        }

        if ($Screen -or ($key.Length -le 6 -and $key -notmatch "^[A-Z]{2}\d{4}")) {
            $diag = $ctx.ScreenDebugger.DiagnoseScreen($key)
            Write-Host "`n=== SCREEN METADATA: $key ===" -ForegroundColor Cyan
            Write-Host ($ctx.QueryEngine.FormatResult($diag.Screen, "Table"))
            if ($diag.Objects) {
                Write-Host "`n=== SCREEN OBJECTS & SP MAPPING ===" -ForegroundColor Cyan
                Write-Host ($ctx.QueryEngine.FormatResult($diag.Objects, "Table"))
            }
        } else {
            Write-Host "`n=== 360 GOLDEN QUERY TRACE: $key ===" -ForegroundColor Cyan
            $trace = $ctx.GoldenQueryEngine.TraceBarcode($key)
            
            Write-Host "`n[STB_SetInfo]" -ForegroundColor Yellow
            Write-Host ($ctx.QueryEngine.FormatResult($trace.SetInfo, "Table"))

            Write-Host "`n[STB_MaterialLotInfo]" -ForegroundColor Yellow
            Write-Host ($ctx.QueryEngine.FormatResult($trace.MaterialLot, "Table"))

            Write-Host "`n[STB_ProdRouteHist]" -ForegroundColor Yellow
            Write-Host ($ctx.QueryEngine.FormatResult($trace.RouteHistory, "Table"))

            if ($Html) {
                $htmlContent = [MesHtmlReportGenerator]::GenerateBarcodeReport($trace, $key)
                $outPath = Join-Path $root "diagnostic_report_$key.html"
                [System.IO.File]::WriteAllText($outPath, $htmlContent, [System.Text.Encoding]::UTF8)
                Write-Host "`n[OK] Generated HTML Report: $outPath" -ForegroundColor Green
                Start-Process $outPath
            }
        }
    }

    "deploy" {
        $file = if ($Path) { $Path } else { $Target }
        if ([string]::IsNullOrWhiteSpace($file)) {
            Write-Host "Usage: .\mes.ps1 deploy -Path ./sql/patches/fix_01.sql [-AllowDangerous]" -ForegroundColor Yellow
            exit 1
        }
        $res = $ctx.DeployEngine.DeploySqlFile($file, $AllowDangerous)
        if ($res.Success) {
            Write-Host "[SUCCESS] Deployed: $file" -ForegroundColor Green
            if ($res.Warnings.Count -gt 0) {
                foreach ($w in $res.Warnings) { Write-Host "  [!] $w" -ForegroundColor Yellow }
            }
        } else {
            Write-Host "[FAILED] Deployment blocked by safety validator:" -ForegroundColor Red
            foreach ($e in $res.Errors) { Write-Host "  [X] $e" -ForegroundColor Red }
            exit 1
        }
    }

    "sync-sp" {
        $sp = if ($Name) { $Name } else { $Target }
        if ([string]::IsNullOrWhiteSpace($sp)) {
            Write-Host "Usage: .\mes.ps1 sync-sp -Name usp_DoProcessProdRouteHist" -ForegroundColor Yellow
            exit 1
        }
        $ok = $ctx.SpSyncManager.ExportProcedure($sp)
        if ($ok) {
            Write-Host "[OK] Synced procedure: $sp" -ForegroundColor Green
        } else {
            Write-Host "[FAILED] Procedure '$sp' not found in database." -ForegroundColor Red
        }
    }

    "clean-sp" {
        $count = $ctx.SpSyncManager.CleanProcedures()
        Write-Host "[OK] Cleaned $count temporary procedure files." -ForegroundColor Green
    }

    "record-fix" {
        if (-not $TCode -or -not $Symptom) {
            Write-Host "Usage: .\mes.ps1 record-fix -TCode 'B523' -Symptom '...' -Cause '...' -Patch '...'" -ForegroundColor Yellow
            exit 1
        }
        $ctx.FixbookLogger.RecordFix($TCode, $Symptom, $Cause, $Patch)
        Write-Host "[OK] Recorded hotfix for $TCode into troubleshooting docs." -ForegroundColor Green
    }

    default {
        Write-Host "======================================================================" -ForegroundColor Cyan
        Write-Host " VINATECH MES_V2 -- UNIFIED COMMAND LINE INTERFACE" -ForegroundColor Cyan
        Write-Host "======================================================================" -ForegroundColor Cyan
        Write-Host "Commands:"
        Write-Host "  check                           Test network & SQL Server connectivity"
        Write-Host "  query SQL [-Format Table|Json|Csv] Execute fast SELECT-only query"
        Write-Host "  debug -Barcode Code [-Html]     Run 360 Golden Query Trace"
        Write-Host "  debug -Screen TCode             Diagnose Screen & SP Object mappings"
        Write-Host "  deploy -Path File.sql           Deploy SQL script with transaction safety"
        Write-Host "  sync-sp -Name usp_name          Export stored procedure for local audit"
        Write-Host "  clean-sp                        Clean all downloaded temporary SPs"
        Write-Host "  record-fix -TCode ...           Log resolved incident into playbook"
        Write-Host "======================================================================" -ForegroundColor Cyan
    }
}
