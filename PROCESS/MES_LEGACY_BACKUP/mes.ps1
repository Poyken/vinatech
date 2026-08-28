# ==============================================================================
# mes.ps1 — VINATECH MES UNIFIED CLI HUB (Trung Tam Dieu Phoi Lenh Van Hanh)
# ==============================================================================

param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',
    
    [Parameter(Position = 1)]
    [string]$Target = '',
    
    [string]$Profile = 'SmartFactoryV2',
    [switch]$Force,
    [switch]$Detail,
    [switch]$Clean
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = $PSScriptRoot
. (Join-Path $scriptDir 'db_shared.ps1')

function Show-MesBanner {
    Write-Host ''
    Write-Host '======================================================================' -ForegroundColor Cyan
    Write-Host '             VINATECH MES UNIFIED CLI HUB (v2.0)' -ForegroundColor Yellow
    Write-Host '    Trung Tam Dieu Phoi Van Hanh, Chan Doan & Khac Phuc Su Co MES' -ForegroundColor White
    Write-Host '======================================================================' -ForegroundColor Cyan
}

function Show-Help {
    Show-MesBanner
    Write-Host ''
    Write-Host 'CAC LENH VAN HANH CHINH:' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  1. TRUY VET DU LIEU & SU CO (INVESTIGATION):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 trace <Lot/Barcode>       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Golden Query 360 do quet sach Lot, Routing, Kho, Thung' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 screen <ScreenID>         ' -NoNewline -ForegroundColor Green
    Write-Host '-> Debug man hinh MES (Grid, SP, Bang lien quan: B530, B540...)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 sp <SP_Name>              ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tai SP goc moi nhat tu DB ve local de phan tich' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 find <Keyword>            ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tra cuu giai phap trong 12+ KB files va 90+ Screens' -ForegroundColor Gray

    Write-Host ''
    Write-Host '  2. TRUY VAN & KIEM TRA HE THONG (SYSTEM & QUERY):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 check [-Profile <Name>]   ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra ket noi toi 15 Database (MES, GW, ERP, POP...)' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 health [-Detail]          ' -NoNewline -ForegroundColor Green
    Write-Host '-> Morning Health Check quet Lot HOLD, WIP 24h, Box do dang' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 audit                     ' -NoNewline -ForegroundColor Green
    Write-Host '-> Audit do tin cay toan bo tai lieu Markdown vs Live DB' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 query "<SELECT_SQL>"      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Chay cau SELECT an toan (kem NOLOCK warning & Multi-DB)' -ForegroundColor Gray

    Write-Host ''
    Write-Host '  3. KHAC PHUC SU CO & TRIEN KHAI (HOTFIX & DEPLOY):' -ForegroundColor Cyan
    Write-Host '     .\mes.ps1 new-fix <IssueCode>       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Sinh template SQL Fix chuan UTF-8-BOM co BEGIN TRAN...ROLLBACK' -ForegroundColor Gray
    Write-Host '     .\mes.ps1 deploy <Path.sql> [-Force]' -NoNewline -ForegroundColor Green
    Write-Host '-> Deploy SQL an toan (Tu dong Snapshot Pre-flight backup)' -ForegroundColor Gray

    Write-Host ''
    Write-Host 'Cac Profile CSDL ho tro:' -ForegroundColor Yellow
    Write-Host '  SmartFactoryV2 (Mac dinh), SmartFramework, Groupware, ERP, Bizbox, POP, Andon...' -ForegroundColor Gray
    Write-Host ''
}

