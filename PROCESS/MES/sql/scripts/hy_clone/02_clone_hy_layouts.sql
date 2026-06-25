-- ============================================================================
-- Script 02: Clone Screen Layouts for 7 HY Screens
-- Target DB: SmartFramework
-- Author: vanduc
-- Date: 2026-06-23
--
-- CRITICAL: Chạy TRÊN SERVER hoặc kết nối ổn định.
--   Layout chứa binary data lớn (varbinary) → tận dụng INSERT INTO...SELECT
--   trực tiếp trên server để tránh timeout WAN.
--
-- Quy trình:
--   1. INSERT INTO...SELECT clone Layout (binary) + Snapshot nguyên trạng
--   2. REPLACE SP names trong XmlLayout → _HY
--   3. PHẢI chạy SAU script 01 (STB_ScreenInfo phải có trước)
--
-- ⚠️ Script mặc định ROLLBACK → xem preview → đổi COMMIT
-- ============================================================================

USE SmartFramework;
GO

BEGIN TRAN;

-- ============================================================================
-- 1. HY220 — Clone from MaterialIqcInfoSampleManagement (C220)
-- ============================================================================
INSERT INTO dbo.STB_ScreenLayoutInfo (Name, Version, DeveloperVersion, Layout, XmlLayout, Description, Snapshot, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
SELECT 
    'MaterialIqcInfoSampleManagement_HY' AS Name,
    1 AS Version,
    src.DeveloperVersion,
    src.Layout,         -- binary data → copy nguyên trạng trên server
    -- Replace 20 SP names → _HY trong XmlLayout
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        CAST(src.XmlLayout AS NVARCHAR(MAX)),
        'usp_MaterialQcInfo_get',                    'usp_MaterialQcInfo_HY_get'),
        'usp_MaterialQcInfo_iud',                    'usp_MaterialQcInfo_HY_iud'),
        'usp_MaterialQcDetail_get',                  'usp_MaterialQcDetail_HY_get'),
        'usp_MaterialQcDetail_iud',                  'usp_MaterialQcDetail_HY_iud'),
        'usp_MaterialQcSampleResult_get',            'usp_MaterialQcSampleResult_HY_get'),
        'usp_MaterialQcSampleResult_iud',            'usp_MaterialQcSampleResult_HY_iud'),
        'usp_DoChangeMaterialQcToPass',              'usp_DoChangeMaterialQcToPass_HY'),
        'usp_DoMakeMaterialIQCDetailList',           'usp_DoMakeMaterialIQCDetailList_HY'),
        'usp_DoMakeMaterialQcSampleResult',          'usp_DoMakeMaterialQcSampleResult_HY'),
        'usp_DoUpdateMaterialQcInfo_Fail',           'usp_DoUpdateMaterialQcInfo_Fail_HY'),
        'usp_DoUpdateMaterialQcInfo_Success',        'usp_DoUpdateMaterialQcInfo_Success_HY'),
        'usp_DoSendEmailForDefectReportIQC',         'usp_DoSendEmailForDefectReportIQC_HY'),
        'usp_IQcDefectReport_iud',                   'usp_IQcDefectReport_HY_iud'),
        'usp_DefectReportNoChange_iud',              'usp_DefectReportNoChange_HY_iud'),
        'usp_MaterialQcInfoChangeLotNo_iud',         'usp_MaterialQcInfoChangeLotNo_HY_iud'),
        'usp_ModifyRevisionsVerFromC220_VVTF4',      'usp_ModifyRevisionsVerFromC220_VVTF4_HY'),
        'usp_NCR_Report_iud',                        'usp_NCR_Report_HY_iud'),
        'usp_QcDefectIQCReport_get',                 'usp_QcDefectIQCReport_HY_get'),
        'usp_UpdateDefectDetailIQC_VVT',             'usp_UpdateDefectDetailIQC_VVT_HY'),
        'usp_GetMaterialQcInfo_ForReport',           'usp_GetMaterialQcInfo_ForReport_HY')
    AS XmlLayout,
    N'HY220 - Clone of C220 for Hung Yen' AS Description,
    src.Snapshot,       -- binary → copy nguyên trạng
    GETDATE() AS CreateDateTime,
    'vinaadmin' AS CreateUserID,
    GETDATE() AS ChangeDateTime,
    'vinaadmin' AS ChangeUserID
