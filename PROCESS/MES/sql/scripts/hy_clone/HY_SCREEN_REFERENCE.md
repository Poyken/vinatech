# Danh Sách 9 Màn Hình HY — SPs, Tables, Functions

> **Ngày tạo:** 2026-06-23  
> **Nhà máy:** Hưng Yên (VVT_F5)  
> **Trạng thái:** Tất cả DB objects (SP, Table, Function) đã tồn tại — không cần tạo mới.

---

## Tóm tắt nhanh

| # | Gốc | TCode HY | Tên HY Screen | Layout Name HY | Trạng thái |
|---|---|---|---|---|---|
| 1 | C121 | `C121_HY` | `QcInspectionGroupItem_HY` | `QcInspectionGroupItem_HY` | ✅ Đã có |
| 2 | C122 | `C122_HY` | `MaterialInspectionCriteria_HY` | `MaterialInspectionCriteria_HY` | ✅ Đã có |
| 3 | C220 | `HY220` | `MaterialIqcInfoSampleManagement_HY` | `MaterialIqcInfoSampleManagement_HY` | ❌ Chưa có |
| 4 | B310 | `HY310` | `ProductionOrderInfo_HY` | `ProductionOrderInfo_HY` | ❌ Chưa có |
| 5 | B442 | `HY442` | `ElectrodePlan_HY` | `ElectrodePlan_HY` | ❌ Chưa có |
| 6 | B470 | `HY470` | `ElectrodePrcsCard_HY` | `ElectrodePrcsCard_HY` | ❌ Chưa có |
| 7 | B552 | `HY552` | `ElectrodeMeasureResult_HY` | `ElectrodeMeasureResult_HY` | ❌ Chưa có |
| 8 | B802 | `HY802` | `ElectrodeProdRouteHist_HY` | `ElectrodeProdRouteHist_HY` | ❌ Chưa có |
| 9 | C460 | `HY460` | `ElectrodeInspectionHistoryForBarcode_HY` | `ElectrodeInspectionHistoryForBarcode_HY` | ❌ Chưa có |

---

## 1. C121 → `C121_HY` — Quản lý nhóm kiểm tra & hạng mục kiểm tra

**Mô tả:** Manage inspection items and inspection teams  
**Trạng thái:** ✅ ĐÃ CÓ (Screen + Layout + Objects + Permission)

### Stored Procedures

| SP HY (dùng trong layout) | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_QcInspectionGroup_HY_get` | `usp_QcInspectionGroup_get` | Riêng HY | ✅ Có |
| `usp_QcInspectionGroup_HY_iud` | `usp_QcInspectionGroup_iud` | Riêng HY | ✅ Có |
| `usp_QcInspectionGroup_HY_popup` | `usp_QcInspectionGroup_popup` | Riêng HY | ✅ Có |
| `usp_QcInspectionItem_HY_get` | `usp_QcInspectionItem_get` | Riêng HY | ✅ Có |
| `usp_QcInspectionItem_HY_iud` | `usp_QcInspectionItem_iud` | Riêng HY | ✅ Có |
| `usp_GetAql_popup` | — | Dùng chung | ✅ Có |
| `usp_GetInspectionLevel_popup` | — | Dùng chung | ✅ Có |
| `usp_GetInspectionType_popup` | — | Dùng chung | ✅ Có |

### Tables

| Table | Vai trò |
|---|---|
| `STB_CommInspSelectGroup` | Nhóm kiểm tra |
| `STB_CommInspSelectItem` | Hạng mục kiểm tra |
| `STB_QcInspectionGroup` | Nhóm QC |
| `STB_QcInspectionItem` | Hạng mục QC |

### Functions

Không dùng function riêng.

---

## 2. C122 → `C122_HY` — Thiết lập tiêu chuẩn kiểm tra nguyên liệu

**Mô tả:** Establish inspection criteria for each raw material  
**Trạng thái:** ✅ ĐÃ CÓ (Screen + Layout + Objects + Permission)

### Stored Procedures

| SP HY | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_MaterialQcInspectionItem_ByMaterial_HY_get` | `usp_MaterialQcInspectionItem_ByMaterial_get` | Riêng HY | ✅ Có |
| `usp_MaterialQcInspectionItem_HY_iud` | `usp_MaterialQcInspectionItem_iud` | Riêng HY | ✅ Có |
| `usp_MaterialMaster_popup` | — | Dùng chung | ✅ Có |

