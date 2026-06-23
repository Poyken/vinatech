-- ============================================================================
-- Script 03: Clone ScreenObjects for 7 HY Screens
-- Target DB: SmartFramework
-- Author: AI Agent (Antigravity)
-- Date: 2026-06-23
--
-- PHẢI chạy SAU script 01 + 02
-- ScreenObjects = mapping giữa UI controls và SP names
-- Clone từ screen gốc, đổi ScreenName → HY, đổi SP ObjectName → _HY
--
-- ⚠️ Script mặc định ROLLBACK → xem preview → đổi COMMIT
-- ============================================================================

USE SmartFramework;
GO

BEGIN TRAN;

-- ============================================================================
-- 1. HY220 — Clone from MaterialIqcInfoSampleManagement (C220) — 51 objects
-- ============================================================================
INSERT INTO dbo.STB_ScreenObjects (ScreenName, ObjectName)
SELECT 
    'MaterialIqcInfoSampleManagement_HY' AS ScreenName,
    CASE ObjectName
        -- SP-type objects → replace with _HY version
        WHEN 'usp_MaterialQcInfo_get'               THEN 'usp_MaterialQcInfo_HY_get'
        WHEN 'usp_MaterialQcInfo_iud'               THEN 'usp_MaterialQcInfo_HY_iud'
        WHEN 'usp_MaterialQcDetail_get'             THEN 'usp_MaterialQcDetail_HY_get'
        WHEN 'usp_MaterialQcDetail_iud'             THEN 'usp_MaterialQcDetail_HY_iud'
        WHEN 'usp_MaterialQcSampleResult_get'       THEN 'usp_MaterialQcSampleResult_HY_get'
        WHEN 'usp_MaterialQcSampleResult_iud'       THEN 'usp_MaterialQcSampleResult_HY_iud'
        WHEN 'usp_DoChangeMaterialQcToPass'         THEN 'usp_DoChangeMaterialQcToPass_HY'
        WHEN 'usp_DoMakeMaterialIQCDetailList'      THEN 'usp_DoMakeMaterialIQCDetailList_HY'
        WHEN 'usp_DoMakeMaterialQcSampleResult'     THEN 'usp_DoMakeMaterialQcSampleResult_HY'
        WHEN 'usp_DoUpdateMaterialQcInfo_Fail'      THEN 'usp_DoUpdateMaterialQcInfo_Fail_HY'
        WHEN 'usp_DoUpdateMaterialQcInfo_Success'   THEN 'usp_DoUpdateMaterialQcInfo_Success_HY'
        WHEN 'usp_DoSendEmailForDefectReportIQC'    THEN 'usp_DoSendEmailForDefectReportIQC_HY'
        WHEN 'usp_IQcDefectReport_iud'              THEN 'usp_IQcDefectReport_HY_iud'
        WHEN 'usp_DefectReportNoChange_iud'         THEN 'usp_DefectReportNoChange_HY_iud'
        WHEN 'usp_MaterialQcInfoChangeLotNo_iud'    THEN 'usp_MaterialQcInfoChangeLotNo_HY_iud'
        WHEN 'usp_ModifyRevisionsVerFromC220_VVTF4' THEN 'usp_ModifyRevisionsVerFromC220_VVTF4_HY'
        WHEN 'usp_NCR_Report_iud'                   THEN 'usp_NCR_Report_HY_iud'
        WHEN 'usp_QcDefectIQCReport_get'            THEN 'usp_QcDefectIQCReport_HY_get'
        WHEN 'usp_UpdateDefectDetailIQC_VVT'        THEN 'usp_UpdateDefectDetailIQC_VVT_HY'
        WHEN 'usp_GetMaterialQcInfo_ForReport'      THEN 'usp_GetMaterialQcInfo_ForReport_HY'
        -- Client-side actions → keep as-is
        WHEN 'usp_DoCancelIQC'                      THEN 'usp_DoCancelIQC'
        WHEN 'usp_DoConfirmIQC'                     THEN 'usp_DoConfirmIQC'
        -- Non-SP objects → keep as-is
        ELSE ObjectName
    END AS ObjectName