FROM dbo.STB_ScreenLayoutInfo src
WHERE src.Name = 'MaterialIqcInfoSampleManagement' AND src.Version = 1;

PRINT 'HY220 layout cloned.';

-- ============================================================================
-- 2. HY310 — Clone from ProductionOrderInfo (B310)
-- ============================================================================
INSERT INTO dbo.STB_ScreenLayoutInfo (Name, Version, DeveloperVersion, Layout, XmlLayout, Description, Snapshot, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
SELECT 
    'ProductionOrderInfo_HY' AS Name,
    1 AS Version,
    src.DeveloperVersion,
    src.Layout,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        CAST(src.XmlLayout AS NVARCHAR(MAX)),
        'usp_ProductionOrderInfo_get',       'usp_ProductionOrderInfo_HY_get'),
        'usp_ProductionOrderBom_get',        'usp_ProductionOrderBom_HY_get'),
        'usp_ProductionOrderRouting_get',    'usp_ProductionOrderRouting_HY_get'),
        'usp_ProductionOrderRouting_iud',    'usp_ProductionOrderRouting_HY_iud'),
        'usp_DoFixProductionOrder',          'usp_DoFixProductionOrder_HY'),
        'usp_DoCancelPO',                   'usp_DoCancelPO_HY'),
        'usp_GetMaterialGIForPO',           'usp_GetMaterialGIForPO_HY')
    AS XmlLayout,
    N'HY310 - Clone of B310 for Hung Yen' AS Description,
    src.Snapshot,
    GETDATE(), 'vinaadmin', GETDATE(), 'vinaadmin'
FROM dbo.STB_ScreenLayoutInfo src
WHERE src.Name = 'ProductionOrderInfo' AND src.Version = 1;

PRINT 'HY310 layout cloned.';

-- ============================================================================
-- 3. HY442 — Clone from ElectrodePlan_Vietnam (B442)
-- ============================================================================
INSERT INTO dbo.STB_ScreenLayoutInfo (Name, Version, DeveloperVersion, Layout, XmlLayout, Description, Snapshot, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
SELECT 
    'ElectrodePlan_HY' AS Name,
    1 AS Version,
    src.DeveloperVersion,
    src.Layout,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        CAST(src.XmlLayout AS NVARCHAR(MAX)),
        'usp_DayProdPlan_get',               'usp_DayProdPlan_HY_get'),
        'usp_DayProdPlan_iud',               'usp_DayProdPlan_HY_iud'),
        'usp_DoCancelDayProdPlan',           'usp_DoCancelDayProdPlan_HY'),
        'usp_DoFixDayProdPlan',              'usp_DoFixDayProdPlan_HY'),
        'usp_SetInfo_get',                   'usp_SetInfo_HY_get'),
        'usp_SetInfo_iud_VNT',              'usp_SetInfo_HY_iud_VNT'),
        'usp_MainAssemblePartWeight_get',    'usp_MainAssemblePartWeight_HY_get')
    AS XmlLayout,
    N'HY442 - Clone of B442 for Hung Yen' AS Description,
    src.Snapshot,
    GETDATE(), 'vinaadmin', GETDATE(), 'vinaadmin'
FROM dbo.STB_ScreenLayoutInfo src
WHERE src.Name = 'ElectrodePlan_Vietnam' AND src.Version = 1;

PRINT 'HY442 layout cloned.';