### Tables

| Table | Vai trò |
|---|---|
| `STB_MaterialQcInspectionItem` | Tiêu chuẩn QC theo material |
| `STB_MaterialMaster` | Master nguyên liệu |
| `STB_QcInspectionItem` | Hạng mục QC (ref) |

### Functions

Không dùng function riêng.

---

## 3. C220 → `HY220` — Kiểm tra chất lượng nguyên liệu nhập kho (IQC)

**Mô tả:** When raw materials arrive, their quality must be checked  
**Trạng thái:** ❌ CHƯA CÓ screen (SPs đã đủ)

### Stored Procedures

| SP HY | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_MaterialQcInfo_HY_get` | `usp_MaterialQcInfo_get` | Riêng HY | ✅ Có |
| `usp_MaterialQcInfo_HY_iud` | `usp_MaterialQcInfo_iud` | Riêng HY | ✅ Có |
| `usp_MaterialQcDetail_HY_get` | `usp_MaterialQcDetail_get` | Riêng HY | ✅ Có |
| `usp_MaterialQcDetail_HY_iud` | `usp_MaterialQcDetail_iud` | Riêng HY | ✅ Có |
| `usp_MaterialQcSampleResult_HY_get` | `usp_MaterialQcSampleResult_get` | Riêng HY | ✅ Có |
| `usp_MaterialQcSampleResult_HY_iud` | `usp_MaterialQcSampleResult_iud` | Riêng HY | ✅ Có |
| `usp_DoChangeMaterialQcToPass_HY` | `usp_DoChangeMaterialQcToPass` | Riêng HY | ✅ Có |
| `usp_DoMakeMaterialIQCDetailList_HY` | `usp_DoMakeMaterialIQCDetailList` | Riêng HY | ✅ Có |
| `usp_DoMakeMaterialQcSampleResult_HY` | `usp_DoMakeMaterialQcSampleResult` | Riêng HY | ✅ Có |
| `usp_DoUpdateMaterialQcInfo_Fail_HY` | `usp_DoUpdateMaterialQcInfo_Fail` | Riêng HY | ✅ Có |
| `usp_DoUpdateMaterialQcInfo_Success_HY` | `usp_DoUpdateMaterialQcInfo_Success` | Riêng HY | ✅ Có |
| `usp_DoSendEmailForDefectReportIQC_HY` | `usp_DoSendEmailForDefectReportIQC` | Riêng HY | ✅ Có |
| `usp_IQcDefectReport_HY_iud` | `usp_IQcDefectReport_iud` | Riêng HY | ✅ Có |
| `usp_DefectReportNoChange_HY_iud` | `usp_DefectReportNoChange_iud` | Riêng HY | ✅ Có |
| `usp_MaterialQcInfoChangeLotNo_HY_iud` | `usp_MaterialQcInfoChangeLotNo_iud` | Riêng HY | ✅ Có |
| `usp_ModifyRevisionsVerFromC220_VVTF4_HY` | `usp_ModifyRevisionsVerFromC220_VVTF4` | Riêng HY | ✅ Có |
| `usp_NCR_Report_HY_iud` | `usp_NCR_Report_iud` | Riêng HY | ✅ Có |
| `usp_QcDefectIQCReport_HY_get` | `usp_QcDefectIQCReport_get` | Riêng HY | ✅ Có |
| `usp_UpdateDefectDetailIQC_VVT_HY` | `usp_UpdateDefectDetailIQC_VVT` | Riêng HY | ✅ Có |
| `usp_GetMaterialQcInfo_ForReport_HY` | `usp_GetMaterialQcInfo_ForReport` | Riêng HY | ✅ Có |
| `usp_DoConfirmCancelQc2` | — | Dùng chung | ✅ Có |
| `usp_CompanyInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_WorkCenterInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_MaterialTypeCode_popup` | — | Dùng chung | ✅ Có |
| `usp_PurchaseMaterialMaster_popup` | — | Dùng chung | ✅ Có |
| `usp_VendorCustomerInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_GetBaseCode_popup` | — | Dùng chung | ✅ Có |
| `usp_GetBaseCodeRemarkFilter_popup` | — | Dùng chung | ✅ Có |
| `usp_GetTestResult_popup` | — | Dùng chung | ✅ Có |
| `usp_DecisionResult_popup` | — | Dùng chung | ✅ Có |
| `usp_ProdWorkerInfo_Popup` | — | Dùng chung | ✅ Có |
| `usp_ProdIInspectionWorkerInfo_Popup` | — | Dùng chung | ✅ Có |
| `usp_ProductGroup_get` | — | Dùng chung | ✅ Có |
| `usp_NameErrorIQC` | — | Dùng chung | ✅ Có |
| `usp_DefectCauseGroup_get` | — | Dùng chung | ✅ Có |
| `usp_DefectCauseGroup_popup` | — | Dùng chung | ✅ Có |

> **Ghi chú:** 7 tên SP trong layout gốc (`usp_DoCancelIQC`, `usp_DoConfirmIQC`, `usp_DoCancelProd`, `usp_DoConfirmProd`, `usp_MaterialIqcDetail_iud`, `usp_MaterialIqcSampleResult_iud`, `usp_DoLossCommInspDoc_VNT`) là **client-side action bindings** — không phải DB SPs, không cần tạo.

### Tables

| Table | Vai trò |
|---|---|
| `STB_MaterialQcInfo` | Thông tin QC nguyên liệu |
| `STB_MaterialQcDetail` | Chi tiết QC |
| `STB_MaterialQcSampleResult` | Kết quả mẫu |
| `STB_MaterialMaster` | Master nguyên liệu |
| `STB_IQcDefectReport` | Báo cáo lỗi IQC |

### Functions

Không dùng function riêng.

---

## 4. B310 → `HY310` — Tạo lệnh sản xuất (Production Order)

**Mô tả:** Create PO  
**Trạng thái:** ❌ CHƯA CÓ screen (SPs đã đủ)

### Stored Procedures

| SP HY | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_ProductionOrderInfo_HY_get` | `usp_ProductionOrderInfo_get` | Riêng HY | ✅ Có |
| `usp_ProductionOrderBom_HY_get` | `usp_ProductionOrderBom_get` | Riêng HY | ✅ Có |
| `usp_ProductionOrderRouting_HY_get` | `usp_ProductionOrderRouting_get` | Riêng HY | ✅ Có |
| `usp_ProductionOrderRouting_HY_iud` | `usp_ProductionOrderRouting_iud` | Riêng HY | ✅ Có |
| `usp_DoFixProductionOrder_HY` | `usp_DoFixProductionOrder` | Riêng HY | ✅ Có |
| `usp_DoCancelPO_HY` | `usp_DoCancelPO` | Riêng HY | ✅ Có |
| `usp_GetMaterialGIForPO_HY` | `usp_GetMaterialGIForPO` | Riêng HY | ✅ Có |
| `usp_DoCreateProductionOrder` | — | Dùng chung (generic) | ✅ Có |
| `usp_BasicRoutingInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_CompanyInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_GetRouteInfoAll_popup` | — | Dùng chung | ✅ Có |
| `usp_ProductionMaterialPopup` | — | Dùng chung | ✅ Có |
| `usp_WorkCenterInfo_popup` | — | Dùng chung | ✅ Có |

