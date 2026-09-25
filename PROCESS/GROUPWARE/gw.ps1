# ==============================================================================
# gw.ps1 — VINATECH GROUPWARE UNIFIED CLI HUB (Trung Tam Dieu Phoi Van Hanh GW)
# ==============================================================================

param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',
    
    [Parameter(Position = 1)]
    [string]$Target = '',
    
    [string]$Profile = 'Groupware',
    [switch]$Force,
    [switch]$Detail,
    [switch]$Clean
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$scriptDir = $PSScriptRoot
$toolsDir = Join-Path $scriptDir 'tools'
. (Join-Path $toolsDir 'db_shared.ps1')

function Show-GwBanner {
    Write-Host ''
    Write-Host '======================================================================' -ForegroundColor Cyan
    Write-Host '          VINATECH GROUPWARE UNIFIED CLI HUB (v1.0)' -ForegroundColor Yellow
    Write-Host '     Trung Tam Dieu Phoi Phe Duyet, Chan Doan & Van Hanh Groupware' -ForegroundColor White
    Write-Host '======================================================================' -ForegroundColor Cyan
}

function Show-Help {
    Show-GwBanner
    Write-Host ''
    Write-Host 'CAC LENH VAN HANH CHINH:' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '  1. TRUY VET & DIEU TRA NGHIEP VU (INVESTIGATION):' -ForegroundColor Cyan
    Write-Host '     .\gw.ps1 trace <Target>             ' -NoNewline -ForegroundColor Green
    Write-Host '-> Golden Query 360° truy vet PO / Ma Van Ban / Nhan Vien / Item xuyen suot GW-ERP-MES' -ForegroundColor Gray
    Write-Host '     .\gw.ps1 form <FormID>              ' -NoNewline -ForegroundColor Green
    Write-Host '-> Soi chi tiet bieu mau (Bang, tuyen duyet, mapping ERP, ma loi: FORM_PO, FORM_ARRIVAL...)' -ForegroundColor Gray
    Write-Host '     .\gw.ps1 find <Keyword>             ' -NoNewline -ForegroundColor Green
    Write-Host '-> Tra cuu L1 Quick Matrix (<0.001s) va 12+ file Markdown Groupware' -ForegroundColor Gray
    Write-Host ''
    Write-Host '  2. CHUYEN SAU CSDL & AI AGENT (DEEP DIVE & ENGINE):' -ForegroundColor Cyan
    Write-Host '     .\gw.ps1 routine [<Name>]           ' -NoNewline -ForegroundColor Green
    Write-Host '-> Soi ma nguon Stored Procedures, Functions & Views trong VINATECH_GROUP' -ForegroundColor Gray
    Write-Host '     .\gw.ps1 agent                      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra he thong Bizbox Alpha AI Agent Engine, Tools, Dynamic APIs & Tokens' -ForegroundColor Gray
    Write-Host '     .\gw.ps1 chain <DocCode>            ' -NoNewline -ForegroundColor Green
    Write-Host '-> Truy vet pha he chuoi lien ket van ban (Expense -> PO -> Arrival -> Receiving)' -ForegroundColor Gray
    Write-Host ''
    Write-Host '  3. KIEM TRA & GIAM SAT HE THONG (HEALTH & MONITORING):' -ForegroundColor Cyan
    Write-Host '     .\gw.ps1 health [-Detail]           ' -NoNewline -ForegroundColor Green
    Write-Host '-> Morning Health Check quet phieu cho duyet, kẹt >48h, thong ke phan he' -ForegroundColor Gray
    Write-Host '     .\gw.ps1 check [-Target <Profile>]  ' -NoNewline -ForegroundColor Green
    Write-Host '-> Kiem tra ket noi toi cac CSDL (Groupware, ERP, MES, SSO)' -ForegroundColor Gray
    Write-Host '     .\gw.ps1 query "<SELECT_SQL>"       ' -NoNewline -ForegroundColor Green
    Write-Host '-> Chay cau SELECT an toan tren VINATECH_GROUP (kem NOLOCK warning)' -ForegroundColor Gray
    Write-Host '     .\gw.ps1 audit                      ' -NoNewline -ForegroundColor Green
    Write-Host '-> Doi soat danh muc bang va luoc do CSDL Groupware vs Live DB' -ForegroundColor Gray
    Write-Host ''
    Write-Host '  HE SINH THAI 3 CLI HUBS CHUYEN TRACH:' -ForegroundColor Cyan
    Write-Host '     .\pop.ps1 ...  -> Hub chuyen trach Mat tran Kiosk POP tai xuong (BOM NVL, Kho ROUTE_VN_WH, Unlock may, Sync)' -ForegroundColor Yellow
    Write-Host '     .\mes.ps1 ...  -> Hub chuyen trach Loi San Xuat MES, Vong doi Lot, Man hinh WinForm & Hotfixes' -ForegroundColor Yellow
    Write-Host '     .\gw.ps1  ...  -> Hub chuyen trach Phe Duyet Groupware & Chung Tu ERP NEOE' -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'Cac Profile CSDL ho tro:' -ForegroundColor Yellow
    Write-Host '  Groupware (Mac dinh), ERP, SmartFactoryV2, SSO, Bizbox, Spreadsheet...' -ForegroundColor Gray
    Write-Host ''
}