-- ============================================================================
-- 4. HY470 — Clone from VNT_ElectrodePrcsCard (B470)
-- ============================================================================
INSERT INTO dbo.STB_ScreenLayoutInfo (Name, Version, DeveloperVersion, Layout, XmlLayout, Description, Snapshot, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
SELECT 
    'ElectrodePrcsCard_HY' AS Name,
    1 AS Version,
    src.DeveloperVersion,
    src.Layout,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        CAST(src.XmlLayout AS NVARCHAR(MAX)),
        'usp_ElectrodeStep_get',             'usp_ElectrodeStep_HY_get'),
        'usp_ElectrodeStep_iud',             'usp_ElectrodeStep_HY_iud'),
        'usp_ElectrodeCommon_get',           'usp_ElectrodeCommon_HY_get'),
        'usp_ElectrodeCommon_iud',           'usp_ElectrodeCommon_HY_iud'),
        'usp_ElectrodeOven_get',             'usp_ElectrodeOven_HY_get'),
        'usp_ElectrodeOven_iud',             'usp_ElectrodeOven_HY_iud')
    AS XmlLayout,
    N'HY470 - Clone of B470 for Hung Yen' AS Description,
    src.Snapshot,
    GETDATE(), 'vinaadmin', GETDATE(), 'vinaadmin'
FROM dbo.STB_ScreenLayoutInfo src
WHERE src.Name = 'VNT_ElectrodePrcsCard' AND src.Version = 1;

PRINT 'HY470 layout cloned.';

-- ============================================================================
-- 5. HY552 — Clone from Vietnam_ElectrodeMeasureResult (B552)
-- Phức tạp nhất: 30 SP replacements
-- ============================================================================
INSERT INTO dbo.STB_ScreenLayoutInfo (Name, Version, DeveloperVersion, Layout, XmlLayout, Description, Snapshot, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
SELECT 
    'ElectrodeMeasureResult_HY' AS Name,
    1 AS Version,
    src.DeveloperVersion,
    src.Layout,
    -- 17 unique SP name replacements (some SPs share prefix → replace longer names first)
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        CAST(src.XmlLayout AS NVARCHAR(MAX)),
        -- Coating Visual Inspection (longer name first to avoid partial match)
        'usp_ElectrodeCoatingVisualInspectionInfo_get',     'usp_ElectrodeCoatingVisualInspectionInfo_HY_get'),
        'usp_ElectrodeCoatingVisualInspectionInfo_iud',     'usp_ElectrodeCoatingVisualInspectionInfo_HY_iud'),
        -- RollPressing Visual Inspection
        'usp_ElectrodeRollPressingVisualInspectionInfo_get','usp_ElectrodeRollPressingVisualInspectionInfo_HY_get'),
        'usp_ElectrodeRollPressingVisualInspectionInfo_iud','usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud'),
        -- RollPressing Info
        'usp_ElectrodeRollPressingInfo_get',                'usp_ElectrodeRollPressingInfo_HY_get'),
        'usp_ElectrodeRollPressingInfo_iud',                'usp_ElectrodeRollPressingInfo_HY_iud'),
        -- Coating Info (after CoatingVisual to avoid partial match)
        'usp_ElectrodeCoatingInfo_get',                     'usp_ElectrodeCoatingInfo_HY_get'),
        'usp_ElectrodeCoatingInfo_iud',                     'usp_ElectrodeCoatingInfo_HY_iud'),
        -- Mix Step Info (before MixInfo to avoid partial match)
        'usp_ElectrodeMixStepInfo_get',                     'usp_ElectrodeMixStepInfo_HY_get'),
        'usp_ElectrodeMixStepInfo_iud',                     'usp_ElectrodeMixStepInfo_HY_iud'),
        -- Mix Info
        'usp_ElectrodeMixInfo_get',                         'usp_ElectrodeMixInfo_HY_get'),
        'usp_ElectrodeMixInfo_iud',                         'usp_ElectrodeMixInfo_HY_iud'),
        -- Slitting Result (before SlittingInfo to avoid partial match)
        'usp_ElectrodeSlittingResult_get',                  'usp_ElectrodeSlittingResult_HY_get'),
        'usp_ElectrodeSlittingResult_iud',                  'usp_ElectrodeSlittingResult_HY_iud'),
        -- Slitting Info
        'usp_ElectrodeSlittingInfo_get',                    'usp_ElectrodeSlittingInfo_HY_get'),
        'usp_ElectrodeSlittingInfo_iud',                    'usp_ElectrodeSlittingInfo_HY_iud'),
        -- Viscosity
        'usp_ElectrodCoatingInfo_Viscosity_VVT_iud',        'usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud')
    AS XmlLayout,
    N'HY552 - Clone of B552 for Hung Yen (partial)' AS Description,
    src.Snapshot,
    GETDATE(), 'vinaadmin', GETDATE(), 'vinaadmin'
