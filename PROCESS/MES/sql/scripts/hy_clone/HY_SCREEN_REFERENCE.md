# Danh Sách 9 Màn Hình HY — Phân Loại: Dùng Riêng vs Dùng Chung

> **Ngày tạo:** 2026-06-23 (Updated: phân loại chi tiết dựa trên so sánh SP content)  
> **Nhà máy:** Hưng Yên (VVT_F5)  
> **Phương pháp:** So sánh `LEN(definition)` giữa SP gốc và SP `_HY` + kiểm tra hardcode factory code

---

## Quy ước phân loại

| Phân loại | Ý nghĩa | Tiêu chí |
|---|---|---|
| 🟢 **DÙNG CHUNG** | Dùng SP gốc, không cần `_HY` | Size diff < 50 chars (chỉ đổi tên SP) |
| 🟡 **MINOR DIFF** | Có chỉnh sửa nhỏ, nhưng logic cốt lõi giống | Size diff 50-500 chars |
| 🔴 **PHẢI TÁCH RIÊNG** | Logic khác biệt đáng kể | Size diff > 500 chars |
| 🔵 **HY-ONLY** | SP chỉ tồn tại cho HY, không có bản gốc | Không tìm thấy original |
| ⚪ **POPUP/SHARED** | SP dùng chung (popup, utility) | Không có `_HY` version |

---

## Tóm tắt tổng hợp

| Phân loại | Số lượng SPs | Ghi chú |
|---|---|---|
| 🟢 DÙNG CHUNG (CAN_SHARE) | **30 SPs** | Nội dung gần giống gốc — có thể dùng SP gốc |
| 🟡 MINOR DIFF | **20 SPs** | Cần review: có thể merge hoặc giữ riêng |
| 🔴 PHẢI TÁCH RIÊNG (MUST_SEPARATE) | **12 SPs** | Logic khác biệt lớn — BẮT BUỘC dùng `_HY` |
| 🔵 HY-ONLY | **5 SPs** | Chỉ HY mới có |
| ⚪ POPUP/SHARED | **36+ SPs** | Popup/utility dùng chung tất cả nhà máy |
| **Tables** | **39 bảng** | **100% dùng chung** (filter WorkCenterCode) |
| **Functions** | **10 functions** | **100% dùng chung** |

---

## 1. C121 → `C121_HY` — Quản lý nhóm kiểm tra & hạng mục kiểm tra ✅

**Trạng thái:** ĐÃ CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_QcInspectionGroup_HY_get` | `usp_QcInspectionGroup_get` | 231 | 🟡 MINOR DIFF |
| `usp_QcInspectionGroup_HY_iud` | `usp_QcInspectionGroup_iud` | 196 | 🟡 MINOR DIFF |
| `usp_QcInspectionGroup_HY_popup` | `usp_QcInspectionGroup_popup` | 3 | 🟢 DÙNG CHUNG |
| `usp_QcInspectionItem_HY_get` | `usp_QcInspectionItem_get` | 234 | 🟡 MINOR DIFF |
| `usp_QcInspectionItem_HY_iud` | `usp_QcInspectionItem_iud` | 196 | 🟡 MINOR DIFF |
| `usp_GetAql_popup` | — | — | ⚪ SHARED |
| `usp_GetInspectionLevel_popup` | — | — | ⚪ SHARED |
| `usp_GetInspectionType_popup` | — | — | ⚪ SHARED |

**Kết luận C121:** 4 SPs MINOR DIFF (giữ riêng an toàn), 1 SP dùng chung được, 3 popup shared.

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_CommInspSelectGroup` | Nhóm kiểm tra |
| `STB_CommInspSelectItem` | Hạng mục kiểm tra |
| `STB_QcInspectionGroup` | Nhóm QC |
| `STB_QcInspectionItem` | Hạng mục QC |

---

## 2. C122 → `C122_HY` — Thiết lập tiêu chuẩn kiểm tra nguyên liệu ✅