> **Ghi chú:** `usp_DoCreateProductionOrder` là SP generic, filter theo parameter `WorkCenterCode`. Không cần tạo `_HY` version.

### Tables

| Table | Vai trò |
|---|---|
| `STB_ProductionOrderInfo` | Lệnh sản xuất (filter `WorkCenterCode = 'VVT_F5'`) |
| `STB_ProductionOrderBom` | BOM theo PO |
| `STB_ProductionOrderRouting` | Routing theo PO |
| `STB_MaterialMaster` | Master nguyên liệu |
| `STB_BasicRoutingInfo` | Master routing |

### Functions

Không dùng function riêng.

---

## 5. B442 → `HY442` — Tạo kế hoạch sản xuất hàng ngày (Electrode)

**Mô tả:** Create Daily Plan  
**Trạng thái:** ❌ CHƯA CÓ screen (SPs đã đủ)

### Stored Procedures

| SP HY | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_DayProdPlan_HY_get` | `usp_DayProdPlan_get` | Riêng HY | ✅ Có |
| `usp_DayProdPlan_HY_iud` | `usp_DayProdPlan_iud` | Riêng HY | ✅ Có |
| `usp_DoCancelDayProdPlan_HY` | `usp_DoCancelDayProdPlan` | Riêng HY | ✅ Có |
| `usp_DoFixDayProdPlan_HY` | `usp_DoFixDayProdPlan` | Riêng HY | ✅ Có |
| `usp_SetInfo_HY_get` | `usp_SetInfo_get` | Riêng HY | ✅ Có |
| `usp_SetInfo_HY_iud_VNT` | `usp_SetInfo_iud_VNT` | Riêng HY | ✅ Có |
| `usp_MainAssemblePartWeight_HY_get` | `usp_MainAssemblePartWeight_get` | Riêng HY | ✅ Có |
| `usp_BomVersion_popup` | — | Dùng chung | ✅ Có |
| `usp_CompanyInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_LineInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_ProductGroup_popup` | — | Dùng chung | ✅ Có |
| `usp_ProductionMaterialPopup` | — | Dùng chung | ✅ Có |
| `usp_RouteInfoForLine_popup` | — | Dùng chung | ✅ Có |
| `usp_ShiftCode_popup` | — | Dùng chung | ✅ Có |
| `usp_WorkCenterInfo_popup` | — | Dùng chung | ✅ Có |

### Tables

| Table | Vai trò |
|---|---|
| `STB_DayProdPlan` | Kế hoạch ngày (filter `WorkCenterCode`, `LineCode`) |
| `STB_SetInfo` | Thông tin Set/Lot |
| `STB_ProductionOrderInfo` | PO liên kết |
| `STB_MaterialMaster` | Master nguyên liệu |
| `STB_LineInfo` | Thông tin dây chuyền |
| `STB_RouteInfo` | Thông tin route |
| `STB_MachineMaster` | Master máy |
| `STB_CompanyInfo` | Thông tin công ty |
| `STB_WorkCenterInfo` | Thông tin nhà máy |

### Functions

| Function | Loại | Vai trò |
|---|---|---|
| `fnGetLocalTime` | Scalar | Chuyển UTC → local time |
| `fnSplitToTable` | Table-valued | Split chuỗi thành bảng |

---

## 6. B470 → `HY470` — Thiết lập công đoạn Mixing (trộn)

**Mô tả:** Set up the Mixing process steps  
**Trạng thái:** ❌ CHƯA CÓ screen (SPs đã đủ)

### Stored Procedures

| SP HY | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_ElectrodeStep_HY_get` | `usp_ElectrodeStep_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeStep_HY_iud` | `usp_ElectrodeStep_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeCommon_HY_get` | `usp_ElectrodeCommon_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeCommon_HY_iud` | `usp_ElectrodeCommon_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeOven_HY_get` | `usp_ElectrodeOven_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeOven_HY_iud` | `usp_ElectrodeOven_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeStep_popup` | — | Dùng chung | ✅ Có |
| `usp_MaterialMasterByMaterialType_popup` | — | Dùng chung | ✅ Có |

