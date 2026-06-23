# 9 Màn Hình HY — Danh Sách Sử Dụng

> **Ngày:** 2026-06-23 | **Nhà máy:** Hưng Yên (VVT_F5)  
> **Nguyên tắc:** Tất cả SPs dùng bản `_HY`. Tables & Functions dùng chung.

---

## Tổng quan

| # | Gốc | TCode HY | Tên Screen HY | Trạng thái |
|---|---|---|---|---|
| 1 | C121 | `C121_HY` | `QcInspectionGroupItem_HY` | ✅ Đã có |
| 2 | C122 | `C122_HY` | `MaterialInspectionCriteria_HY` | ✅ Đã có |
| 3 | C220 | `HY220` | `MaterialIqcInfoSampleManagement_HY` | ❌ Cần tạo |
| 4 | B310 | `HY310` | `ProductionOrderInfo_HY` | ❌ Cần tạo |
| 5 | B442 | `HY442` | `ElectrodePlan_HY` | ❌ Cần tạo |
| 6 | B470 | `HY470` | `ElectrodePrcsCard_HY` | ❌ Cần tạo |
| 7 | B552 | `HY552` | `ElectrodeMeasureResult_HY` | ❌ Cần tạo |
| 8 | B802 | `HY802` | `ElectrodeProdRouteHist_HY` | ❌ Cần tạo |
| 9 | C460 | `HY460` | `ElectrodeInspectionHistoryForBarcode_HY` | ❌ Cần tạo |

---

## 1. C121 → `C121_HY` — Quản lý nhóm & hạng mục kiểm tra ✅ ĐÃ CÓ

**Parent:** `QC_HY`

### SPs dùng _HY

| SP |
|---|
| `usp_QcInspectionGroup_HY_get` |
| `usp_QcInspectionGroup_HY_iud` |
| `usp_QcInspectionGroup_HY_popup` |
| `usp_QcInspectionItem_HY_get` |
| `usp_QcInspectionItem_HY_iud` |

### SPs dùng chung

| SP |
|---|
| `usp_GetAql_popup` |
| `usp_GetInspectionLevel_popup` |
| `usp_GetInspectionType_popup` |

### Tables (dùng chung)

`STB_QcInspectionGroup`, `STB_QcInspectionItem`, `STB_CommInspSelectGroup`, `STB_CommInspSelectItem`

---

## 2. C122 → `C122_HY` — Tiêu chuẩn kiểm tra nguyên liệu ✅ ĐÃ CÓ

**Parent:** `QC_HY`

### SPs dùng _HY

| SP |
|---|
| `usp_MaterialQcInspectionItem_ByMaterial_HY_get` |
| `usp_MaterialQcInspectionItem_HY_iud` |

### SPs dùng chung

| SP |
|---|
| `usp_MaterialMaster_popup` |

### Tables (dùng chung)

`STB_MaterialQcInspectionItem`, `STB_MaterialMaster`, `STB_QcInspectionItem`

---

## 3. C220 → `HY220` — IQC Confirmation ❌ CẦN TẠO

**Clone từ:** `MaterialIqcInfoSampleManagement` | **Parent:** `QC_HY`

### SPs dùng _HY

| SP |
|---|
| `usp_MaterialQcInfo_HY_get` |
| `usp_MaterialQcInfo_HY_iud` |
| `usp_MaterialQcDetail_HY_get` |
| `usp_MaterialQcDetail_HY_iud` |
| `usp_MaterialQcSampleResult_HY_get` |
| `usp_MaterialQcSampleResult_HY_iud` |
| `usp_DoChangeMaterialQcToPass_HY` |
| `usp_DoMakeMaterialIQCDetailList_HY` |
| `usp_DoMakeMaterialQcSampleResult_HY` |
| `usp_DoUpdateMaterialQcInfo_Fail_HY` |
| `usp_DoUpdateMaterialQcInfo_Success_HY` |
| `usp_DoSendEmailForDefectReportIQC_HY` |
| `usp_IQcDefectReport_HY_iud` |
| `usp_DefectReportNoChange_HY_iud` |
| `usp_MaterialQcInfoChangeLotNo_HY_iud` |
| `usp_ModifyRevisionsVerFromC220_VVTF4_HY` |
| `usp_NCR_Report_HY_iud` |
| `usp_QcDefectIQCReport_HY_get` |
| `usp_UpdateDefectDetailIQC_VVT_HY` |
| `usp_GetMaterialQcInfo_ForReport_HY` |