FROM dbo.STB_ScreenObjects
WHERE ScreenName = 'MaterialIqcInfoSampleManagement';

PRINT 'HY220 ScreenObjects cloned: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- ============================================================================
-- 2. HY310 — Clone from ProductionOrderInfo (B310) — 19 objects
-- ============================================================================
INSERT INTO dbo.STB_ScreenObjects (ScreenName, ObjectName)
SELECT 
    'ProductionOrderInfo_HY' AS ScreenName,
    CASE ObjectName
        WHEN 'usp_ProductionOrderInfo_get'    THEN 'usp_ProductionOrderInfo_HY_get'
        WHEN 'usp_ProductionOrderBom_get'     THEN 'usp_ProductionOrderBom_HY_get'
        WHEN 'usp_ProductionOrderRouting_get' THEN 'usp_ProductionOrderRouting_HY_get'
        WHEN 'usp_ProductionOrderRouting_iud' THEN 'usp_ProductionOrderRouting_HY_iud'
        WHEN 'usp_DoFixProductionOrder'       THEN 'usp_DoFixProductionOrder_HY'
        WHEN 'usp_DoCancelPO'                THEN 'usp_DoCancelPO_HY'
        WHEN 'usp_GetMaterialGIForPO'        THEN 'usp_GetMaterialGIForPO_HY'
        ELSE ObjectName
    END AS ObjectName
FROM dbo.STB_ScreenObjects
WHERE ScreenName = 'ProductionOrderInfo';

PRINT 'HY310 ScreenObjects cloned: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- ============================================================================
-- 3. HY442 — Clone from ElectrodePlan_Vietnam (B442)
-- ============================================================================
INSERT INTO dbo.STB_ScreenObjects (ScreenName, ObjectName)
SELECT 
    'ElectrodePlan_HY' AS ScreenName,
    CASE ObjectName
        WHEN 'usp_DayProdPlan_get'            THEN 'usp_DayProdPlan_HY_get'
        WHEN 'usp_DayProdPlan_iud'            THEN 'usp_DayProdPlan_HY_iud'
        WHEN 'usp_DoCancelDayProdPlan'        THEN 'usp_DoCancelDayProdPlan_HY'
        WHEN 'usp_DoFixDayProdPlan'           THEN 'usp_DoFixDayProdPlan_HY'
        WHEN 'usp_SetInfo_get'                THEN 'usp_SetInfo_HY_get'
        WHEN 'usp_SetInfo_iud_VNT'            THEN 'usp_SetInfo_HY_iud_VNT'
        WHEN 'usp_MainAssemblePartWeight_get' THEN 'usp_MainAssemblePartWeight_HY_get'
        ELSE ObjectName
    END AS ObjectName
FROM dbo.STB_ScreenObjects
WHERE ScreenName = 'ElectrodePlan_Vietnam';

PRINT 'HY442 ScreenObjects cloned: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- ============================================================================
-- 4. HY470 — Clone from VNT_ElectrodePrcsCard (B470) — 10 objects
-- ============================================================================
INSERT INTO dbo.STB_ScreenObjects (ScreenName, ObjectName)
SELECT 
    'ElectrodePrcsCard_HY' AS ScreenName,
    CASE ObjectName
        WHEN 'usp_ElectrodeStep_get'    THEN 'usp_ElectrodeStep_HY_get'
        WHEN 'usp_ElectrodeStep_iud'    THEN 'usp_ElectrodeStep_HY_iud'
        WHEN 'usp_ElectrodeCommon_get'  THEN 'usp_ElectrodeCommon_HY_get'
        WHEN 'usp_ElectrodeCommon_iud'  THEN 'usp_ElectrodeCommon_HY_iud'
        WHEN 'usp_ElectrodeOven_get'    THEN 'usp_ElectrodeOven_HY_get'
        WHEN 'usp_ElectrodeOven_iud'    THEN 'usp_ElectrodeOven_HY_iud'
        ELSE ObjectName
    END AS ObjectName