### Tables

| Table | Vai trò |
|---|---|
| `STB_ElectrodeStep` | Công đoạn electrode |
| `STB_ElectrodeCommon` | Thông số chung electrode |
| `STB_ElectrodeOven` | Thông số lò sấy |
| `STB_MaterialMaster` | Master nguyên liệu |

### Functions

Không dùng function riêng.

---

## 7. B552 → `HY552` — Kết quả sản xuất electrode từng công đoạn

**Mô tả:** Electrode production results at each stage  
**Trạng thái:** ❌ CHƯA CÓ screen (SPs đã đủ) — Phức tạp nhất (25 SPs riêng HY)

### Stored Procedures

| SP HY | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_ElectrodeCoatingInfo_HY_get` | `usp_ElectrodeCoatingInfo_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeCoatingInfo_HY_iud` | `usp_ElectrodeCoatingInfo_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_get` | `usp_ElectrodeCoatingVisualInspectionInfo_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_iud` | `usp_ElectrodeCoatingVisualInspectionInfo_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeMixInfo_HY_get` | `usp_ElectrodeMixInfo_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeMixInfo_HY_iud` | `usp_ElectrodeMixInfo_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeMixStepInfo_HY_get` | `usp_ElectrodeMixStepInfo_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeMixStepInfo_HY_iud` | `usp_ElectrodeMixStepInfo_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeRollPressingInfo_HY_get` | `usp_ElectrodeRollPressingInfo_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeRollPressingInfo_HY_iud` | `usp_ElectrodeRollPressingInfo_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_get` | `usp_ElectrodeRollPressingVisualInspectionInfo_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud` | `usp_ElectrodeRollPressingVisualInspectionInfo_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeSlittingInfo_HY_get` | `usp_ElectrodeSlittingInfo_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeSlittingInfo_HY_iud` | `usp_ElectrodeSlittingInfo_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeSlittingResult_HY_get` | `usp_ElectrodeSlittingResult_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeSlittingResult_HY_iud` | `usp_ElectrodeSlittingResult_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeWasteInfoNew_HY_iud` | `usp_ElectrodeWasteInfoNew_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeWastePriceNewByBarcode_HY_get` | `usp_ElectrodeWastePriceNewByBarcode_get` | Riêng HY | ✅ Có |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | `usp_ElectrodCoatingInfo_Viscosity_VVT_iud` | Riêng HY | ✅ Có |
| `usp_DoUpdateCoatingBarcodePrintYn_HY` | `usp_DoUpdateCoatingBarcodePrintYn` | Riêng HY | ✅ Có |
| `usp_DoUpdateRollPressBarcodePrintYn_HY` | `usp_DoUpdateRollPressBarcodePrintYn` | Riêng HY | ✅ Có |
| `usp_DoUpdateSlitingBarcodePrintYn_HY` | `usp_DoUpdateSlitingBarcodePrintYn` | Riêng HY | ✅ Có |
| `usp_LocationElectric_HY` | `usp_LocationElectric` | Riêng HY | ✅ Có |
| `usp_test_check_expired_HY` | `usp_test_check_expired` | Riêng HY | ✅ Có |
| `usp_Vietnam_RollPressingSlitting_HY_get` | `usp_Vietnam_RollPressingSlitting_get` | Riêng HY | ✅ Có |
| `usp_RouteInfo_get` | — | Dùng chung (param-based) | ✅ Có |
| `usp_GetBaseCode_popup` | — | Dùng chung | ✅ Có |
| `usp_GetBasicRouteingDetailForRoute_popup` | — | Dùng chung (param-based) | ✅ Có |
| `usp_MaterialMaster_popup` | — | Dùng chung | ✅ Có |
| `usp_ProductMachine_popup` | — | Dùng chung (param-based) | ✅ Có |
| `usp_ProductMachineForRoute_popup` | — | Dùng chung (param-based) | ✅ Có |
| `usp_ProdWorkerInfo_Popup` | — | Dùng chung | ✅ Có |
| `usp_Vietnam_DefectInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_CommonCode_INOUT_popup` | — | Dùng chung | ✅ Có |
| `usp_CommonCode_OKNG_popup` | — | Dùng chung | ✅ Có |
| `usp_CommonCode_OX_LEFT_popup` | — | Dùng chung | ✅ Có |
| `usp_CommonCode_OX_RIGHT_popup` | — | Dùng chung | ✅ Có |
| `usp_CommonCode_YesNo_popup` | — | Dùng chung | ✅ Có |
| `usp_CommonCode_YesNo_PushingYn_popup` | — | Dùng chung | ✅ Có |

### Tables

| Table | Vai trò |
|---|---|
| `STB_ElectrodeCoatingInfo` | Kết quả coating |
| `STB_ElectrodeCoatingVisualInspectionInfo` | Kiểm tra visual coating |
| `STB_ElectrodeMixInfo` | Kết quả mixing |
| `STB_ElectrodeMixStepInfo` | Chi tiết bước mixing |
| `STB_ElectrodeRollPressingInfo` | Kết quả cán |
| `STB_ElectrodeRollPressingVisualInspectionInfo` | Kiểm tra visual cán |
| `STB_ElectrodeSlittingInfo` | Kết quả cắt |
| `STB_ElectrodeSlittingResult` | Kết quả chi tiết cắt |
| `STB_ElectrodeWasteInfo` | Phế liệu electrode |
| `STB_SlittingLocationConfig_VVT` | Cấu hình vị trí cắt |
| `STB_CoatingToSlittingMaster` | Mapping coating→slitting |
| `STB_ProdRouteHist` | Lịch sử route sản xuất |

### Functions

| Function | Loại | Vai trò |
|---|---|---|
| `fnGetElectrodeDensity` | Scalar | Tính mật độ electrode |
| `fnGetElectrodeDensityAvg` | Scalar | Mật độ trung bình |
| `fnGetElectrodeDensityNew` | Scalar | Mật độ (phiên bản mới) |
| `fnGetElectrodeThickness01` | Scalar | Độ dày electrode #1 |
| `fnGetElectrodeThickness02` | Scalar | Độ dày electrode #2 |
| `fnGetElectrodeThickness03` | Scalar | Độ dày electrode #3 |

---

## 8. B802 → `HY802` — Báo cáo kết quả sản xuất electrode

**Mô tả:** Report on electrode production results  
**Trạng thái:** ❌ CHƯA CÓ screen (SPs đã đủ)

### Stored Procedures

| SP HY | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_Vietnam_ElectrodeProdRouteHist_HY_get` | `usp_Vietnam_ElectrodeProdRouteHist_get` | Riêng HY | ✅ Có |
| `usp_Vietnam_ElectrodeDefectHist_HY_get` | `usp_Vietnam_ElectrodeDefectHist_get` | Riêng HY | ✅ Có |
| `usp_CompanyInfo_get` | — | Dùng chung | ✅ Có |
| `usp_GetBaseCode_popup` | — | Dùng chung | ✅ Có |
| `usp_GetBaseCode_popup2` | — | Dùng chung | ✅ Có |
| `usp_vvt_RnDorProduction_popup` | — | Dùng chung | ✅ Có |
| `usp_WorkCenterInfo_popup` | — | Dùng chung | ✅ Có |