### SPs dùng chung

| SP |
|---|
| `usp_DoConfirmCancelQc2` |
| `usp_CompanyInfo_popup` |
| `usp_WorkCenterInfo_popup` |
| `usp_MaterialTypeCode_popup` |
| `usp_PurchaseMaterialMaster_popup` |
| `usp_VendorCustomerInfo_popup` |
| `usp_GetBaseCode_popup` |
| `usp_GetBaseCodeRemarkFilter_popup` |
| `usp_GetTestResult_popup` |
| `usp_DecisionResult_popup` |
| `usp_ProdWorkerInfo_Popup` |
| `usp_ProdIInspectionWorkerInfo_Popup` |
| `usp_ProductGroup_get` |
| `usp_NameErrorIQC` |
| `usp_DefectCauseGroup_get` |
| `usp_DefectCauseGroup_popup` |

### Tables (dùng chung)

`STB_MaterialQcInfo`, `STB_MaterialQcDetail`, `STB_MaterialQcSampleResult`, `STB_MaterialMaster`, `STB_IQcDefectReport`

---

## 4. B310 → `HY310` — Tạo PO ❌ CẦN TẠO

**Clone từ:** `ProductionOrderInfo` | **Parent:** `Production_HY`

> HY311 (PO_Electrode_HY) đã có nhưng là PO Electrode simplified — KHÁC B310 (General PO).

### SPs dùng _HY

| SP |
|---|
| `usp_ProductionOrderInfo_HY_get` |
| `usp_ProductionOrderBom_HY_get` |
| `usp_ProductionOrderRouting_HY_get` |
| `usp_ProductionOrderRouting_HY_iud` |
| `usp_DoFixProductionOrder_HY` |
| `usp_DoCancelPO_HY` |
| `usp_GetMaterialGIForPO_HY` |

### SPs dùng chung

| SP |
|---|
| `usp_DoCreateProductionOrder` |
| `usp_BasicRoutingInfo_popup` |
| `usp_CompanyInfo_popup` |
| `usp_GetRouteInfoAll_popup` |
| `usp_ProductionMaterialPopup` |
| `usp_WorkCenterInfo_popup` |

### Tables (dùng chung)

`STB_ProductionOrderInfo`, `STB_ProductionOrderBom`, `STB_ProductionOrderRouting`, `STB_MaterialMaster`, `STB_BasicRoutingInfo`

---

## 5. B442 → `HY442` — Daily Plan Electrode ❌ CẦN TẠO

**Clone từ:** `ElectrodePlan_Vietnam` | **Parent:** `ElectrodeHY`  
⚠️ Cần Electrode Lines trước khi sử dụng

### SPs dùng _HY

| SP |
|---|
| `usp_DayProdPlan_HY_get` |
| `usp_DayProdPlan_HY_iud` |
| `usp_DoCancelDayProdPlan_HY` |
| `usp_DoFixDayProdPlan_HY` |
| `usp_SetInfo_HY_get` |
| `usp_SetInfo_HY_iud_VNT` |
| `usp_MainAssemblePartWeight_HY_get` |

### SPs dùng chung

| SP |
|---|
| `usp_BomVersion_popup` |
| `usp_CompanyInfo_popup` |
| `usp_LineInfo_popup` |
| `usp_ProductGroup_popup` |
| `usp_ProductionMaterialPopup` |
| `usp_RouteInfoForLine_popup` |
| `usp_ShiftCode_popup` |
| `usp_WorkCenterInfo_popup` |

### Tables (dùng chung)

`STB_DayProdPlan`, `STB_SetInfo`, `STB_ProductionOrderInfo`, `STB_MaterialMaster`, `STB_LineInfo`, `STB_RouteInfo`, `STB_MachineMaster`, `STB_CompanyInfo`, `STB_WorkCenterInfo`

### Functions (dùng chung)

`fnGetLocalTime`, `fnSplitToTable`

---