# Main Command Dispatcher
$cmdLower = $Command.ToLower()
if ($cmdLower -eq 'help' -or $cmdLower -eq '-h' -or $cmdLower -eq '--help') {
    Show-Help
}
elseif ($cmdLower -eq 'check') {
    Show-MesBanner
    if ($Target) { $Profile = $Target }
    Write-Host "Kiem tra ket noi Database Profile: $Profile..." -ForegroundColor Cyan
    $conn = Get-DbConnection -Profile $Profile
    if ($conn -ne $null) {
        Write-Host "-> Ket noi thanh cong toi Database: $($conn.Database) tren may chu: $($conn.DataSource)" -ForegroundColor Green
        $conn.Close()
    } else {
        Write-Host "-> Khong the ket noi toi profile: $Profile" -ForegroundColor Red
    }
}
elseif ($cmdLower -eq 'trace') {
    Show-MesBanner
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host 'Loi: Vui long nhap ma LotID hoac Barcode can truy vet!' -ForegroundColor Red
        Write-Host 'Vi du: .\mes.ps1 trace "VN-2026-LOT001"' -ForegroundColor Yellow
        exit 1
    }

    Write-Host "(*) [GOLDEN QUERY 360] Dang truy vet toan dien ma: $Target..." -ForegroundColor Cyan
    
    $conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
    if ($conn -eq $null) { exit 1 }

    try {
        Write-Host ''
        Write-Host '=== 1. THONG TIN LOT & TON KHO (STB_MaterialLotInfo) ===' -ForegroundColor Yellow
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 30
        $cmd.CommandText = 'SELECT TOP 5 MaterialLotNo, MaterialCode, MaterialName, FactoryCode, PlantCode, CurrentQty, MaterialWarehouseCode, ExpireDate, InDate, CreateDateTime FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE MaterialLotNo = @Lot OR Barcode = @Lot OR PackingID = @Lot'
        $cmd.Parameters.AddWithValue('@Lot', $Target) | Out-Null
        $adp = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dtLot = New-Object System.Data.DataTable
        $null = $adp.Fill($dtLot)
        if ($dtLot.Rows.Count -gt 0) {
            $dtLot | Format-Table -AutoSize | Out-String -Width 4000 | Write-Host -ForegroundColor White
        } else {
            Write-Host '  (Khong tim thay ban ghi trong STB_MaterialLotInfo)' -ForegroundColor Gray
        }

        Write-Host ''
        Write-Host '=== 2. THONG TIN SAN XUAT & SET (STB_SetInfo) ===' -ForegroundColor Yellow
        $cmd.CommandText = 'SELECT TOP 5 ControlNo, PONo, MaterialCode, Barcode, SetSeq, IsLineInput, IsLoss, IsDefect, CreateDateTime FROM STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @Lot OR PONo = @Lot OR Barcode = @Lot'
        $dtBox = New-Object System.Data.DataTable
        $null = $adp.Fill($dtBox)
        if ($dtBox.Rows.Count -gt 0) {
            $dtBox | Format-Table -AutoSize | Out-String -Width 4000 | Write-Host -ForegroundColor White
        } else {
            Write-Host '  (Khong co thong tin trong STB_SetInfo)' -ForegroundColor Gray
        }

        Write-Host ''
        Write-Host '=== 3. LICH SU CONG DOAN SAN XUAT (STB_ProdRouteHist) ===' -ForegroundColor Yellow
        $cmd.CommandText = 'SELECT TOP 15 ProdRouteHistNo, ControlNo, PONo, WorkCenterCode, RouteCode, ProdQty, DefectQty, CreateDateTime FROM STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = @Lot OR PONo = @Lot OR ProdRouteHistNo = @Lot ORDER BY CreateDateTime DESC'
        $dtRoute = New-Object System.Data.DataTable
        $null = $adp.Fill($dtRoute)
        if ($dtRoute.Rows.Count -gt 0) {
            $dtRoute | Format-Table -AutoSize | Out-String -Width 4000 | Write-Host -ForegroundColor White
        } else {
            Write-Host '  (Khong co lich su cong doan trong STB_ProdRouteHist)' -ForegroundColor Gray
        }

        Write-Host ''
        Write-Host '=== 4. LIEN KET NGUYEN VAT LIEU / CHUNG TU (STB_MaterialDocDetail) ===' -ForegroundColor Yellow
        $cmd.CommandText = 'SELECT TOP 5 DocNo, DocSeq, MaterialCode, MaterialLotNo, TargetMaterialLotNo, DocQty, CreateDateTime FROM STB_MaterialDocDetail WITH(NOLOCK) WHERE MaterialLotNo = @Lot OR TargetMaterialLotNo = @Lot OR DocNo = @Lot'
        $dtDoc = New-Object System.Data.DataTable
        $null = $adp.Fill($dtDoc)
        if ($dtDoc.Rows.Count -gt 0) {
            $dtDoc | Format-Table -AutoSize | Out-String -Width 4000 | Write-Host -ForegroundColor White
        } else {
            Write-Host '  (Khong co chung tu lien ket NVL trong STB_MaterialDocDetail)' -ForegroundColor Gray
        }

    } catch {
        Write-Host "Loi khi truy vet: $_" -ForegroundColor Red
    } finally {
        if ($conn.State -eq 'Open') { $conn.Close() }
    }
}
elseif ($cmdLower -eq 'screen') {
    $dbgScript = Join-Path $scriptDir 'debug_screen.ps1'
    if (Test-Path $dbgScript) {
        & $dbgScript -TCode $Target
    } else {
        Write-Error 'debug_screen.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'sp') {
    $spScript = Join-Path $scriptDir 'db_sync_tool.ps1'
    if (Test-Path $spScript) {
        if ($Clean) {
            & $spScript -Clean
        } else {
            & $spScript -SP $Target
        }
    } else {
        Write-Error 'db_sync_tool.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'query') {
    $qScript = Join-Path $scriptDir 'run_query.ps1'
    if (Test-Path $qScript) {
        & $qScript -Query $Target -Profile $Profile
    } else {
        Write-Error 'run_query.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'new-fix') {
    Show-MesBanner
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host 'Loi: Vui long nhap ma su co hoac ten mo ta cho Hotfix!' -ForegroundColor Red
        Write-Host 'Vi du: .\mes.ps1 new-fix "FIX_B530_LOT_HOLD"' -ForegroundColor Yellow
        exit 1
    }

    $sqlDir = Join-Path $scriptDir 'sql'
    if (!(Test-Path $sqlDir)) {
        New-Item -ItemType Directory -Path $sqlDir -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $fileName = "hotfix_${timestamp}_${Target}.sql"
    $filePath = Join-Path $sqlDir $fileName

    $templatePath = Join-Path $sqlDir 'template_hotfix.sql'
    $content = ''
    if (Test-Path $templatePath) {
        $content = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
        $content = $content.Replace('{{ISSUE_CODE}}', $Target)
        $content = $content.Replace('{{DATE_CREATED}}', (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
    } else {
        $content = "-- HOTFIX: $Target`nUSE SmartFactoryV2;`nGO`nBEGIN TRAN;`n-- Add your SQL here`nROLLBACK TRAN;`nGO"
    }

    $utf8WithBom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($filePath, $content, $utf8WithBom)

    Write-Host '-> Da tao thanh cong template Hotfix chuan UTF-8-BOM:' -ForegroundColor Green
    Write-Host "  Path: $filePath" -ForegroundColor Cyan
    Write-Host 'Huong dan tiep theo:' -ForegroundColor Yellow
    Write-Host '  1. Mo file chinh sua cau lenh UPDATE/WHERE chinh xac.' -ForegroundColor Gray
    Write-Host "  2. Chay thu nghiem an toan: .\mes.ps1 deploy $filePath" -ForegroundColor Gray
}
elseif ($cmdLower -eq 'deploy') {
    $depScript = Join-Path $scriptDir 'deploy_tool.ps1'
    if (Test-Path $depScript) {
        if ($Force) {
            & $depScript -SqlPath $Target -Profile $Profile -Force
        } else {
            & $depScript -SqlPath $Target -Profile $Profile
        }
    } else {
        Write-Error 'deploy_tool.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'find') {
    $findScript = Join-Path $scriptDir 'find_kb.ps1'
    if (Test-Path $findScript) {
        & $findScript -Query $Target
    } else {
        Write-Error 'find_kb.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'health') {
    $healthScript = Join-Path $scriptDir 'health_check.ps1'
    if (Test-Path $healthScript) {
        if ($Detail) {
            & $healthScript -Detail
        } else {
            & $healthScript
        }
    } else {
        Write-Error 'health_check.ps1 not found.'
    }
}
elseif ($cmdLower -eq 'audit' -or $cmdLower -eq 'verify-kb') {
    $auditScript = Join-Path $scriptDir 'audit_kb_reliability.ps1'
    if (Test-Path $auditScript) {
        & $auditScript
    } else {
        Write-Error 'audit_kb_reliability.ps1 not found.'
    }
}
else {
    Write-Host "Lenh khong hop le: $Command" -ForegroundColor Red
    Show-Help
}
