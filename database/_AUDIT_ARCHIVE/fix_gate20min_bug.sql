-- ================================================================
-- FIX: Gate 20 phút trong usp_DoProcessProdRouteHistForCalc_SmartApp_VNT
-- Bug: @SIExtInt01 = Null  → LUÔN FALSE (SQL Server syntax)
-- Fix: @SIExtInt01 IS Null  → Hoạt động đúng
--
-- Author: Deep Audit 2026-05-05
-- Impact: VNT (Bắc Ninh) Electrode line — cho phép scan liên tục < 20 phút
-- Risk: LOW (chỉ sửa 1 dòng, logic giữ nguyên)
-- ================================================================

-- STEP 1: Xác nhận bug hiện tại
PRINT '=== STEP 1: Verify current bug ==='
SELECT 
    ROUTINE_NAME,
    LEFT(OBJECT_DEFINITION(OBJECT_ID('usp_DoProcessProdRouteHistForCalc_SmartApp_VNT')), 1) AS SP_Exists
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_NAME = 'usp_DoProcessProdRouteHistForCalc_SmartApp_VNT'

-- Tìm dòng lỗi
DECLARE @SPText NVARCHAR(MAX)
SET @SPText = OBJECT_DEFINITION(OBJECT_ID('usp_DoProcessProdRouteHistForCalc_SmartApp_VNT'))

IF CHARINDEX('@SIExtInt01 = Null', @SPText) > 0
    PRINT '❌ BUG CONFIRMED: Found "@SIExtInt01 = Null" (always FALSE)'
ELSE IF CHARINDEX('@SIExtInt01 IS Null', @SPText) > 0
    PRINT '✅ Already fixed: Found "@SIExtInt01 IS Null"'
ELSE
    PRINT '⚠️ Pattern not found - SP may have been modified'

-- STEP 2: Show the fix (DO NOT EXECUTE - review first)
PRINT ''
PRINT '=== STEP 2: Fix Script (ALTER PROCEDURE) ==='
PRINT 'The following line needs to change:'
PRINT ''
PRINT 'BEFORE (line 218):'
PRINT '  IF @CompanyCode = ''VNT'' AND @SIExtInt01 = Null AND @RouteIndex > 1 AND @RouteCode <> ''E-25'' AND @RouteCode <> ''E-23'''
PRINT ''
PRINT 'AFTER:'
PRINT '  IF @CompanyCode = ''VNT'' AND @SIExtInt01 IS Null AND @RouteIndex > 1 AND @RouteCode <> ''E-25'' AND @RouteCode <> ''E-23'''
PRINT ''
PRINT '⚠️ To apply: Use ALTER PROCEDURE to modify the SP, changing "= Null" to "IS Null" on line 218'
PRINT '⚠️ Test on DEV first before applying to production!'

-- STEP 3: Verify impact - how many barcodes would be affected
PRINT ''
PRINT '=== STEP 3: Impact Analysis ==='

-- Count VNT records that would have been blocked
SELECT 
    COUNT(*) AS TotalVNT_7days,
    SUM(CASE WHEN SIExtInt01 IS NULL THEN 1 ELSE 0 END) AS WouldBeChecked,
    SUM(CASE WHEN SIExtInt01 = 1 THEN 1 ELSE 0 END) AS AlreadyFlagged
FROM STB_SetInfo
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
AND ControlNo IN (
    SELECT DISTINCT PRH.ControlNo 
    FROM STB_ProdRouteHist PRH
    JOIN STB_RouteInfo RI ON PRH.RouteCode = RI.RouteCode
    WHERE RI.CompanyCode = 'VNT'
    AND PRH.CreateDateTime >= DATEADD(DAY, -7, GETDATE())
)