### Tables

| Table | Vai trò |
|---|---|
| `STB_ProdRouteHist` | Lịch sử route sản xuất |
| `STB_ElectrodeCoatingInfo` | Data coating (ref) |
| `STB_ElectrodeRollPressingInfo` | Data cán (ref) |
| `STB_ElectrodeSlittingInfo` | Data cắt (ref) |
| `STB_ElectrodeMixInfo` | Data mixing (ref) |

### Functions

| Function | Loại | Vai trò |
|---|---|---|
| `fnGetJobDateShiftTime` | Scalar | Lấy ca/ngày theo thời gian |

---

## 9. C460 → `HY460` — QC kiểm tra electrode nhập kho

**Mô tả:** QC workers inspect the incoming electrodes  
**Trạng thái:** ❌ CHƯA CÓ screen (SPs đã đủ)

### Stored Procedures

| SP HY | SP Gốc | Loại | Trạng thái |
|---|---|---|---|
| `usp_GetElectrodeInspectionHistoryForBarcode_HY` | `usp_GetElectrodeInspectionHistoryForBarcode` | Riêng HY | ✅ Có |
| `usp_DoAddCommInspMeasureHistForBarcode_HY` | `usp_DoAddCommInspMeasureHistForBarcode` | Riêng HY | ✅ Có |
| `usp_DoFinishCommInspDoc_HY` | `usp_DoFinishCommInspDoc` | Riêng HY | ✅ Có |
| `usp_DoFinishCommInspDoc_VNT_HY` | `usp_DoFinishCommInspDoc_VNT` | Riêng HY | ✅ Có |
| `usp_DoLossElectrodeProcess_HY_iud` | `usp_DoLossElectrodeProcess_iud` | Riêng HY | ✅ Có |
| `usp_ElectrodeCoatingInfo_HY_get` | `usp_ElectrodeCoatingInfo_get` | Riêng HY | ✅ Có |
| `usp_ElectrodeDivision_popup_HY` | `usp_ElectrodeDivision_popup` | Riêng HY | ✅ Có |
| `usp_DoLossCommInspDoc_VNT` | — | Dùng chung (generic) | ✅ Có |
| `usp_CommInspSelectItem_popup` | — | Dùng chung | ✅ Có |
| `usp_CommonCode_OKNG_popup` | — | Dùng chung | ✅ Có |
| `usp_CompanyInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_DefectInfo_popup` | — | Dùng chung (param-based) | ✅ Có |
| `usp_LineInfo_popup` | — | Dùng chung | ✅ Có |
| `usp_ProdWorkerInfo_Popup` | — | Dùng chung | ✅ Có |
| `usp_RouteInfoForLine_popup` | — | Dùng chung | ✅ Có |
| `usp_WorkCenterInfo_popup` | — | Dùng chung | ✅ Có |