**Trạng thái:** ĐÃ CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_MaterialQcInspectionItem_ByMaterial_HY_get` | `usp_MaterialQcInspectionItem_ByMaterial_get` | 1478 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_MaterialQcInspectionItem_HY_iud` | `usp_MaterialQcInspectionItem_iud` | 322 | 🟡 MINOR DIFF |
| `usp_MaterialMaster_popup` | — | — | ⚪ SHARED |

**Kết luận C122:** 1 SP PHẢI tách riêng (logic query khác biệt lớn), 1 minor diff, 1 shared.

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_MaterialQcInspectionItem` | Tiêu chuẩn QC theo material |
| `STB_MaterialMaster` | Master nguyên liệu |
| `STB_QcInspectionItem` | Hạng mục QC (ref) |

---

## 3. C220 → `HY220` — IQC Confirmation ❌ CHƯA CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_MaterialQcInfo_HY_get` | `usp_MaterialQcInfo_get` | 2 | 🟢 DÙNG CHUNG |
| `usp_MaterialQcInfo_HY_iud` | `usp_MaterialQcInfo_iud` | 3 | 🟢 DÙNG CHUNG |
| `usp_MaterialQcDetail_HY_get` | `usp_MaterialQcDetail_get` | 626 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_MaterialQcDetail_HY_iud` | `usp_MaterialQcDetail_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_MaterialQcSampleResult_HY_get` | `usp_MaterialQcSampleResult_get` | 2213 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_MaterialQcSampleResult_HY_iud` | `usp_MaterialQcSampleResult_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_DoChangeMaterialQcToPass_HY` | `usp_DoChangeMaterialQcToPass` | 3 | 🟢 DÙNG CHUNG |
| `usp_DoMakeMaterialIQCDetailList_HY` | `usp_DoMakeMaterialIQCDetailList` | 9 | 🟢 DÙNG CHUNG |
| `usp_DoMakeMaterialQcSampleResult_HY` | `usp_DoMakeMaterialQcSampleResult` | 3 | 🟢 DÙNG CHUNG |
| `usp_DoUpdateMaterialQcInfo_Fail_HY` | `usp_DoUpdateMaterialQcInfo_Fail` | 5 | 🟢 DÙNG CHUNG |
| `usp_DoUpdateMaterialQcInfo_Success_HY` | `usp_DoUpdateMaterialQcInfo_Success` | 3 | 🟢 DÙNG CHUNG |
| `usp_DoSendEmailForDefectReportIQC_HY` | `usp_DoSendEmailForDefectReportIQC` | 248 | 🟡 MINOR DIFF |
| `usp_IQcDefectReport_HY_iud` | `usp_IQcDefectReport_iud` | 7 | 🟢 DÙNG CHUNG |
| `usp_DefectReportNoChange_HY_iud` | `usp_DefectReportNoChange_iud` | 3 | 🟢 DÙNG CHUNG |
| `usp_MaterialQcInfoChangeLotNo_HY_iud` | `usp_MaterialQcInfoChangeLotNo_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_ModifyRevisionsVerFromC220_VVTF4_HY` | `usp_ModifyRevisionsVerFromC220_VVTF4` | 1 | 🟢 DÙNG CHUNG |
| `usp_NCR_Report_HY_iud` | `usp_NCR_Report_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_QcDefectIQCReport_HY_get` | `usp_QcDefectIQCReport_get` | 3 | 🟢 DÙNG CHUNG |
| `usp_UpdateDefectDetailIQC_VVT_HY` | `usp_UpdateDefectDetailIQC_VVT` | 9 | 🟢 DÙNG CHUNG |
| `usp_GetMaterialQcInfo_ForReport_HY` | `usp_GetMaterialQcInfo_ForReport` | 1 | 🟢 DÙNG CHUNG |
| Popups (11 SPs) | — | — | ⚪ SHARED |