FROM dbo.STB_ScreenLayoutInfo src
WHERE src.Name = 'Vietnam_ElectrodeMeasureResult' AND src.Version = 1;

-- Tiếp tục replace các SPs còn lại trên bản ghi vừa insert
UPDATE dbo.STB_ScreenLayoutInfo
SET XmlLayout = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    CAST(XmlLayout AS NVARCHAR(MAX)),
    'usp_ElectrodeWasteInfoNew_iud',                'usp_ElectrodeWasteInfoNew_HY_iud'),
    'usp_ElectrodeWastePriceNewByBarcode_get',      'usp_ElectrodeWastePriceNewByBarcode_HY_get'),
    'usp_DoUpdateCoatingBarcodePrintYn',            'usp_DoUpdateCoatingBarcodePrintYn_HY'),
    'usp_DoUpdateRollPressBarcodePrintYn',          'usp_DoUpdateRollPressBarcodePrintYn_HY'),
    'usp_DoUpdateSlitingBarcodePrintYn',            'usp_DoUpdateSlitingBarcodePrintYn_HY'),
    'usp_LocationElectric',                         'usp_LocationElectric_HY'),
    'usp_test_check_expired',                       'usp_test_check_expired_HY'),
    'usp_Vietnam_RollPressingSlitting_get',         'usp_Vietnam_RollPressingSlitting_HY_get'),
    Description = N'HY552 - Clone of B552 for Hung Yen'
WHERE Name = 'ElectrodeMeasureResult_HY';

PRINT 'HY552 layout cloned (2 phases).';

