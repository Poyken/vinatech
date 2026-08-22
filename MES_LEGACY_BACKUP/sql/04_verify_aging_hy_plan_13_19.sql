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