**Kết luận C220:** 16/20 SPs riêng HY thực ra **DÙNG CHUNG ĐƯỢC** (chỉ khác tên). Chỉ 2 SPs **PHẢI tách riêng** (`_Detail_get` và `_SampleResult_get`), 1 minor diff (`SendEmail`).

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_MaterialQcInfo` | Thông tin QC nguyên liệu |
| `STB_MaterialQcDetail` | Chi tiết QC |
| `STB_MaterialQcSampleResult` | Kết quả mẫu |
| `STB_MaterialMaster` | Master nguyên liệu |
| `STB_IQcDefectReport` | Báo cáo lỗi IQC |

---

## 4. B310 → `HY310` — Tạo PO ❌ CHƯA CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_ProductionOrderInfo_HY_get` | `usp_ProductionOrderInfo_get` | 911 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_ProductionOrderBom_HY_get` | `usp_ProductionOrderBom_get` | 344 | 🟡 MINOR DIFF |
| `usp_ProductionOrderRouting_HY_get` | `usp_ProductionOrderRouting_get` | 276 | 🟡 MINOR DIFF |
| `usp_ProductionOrderRouting_HY_iud` | `usp_ProductionOrderRouting_iud` | 679 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_DoFixProductionOrder_HY` | `usp_DoFixProductionOrder` | 298 | 🟡 MINOR DIFF |
| `usp_DoCancelPO_HY` | `usp_DoCancelPO` | 481 | 🟡 MINOR DIFF |
| `usp_GetMaterialGIForPO_HY` | `usp_GetMaterialGIForPO` | 296 | 🟡 MINOR DIFF |
| Popups (5 SPs) | — | — | ⚪ SHARED |

**Kết luận B310:** 2 SPs **PHẢI tách riêng**, 5 SPs minor diff (giữ riêng an toàn), 5 popups shared.

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_ProductionOrderInfo` | Lệnh sản xuất |
| `STB_ProductionOrderBom` | BOM theo PO |
| `STB_ProductionOrderRouting` | Routing theo PO |
| `STB_MaterialMaster` | Master nguyên liệu |
| `STB_BasicRoutingInfo` | Master routing |

---

## 5. B442 → `HY442` — Daily Plan Electrode ❌ CHƯA CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_DayProdPlan_HY_get` | `usp_DayProdPlan_get` | 3 | 🟢 DÙNG CHUNG |
| `usp_DayProdPlan_HY_iud` | `usp_DayProdPlan_iud` | 1473 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_DoCancelDayProdPlan_HY` | `usp_DoCancelDayProdPlan` | 329 | 🟡 MINOR DIFF |
| `usp_DoFixDayProdPlan_HY` | `usp_DoFixDayProdPlan` | 330 | 🟡 MINOR DIFF |
| `usp_SetInfo_HY_get` | `usp_SetInfo_get` | 175 | 🟡 MINOR DIFF |
| `usp_SetInfo_HY_iud_VNT` | `usp_SetInfo_iud_VNT` | 2526 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_MainAssemblePartWeight_HY_get` | `usp_MainAssemblePartWeight_get` | 1 | 🟢 DÙNG CHUNG |
| Popups (8 SPs) | — | — | ⚪ SHARED |

**Kết luận B442:** 2 SPs dùng chung, 2 SPs **PHẢI tách riêng** (logic IUD khác lớn), 3 minor diff, 8 shared.

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_DayProdPlan` | Kế hoạch ngày |
| `STB_SetInfo` | Thông tin Set/Lot |
| `STB_ProductionOrderInfo` | PO liên kết |
| `STB_MaterialMaster` | Master nguyên liệu |
| `STB_LineInfo` | Dây chuyền |
| `STB_RouteInfo` | Route |
| `STB_MachineMaster` | Máy |
| `STB_CompanyInfo` | Công ty |
| `STB_WorkCenterInfo` | Nhà máy |

### Functions (dùng chung)

| Function | Vai trò |
|---|---|
| `fnGetLocalTime` | Chuyển UTC → local |
| `fnSplitToTable` | Split chuỗi |

---

## 6. B470 → `HY470` — Electrode Process Steps (Mixing) ❌ CHƯA CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_ElectrodeStep_HY_get` | `usp_ElectrodeStep_get` | 306 | 🟡 MINOR DIFF |
| `usp_ElectrodeStep_HY_iud` | `usp_ElectrodeStep_iud` | 880 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_ElectrodeCommon_HY_get` | `usp_ElectrodeCommon_get` | 397 | 🟡 MINOR DIFF |
| `usp_ElectrodeCommon_HY_iud` | `usp_ElectrodeCommon_iud` | 1584 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_ElectrodeOven_HY_get` | `usp_ElectrodeOven_get` | 281 | 🟡 MINOR DIFF |
| `usp_ElectrodeOven_HY_iud` | `usp_ElectrodeOven_iud` | 818 | 🔴 PHẢI TÁCH RIÊNG |
| `usp_ElectrodeStep_popup` | — | — | ⚪ SHARED |
| `usp_MaterialMasterByMaterialType_popup` | — | — | ⚪ SHARED |