## 6. B470 → `HY470` — Mixing Process Steps ❌ CẦN TẠO

**Clone từ:** `VNT_ElectrodePrcsCard` | **Parent:** `ElectrodeHY`  
⚠️ Cần Electrode Lines trước khi sử dụng

### SPs dùng _HY

| SP |
|---|
| `usp_ElectrodeStep_HY_get` |
| `usp_ElectrodeStep_HY_iud` |
| `usp_ElectrodeCommon_HY_get` |
| `usp_ElectrodeCommon_HY_iud` |
| `usp_ElectrodeOven_HY_get` |
| `usp_ElectrodeOven_HY_iud` |

### SPs dùng chung

| SP |
|---|
| `usp_ElectrodeStep_popup` |
| `usp_MaterialMasterByMaterialType_popup` |

### Tables (dùng chung)

`STB_ElectrodeStep`, `STB_ElectrodeCommon`, `STB_ElectrodeOven`, `STB_MaterialMaster`

---

## 7. B552 → `HY552` — Electrode Measure Results ❌ CẦN TẠO

**Clone từ:** `Vietnam_ElectrodeMeasureResult` | **Parent:** `ElectrodeHY`  
⚠️ Layout lớn nhất (2.76M chars) — clone 2 phase. Cần Electrode Lines.

### SPs dùng _HY

