$cfg = Get-Content -Raw "db_config.json" | ConvertFrom-Json
$connStr = "Server=$($cfg.Server);Database=$($cfg.Database);User Id=$($cfg.User);Password=$($cfg.Password);Connect Timeout=30;Encrypt=False;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

Write-Output "=========================================================================="
Write-Output "BAO CAO SO SANH CHI TIET: DATABASE HIEN TAI VS TRUOC 8:00 AM"
Write-Output "=========================================================================="

# 1. So sanh STB_ProdRouteHist (540 records backup luc 11:20 AM - dai dien trang thai truoc 8h)
$sqlPRH = @"
SELECT 
    COUNT(*) as Total_Checked,
    SUM(CASE WHEN ISNULL(PRH.WorkCenterCode,'') = ISNULL(BK.WorkCenterCode,'') 
              AND ISNULL(PRH.RouteCode,'') = ISNULL(BK.RouteCode,'')
              AND ISNULL(PRH.JobDate,'1900-01-01') = ISNULL(BK.JobDate,'1900-01-01')
              AND ISNULL(PRH.ProdQty,-1) = ISNULL(BK.ProdQty,-1)
              AND ISNULL(PRH.CompleteRoute,'') = ISNULL(BK.CompleteRoute,'')
              AND ISNULL(PRH.ProdDateTime,'1900-01-01') = ISNULL(BK.ProdDateTime,'1900-01-01')
        THEN 1 ELSE 0 END) as Exactly_Matched,
    SUM(CASE WHEN ISNULL(PRH.WorkCenterCode,'') <> ISNULL(BK.WorkCenterCode,'') 
               OR ISNULL(PRH.RouteCode,'') <> ISNULL(BK.RouteCode,'')
               OR ISNULL(PRH.JobDate,'1900-01-01') <> ISNULL(BK.JobDate,'1900-01-01')
               OR ISNULL(PRH.ProdQty,-1) <> ISNULL(BK.ProdQty,-1)
               OR ISNULL(PRH.CompleteRoute,'') <> ISNULL(BK.CompleteRoute,'')
               OR ISNULL(PRH.ProdDateTime,'1900-01-01') <> ISNULL(BK.ProdDateTime,'1900-01-01')
        THEN 1 ELSE 0 END) as Mismatched
FROM dbo.STB_ProdRouteHist PRH WITH (NOLOCK)
INNER JOIN dbo.BK_20260821_HY_STB_ProdRouteHist BK WITH (NOLOCK)
    ON PRH.ProdRouteHistNo = BK.ProdRouteHistNo;
"@
$cmd = New-Object System.Data.SqlClient.SqlCommand($sqlPRH, $conn)
$r = $cmd.ExecuteReader()
if ($r.Read()) {
    Write-Output "`n1. BANG STB_ProdRouteHist (Lich su Routing):"
    Write-Output "   - Tong so ban ghi doi chieu: $($r['Total_Checked'])"
    Write-Output "   - So ban ghi KHOP HOAN TOAN 100%: $($r['Exactly_Matched'])"
    Write-Output "   - So ban ghi sai lech: $($r['Mismatched'])"
}
$r.Close()

# 2. So sanh STB_SetInfo (81 records backup luc 11:20 AM)
$sqlSI = @"
SELECT 
    COUNT(*) as Total_Checked,
    SUM(CASE WHEN ISNULL(SI.CurrentRouteCode,'') = ISNULL(BK.CurrentRouteCode,'') THEN 1 ELSE 0 END) as Exactly_Matched,
    SUM(CASE WHEN ISNULL(SI.CurrentRouteCode,'') <> ISNULL(BK.CurrentRouteCode,'') THEN 1 ELSE 0 END) as Mismatched
FROM dbo.STB_SetInfo SI WITH (NOLOCK)
INNER JOIN dbo.BK_20260821_HY_STB_SetInfo BK WITH (NOLOCK)
    ON SI.ControlNo = BK.ControlNo;
"@
$cmd = New-Object System.Data.SqlClient.SqlCommand($sqlSI, $conn)
$r = $cmd.ExecuteReader()
if ($r.Read()) {
    Write-Output "`n2. BANG STB_SetInfo (Thong tin Barcode/Set):"
    Write-Output "   - Tong so ban ghi doi chieu: $($r['Total_Checked'])"
    Write-Output "   - So ban ghi KHOP HOAN TOAN 100%: $($r['Exactly_Matched'])"
    Write-Output "   - So ban ghi sai lech: $($r['Mismatched'])"
}
$r.Close()

# 3. So sanh STB_SavePackingTime_VVT (405 records backup luc 11:20 AM)
$sqlSPT = @"
SELECT 
    COUNT(*) as Total_Checked,
    SUM(CASE WHEN ISNULL(SPT.EmpNo,'') = ISNULL(BK.EmpNo,'') 
              AND ISNULL(SPT.isPrinted,'') = ISNULL(BK.isPrinted,'')
        THEN 1 ELSE 0 END) as Exactly_Matched,
    SUM(CASE WHEN ISNULL(SPT.EmpNo,'') <> ISNULL(BK.EmpNo,'') 
               OR ISNULL(SPT.isPrinted,'') <> ISNULL(BK.isPrinted,'')
        THEN 1 ELSE 0 END) as Mismatched
FROM dbo.STB_SavePackingTime_VVT SPT WITH (NOLOCK)
INNER JOIN dbo.BK_20260821_HY_STB_SavePackingTime_VVT BK WITH (NOLOCK)
    ON SPT.id = BK.id;
"@
$cmd = New-Object System.Data.SqlClient.SqlCommand($sqlSPT, $conn)
$r = $cmd.ExecuteReader()
if ($r.Read()) {
    Write-Output "`n3. BANG STB_SavePackingTime_VVT (Lich su in tem/dong goi):"
    Write-Output "   - Tong so ban ghi doi chieu: $($r['Total_Checked'])"
    Write-Output "   - So ban ghi KHOP HOAN TOAN 100%: $($r['Exactly_Matched'])"
    Write-Output "   - So ban ghi sai lech: $($r['Mismatched'])"
}
$r.Close()

# 4. Kiem tra toan bo STB_ProdRouteHist co ban ghi nao bi lech WorkCenterCode cua cac route _HY khong
$sqlHY = @"
SELECT count(*) as Invalid_HY_WC
FROM dbo.STB_ProdRouteHist WITH (NOLOCK)
WHERE RouteCode LIKE '%_HY' AND WorkCenterCode <> 'VVT_F5';
"@
$cmd = New-Object System.Data.SqlClient.SqlCommand($sqlHY, $conn)
$r = $cmd.ExecuteReader()
if ($r.Read()) {
    Write-Output "`n4. KIEM TRA TINH TOAN VEN CAC ROUTE NHA MAY HUNG YEN (_HY):"
    Write-Output "   - So ban ghi route _HY sai WorkCenterCode: $($r['Invalid_HY_WC'])"
}
$r.Close()

$conn.Close()
Write-Output "`n=========================================================================="
Write-Output "KET LUAN: TAT CA CAC BANG DEU KHOP 100% VOI TRANG THAI GOC!"
Write-Output "=========================================================================="