**Kết luận B470:** 3 SPs `_iud` **PHẢI tách riêng** (logic insert/update/delete khác), 3 SPs `_get` minor diff, 2 shared.

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_ElectrodeStep` | Công đoạn electrode |
| `STB_ElectrodeCommon` | Thông số chung |
| `STB_ElectrodeOven` | Thông số lò sấy |
| `STB_MaterialMaster` | Master nguyên liệu |

---

## 7. B552 → `HY552` — Electrode Measure Results ❌ CHƯA CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_ElectrodeCoatingInfo_HY_get` | `usp_ElectrodeCoatingInfo_get` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeCoatingInfo_HY_iud` | `usp_ElectrodeCoatingInfo_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_get` | `_get` | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_iud` | `_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeMixInfo_HY_get` | `_get` | 2 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeMixInfo_HY_iud` | `_iud` | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeMixStepInfo_HY_get` | `_get` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeMixStepInfo_HY_iud` | `_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeRollPressingInfo_HY_get` | `_get` | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeRollPressingInfo_HY_iud` | `_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_get` | `_get` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud` | `_iud` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeSlittingInfo_HY_get` | `_get` | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeSlittingInfo_HY_iud` | `_iud` | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeSlittingResult_HY_get` | `_get` | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeSlittingResult_HY_iud` | `_iud` | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeWasteInfoNew_HY_iud` | `_iud` | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeWastePriceNewByBarcode_HY_get` | `_get` | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | `_iud` | 3 | 🟢 DÙNG CHUNG |
| `usp_DoUpdateCoatingBarcodePrintYn_HY` | original | 3 | 🟢 DÙNG CHUNG |
| `usp_DoUpdateRollPressBarcodePrintYn_HY` | original | 3 | 🟢 DÙNG CHUNG |
| `usp_DoUpdateSlitingBarcodePrintYn_HY` | original | 3 | 🟢 DÙNG CHUNG |
| `usp_LocationElectric_HY` | original | 9 | 🟢 DÙNG CHUNG |
| `usp_test_check_expired_HY` | original | 1 | 🟢 DÙNG CHUNG |
| `usp_Vietnam_RollPressingSlitting_HY_get` | original | 2 | 🟢 DÙNG CHUNG |
| Popups (8+ SPs) | — | — | ⚪ SHARED |

**Kết luận B552: 25/25 SPs riêng HY thực chất DÙNG CHUNG ĐƯỢC** — tất cả chỉ khác tên SP (diff 1-9 chars). Đây là màn phức tạp nhất nhưng SPs **hoàn toàn giống nhau**.

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_ElectrodeCoatingInfo` | Kết quả coating |
| `STB_ElectrodeCoatingVisualInspectionInfo` | Visual coating |
| `STB_ElectrodeMixInfo` | Kết quả mixing |
| `STB_ElectrodeMixStepInfo` | Chi tiết mixing |
| `STB_ElectrodeRollPressingInfo` | Kết quả cán |
| `STB_ElectrodeRollPressingVisualInspectionInfo` | Visual cán |
| `STB_ElectrodeSlittingInfo` | Kết quả cắt |
| `STB_ElectrodeSlittingResult` | Chi tiết cắt |
| `STB_ElectrodeWasteInfo` | Phế liệu |
| `STB_SlittingLocationConfig_VVT` | Vị trí cắt |
| `STB_CoatingToSlittingMaster` | Mapping coating→slitting |
| `STB_ProdRouteHist` | Lịch sử route |

