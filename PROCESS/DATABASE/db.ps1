<#
.SYNOPSIS
    VINATECH DATABASE COMMAND HUB (db.ps1 v3.0) - CLI DIEU PHOI 15 CO SO DU LIEU
.DESCRIPTION
    Trung tam dieu phoi duy nhat cho cac tac vu kiem toan, tra cuu tri thuc, trich xuat cau truc, doc ma nguon Stored Procedure va truy van du lieu an toan tren 15 CSDL tai may chu dbserver.hycap.co.kr,5398.
.EXAMPLE
    .\db.ps1 health
    .\db.ps1 jobs -ActiveOnly
    .\db.ps1 triggers -Profile SmartFactoryV2 -Name utr_STB_SetInfo_DayPlanNo_iu -Definition
    .\db.ps1 index -Profile SmartFactoryV2 -Table STB_VVT_ESRDATA
    .\db.ps1 crossdb -Profile SmartFactoryV2
    .\db.ps1 lineage -Type BARCODE -Value "VVQR153R060615"
#>
param (
    [Parameter(Position=0)]
    [ValidateSet("help", "list", "health", "find", "schema", "query", "trace", "stats", "sp", "jobs", "triggers", "index", "crossdb", "lineage", "auditkb", "locks", "user", "pack")]
    [string]$Action = "help",

    [Parameter(Position=1)]
    [string]$Target,

    [string]$Profile = "SmartFactoryV2",
    [string]$Table,
    [string]$Query,
    [string]$Type = "PO",
    [string]$Value,
    [string]$Search,
    [string]$Name,
    [switch]$Definition,
    [int]$MaxRows = 50,
    [switch]$Detail,
    [switch]$ActiveOnly,
    [switch]$AllDatabases,
    [switch]$ExportReport
)

$toolsDir = "$PSScriptRoot\tools"
. "$toolsDir\db_shared.ps1"

function Show-Banner {
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  VINATECH DATABASE CLI COMMAND HUB (db.ps1 v3.0)" -ForegroundColor Cyan
    Write-Host "  May chu: dbserver.hycap.co.kr,5398 - 15 Co so Du lieu, 11,509 Tables, 66,540 SPs" -ForegroundColor DarkCyan
    Write-Host "================================================================================" -ForegroundColor Cyan
}

function Show-Help {
    Show-Banner
    Write-Host "CAC LENH DIEU HANH CHINH:" -ForegroundColor Yellow
    Write-Host '  1. .\db.ps1 list                             - Liet ke toan bo 15 CSDL va Profiles'
    Write-Host '  2. .\db.ps1 health [-Detail]                 - Quet suc khoe va do do tre 15 CSDL'
    Write-Host '  3. .\db.ps1 stats [-Profile <P>]             - Thong ke chuyen sau: Tables, Views, SPs, Top Rows'
    Write-Host '  4. .\db.ps1 sp -Profile <P> -Search <Word>   - Tra cuu Stored Procedure (trong 66,540 SPs)'
    Write-Host '  5. .\db.ps1 sp -Profile <P> -Name <N> -Def   - Doc ma nguon SQL cua Stored Procedure'
    Write-Host '  6. .\db.ps1 schema -Profile <P> -Table <T>   - Tra cuu cau truc cot, kieu du lieu, PK, Comment'
    Write-Host '  7. .\db.ps1 query -Profile <P> "<SQL>"       - Thuc thi SELECT an toan (NOLOCK, TOP 50)'
    Write-Host '  8. .\db.ps1 find "<Keyword>"                 - Tra cuu sieu toc L1 Cache va 20+ file KB'
    Write-Host '  9. .\db.ps1 jobs [-ActiveOnly] [-Name <N>]   - Kiem toan SQL Server Agent Jobs & buoc chay'
    Write-Host ' 10. .\db.ps1 triggers -Profile <P> [-Def]     - Kiem toan DML/DDL Triggers va ma nguon'
    Write-Host ' 11. .\db.ps1 index -Profile <P> -Table <T>    - Kiem toan Index, Space Used va DMV Missing Index'
    Write-Host ' 12. .\db.ps1 crossdb [-Profile <P>]           - Quet cac phu thuoc goi cheo CSDL & Linked Servers'
    Write-Host ' 13. .\db.ps1 lineage -Type <T> -Value <V>     - Truy vet huyet mach du lieu 360 do (PO/WO/LOT/BARCODE)'
    Write-Host ' 14. .\db.ps1 auditkb [-ExportReport]          - Kiem toan do tin cay cua Markdown KB vs Live DB'
    Write-Host ' 15. .\db.ps1 locks [-Profile <P>]             - Soi real-time khoa blocking, page U-locks tren 15 CSDL'
    Write-Host ' 16. .\db.ps1 user "<EmpNo/UserId>"           - Tra cuu nhan su & tai khoan 360 do tren 5 CSDL'
    Write-Host ' 17. .\db.ps1 pack "<Lot/PackingID>"          - Truy vet dong goi & in tem PackingID 360 do'
    Write-Host ""
    Write-Host "DANH SACH PROFILES CHINH:" -ForegroundColor Magenta
    Write-Host "  SmartFactoryV2, SmartFramework, Groupware, ERP, Bizbox, POP, Andon,"
    Write-Host "  SSO, WebSocket, Spreadsheet, WCMS, Incubator, KSOX, LegacyERP, StreamDocs"
    Write-Host "================================================================================" -ForegroundColor Cyan
}

