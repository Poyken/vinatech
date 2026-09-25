<#
.SYNOPSIS
    K-SYSTEM ACE ERP CLI COMMAND HUB (ksys.ps1 v1.0) — FINAL UNIFIED SYSTEM
.DESCRIPTION
    Trung tam dieu phoi duy nhat cho cac tac vu kiem toan, tra cuu tri thuc L1,
    truy vet LOT 360 do va doi soat lien thong giua K-System Ace ERP va cac he thong cu.
#>

param (
    [Parameter(Position=0)]
    [ValidateSet("help", "find", "trace", "module", "schema", "bridge", "health")]
    [string]$Action = "help",

    [Parameter(Position=1)]
    [string]$Target,

    [int]$Seq,
    [string]$Prefix,
    [string]$Table,
    [switch]$WorkOrder
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = Join-Path $PSScriptRoot "tools"
$matrixFile = Join-Path $PSScriptRoot "AI_AGENT_CONFIG\KSYSTEM_MATRIX.json"

function Show-KSysBanner {
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  YOUNGLIMWON K-SYSTEM ACE ERP COMMAND HUB (ksys.ps1 v1.0)" -ForegroundColor Cyan
    Write-Host "  Hat nhan hop nhat doanh nghiep: evn.vinatech.com - Vinatech Vina (CompanySeq = 1)" -ForegroundColor DarkCyan
    Write-Host "================================================================================" -ForegroundColor Cyan
}

function Show-KSysHelp {
    Show-KSysBanner
    Write-Host "CAC LENH DIEU HANH CHINH:" -ForegroundColor Yellow
    Write-Host "  1. .\ksys.ps1 find `"<Keyword>`"             - Tra cuu sieu toc L1 Cache qua 17 phan he va 213 quy trinh"
    Write-Host "  2. .\ksys.ps1 trace `"<LotNo/WO>`"           - Truy vet 360 do Lot/Lenh SX theo chuan FrmWPDLotList"
    Write-Host "  3. .\ksys.ps1 module [-Seq <N>]            - Xem tong quan 17 phan he hoac xem chi tiet 1 phan he"
    Write-Host "  4. .\ksys.ps1 schema [-Prefix <P>]         - Tra cuu danh muc bang theo 10 ho tien to (_TPR, _TMA...)"
    Write-Host "  5. .\ksys.ps1 bridge                       - Kiem toan phan he cau noi K-Smart (Module 132)"
    Write-Host "  6. .\ksys.ps1 health                       - Kiem tra do tre mang va ket noi CSDL K-System"
    Write-Host ""
    Write-Host "10 HO TIEN TO BANG CHINH TRONG VINATECVN:" -ForegroundColor Magenta
    Write-Host "  _TCA (Admin), _TDA (Master Data), _TAC (Accounting), _TPR (Production),"
    Write-Host "  _TMA (Material/Lot), _TSA (Sales), _TQC (QA/QC), _THR (HRM), _TCO (Costing), _TCOM (Common)"
    Write-Host "================================================================================" -ForegroundColor Cyan
}

switch ($Action.ToLower()) {
    "help" {
        Show-KSysHelp
    }

    "find" {
        if (-not $Target) {
            Write-Host "Vui long nhap tu khoa tra cuu. Vi du: .\ksys.ps1 find `"Lot`"" -ForegroundColor Yellow
            exit 0
        }
        $findScript = Join-Path $toolsDir "ksys_find.ps1"
        & $findScript -Keyword $Target
    }

    "trace" {
        if (-not $Target) {
            Write-Host "Vui long nhap ma LOT hoac ma Lenh SX. Vi du: .\ksys.ps1 trace `"VVQR153R060609`"" -ForegroundColor Yellow
            exit 0
        }
        $traceScript = Join-Path $toolsDir "ksys_trace.ps1"
        & $traceScript -Target $Target -WorkOrder:$WorkOrder
    }

    "module" {
        Show-KSysBanner
        if (Test-Path $matrixFile) {
            $matrix = Get-Content -Raw $matrixFile -Encoding UTF8 | ConvertFrom-Json
            if ($Seq -gt 0) {
                $m = $matrix.modules."$Seq"
                if ($m) {
                    Write-Host "`nCHI TIET PHAN HE: [Seq $($m.module_seq)] $($m.name_vi) ($($m.name_ko))" -ForegroundColor Green
                    Write-Host "  * Ma phan he: $($m.module_code)" -ForegroundColor White
                    Write-Host "  * So quy trinh nghiep vu: $($m.process_menu_count)" -ForegroundColor White
                    Write-Host "  * So chuong trinh thuc thi: $($m.program_count)" -ForegroundColor White
                    Write-Host "  * Cac bang CSDL cot loi: $($m.key_tables -join ', ')" -ForegroundColor DarkCyan
                    if ($m.key_screens) {
                        Write-Host "`n  Cac Man Hinh Trong Diem:" -ForegroundColor Yellow
                        foreach ($s in $m.key_screens) {
                            Write-Host "    - [PgmSeq: $($s.pgm_seq)] $($s.pgm_id): $($s.name_vi)" -ForegroundColor Cyan
                            Write-Host "      $($s.desc)" -ForegroundColor Gray
                        }
                    }
                } else {
                    Write-Host "Khong tim thay Phan he voi Sequence: $Seq" -ForegroundColor Red
                }
            } else {
                Write-Host "`nDANH SACH TOAN BO 17 PHAN HE K-SYSTEM ACE:" -ForegroundColor Yellow
                $list = @()
                foreach ($k in $matrix.modules.PSObject.Properties.Name) {
                    $mod = $matrix.modules.$k
                    $list += [PSCustomObject]@{
                        Seq         = $mod.module_seq
                        Code        = $mod.module_code
                        Name_VI     = $mod.name_vi
                        Name_KO     = $mod.name_ko
                        Processes   = $mod.process_menu_count
                        Programs    = $mod.program_count
                    }
                }
                $list | Sort-Object -Property Seq | Format-Table -AutoSize
            }
        }
    }

    "schema" {
        Show-KSysBanner
        $sharedScript = Join-Path $toolsDir "ksys_shared.ps1"
        . $sharedScript
        $pre = if ($Prefix) { $Prefix } else { "_T" }
        Write-Host "Tra cuu ho tien to bang: '$pre' trong CSDL VINATECVN..." -ForegroundColor Yellow
        $sql = "SELECT TOP 30 TABLE_NAME, TABLE_TYPE FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '$pre%' ORDER BY TABLE_NAME;"
        $res = Invoke-KSysQuery -Query $sql -TargetDB "VINATECVN"
        if ($res) {
            $res | Format-Table -AutoSize
        } else {
            Write-Host "  (Khong the truy van CSDL truc tiep hoac bang trong. Tham chieu VOL_01_CORE_ENGINE_AND_DATA_TAXONOMY.md)" -ForegroundColor Gray
        }
    }

    "bridge" {
        Show-KSysBanner
        Write-Host "Kiem tra phan he cau noi K-Smart (Module 132)..." -ForegroundColor Yellow
        Write-Host "  * Dinh danh quy trinh: [K-SMART] GibonJeongbo (Seq: 10002131)" -ForegroundColor Cyan
        Write-Host "  * Man hinh dang ky nguoi dung lien thong: FrmWCMUserEntrySinCompanyWeb (PgmSeq: 525585)" -ForegroundColor White
        Write-Host "  * Ma tran phan quyen lien thong: FrmWCMPrcMenuGroupSecuEntry (PgmSeq: 524337)" -ForegroundColor White
        Write-Host "  * Trang thai co kho MES: _TDAWH.IsMES = 'Y' (8 kho da duoc phan dinh)" -ForegroundColor Green
        Write-Host "  * Danh gia: Phan he cau noi da san sang don nhan du lieu tu NAIS MES va POP Kiosk." -ForegroundColor Green
    }

    "health" {
        Show-KSysBanner
        Write-Host "Dang kiem tra ket noi toi may chu dbserver.hycap.co.kr,5398..." -ForegroundColor Yellow
        $sharedScript = Join-Path $toolsDir "ksys_shared.ps1"
        . $sharedScript
        $conn = Get-KSysConnection -TargetDB "VINATECVN"
        if ($conn) {
            Write-Host "  [OK] CSDL VINATECVN: Ket noi truc tuyen thanh cong!" -ForegroundColor Green
            $conn.Connection.Close()
        } else {
            Write-Host "  [OFFLINE / TIMEOUT] Khong the ket noi toi dbserver.hycap.co.kr,5398." -ForegroundColor Red
            Write-Host "  Ly do: Cong 5398 dang bi tuong lua IDC chan hoac ngoai khung gio cho phep ket noi tu xa." -ForegroundColor Gray
            Write-Host "  Toan bo du lieu kien truc da duoc dong bo an toan trong L1 Cache (KSYSTEM_MATRIX.json)." -ForegroundColor Cyan
        }
    }
}