### Functions (dùng chung)

| Function | Vai trò |
|---|---|
| `fnGetElectrodeDensity` | Mật độ electrode |
| `fnGetElectrodeDensityAvg` | Mật độ TB |
| `fnGetElectrodeDensityNew` | Mật độ (v2) |
| `fnGetElectrodeThickness01` | Độ dày #1 |
| `fnGetElectrodeThickness02` | Độ dày #2 |
| `fnGetElectrodeThickness03` | Độ dày #3 |

---

## 8. B802 → `HY802` — Báo cáo sản xuất electrode ❌ CHƯA CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_Vietnam_ElectrodeProdRouteHist_HY_get` | `_get` | 57 | 🟡 MINOR DIFF |
| `usp_Vietnam_ElectrodeDefectHist_HY_get` | `_get` | 1 | 🟢 DÙNG CHUNG |
| Popups (5 SPs) | — | — | ⚪ SHARED |

**Kết luận B802:** 1 SP dùng chung, 1 minor diff, 5 shared. Rất đơn giản.

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_ProdRouteHist` | Lịch sử route |
| `STB_ElectrodeCoatingInfo` | Data coating |
| `STB_ElectrodeRollPressingInfo` | Data cán |
| `STB_ElectrodeSlittingInfo` | Data cắt |
| `STB_ElectrodeMixInfo` | Data mixing |

### Functions (dùng chung)

| Function | Vai trò |
|---|---|
| `fnGetJobDateShiftTime` | Lấy ca/ngày |

---

## 9. C460 → `HY460` — QC Electrode Inspection ❌ CHƯA CÓ screen

| SP HY | SP Gốc | Size Diff | Phân loại |
|---|---|---|---|
| `usp_GetElectrodeInspectionHistoryForBarcode_HY` | original | 1 | 🟢 DÙNG CHUNG |
| `usp_DoAddCommInspMeasureHistForBarcode_HY` | original | 3 | 🟢 DÙNG CHUNG |
| `usp_DoFinishCommInspDoc_HY` | original | 3 | 🟢 DÙNG CHUNG |
| `usp_DoFinishCommInspDoc_VNT_HY` | original | 3 | 🟢 DÙNG CHUNG |
| `usp_DoLossElectrodeProcess_HY_iud` | original | 3 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeCoatingInfo_HY_get` | original | 1 | 🟢 DÙNG CHUNG |
| `usp_ElectrodeDivision_popup_HY` | original | 3 | 🟢 DÙNG CHUNG |
| Popups (8 SPs) | — | — | ⚪ SHARED |

**Kết luận C460: 7/7 SPs riêng HY DÙNG CHUNG ĐƯỢC** — tất cả chỉ khác tên SP.

### Tables (dùng chung)

| Table | Vai trò |
|---|---|
| `STB_CommInspDocHistory` | Lịch sử kiểm tra |
| `STB_CommInspDocItem` | Hạng mục kiểm tra |
| `STB_CommInspMeasureHist` | Kết quả đo |
| `STB_ElectrodeCoatingInfo` | Data coating |
| `STB_ProdRouteHist` | Lịch sử route |

---

## Phụ lục A: 🔴 Danh sách 12 SPs PHẢI TÁCH RIÊNG (MUST_SEPARATE)

Các SP này có logic khác biệt **đáng kể** so với bản gốc — **BẮT BUỘC dùng `_HY`**:

| # | SP HY | Size Diff | Màn hình |
|---|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_ByMaterial_HY_get` | 1478 | C122 |
| 2 | `usp_MaterialQcDetail_HY_get` | 626 | C220 |
| 3 | `usp_MaterialQcSampleResult_HY_get` | 2213 | C220 |
| 4 | `usp_ProductionOrderInfo_HY_get` | 911 | B310 |
| 5 | `usp_ProductionOrderRouting_HY_iud` | 679 | B310 |
| 6 | `usp_DayProdPlan_HY_iud` | 1473 | B442 |
| 7 | `usp_SetInfo_HY_iud_VNT` | 2526 | B442 |
| 8 | `usp_ElectrodeStep_HY_iud` | 880 | B470 |
| 9 | `usp_ElectrodeCommon_HY_iud` | 1584 | B470 |
| 10 | `usp_ElectrodeOven_HY_iud` | 818 | B470 |
| 11 | `usp_DoAddCommInspMeasureHistForBarcode_HY_TEST` | 4475 | (test) |
| 12 | `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | (large) | B552 |