FROM dbo.STB_ScreenObjects
WHERE ScreenName = 'VNT_ElectrodePrcsCard';

PRINT 'HY470 ScreenObjects cloned: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- ============================================================================
-- 5. HY552 — Clone from Vietnam_ElectrodeMeasureResult (B552) — 76 objects
-- ============================================================================
INSERT INTO dbo.STB_ScreenObjects (ScreenName, ObjectName)
SELECT 
    'ElectrodeMeasureResult_HY' AS ScreenName,
    CASE ObjectName
        WHEN 'usp_ElectrodeCoatingInfo_get'                      THEN 'usp_ElectrodeCoatingInfo_HY_get'
        WHEN 'usp_ElectrodeCoatingInfo_iud'                      THEN 'usp_ElectrodeCoatingInfo_HY_iud'
        WHEN 'usp_ElectrodeCoatingVisualInspectionInfo_get'      THEN 'usp_ElectrodeCoatingVisualInspectionInfo_HY_get'
        WHEN 'usp_ElectrodeCoatingVisualInspectionInfo_iud'      THEN 'usp_ElectrodeCoatingVisualInspectionInfo_HY_iud'
        WHEN 'usp_ElectrodeMixInfo_get'                          THEN 'usp_ElectrodeMixInfo_HY_get'
        WHEN 'usp_ElectrodeMixInfo_iud'                          THEN 'usp_ElectrodeMixInfo_HY_iud'
        WHEN 'usp_ElectrodeMixStepInfo_get'                      THEN 'usp_ElectrodeMixStepInfo_HY_get'
        WHEN 'usp_ElectrodeMixStepInfo_iud'                      THEN 'usp_ElectrodeMixStepInfo_HY_iud'
        WHEN 'usp_ElectrodeRollPressingInfo_get'                 THEN 'usp_ElectrodeRollPressingInfo_HY_get'
        WHEN 'usp_ElectrodeRollPressingInfo_iud'                 THEN 'usp_ElectrodeRollPressingInfo_HY_iud'
        WHEN 'usp_ElectrodeRollPressingVisualInspectionInfo_get' THEN 'usp_ElectrodeRollPressingVisualInspectionInfo_HY_get'
        WHEN 'usp_ElectrodeRollPressingVisualInspectionInfo_iud' THEN 'usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud'
        WHEN 'usp_ElectrodeSlittingInfo_get'                     THEN 'usp_ElectrodeSlittingInfo_HY_get'
        WHEN 'usp_ElectrodeSlittingInfo_iud'                     THEN 'usp_ElectrodeSlittingInfo_HY_iud'
        WHEN 'usp_ElectrodeSlittingResult_get'                   THEN 'usp_ElectrodeSlittingResult_HY_get'
        WHEN 'usp_ElectrodeSlittingResult_iud'                   THEN 'usp_ElectrodeSlittingResult_HY_iud'
        WHEN 'usp_ElectrodeWasteInfoNew_iud'                     THEN 'usp_ElectrodeWasteInfoNew_HY_iud'
        WHEN 'usp_ElectrodeWastePriceNewByBarcode_get'           THEN 'usp_ElectrodeWastePriceNewByBarcode_HY_get'
        WHEN 'usp_ElectrodCoatingInfo_Viscosity_VVT_iud'         THEN 'usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud'
        WHEN 'usp_DoUpdateCoatingBarcodePrintYn'                 THEN 'usp_DoUpdateCoatingBarcodePrintYn_HY'
        WHEN 'usp_DoUpdateRollPressBarcodePrintYn'               THEN 'usp_DoUpdateRollPressBarcodePrintYn_HY'
        WHEN 'usp_DoUpdateSlitingBarcodePrintYn'                 THEN 'usp_DoUpdateSlitingBarcodePrintYn_HY'
        WHEN 'usp_LocationElectric'                              THEN 'usp_LocationElectric_HY'
        WHEN 'usp_test_check_expired'                            THEN 'usp_test_check_expired_HY'
        WHEN 'usp_Vietnam_RollPressingSlitting_get'              THEN 'usp_Vietnam_RollPressingSlitting_HY_get'
        ELSE ObjectName
    END AS ObjectName
