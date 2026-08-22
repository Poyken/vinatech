-- ==============================================================================
-- 04_verify_script_phase2.sql — Kiểm Tra Sau Khi Chuyển Toàn Bộ Sang Hưng Yên
-- ==============================================================================

-- 1. Thống kê sản lượng Hưng Yên (vvtworker_hy) theo từng ngày
SELECT 
    CAST(PrintTime AS DATE) AS PrintDate,
    EmpNo,
    COUNT(DISTINCT LotNo) AS UniqueLots,
    COUNT(*) AS RecordCount,
    SUM(PackQty) AS TotalQty
FROM dbo.STB_SavePackingTime_VVT WITH (NOLOCK)
WHERE PrintTime >= '2026-08-13' AND PrintTime < '2026-08-21'
  AND EmpNo IN ('vvtworker_hy', 'vvtworker_HY', 'vvtworker_bg')
GROUP BY CAST(PrintTime AS DATE), EmpNo
ORDER BY PrintDate, EmpNo;