-- ============================================================================
-- 6. HY802 — Clone from Vietnam_EletrodeProdRouteHist (B802)
-- ============================================================================
INSERT INTO dbo.STB_ScreenLayoutInfo (Name, Version, DeveloperVersion, Layout, XmlLayout, Description, Snapshot, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
SELECT 
    'ElectrodeProdRouteHist_HY' AS Name,
    1 AS Version,
    src.DeveloperVersion,
    src.Layout,
    REPLACE(REPLACE(
        CAST(src.XmlLayout AS NVARCHAR(MAX)),
        'usp_Vietnam_ElectrodeProdRouteHist_get',   'usp_Vietnam_ElectrodeProdRouteHist_HY_get'),
        'usp_Vietnam_ElectrodeDefectHist_get',      'usp_Vietnam_ElectrodeDefectHist_HY_get')
    AS XmlLayout,
    N'HY802 - Clone of B802 for Hung Yen' AS Description,
    src.Snapshot,
    GETDATE(), 'vinaadmin', GETDATE(), 'vinaadmin'
FROM dbo.STB_ScreenLayoutInfo src
WHERE src.Name = 'Vietnam_EletrodeProdRouteHist' AND src.Version = 1;

PRINT 'HY802 layout cloned.';

-- ============================================================================
-- 7. HY460 — Clone from ElectrodeInspectionHistoryForBarcode (C460)
-- ============================================================================
-- Phase 1: Replace all SPs EXCEPT usp_DoFinishCommInspDoc (to avoid double-replace)
-- usp_DoFinishCommInspDoc_VNT contains usp_DoFinishCommInspDoc as substring
-- → Replace _VNT version first, mark with placeholder, then handle base version
INSERT INTO dbo.STB_ScreenLayoutInfo (Name, Version, DeveloperVersion, Layout, XmlLayout, Description, Snapshot, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID)
SELECT 
    'ElectrodeInspectionHistoryForBarcode_HY' AS Name,
    1 AS Version,
    src.DeveloperVersion,
    src.Layout,
    REPLACE(REPLACE(REPLACE(REPLACE(
        CAST(src.XmlLayout AS NVARCHAR(MAX)),
        'usp_GetElectrodeInspectionHistoryForBarcode',  'usp_GetElectrodeInspectionHistoryForBarcode_HY'),
        'usp_DoAddCommInspMeasureHistForBarcode',       'usp_DoAddCommInspMeasureHistForBarcode_HY'),
        'usp_DoLossElectrodeProcess_iud',               'usp_DoLossElectrodeProcess_HY_iud'),
        'usp_ElectrodeDivision_popup',                  'usp_ElectrodeDivision_popup_HY')
    AS XmlLayout,
    N'HY460 - Clone of C460 for Hung Yen' AS Description,
    src.Snapshot,
    GETDATE(), 'vinaadmin', GETDATE(), 'vinaadmin'
FROM dbo.STB_ScreenLayoutInfo src
WHERE src.Name = 'ElectrodeInspectionHistoryForBarcode' AND src.Version = 1;

-- Phase 2: Replace usp_DoFinishCommInspDoc_VNT first (longer match), then base
-- Also replace usp_ElectrodeCoatingInfo_get
UPDATE dbo.STB_ScreenLayoutInfo
SET XmlLayout = REPLACE(
    CAST(XmlLayout AS NVARCHAR(MAX)),
    'usp_DoFinishCommInspDoc_VNT', 'usp_DoFinishCommInspDoc_VNT_HY')
WHERE Name = 'ElectrodeInspectionHistoryForBarcode_HY';

-- Now safe to replace the shorter name (VNT version already has _HY suffix, won't match again)
UPDATE dbo.STB_ScreenLayoutInfo
SET XmlLayout = REPLACE(
    CAST(XmlLayout AS NVARCHAR(MAX)),
    'usp_DoFinishCommInspDoc', 'usp_DoFinishCommInspDoc_HY')
WHERE Name = 'ElectrodeInspectionHistoryForBarcode_HY'
  -- Safety: only replace exact match that isn't already _HY
  AND CAST(XmlLayout AS NVARCHAR(MAX)) LIKE '%usp_DoFinishCommInspDoc<%';

-- Replace usp_ElectrodeCoatingInfo_get
UPDATE dbo.STB_ScreenLayoutInfo
SET XmlLayout = REPLACE(
    CAST(XmlLayout AS NVARCHAR(MAX)),
    'usp_ElectrodeCoatingInfo_get', 'usp_ElectrodeCoatingInfo_HY_get')
WHERE Name = 'ElectrodeInspectionHistoryForBarcode_HY';

PRINT 'HY460 layout cloned.';

-- ============================================================================
-- Verify: Check tất cả 7 layouts đã tồn tại
-- ============================================================================
SELECT 
    Name, 
    Version,
    LEN(CAST(XmlLayout AS NVARCHAR(MAX))) AS XmlLen,
    CASE WHEN Layout IS NOT NULL THEN 'HAS_BINARY' ELSE 'NO_BINARY' END AS LayoutStatus,
    CreateDateTime
FROM dbo.STB_ScreenLayoutInfo 
WHERE Name IN (
    'MaterialIqcInfoSampleManagement_HY',
    'ProductionOrderInfo_HY',
    'ElectrodePlan_HY',
    'ElectrodePrcsCard_HY',
    'ElectrodeMeasureResult_HY',
    'ElectrodeProdRouteHist_HY',
    'ElectrodeInspectionHistoryForBarcode_HY'
)
ORDER BY Name;

PRINT '=== 7 layouts cloned. Review above, then change ROLLBACK to COMMIT ===';

ROLLBACK; -- ← Đổi thành COMMIT khi đã xác nhận OK
-- COMMIT;
GO