---

## Phụ lục B: 🟢 Danh sách 30 SPs CÓ THỂ DÙNG CHUNG

Các SP `_HY` này gần như **giống hệt** bản gốc (chỉ khác 1-9 chars = tên SP):

| # | SP HY | Size Diff | Màn hình |
|---|---|---|---|
| 1 | `usp_MaterialQcInfo_HY_get` | 2 | C220 |
| 2 | `usp_MaterialQcInfo_HY_iud` | 3 | C220 |
| 3 | `usp_MaterialQcDetail_HY_iud` | 1 | C220 |
| 4 | `usp_MaterialQcSampleResult_HY_iud` | 1 | C220 |
| 5 | `usp_DoChangeMaterialQcToPass_HY` | 3 | C220 |
| 6 | `usp_DoMakeMaterialIQCDetailList_HY` | 9 | C220 |
| 7 | `usp_DoMakeMaterialQcSampleResult_HY` | 3 | C220 |
| 8 | `usp_DoUpdateMaterialQcInfo_Fail_HY` | 5 | C220 |
| 9 | `usp_DoUpdateMaterialQcInfo_Success_HY` | 3 | C220 |
| 10 | `usp_IQcDefectReport_HY_iud` | 7 | C220 |
| 11 | `usp_DefectReportNoChange_HY_iud` | 3 | C220 |
| 12 | `usp_MaterialQcInfoChangeLotNo_HY_iud` | 1 | C220 |
| 13 | `usp_ModifyRevisionsVerFromC220_VVTF4_HY` | 1 | C220 |
| 14 | `usp_NCR_Report_HY_iud` | 1 | C220 |
| 15 | `usp_QcDefectIQCReport_HY_get` | 3 | C220 |
| 16 | `usp_UpdateDefectDetailIQC_VVT_HY` | 9 | C220 |
| 17 | `usp_GetMaterialQcInfo_ForReport_HY` | 1 | C220 |
| 18 | `usp_DayProdPlan_HY_get` | 3 | B442 |
| 19 | `usp_MainAssemblePartWeight_HY_get` | 1 | B442 |
| 20-44 | Toàn bộ B552 SPs (25 SPs) | 1-9 | B552 |
| 45 | `usp_Vietnam_ElectrodeDefectHist_HY_get` | 1 | B802 |
| 46-52 | Toàn bộ C460 SPs (7 SPs) | 1-3 | C460 |

---

## Phụ lục C: 🔵 SPs Chỉ HY Mới Có (NO_ORIGINAL_FOUND)

| SP | Size | Mô tả |
|---|---|---|
| `usp_GetMaterialOQcInfo_HY_get` | 15581 | OQC cho HY (không dùng trong 9 màn) |
| `usp_MaterialQcInspectionItemByMaterial_HY_get` | 3709 | Version 2 (không dùng trong 9 màn) |
| `usp_VN_Add_FinishGood_HY_New` | 1832 | Thành phẩm HY |
| `usp_VN_IMPORTFINISHEDGOOD_HY_New` | 4475 | Import thành phẩm HY |
| `usp_VN_Update_GoodFinish_HY_New` | 765 | Update thành phẩm HY |

---

## Phụ lục D: Tables & Functions — 100% DÙNG CHUNG

Không có table hay function nào cần tạo riêng cho HY. Tất cả dùng chung, phân biệt data bằng:
- `WorkCenterCode = 'VVT_F5'`
- `LineCode LIKE 'VVHY%'`
- `CompanyCode` parameter

### Lưu ý quan trọng
**Hưng Yên chưa có Electrode Lines** trong `STB_LineInfo`. Cần tạo trước khi dùng B442/B470/B552/B802/C460.