| SP |
|---|
| `usp_ElectrodeCoatingInfo_HY_get` |
| `usp_ElectrodeCoatingInfo_HY_iud` |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_get` |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_iud` |
| `usp_ElectrodeMixInfo_HY_get` |
| `usp_ElectrodeMixInfo_HY_iud` |
| `usp_ElectrodeMixStepInfo_HY_get` |
| `usp_ElectrodeMixStepInfo_HY_iud` |
| `usp_ElectrodeRollPressingInfo_HY_get` |
| `usp_ElectrodeRollPressingInfo_HY_iud` |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_get` |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud` |
| `usp_ElectrodeSlittingInfo_HY_get` |
| `usp_ElectrodeSlittingInfo_HY_iud` |
| `usp_ElectrodeSlittingResult_HY_get` |
| `usp_ElectrodeSlittingResult_HY_iud` |
| `usp_ElectrodeWasteInfoNew_HY_iud` |
| `usp_ElectrodeWastePriceNewByBarcode_HY_get` |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` |
| `usp_DoUpdateCoatingBarcodePrintYn_HY` |
| `usp_DoUpdateRollPressBarcodePrintYn_HY` |
| `usp_DoUpdateSlitingBarcodePrintYn_HY` |
| `usp_LocationElectric_HY` |
| `usp_test_check_expired_HY` |
| `usp_Vietnam_RollPressingSlitting_HY_get` |

### SPs dùng chung

| SP |
|---|
| `usp_RouteInfo_get` |
| `usp_GetBaseCode_popup` |
| `usp_GetBasicRouteingDetailForRoute_popup` |
| `usp_MaterialMaster_popup` |
| `usp_ProductMachine_popup` |
| `usp_ProductMachineForRoute_popup` |
| `usp_ProdWorkerInfo_Popup` |
| `usp_Vietnam_DefectInfo_popup` |
| `usp_CommonCode_INOUT_popup` |
| `usp_CommonCode_OKNG_popup` |
| `usp_CommonCode_OX_LEFT_popup` |
| `usp_CommonCode_OX_RIGHT_popup` |
| `usp_CommonCode_YesNo_popup` |
| `usp_CommonCode_YesNo_PushingYn_popup` |

### Tables (dùng chung)

`STB_ElectrodeCoatingInfo`, `STB_ElectrodeCoatingVisualInspectionInfo`, `STB_ElectrodeMixInfo`, `STB_ElectrodeMixStepInfo`, `STB_ElectrodeRollPressingInfo`, `STB_ElectrodeRollPressingVisualInspectionInfo`, `STB_ElectrodeSlittingInfo`, `STB_ElectrodeSlittingResult`, `STB_ElectrodeWasteInfo`, `STB_SlittingLocationConfig_VVT`, `STB_CoatingToSlittingMaster`, `STB_ProdRouteHist`

### Functions (dùng chung)

`fnGetElectrodeDensity`, `fnGetElectrodeDensityAvg`, `fnGetElectrodeDensityNew`, `fnGetElectrodeThickness01`, `fnGetElectrodeThickness02`, `fnGetElectrodeThickness03`

---

## 8. B802 → `HY802` — Báo cáo sản xuất electrode ❌ CẦN TẠO

**Clone từ:** `Vietnam_EletrodeProdRouteHist` | **Parent:** `ElectrodeHY`  
⚠️ Cần Electrode Lines trước khi sử dụng

### SPs dùng _HY

| SP |
|---|
| `usp_Vietnam_ElectrodeProdRouteHist_HY_get` |
| `usp_Vietnam_ElectrodeDefectHist_HY_get` |

### SPs dùng chung

| SP |
|---|
| `usp_CompanyInfo_get` |
| `usp_GetBaseCode_popup` |
| `usp_GetBaseCode_popup2` |
| `usp_vvt_RnDorProduction_popup` |
| `usp_WorkCenterInfo_popup` |

### Tables (dùng chung)

`STB_ProdRouteHist`, `STB_ElectrodeCoatingInfo`, `STB_ElectrodeRollPressingInfo`, `STB_ElectrodeSlittingInfo`, `STB_ElectrodeMixInfo`

### Functions (dùng chung)

`fnGetJobDateShiftTime`

---

## 9. C460 → `HY460` — QC Electrode Inspection ❌ CẦN TẠO

**Clone từ:** `ElectrodeInspectionHistoryForBarcode` | **Parent:** `QC_HY`  
⚠️ Cần Electrode Lines. Layout cần 3-phase replace (tránh double-replace `DoFinishCommInspDoc`).

> HY443 (CommInspectionHistoryForBarcode_HY) đã có nhưng là General CommInsp — KHÁC C460 (Electrode Inspection).

### SPs dùng _HY

| SP |
|---|
| `usp_GetElectrodeInspectionHistoryForBarcode_HY` |
| `usp_DoAddCommInspMeasureHistForBarcode_HY` |
| `usp_DoFinishCommInspDoc_HY` |
| `usp_DoFinishCommInspDoc_VNT_HY` |
| `usp_DoLossElectrodeProcess_HY_iud` |
| `usp_ElectrodeCoatingInfo_HY_get` |
| `usp_ElectrodeDivision_popup_HY` |

### SPs dùng chung

| SP |
|---|
| `usp_DoLossCommInspDoc_VNT` |
| `usp_CommInspSelectItem_popup` |
| `usp_CommonCode_OKNG_popup` |
| `usp_CompanyInfo_popup` |
| `usp_DefectInfo_popup` |
| `usp_LineInfo_popup` |
| `usp_ProdWorkerInfo_Popup` |
| `usp_RouteInfoForLine_popup` |
| `usp_WorkCenterInfo_popup` |

### Tables (dùng chung)

`STB_CommInspDocHistory`, `STB_CommInspDocItem`, `STB_CommInspMeasureHist`, `STB_ElectrodeCoatingInfo`, `STB_ProdRouteHist`

---

## Prerequisite: Electrode Lines ⚠️

HY hiện có 15 lines (10 Cell + 5 Module), **chưa có Electrode lines**.  
Cần tạo trong `STB_LineInfo` trước khi dùng B442/B470/B552/B802/C460.

**Tham khảo BN:**
- `ElectrodeBN`
- `VVC-ELECTRODE-LINE`

---

## Scripts deploy (đã tạo sẵn)

| Thứ tự | Script | Mô tả |
|---|---|---|
| 1 | `01_register_hy_screens.sql` | INSERT 7 screens → `STB_ScreenInfo` |
| 2 | `02_clone_hy_layouts.sql` | Clone layouts + REPLACE tên SP → `STB_ScreenLayoutInfo` |
| 3 | `03_clone_hy_screen_objects.sql` | Clone ~200 objects → `STB_ScreenObjects` |
| 4 | `04_grant_hy_permissions.sql` | Grant Admin → `STB_UserTypeBasicPermission` |

Chạy trên SSMS theo thứ tự 1→2→3→4. Mặc định ROLLBACK, đổi COMMIT khi OK.