### Tables

| Table | Vai trò |
|---|---|
| `STB_CommInspDocHistory` | Lịch sử kiểm tra |
| `STB_CommInspDocItem` | Hạng mục kiểm tra |
| `STB_CommInspMeasureHist` | Kết quả đo |
| `STB_ElectrodeCoatingInfo` | Data coating (ref) |
| `STB_ProdRouteHist` | Lịch sử route |

### Functions

Không dùng function riêng.

---

## Phụ lục: Tổng hợp DB Objects dùng chung (không cần tạo _HY)

### Tables dùng chung (16 bảng)

Tất cả bảng dưới đây đều đã tồn tại. Dữ liệu HY được phân biệt bằng `WorkCenterCode = 'VVT_F5'` hoặc `LineCode LIKE 'VVHY%'`.

| Table | Dùng bởi màn |
|---|---|
| `STB_ProductionOrderInfo` | B310, B442 |
| `STB_ProductionOrderBom` | B310 |
| `STB_ProductionOrderRouting` | B310 |
| `STB_DayProdPlan` | B442 |
| `STB_SetInfo` | B442 |
| `STB_MaterialMaster` | Tất cả |
| `STB_MaterialQcInfo` | C220 |
| `STB_MaterialQcDetail` | C220 |
| `STB_QcInspectionGroup` | C121 |
| `STB_QcInspectionItem` | C121, C122 |
| `STB_ElectrodeCoatingInfo` | B552, B802, C460 |
| `STB_ElectrodeSlittingResult` | B552 |
| `STB_ProdRouteHist` | B802, C460 |
| `STB_CommInspDocHistory` | C460 |
| `STB_LineInfo` | B442, C460 |
| `STB_CompanyInfo` | B310, B442, B802 |

### Functions dùng chung (10 functions)

| Function | Loại | Dùng bởi |
|---|---|---|
| `fnGetJobDateShiftTime` | Scalar | B442, B802 |
| `fnGetLocalTime` | Scalar | B442 |
| `fnGetElectrodeDensity` | Scalar | B552 |
| `fnGetElectrodeDensityAvg` | Scalar | B552 |
| `fnGetElectrodeDensityNew` | Scalar | B552 |
| `fnGetElectrodeThickness01` | Scalar | B552 |
| `fnGetElectrodeThickness02` | Scalar | B552 |
| `fnGetElectrodeThickness03` | Scalar | B552 |
| `fn_split_string` | Table-valued | Nhiều SPs |
| `fnSplitToTable` | Table-valued | B442 |

### Lưu ý: Hưng Yên chưa có Electrode Lines

HY hiện có 15 lines: 10 Cell (`VVHYC-01`→`10`) + 5 Module (`VVHYMD-01`→`05`).  
**Chưa có Electrode lines** → cần tạo (vd: `VVHYEL-01`) trước khi dùng B442/B470/B552/B802/C460.