# Main Command Dispatcher
$cmdLower = $Command.ToLower()
if ($cmdLower -eq 'help' -or $cmdLower -eq '-h' -or $cmdLower -eq '--help') {
    Show-Help
}
elseif ($cmdLower -eq 'check') {
    Show-GwBanner
    $targetProfile = if ($Target) { $Target } else { $Profile }
    Write-Host "Kiem tra ket noi Database Profile: $targetProfile..." -ForegroundColor Cyan
    $conn = Get-DbConnection -Profile $targetProfile
    if ($conn -ne $null) {
        Write-Host "-> [THANH CONG] Ket noi thanh cong toi DB: $($conn.Database) tren may chu: $($conn.DataSource)" -ForegroundColor Green
        $conn.Close()
    } else {
        Write-Host "-> [THAT BAI] Khong the ket noi toi profile: $targetProfile" -ForegroundColor Red
    }
}
elseif ($cmdLower -eq 'trace') {
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Show-GwBanner
        Write-Host 'Loi: Vui long nhap ma can truy vet (Ma Van Ban, So PO, Ma Nhan Vien, Ma Vat Tu)!' -ForegroundColor Red
        Write-Host 'Vi du: .\gw.ps1 trace "PO202606001"' -ForegroundColor Yellow
        Write-Host '       .\gw.ps1 trace "21910034"' -ForegroundColor Yellow
        exit 1
    }
    $traceScript = Join-Path $toolsDir 'gw_trace.ps1'
    if (Test-Path $traceScript) {
        & $traceScript -Target $Target
    } else {
        Write-Error "tools/gw_trace.ps1 not found."
    }
}
elseif ($cmdLower -eq 'form') {
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Show-GwBanner
        Write-Host 'Loi: Vui long nhap ma bieu mau FormID (VD: FORM_PO, FORM_ARRIVAL, FORM_LEAVE)!' -ForegroundColor Red
        exit 1
    }
    $inspectScript = Join-Path $toolsDir 'inspect_form.ps1'
    if (Test-Path $inspectScript) {
        & $inspectScript -FormID $Target
    } else {
        Write-Error "tools/inspect_form.ps1 not found."
    }
}
elseif ($cmdLower -eq 'find') {
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Show-GwBanner
        Write-Host 'Loi: Vui long nhap tu khoa tra cuu!' -ForegroundColor Red
        exit 1
    }
    $findScript = Join-Path $toolsDir 'find_kb.ps1'
    if (Test-Path $findScript) {
        & $findScript -Query $Target
    } else {
        Write-Error "tools/find_kb.ps1 not found."
    }
}
elseif ($cmdLower -eq 'health') {
    $healthScript = Join-Path $toolsDir 'health_check.ps1'
    if (Test-Path $healthScript) {
        if ($Detail) {
            & $healthScript -Detail
        } else {
            & $healthScript
        }
    } else {
        Write-Error "tools/health_check.ps1 not found."
    }
}
elseif ($cmdLower -eq 'query') {
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host "Loi: Vui long nhap cau lenh SQL SELECT can thuc thi." -ForegroundColor Red
        exit 1
    }
    $queryScript = Join-Path $toolsDir 'run_query.ps1'
    if (Test-Path $queryScript) {
        & $queryScript -Profile $Profile -Query $Target
    } else {
        Write-Error "tools/run_query.ps1 not found."
    }
}
elseif ($cmdLower -eq 'audit') {
    $auditScript = Join-Path $toolsDir 'audit_kb_reliability.ps1'
    if (Test-Path $auditScript) {
        if ($Detail) {
            & $auditScript -Detailed
        } else {
            & $auditScript
        }
    } else {
        Write-Error "tools/audit_kb_reliability.ps1 not found."
    }
}
elseif ($cmdLower -eq 'routine') {
    Show-GwBanner
    $conn = Get-DbConnection -Profile 'Groupware'
    if ($conn -eq $null) {
        Write-Host "Khong the ket noi CSDL VINATECH_GROUP de tra cuu routine." -ForegroundColor Red
        exit 1
    }
    
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host "Danh sach Stored Procedures & Functions trong VINATECH_GROUP:" -ForegroundColor Cyan
        $dtRoutines = Invoke-DbQuery -Connection $conn -Query "SELECT ROUTINE_TYPE, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES ORDER BY ROUTINE_TYPE, ROUTINE_NAME"
        $dtRoutines.DefaultView | Format-Table -AutoSize
        
        Write-Host "`r`nDanh sach Views trong VINATECH_GROUP:" -ForegroundColor Cyan
        $dtViews = Invoke-DbQuery -Connection $conn -Query "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS ORDER BY TABLE_NAME"
        $dtViews.DefaultView | Format-Table -AutoSize
        Write-Host "`r`n-> De xem chi tiet ma nguon routine, go: .\gw.ps1 routine <RoutineName>" -ForegroundColor Yellow
    } else {
        Write-Host "Tra cuu ma nguon Routine/View: $Target..." -ForegroundColor Cyan
        $localSql = Join-Path $scriptDir "sql\routines\$Target.sql"
        if (-not (Test-Path $localSql)) {
            $localSql = Join-Path $scriptDir "sql\views\$Target.sql"
        }
        
        if (Test-Path $localSql) {
            Write-Host "-> [DA TRICH XUAT] Hien thi tu tep tin: $localSql`r`n" -ForegroundColor Green
            Get-Content -Path $localSql -Encoding UTF8 -TotalCount 60 | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
            Write-Host "... (Con tiep, mo file $localSql de xem toan bo)" -ForegroundColor Yellow
        } else {
            $defQuery = "SELECT OBJECT_DEFINITION(OBJECT_ID('$Target')) AS DEF"
            $dtDef = Invoke-DbQuery -Connection $conn -Query $defQuery
            if ($dtDef.Rows.Count -gt 0 -and $dtDef.Rows[0]['DEF'] -ne [DBNull]::Value) {
                Write-Host "-> [LIVE DB] Dinh nghia tu CSDL Live:`r`n" -ForegroundColor Green
                $lines = ($dtDef.Rows[0]['DEF'] -split "`r?`n") | Select-Object -First 60
                $lines | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
            } else {
                Write-Host "Khong tim thay Routine/View nao co ten '$Target' trong VINATECH_GROUP." -ForegroundColor Red
            }
        }
    }
    $conn.Close()
}
elseif ($cmdLower -eq 'agent') {
    Show-GwBanner
    Write-Host "Kiem tra he thong Bizbox Alpha AI Agent Engine trong VINATECH_GROUP..." -ForegroundColor Cyan
    $conn = Get-DbConnection -Profile 'Groupware'
    if ($conn -eq $null) {
        Write-Host "Khong the ket noi CSDL de kiem tra Agent." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "`r`n1. CAC LOAI AI AGENT (VINA_AGENT_TYPE):" -ForegroundColor Yellow
    $agentTypeSql = 'SELECT T.AGENT_TYPE, SD.STATIC_DATA_NAME_KR AS AGENT_NAME_KR, SD.STATIC_DATA_NAME_EN AS AGENT_NAME_EN, T.AGENT_TYPE_STREAM_YN AS STREAM_YN, T.AGENT_TYPE_CHAT_SAVE_LENGTH AS MEMORY_LENGTH, T.NO_EMP_WRITER AS CREATOR FROM VINA_AGENT_TYPE T WITH (NOLOCK) LEFT JOIN VINA_STATIC_DATA SD WITH (NOLOCK) ON T.AGENT_TYPE = SD.STATIC_DATA_CODE;'
    $dtAgentTypes = Invoke-DbQuery -Connection $conn -Query $agentTypeSql
    $dtAgentTypes.DefaultView | Format-Table -AutoSize

    Write-Host "`r`n2. CAC DYNAMIC API CUA LLM (VINA_AGENT_DYNAMIC_API):" -ForegroundColor Yellow
    $dynamicApiSql = 'SELECT AGENT_DYNAMIC_API_NAME AS API_NAME, AGENT_DYNAMIC_API_BEAN_NAME AS SPRING_BEAN, AGENT_DYNAMIC_API_METHOD_NAME AS JAVA_METHOD, AGENT_DYNAMIC_API_DISPLAY_COLUMNS AS RETURN_DTO FROM VINA_AGENT_DYNAMIC_API WITH (NOLOCK);'
    $dtDynamicApis = Invoke-DbQuery -Connection $conn -Query $dynamicApiSql
    $dtDynamicApis.DefaultView | Format-Table -AutoSize

    Write-Host "`r`n3. CONG CU THUC THI (VINA_AGENT_TOOL):" -ForegroundColor Yellow
    $toolSql = "SELECT T.AGENT_TYPE, ISNULL(SD.STATIC_DATA_NAME_EN, API.AGENT_DYNAMIC_API_NAME) AS TOOL_NAME, ISNULL(SD.STATIC_DATA_FIELD1, 'dynamic_api') AS TOOL_HANDLE FROM VINA_AGENT_TOOL T WITH (NOLOCK) LEFT JOIN VINA_STATIC_DATA SD WITH (NOLOCK) ON T.AGENT_TOOL_TYPE = SD.STATIC_DATA_CODE LEFT JOIN VINA_AGENT_DYNAMIC_API API WITH (NOLOCK) ON T.AGENT_DYNAMIC_API_CODE = API.AGENT_DYNAMIC_API_CODE;"
    $dtTools = Invoke-DbQuery -Connection $conn -Query $toolSql
    $dtTools.DefaultView | Format-Table -AutoSize
    
    $conn.Close()
}
elseif ($cmdLower -eq 'chain') {
    Show-GwBanner
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host "Loi: Vui long nhap ma to trinh (DOCUMENT_SAVE_CODE hoac RECORD_INCREASE_CODE)!" -ForegroundColor Red
        Write-Host "Vi du: .\gw.ps1 chain 'DOCUMENT_SAVE_20260312093012345001'" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Truy vet pha he chuoi lien ket van ban cho: '$Target'..." -ForegroundColor Cyan
    $conn = Get-DbConnection -Profile 'Groupware'
    if ($conn -eq $null) {
        Write-Host "Khong the ket noi CSDL VINATECH_GROUP." -ForegroundColor Red
        exit 1
    }
    
    $chainSql = "SELECT S.DOCUMENT_SAVE_CODE, S.RECORD_INCREASE_CODE, S.DOCUMENT_TYPE_ID, S.DOCUMENT_SAVE_SUBJECT, S.DOCUMENT_SAVE_STATE, S.NO_EMP_WRITER, V.RELATION_RECORD_INCREASE_CODE FROM VINA_DOCUMENT_SAVE S WITH (NOLOCK) LEFT JOIN VINA_DOCUMENT_RELATION_STUFF_VIEW V WITH (NOLOCK) ON S.DOCUMENT_SAVE_CODE = V.DOCUMENT_SAVE_CODE WHERE S.DOCUMENT_SAVE_CODE = '$Target' OR S.RECORD_INCREASE_CODE = '$Target';"
    $dtChain = Invoke-DbQuery -Connection $conn -Query $chainSql
    if ($dtChain.Rows.Count -gt 0) {
        $dtChain.DefaultView | Format-Table -AutoSize
        $rel = $dtChain.Rows[0]['RELATION_RECORD_INCREASE_CODE']
        if ($rel -ne [DBNull]::Value -and -not [string]::IsNullOrWhiteSpace($rel)) {
            Write-Host "`r`n-> CHUOI VAN BAN LIEN DOI (STUFF CHAIN):" -ForegroundColor Green
            $items = $rel -split ','
            foreach ($item in $items) {
                $parts = $item -split '#'
                Write-Host "   [LIEN KET] Ma: $($parts[0]) | Loai: $($parts[1]) | Ho so: $($parts[2])" -ForegroundColor Cyan
            }
        } else {
            Write-Host "`r`n-> Khong phat sinh van ban lien doi (Doc lap hoac la van ban dau nguon)." -ForegroundColor Gray
        }
    } else {
        Write-Host "Khong tim thay van ban nao co ma '$Target' trong VINA_DOCUMENT_SAVE." -ForegroundColor Yellow
    }
    $conn.Close()
}
else {
    Write-Host "Lenh khong hop le: '$Command'. Go '.\gw.ps1 help' de xem huong dan." -ForegroundColor Red
}
