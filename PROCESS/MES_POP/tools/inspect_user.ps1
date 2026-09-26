# ==============================================================================
# inspect_user.ps1 — 360° Comprehensive User & Auth Investigator
# Multi-DB Cross Query: ERP (NEOE) | POP (VINA_EMP) | MES (SmartFramework) | GW | SSO
# Tối ưu hóa 1-Shot (<1s), triệt tiêu nhu cầu chạy SELECT dò dẫm
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Target
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

$t = $Target.Trim()
if ([string]::IsNullOrWhiteSpace($t)) {
    Write-Host "Loi: Vui long nhap ma nhan vien, username hoac ten nguoi dung!" -ForegroundColor Red
    Write-Host "Vi du: .\mes.ps1 user '92603003'" -ForegroundColor Yellow
    Write-Host "       .\mes.ps1 user '31707007'" -ForegroundColor Yellow
    Write-Host "       .\mes.ps1 user 'vanduc'" -ForegroundColor Yellow
    exit 1
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '     [USER-INVESTIGATOR 360] TRA CUU NHAN SU & TAI KHOAN DONG BO' -ForegroundColor Yellow
Write-Host "     Doi tuong: $t | Pham vi: ERP NEOE, POP, SmartFramework, GW, SSO" -ForegroundColor White
Write-Host '======================================================================' -ForegroundColor Cyan

# 1. ERP NEOE (MA_USER & MA_EMP)
Write-Host ''
Write-Host '--- 1. CSDL ERP (NEOE - Douzone iU) ---' -ForegroundColor Magenta
$connErp = Get-DbConnection -Profile 'ERP' -Silent
if ($connErp) {
    try {
        $cmd = $connErp.CreateCommand()
        $cmd.CommandText = @"
SELECT TOP 5 
    U.ID_USER AS UserID, 
    U.NO_EMP AS EmpNo, 
    U.NM_USER AS UserName, 
    E.NM_KOR AS NameKor, 
    E.NM_ENG AS NameEng, 
    E.CD_DEPT AS DeptCode, 
    U.YN_LOGIN AS CanLogin, 
    U.YN_GW AS LinkGW, 
    U.CD_STOP AS StopStatus, 
    U.GRD_USER AS UserLevel, 
    U.CD_PW AS PwType
FROM NEOE.NEOE.MA_USER U WITH (NOLOCK)
LEFT JOIN NEOE.NEOE.MA_EMP E WITH (NOLOCK) ON U.NO_EMP = E.NO_EMP AND E.CD_COMPANY = '2000'
WHERE U.CD_COMPANY = '2000' 
  AND (U.ID_USER = '$t' OR U.NO_EMP = '$t' OR U.NM_USER LIKE '%$t%');
"@
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dtErp = New-Object System.Data.DataTable
        $null = $da.Fill($dtErp)
        if ($dtErp.Rows.Count -gt 0) {
            $dtErp | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        } else {
            Write-Host "  (Khong tim thay ban ghi MA_USER nao tren ERP voi khoa '$t')" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Loi ERP: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $connErp.Close()
    }
} else {
    Write-Host '  Khong the ket noi toi CSDL ERP!' -ForegroundColor Red
}

# 2. POP KIOSK (VINATECH_POP.dbo.VINA_EMP & VINA_KIOSK_LOG)
Write-Host ''
Write-Host '--- 2. CSDL POP KIOSK (VINATECH_POP) ---' -ForegroundColor Magenta
$connPop = Get-DbConnection -Profile 'POP' -Silent
$popFound = $false
if ($connPop) {
    try {
        $cmd = $connPop.CreateCommand()
        $cmd.CommandText = @"
SELECT TOP 5 
    NO_EMP AS EmpNo, 
    CD_COMPANY AS Company, 
    EMP_ADMIN AS IsAdmin, 
    EMP_SYSTEM_ADMIN AS IsSysAdmin, 
    EMP_STOP AS IsStop, 
    EMP_CAPABILITY AS Capability, 
    EMP_MBTI AS MBTI
FROM VINATECH_POP.dbo.VINA_EMP WITH (NOLOCK)
WHERE NO_EMP = '$t';
"@
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dtPop = New-Object System.Data.DataTable
        $null = $da.Fill($dtPop)
        if ($dtPop.Rows.Count -gt 0) {
            $popFound = $true
            Write-Host "[Danh bạ công nhân POP - VINA_EMP]:" -ForegroundColor DarkCyan
            $dtPop | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        } else {
            Write-Host "  (Chua dang ky trong VINATECH_POP.dbo.VINA_EMP)" -ForegroundColor Yellow
            Write-Host "  -> Luu y: Worker chon ca can co trong VINA_EMP (EMP_STOP='0'). User IT/Admin co the dang nhap truc tiep qua tai khoan ERP/SSO." -ForegroundColor Gray
        }

        # Kiosk Log
        $cmd.CommandText = @"
SELECT TOP 5 
    LOG_ID AS LogId, 
    EVENT_TYPE AS EventType, 
    SCREEN_NAME AS Screen, 
    WORKER_ID AS WorkerId, 
    EVENT_DETAIL AS Detail, 
    REG_DATE AS LogTime
FROM VINATECH_POP.dbo.VINA_KIOSK_LOG WITH (NOLOCK)
WHERE WORKER_ID = '$t'
ORDER BY LOG_ID DESC;
"@
        $dtLog = New-Object System.Data.DataTable
        $null = (New-Object System.Data.SqlClient.SqlDataAdapter($cmd)).Fill($dtLog)
        if ($dtLog.Rows.Count -gt 0) {
            Write-Host "[Nhat ky thao tac Kiosk gan nhat - VINA_KIOSK_LOG]:" -ForegroundColor DarkCyan
            $dtLog | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Loi POP: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $connPop.Close()
    }
} else {
    Write-Host '  Khong the ket noi toi CSDL POP!' -ForegroundColor Red
}

# 3. MES SMARTFRAMEWORK (STB_UserInfo)
Write-Host ''
Write-Host '--- 3. CSDL PHAN QUYEN MES (SmartFramework) ---' -ForegroundColor Magenta
$connFrame = Get-DbConnection -Profile 'SmartFramework' -Silent
if ($connFrame) {
    try {
        $cmd = $connFrame.CreateCommand()
        $cmd.CommandText = @"
SELECT TOP 5 
    UserID, 
    UserName, 
    AllowFlag, 
    IsDeveloper, 
    IsLogin, 
    IPAddress, 
    LastLoginDateTime, 
    Appendix8 AS ErpEmpNo
FROM SmartFramework.dbo.STB_UserInfo WITH (NOLOCK)
WHERE UserID = '$t' OR Appendix8 = '$t' OR UserName LIKE '%$t%';
"@
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dtFrame = New-Object System.Data.DataTable
        $null = $da.Fill($dtFrame)
        if ($dtFrame.Rows.Count -gt 0) {
            $dtFrame | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        } else {
            Write-Host "  (Khong tim thay trong SmartFramework.dbo.STB_UserInfo)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Loi SmartFramework: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $connFrame.Close()
    }
} else {
    Write-Host '  Khong the ket noi toi CSDL SmartFramework!' -ForegroundColor Red
}

# 4. GROUPWARE (VINATECH_GROUP.dbo.VINA_EMP)
Write-Host ''
Write-Host '--- 4. CSDL GROUPWARE (VINATECH_GROUP) ---' -ForegroundColor Magenta
$connGw = Get-DbConnection -Profile 'Groupware' -Silent
if ($connGw) {
    try {
        $cmd = $connGw.CreateCommand()
        $cmd.CommandText = @"
SELECT TOP 5 
    NO_EMP AS EmpNo, 
    CD_COMPANY AS Company, 
    EMP_ADMIN AS IsAdmin, 
    EMP_SYSTEM_ADMIN AS IsSysAdmin, 
    EMP_STOP AS IsStop, 
    DT_ENTER_LEAVE AS LeaveDate, 
    EMP_SYSTEM_MASTER AS IsMaster
FROM VINATECH_GROUP.dbo.VINA_EMP WITH (NOLOCK)
WHERE NO_EMP = '$t';
"@
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dtGw = New-Object System.Data.DataTable
        $null = $da.Fill($dtGw)
        if ($dtGw.Rows.Count -gt 0) {
            $dtGw | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        } else {
            Write-Host "  (Khong tim thay trong VINATECH_GROUP.dbo.VINA_EMP)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Loi Groupware: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $connGw.Close()
    }
} else {
    Write-Host '  Khong the ket noi toi CSDL Groupware!' -ForegroundColor Red
}

# 5. SSO LOGIN (VINATECH_RESTFUL.dbo.VINA_SSO_LOGIN)
Write-Host ''
Write-Host '--- 5. CSDL DANG NHAP SSO (VINATECH_RESTFUL) ---' -ForegroundColor Magenta
$connSso = Get-DbConnection -Profile 'SSO' -Silent
if ($connSso) {
    try {
        $cmd = $connSso.CreateCommand()
        $cmd.CommandText = @"
SELECT TOP 3 
    ID_USER AS UserId, 
    CD_COMPANY AS Company, 
    SSO_LOGIN_DATE AS LoginDate, 
    SSO_LOGIN_COUNT AS LoginCount, 
    SSO_LOGIN_MODIFY_DATE AS ModifyDate
FROM VINATECH_RESTFUL.dbo.VINA_SSO_LOGIN WITH (NOLOCK)
WHERE ID_USER = '$t'
ORDER BY SSO_LOGIN_DATE DESC;
"@
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dtSso = New-Object System.Data.DataTable
        $null = $da.Fill($dtSso)
        if ($dtSso.Rows.Count -gt 0) {
            $dtSso | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White
        } else {
            Write-Host "  (Khong co lich su dang nhap SSO gan day)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Loi SSO: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $connSso.Close()
    }
} else {
    Write-Host '  Khong the ket noi toi CSDL SSO!' -ForegroundColor Red
}

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '                     [CHAN DOAN & CO CHE XAC THUC]' -ForegroundColor Yellow
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '(*) CO CHE DANG NHAP HE THONG:' -ForegroundColor Yellow
Write-Host '  1. ERP Douzone: Xac thuc qua NEOE.MA_USER (Can YN_LOGIN = "Y", CD_STOP = "0").' -ForegroundColor Gray
Write-Host '  2. Groupware:   Dong bo tu ERP qua Trigger UT_MA_EMP_BIZBOX_GW (Luu tai VINATECH_GROUP.dbo.VINA_EMP).' -ForegroundColor Gray
Write-Host '  3. POP Kiosk:   - Worker chon ca: Bat buoc co trong VINATECH_POP.dbo.VINA_EMP (EMP_STOP = "0").' -ForegroundColor Gray
Write-Host '                  - Quyen Huy Box / Admin: Can EMP_ADMIN = "Y" hoac EMP_SYSTEM_ADMIN = "Y".' -ForegroundColor Gray
Write-Host '                  - User IT / Quan ly: Co the dang nhap xac thuc qua SSO / ERP MA_USER.' -ForegroundColor Gray
Write-Host '  4. MES WinForm: Xac thuc qua SmartFramework.dbo.STB_UserInfo (AllowFlag = "Y", Appendix8 = NoEmp).' -ForegroundColor Gray

$sw.Stop()
Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host "  Hoan tat tra cuu 5 he thong trong: $([Math]::Round($sw.Elapsed.TotalSeconds, 2))s" -ForegroundColor Green
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''
