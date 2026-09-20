-- ==============================================================================
-- TEMPLATE: B782 CHUYEN NGAY GHI NHAN SAN XUAT (MOVE JOB DATE)
-- Thay the: {{CONTROLNO_LIST}}, {{ROUTE_CODE}}, {{TARGET_DATE}}, {{TARGET_DATETIME}}
-- Tham chieu: KB_03_01 § 5.2, KB_09 § B782
-- ==============================================================================
-- HUONG DAN:
--   1. Thay {{CONTROLNO_LIST}} bang danh sach ControlNo (vd: '20260915000223','20260915000224')
--   2. Thay {{ROUTE_CODE}} bang cong doan can doi (vd: 'V-23_HY', 'V-24_HY')
--   3. Thay {{TARGET_DATE}} bang ngay dich (vd: '2026-09-18')
--   4. Thay {{TARGET_DATETIME}} bang thoi gian dich (vd: '2026-09-18 10:05:00')
--      Luu y: B782 tinh ca tu 10:00:00 sang hom truoc den 10:00:00 sang hom sau
--      Nen set thoi gian >= 10:00:00 cua ngay dich de hien thi dung ngay tren B782
--   5. Luon ROLLBACK truoc, chi COMMIT khi chac chan
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. [BEFORE] Khao sat hien trang truoc khi doi
SELECT ControlNo, RouteCode, ProdDateTime, JobDate, CompleteRoute, ProdQty
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo IN ({{CONTROLNO_LIST}})
  AND RouteCode IN ({{ROUTE_CODE}})
ORDER BY ControlNo, RouteCode;

-- 2. [EXECUTION] Cap nhat ProdDateTime va JobDate cho cong doan
UPDATE STB_ProdRouteHist 
SET ProdDateTime = '{{TARGET_DATETIME}}',
    JobDate = '{{TARGET_DATE}}',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ({{CONTROLNO_LIST}})
  AND RouteCode IN ({{ROUTE_CODE}});

-- 3. [SYNC] Dong bo thoi gian phe NG trong STB_DefectRepairInfo (neu co)
UPDATE STB_DefectRepairInfo 
SET CreateDateTime = '{{TARGET_DATETIME}}',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'it_hotfix'
WHERE ControlNo IN ({{CONTROLNO_LIST}})
  AND FindRouteCode IN ({{ROUTE_CODE}});

-- 4. [AFTER] Xac minh ket qua
SELECT ControlNo, RouteCode, ProdDateTime, JobDate, CompleteRoute
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo IN ({{CONTROLNO_LIST}})
  AND RouteCode IN ({{ROUTE_CODE}})
ORDER BY ControlNo, RouteCode;

SELECT ControlNo, FindRouteCode, DefectQty, CreateDateTime
FROM STB_DefectRepairInfo WITH(NOLOCK)
WHERE ControlNo IN ({{CONTROLNO_LIST}})
  AND FindRouteCode IN ({{ROUTE_CODE}});

-- [CONTROL] MAC DINH ROLLBACK (CHUYEN SANG COMMIT KHI CHAC CHAN)
ROLLBACK TRANSACTION;
-- COMMIT TRANSACTION;
GO