FROM dbo.STB_ScreenObjects
WHERE ScreenName = 'Vietnam_ElectrodeMeasureResult';

PRINT 'HY552 ScreenObjects cloned: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- ============================================================================
-- 6. HY802 — Clone from Vietnam_EletrodeProdRouteHist (B802) — 6 objects
-- ============================================================================
INSERT INTO dbo.STB_ScreenObjects (ScreenName, ObjectName)
SELECT 
    'ElectrodeProdRouteHist_HY' AS ScreenName,
    CASE ObjectName
        WHEN 'usp_Vietnam_ElectrodeProdRouteHist_get' THEN 'usp_Vietnam_ElectrodeProdRouteHist_HY_get'
        WHEN 'usp_Vietnam_ElectrodeDefectHist_get'    THEN 'usp_Vietnam_ElectrodeDefectHist_HY_get'
        ELSE ObjectName
    END AS ObjectName
FROM dbo.STB_ScreenObjects
WHERE ScreenName = 'Vietnam_EletrodeProdRouteHist';

PRINT 'HY802 ScreenObjects cloned: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- ============================================================================
-- 7. HY460 — Clone from ElectrodeInspectionHistoryForBarcode (C460) — 19 objects
-- ============================================================================
INSERT INTO dbo.STB_ScreenObjects (ScreenName, ObjectName)
SELECT 
    'ElectrodeInspectionHistoryForBarcode_HY' AS ScreenName,
    CASE ObjectName
        WHEN 'usp_GetElectrodeInspectionHistoryForBarcode'  THEN 'usp_GetElectrodeInspectionHistoryForBarcode_HY'
        WHEN 'usp_DoAddCommInspMeasureHistForBarcode'       THEN 'usp_DoAddCommInspMeasureHistForBarcode_HY'
        WHEN 'usp_DoAddCommInspMeasureHistForBarcode_TEST'  THEN 'usp_DoAddCommInspMeasureHistForBarcode_HY'  -- TEST alias → same HY
        WHEN 'usp_DoFinishCommInspDoc'                      THEN 'usp_DoFinishCommInspDoc_HY'
        WHEN 'usp_DoFinishCommInspDoc_VNT'                  THEN 'usp_DoFinishCommInspDoc_VNT_HY'
        WHEN 'usp_DoLossElectrodeProcess_iud'               THEN 'usp_DoLossElectrodeProcess_HY_iud'
        WHEN 'usp_ElectrodeCoatingInfo_get'                 THEN 'usp_ElectrodeCoatingInfo_HY_get'
        WHEN 'usp_ElectrodeDivision_popup'                  THEN 'usp_ElectrodeDivision_popup_HY'
        ELSE ObjectName
    END AS ObjectName
FROM dbo.STB_ScreenObjects
WHERE ScreenName = 'ElectrodeInspectionHistoryForBarcode';

PRINT 'HY460 ScreenObjects cloned: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- ============================================================================
-- Verify: Count objects per HY screen
-- ============================================================================
SELECT ScreenName, COUNT(*) AS ObjectCount
FROM dbo.STB_ScreenObjects
WHERE ScreenName IN (
    'MaterialIqcInfoSampleManagement_HY',
    'ProductionOrderInfo_HY',
    'ElectrodePlan_HY',
    'ElectrodePrcsCard_HY',
    'ElectrodeMeasureResult_HY',
    'ElectrodeProdRouteHist_HY',
    'ElectrodeInspectionHistoryForBarcode_HY'
)
GROUP BY ScreenName
ORDER BY ScreenName;

PRINT '=== ScreenObjects cloned. Review above, then change ROLLBACK to COMMIT ===';

ROLLBACK; -- ← Đổi thành COMMIT khi đã xác nhận OK
-- COMMIT;
GO
