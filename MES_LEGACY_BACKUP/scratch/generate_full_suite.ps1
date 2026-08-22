$data = Import-Csv "scratch/aging_lots_with_material.csv"

# Load the allocated lots
$d13_excel = @('VVQO183R072714', 'VVQO163R072709', 'VVQO193R072761', 'VVQO183R072716', 'VVQO193R072713', 'VVQO153R072712', 'VVQO193R072734', 'VVQO153R072714', 'VVQO153R072727', 'VVQO173R072751')
$d13_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-13' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 9)
$d13_lots = $d13_excel + ($d13_vvqq | ForEach-Object { $_.Barcode })

$d13_rem_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-13' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -Skip 9)
$d14_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-14' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d14_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-14' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 23)
$d14_lots = ($d13_rem_vvqq | ForEach-Object { $_.Barcode }) + ($d14_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d14_f1_vvqq | ForEach-Object { $_.Barcode })

$d15_excel = @('VVQO193R072708', 'VVQO173R072761', 'VVQO193R072748')
$d15_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-15' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d15_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-15' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d15_lots = $d15_excel + ($d15_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d15_f1_vvqq | ForEach-Object { $_.Barcode })

$d16_excel = @('VVQO193R072768', 'VVQO153R072719', 'VVQO153R072709', 'VVQO153R072728', 'VVQO183R072760')
$d16_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-16' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d16_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-16' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 14)
$d16_lots = $d16_excel + ($d16_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d16_f1_vvqq | ForEach-Object { $_.Barcode })

$d17_excel = @('VVQO183R072770', 'VVQO153R072711', 'VVQO153R072720', 'VVQO183R072712', 'VVQO183R072717', 'VVQN033R072790', 'VVQO173R072718', 'VVQO193R072767', 'VVQO193R072749', 'VVQO203R072758', 'VVQO163R072712', 'VVQO193R072725', 'VVQO173R072705', 'VVQO183R072769', 'VVQO203R072711', 'VVQO173R072735')
$d17_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-17' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d17_lots = $d17_excel + ($d17_f5_vvqq | ForEach-Object { $_.Barcode })

$d17_rem_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-17' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' } | Select-Object -Skip 8)
$d18_excel = @('VVQO193R072766', 'VVQO193R072712', 'VVQO153R072726', 'VVQO173R072731', 'VVQO163R072742', 'VVQO203R072713')
$d18_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-18' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d18_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-18' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 8)
$d18_lots = $d18_excel + ($d17_rem_vvqq | ForEach-Object { $_.Barcode }) + ($d18_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d18_f1_vvqq | ForEach-Object { $_.Barcode })

$d19_excel = @('VVQP263R072710', 'VVQP283R072702', 'VVQP263R072709', 'VVQP183R072706', 'VVQO183R072711')
$d19_f5_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-19' -and $_.WorkCenterCode -eq 'VVT_F5' -and $_.Barcode -like 'VVQQ*' })
$d19_f1_vvqq = ($data | Where-Object { $_.JobDate -eq '2026-08-19' -and $_.WorkCenterCode -eq 'VVT_F1' -and $_.Barcode -like 'VVQQ*' } | Select-Object -First 2)
$d19_lots = $d19_excel + ($d19_f5_vvqq | ForEach-Object { $_.Barcode }) + ($d19_f1_vvqq | ForEach-Object { $_.Barcode })

$allLots = $d13_lots + $d14_lots + $d15_lots + $d16_lots + $d17_lots + $d18_lots + $d19_lots
$allLotsSql = ($allLots | ForEach-Object { "'$_'" }) -join ", "

# 1. Backup script
$backupSql = @"
-- ==============================================================================
-- 01_backup_aging_hy_plan_13_19.sql
-- Backup du lieu truoc khi cap nhat ke hoach san luong Aging Hung Yen ngay 13-19/08/2026
-- ==============================================================================
IF OBJECT_ID('dbo.BK_20260821_AGING_PLAN_ProdRouteHist', 'U') IS NOT NULL
    DROP TABLE dbo.BK_20260821_AGING_PLAN_ProdRouteHist;