switch ($Action.ToLower()) {
    "help" {
        Show-Help
    }

    "list" {
        Show-Banner
        $config = Get-DBConfig
        $list = @()
        foreach ($prop in $config.Profiles.PSObject.Properties) {
            $list += [PSCustomObject]@{
                Profile     = $prop.Name
                Database    = $prop.Value.Database
                Description = $prop.Value.Description
            }
        }
        $list | Format-Table -AutoSize
    }

    "health" {
        & "$toolsDir\health_check.ps1" -Detail:$Detail
    }

    "stats" {
        & "$toolsDir\db_stats.ps1" -Profile $Profile
    }

    "sp" {
        $spSearch = if ($Search) { $Search } elseif ($Target) { $Target } else { $Name }
        $spName = if ($Name) { $Name } else { $Target }
        & "$toolsDir\inspect_sp.ps1" -Profile $Profile -Search $spSearch -Name $spName -Definition:$Definition
    }

    "find" {
        $keyword = if ($Target) { $Target } else { $Value }
        if (-not $keyword) {
            Write-Host 'Vui long nhap tu khoa can tra cuu: .\db.ps1 find "<TuKhoa>"' -ForegroundColor Red
            return
        }
        & "$toolsDir\find_kb.ps1" -Keyword $keyword
    }

    "schema" {
        $tbl = if ($Table) { $Table } else { $Target }
        if (-not $tbl) {
            Write-Host 'Vui long chi dinh ten bang: .\db.ps1 schema -Profile <Profile> -Table <TableName>' -ForegroundColor Red
            return
        }
        & "$toolsDir\inspect_schema.ps1" -Table $tbl -Profile $Profile
    }

    "query" {
        $sql = if ($Query) { $Query } else { $Target }
        if (-not $sql) {
            Write-Host 'Vui long chi dinh cau lenh SQL SELECT: .\db.ps1 query -Profile <Profile> "<SQL>"' -ForegroundColor Red
            return
        }
        & "$toolsDir\run_query.ps1" -Query $sql -Profile $Profile -MaxRows $MaxRows
    }

    "jobs" {
        $jobName = if ($Name) { $Name } else { $Target }
        & "$toolsDir\audit_jobs.ps1" -Search $Search -Name $jobName -ActiveOnly:$ActiveOnly -Detail:$Detail
    }

    "triggers" {
        $trigName = if ($Name) { $Name } else { $Target }
        $trigTbl = if ($Table) { $Table } else { $null }
        & "$toolsDir\audit_triggers.ps1" -Profile $Profile -Table $trigTbl -Name $trigName -Definition:$Definition
    }

    "index" {
        $idxTbl = if ($Table) { $Table } else { $Target }
        if (-not $idxTbl) {
            Write-Host 'Vui long chi dinh ten bang: .\db.ps1 index -Profile <Profile> -Table <TableName>' -ForegroundColor Red
            return
        }
        & "$toolsDir\audit_indexes.ps1" -Table $idxTbl -Profile $Profile
    }

    "crossdb" {
        & "$toolsDir\audit_cross_db.ps1" -Profile $Profile -AllDatabases:$AllDatabases
    }

    "lineage" {
        $lineageVal = if ($Value) { $Value } else { $Target }
        if (-not $lineageVal) {
            Write-Host 'Vui long chi dinh gia tri can truy vet: .\db.ps1 lineage -Type <LOT|BARCODE|PO|WO|ITEM> -Value <Val>' -ForegroundColor Red
            return
        }
        & "$toolsDir\trace_lineage.ps1" -Type $Type -Value $lineageVal
    }

    "trace" {
        $val = if ($Value) { $Value } else { $Target }
        if (-not $val) {
            Write-Host 'Vui long chi dinh gia tri can truy vet: .\db.ps1 trace -Type <PO|Lot> -Value <Val>' -ForegroundColor Red
            return
        }
        Show-Banner
        Write-Host "TRUY VET MA: Type = $Type | Value = $val" -ForegroundColor Yellow

        switch ($Type.ToUpper()) {
            "PO" {
                Write-Host "1. Kiem tra Groupware PO (VINATECH_GROUP)..." -ForegroundColor Cyan
                & "$toolsDir\run_query.ps1" -Profile "Groupware" -Query "SELECT TOP 5 DOCUMENT_SAVE_CODE, NO_PO, CD_COMPANY, CD_PARTNER, DT_PO FROM VINA_DOCUMENT_POH WITH(NOLOCK) WHERE NO_PO LIKE '%$val%'"
                
                Write-Host "2. Kiem tra ERP PO (NEOE)..." -ForegroundColor Cyan
                & "$toolsDir\run_query.ps1" -Profile "ERP" -Query "SELECT TOP 5 NO_PO, CD_PARTNER, DT_PO, AM_EXCH, FG_TRANS FROM PU_POH WITH(NOLOCK) WHERE NO_PO LIKE '%$val%'"
            }
            "LOT" {
                Write-Host "1. Kiem tra MES SetInfo (SmartFactoryV2)..." -ForegroundColor Cyan
                & "$toolsDir\run_query.ps1" -Profile "SmartFactoryV2" -Query "SELECT TOP 5 ControlNo, DayPlanNo, MaterialCode, Barcode, CurrentRouteCode, ProdQty, DefectQty, LotNumber FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode LIKE '%$val%' OR LotNumber LIKE '%$val%'"
                
                Write-Host "2. Kiem tra POP Sync (MongoToMesPerformance)..." -ForegroundColor Cyan
                & "$toolsDir\run_query.ps1" -Profile "SmartFactoryV2" -Query "SELECT TOP 5 DayPlanNo, Barcode, RouteCode, MachineCode, IsDone, TotalProdQty, InsertDateTime FROM MongoToMesPerformance WITH(NOLOCK) WHERE Barcode LIKE '%$val%'"
            }
            default {
                Write-Host "Loai truy vet khong duoc ho tro: $Type. Ho tro: PO, LOT" -ForegroundColor Red
            }
        }
    }

    "auditkb" {
        if ($PSBoundParameters.ContainsKey('ExportReport')) {
            & "$toolsDir\audit_kb_reliability.ps1" -ExportReport:$ExportReport
        } else {
            & "$toolsDir\audit_kb_reliability.ps1" -ExportReport:$true
        }
    }

    "locks" {
        $mesTools = Join-Path $PSScriptRoot "..\MES_POP\tools"
        $lockScript = Join-Path $mesTools "inspect_db_locks.ps1"
        if (Test-Path $lockScript) {
            & $lockScript -Profile $Profile
        } else {
            Write-Error "inspect_db_locks.ps1 not found."
        }
    }

    "user" {
        $mesTools = Join-Path $PSScriptRoot "..\MES_POP\tools"
        $userScript = Join-Path $mesTools "inspect_user.ps1"
        $usr = if ($Target) { $Target } else { $Value }
        if (Test-Path $userScript) {
            & $userScript $usr
        } else {
            Write-Error "inspect_user.ps1 not found."
        }
    }

    "pack" {
        $mesTools = Join-Path $PSScriptRoot "..\MES_POP\tools"
        $packScript = Join-Path $mesTools "inspect_pack.ps1"
        $pk = if ($Target) { $Target } else { $Value }
        if (Test-Path $packScript) {
            & $packScript $pk
        } else {
            Write-Error "inspect_pack.ps1 not found."
        }
    }
}