SELECT PRH.*
INTO dbo.BK_20260821_AGING_PLAN_ProdRouteHist
FROM dbo.STB_ProdRouteHist PRH WITH (NOLOCK)
INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
WHERE SI.Barcode IN ($allLotsSql)
  AND PRH.RouteCode LIKE 'V-26%';

PRINT 'BACKUP DỮ LIỆU AGING CHO 191 LOTS HOÀN TẤT!';
SELECT COUNT(*) AS Backup_Count FROM dbo.BK_20260821_AGING_PLAN_ProdRouteHist;
"@

$backupSql | Out-File "sql/01_backup_aging_hy_plan_13_19.sql" -Encoding utf8

# 2. Rollback script
$rollbackSql = @"
-- ==============================================================================
-- 03_rollback_aging_hy_plan_13_19.sql
-- Khoi phuc du lieu ve trang thai truoc khi chay plan 13-19
-- ==============================================================================
BEGIN TRANSACTION;
BEGIN TRY

    UPDATE PRH
    SET PRH.WorkCenterCode = BK.WorkCenterCode,
        PRH.JobDate = BK.JobDate,
        PRH.ProdDateTime = BK.ProdDateTime,
        PRH.CompleteRoute = BK.CompleteRoute,
        PRH.ChangeUserID = BK.ChangeUserID,
        PRH.ChangeDateTime = BK.ChangeDateTime
    FROM dbo.STB_ProdRouteHist PRH WITH (UPDLOCK)
    INNER JOIN dbo.BK_20260821_AGING_PLAN_ProdRouteHist BK WITH (NOLOCK)
        ON PRH.ControlNo = BK.ControlNo AND PRH.RouteCode = BK.RouteCode;

    COMMIT TRANSACTION;
    PRINT 'ROLLBACK DỮ LIỆU AGING 13-19 VỀ NGUYÊN BẢN THÀNH CÔNG!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('LOI KHI ROLLBACK: %s', 16, 1, @ErrMsg);
END CATCH;
"@

$rollbackSql | Out-File "sql/03_rollback_aging_hy_plan_13_19.sql" -Encoding utf8

# 3. Verify script
$verifySql = @"
-- ==============================================================================
-- 04_verify_aging_hy_plan_13_19.sql
-- Kiem tra san luong Aging Hung Yen tu ngay 13 den ngay 19
-- ==============================================================================
SELECT 
    CAST(PRH.JobDate AS DATE) AS Aging_JobDate,
    PRH.WorkCenterCode,
    COUNT(DISTINCT SI.Barcode) AS Lot_Count,
    SUM(PRH.ProdQty) AS Total_Qty,
    CASE CAST(PRH.JobDate AS DATE)
        WHEN '2026-08-13' THEN 20000
        WHEN '2026-08-14' THEN 40000
        WHEN '2026-08-15' THEN 23000
        WHEN '2026-08-16' THEN 25000
        WHEN '2026-08-17' THEN 25000
        WHEN '2026-08-18' THEN 25000
        WHEN '2026-08-19' THEN 26000
    END AS Target_Qty,
    SUM(PRH.ProdQty) - CASE CAST(PRH.JobDate AS DATE)
        WHEN '2026-08-13' THEN 20000
        WHEN '2026-08-14' THEN 40000
        WHEN '2026-08-15' THEN 23000
        WHEN '2026-08-16' THEN 25000
        WHEN '2026-08-17' THEN 25000
        WHEN '2026-08-18' THEN 25000
        WHEN '2026-08-19' THEN 26000
    END AS Diff_From_Target
FROM dbo.STB_ProdRouteHist PRH WITH (NOLOCK)
INNER JOIN dbo.STB_SetInfo SI WITH (NOLOCK) ON PRH.ControlNo = SI.ControlNo
WHERE PRH.WorkCenterCode = 'VVT_F5'
  AND PRH.RouteCode LIKE 'V-26%'
  AND CAST(PRH.JobDate AS DATE) BETWEEN '2026-08-13' AND '2026-08-19'
GROUP BY CAST(PRH.JobDate AS DATE), PRH.WorkCenterCode
ORDER BY Aging_JobDate;
"@

$verifySql | Out-File "sql/04_verify_aging_hy_plan_13_19.sql" -Encoding utf8
Write-Output "Generated backup, rollback and verify scripts!"
