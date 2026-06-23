# Danh Sách 9 Màn Hình HY — Plan & Hiện Trạng Toàn Diện

> **Ngày cập nhật:** 2026-06-23 21:00  
> **Nhà máy:** Hưng Yên (VVT_F5)  
> **DB verified:** SmartFactoryV2 + SmartFramework

---

## Tổng quan hiện trạng

### Menu Structure (đã có)

```
Vietnam_TOP_MENU
└── HungYenFactory (HY00000)
    ├── QC_HY (HY000001)             ← 9 screens con đã có
    ├── Production_HY (HY000002)     ← 2 screens con đã có
    ├── MaterialWarehouseHY (HY000003) ← 6 screens con đã có
    ├── ElectrodeHY (HY000004)       ← 0 screens con ⚠️
    └── PriceAndMateralCode (HY000005) ← 1 screen con đã có
```

### Tổng quan 9 màn hình

| # | Yêu cầu | Gốc | Hiện trạng | Hành động |
|---|---|---|---|---|
| 1 | C121 - Manage inspection groups | C121 | ✅ `C121_HY` đầy đủ (Screen+Layout+Objects+Perm) | **DÙNG LẠI** |
| 2 | C122 - Material inspection criteria | C122 | ✅ `C122_HY` đầy đủ (Screen+Layout+Objects+Perm) | **DÙNG LẠI** |
| 3 | C220 - IQC Confirmation | C220 | ❌ Chưa có screen, SPs _HY đầy đủ | **TẠO MỚI** → `HY220` |
| 4 | B310 - Create PO | B310 | ❌ Chưa có. (HY311 = PO Electrode, khác B310) | **TẠO MỚI** → `HY310` |
| 5 | B442 - Daily Plan Electrode | B442 | ❌ Chưa có screen, SPs _HY đầy đủ | **TẠO MỚI** → `HY442` |
| 6 | B470 - Mixing Process Steps | B470 | ❌ Chưa có screen, SPs _HY đầy đủ | **TẠO MỚI** → `HY470` |
| 7 | B552 - Electrode Measure Results | B552 | ❌ Chưa có screen, SPs _HY đầy đủ | **TẠO MỚI** → `HY552` |
| 8 | B802 - Electrode Report | B802 | ❌ Chưa có screen, SPs _HY đầy đủ | **TẠO MỚI** → `HY802` |
| 9 | C460 - Electrode QC Inspection | C460 | ❌ Chưa có. (HY443 = CommInsp general, khác C460) | **TẠO MỚI** → `HY460` |

### Prerequisite: Electrode Lines ⚠️

HY hiện có **15 lines** (10 Cell + 5 Module), **CHƯA CÓ Electrode lines**.  
Cần tạo (vd: `VVHYEL-01`) trong `STB_LineInfo` trước khi dùng B442/B470/B552/B802/C460.  
Tham khảo Bắc Ninh: `ElectrodeBN`, `VVC-ELECTRODE-LINE`.

---

## Screens đã có sẵn (DÙNG LẠI - Không cần làm gì)

### 1. C121 → `C121_HY` (TCode: `C121_HY`) ✅

**Chức năng:** Quản lý nhóm kiểm tra & hạng mục kiểm tra  
**Parent:** `QC_HY` | **Layout:** 287,535 chars | **SP Objects:** 4 | **Permission:** Admin ✅

| SP trong layout | Loại | So với gốc |
|---|---|---|
| `usp_QcInspectionGroup_HY_get` | Riêng HY | 🟡 Minor diff (231 chars) |
| `usp_QcInspectionGroup_HY_iud` | Riêng HY | 🟡 Minor diff (196 chars) |
| `usp_QcInspectionGroup_HY_popup` | Riêng HY | 🟢 Giống gốc (3 chars) |
| `usp_QcInspectionItem_HY_get` | Riêng HY | 🟡 Minor diff (234 chars) |
| `usp_QcInspectionItem_HY_iud` | Riêng HY | 🟡 Minor diff (196 chars) |
| `usp_GetAql_popup` | Dùng chung | ⚪ Shared |
| `usp_GetInspectionLevel_popup` | Dùng chung | ⚪ Shared |
| `usp_GetInspectionType_popup` | Dùng chung | ⚪ Shared |

**Tables:** `STB_QcInspectionGroup`, `STB_QcInspectionItem`, `STB_CommInspSelectGroup`, `STB_CommInspSelectItem` — dùng chung

---

### 2. C122 → `C122_HY` (TCode: `C122_HY`) ✅

**Chức năng:** Thiết lập tiêu chuẩn kiểm tra nguyên liệu  
**Parent:** `QC_HY` | **Layout:** 680,498 chars | **SP Objects:** 2 | **Permission:** Admin ✅

| SP trong layout | Loại | So với gốc |
|---|---|---|
| `usp_MaterialQcInspectionItem_ByMaterial_HY_get` | Riêng HY | 🔴 Khác lớn (1478 chars) — PHẢI riêng |
| `usp_MaterialQcInspectionItem_HY_iud` | Riêng HY | 🟡 Minor diff (322 chars) |
| `usp_MaterialMaster_popup` | Dùng chung | ⚪ Shared |

**Tables:** `STB_MaterialQcInspectionItem`, `STB_MaterialMaster`, `STB_QcInspectionItem` — dùng chung

---

## Screens cần TẠO MỚI (7 screens)

### 3. C220 → `HY220` — IQC Confirmation

**Clone từ:** `MaterialIqcInfoSampleManagement` (C220)  
**Layout gốc:** 2,371,987 chars | **Parent HY:** `QC_HY`

#### Cần tạo:
- [x] SPs _HY: 20 SPs — **ĐÃ ĐỦ** trong DB
- [ ] Screen registration: `STB_ScreenInfo` → TCode `HY220`, Name `MaterialIqcInfoSampleManagement_HY`
- [ ] Layout clone: `STB_ScreenLayoutInfo` → clone + replace SP names
- [ ] Screen objects: `STB_ScreenObjects` → ~51 objects
- [ ] Permission: `STB_UserTypeBasicPermission` → Admin

#### SPs — Phân loại chi tiết:

| SP HY | So với gốc | Hành động |
|---|---|---|
| `usp_MaterialQcInfo_HY_get` | 🟢 Giống gốc (2 chars) | Dùng chung được nhưng _HY đã có |
| `usp_MaterialQcInfo_HY_iud` | 🟢 Giống gốc (3 chars) | Dùng chung được nhưng _HY đã có |
| `usp_MaterialQcDetail_HY_get` | 🔴 Khác lớn (626 chars) | **PHẢI dùng _HY** |
| `usp_MaterialQcDetail_HY_iud` | 🟢 Giống gốc (1 char) | Dùng chung được nhưng _HY đã có |
| `usp_MaterialQcSampleResult_HY_get` | 🔴 Khác lớn (2213 chars) | **PHẢI dùng _HY** |
| `usp_MaterialQcSampleResult_HY_iud` | 🟢 Giống gốc (1 char) | Dùng chung được nhưng _HY đã có |
| `usp_DoChangeMaterialQcToPass_HY` | 🟢 Giống (3 chars) | Dùng chung được nhưng _HY đã có |
| `usp_DoMakeMaterialIQCDetailList_HY` | 🟢 Giống (9 chars) | Dùng chung được nhưng _HY đã có |
| `usp_DoMakeMaterialQcSampleResult_HY` | 🟢 Giống (3 chars) | Dùng chung được nhưng _HY đã có |
| `usp_DoUpdateMaterialQcInfo_Fail_HY` | 🟢 Giống (5 chars) | Dùng chung được nhưng _HY đã có |
| `usp_DoUpdateMaterialQcInfo_Success_HY` | 🟢 Giống (3 chars) | Dùng chung được nhưng _HY đã có |
| `usp_DoSendEmailForDefectReportIQC_HY` | 🟡 Minor diff (248 chars) | Giữ _HY an toàn |
| `usp_IQcDefectReport_HY_iud` | 🟢 Giống (7 chars) | Dùng chung được nhưng _HY đã có |
| `usp_DefectReportNoChange_HY_iud` | 🟢 Giống (3 chars) | Dùng chung được nhưng _HY đã có |
| `usp_MaterialQcInfoChangeLotNo_HY_iud` | 🟢 Giống (1 char) | Dùng chung được nhưng _HY đã có |
| `usp_ModifyRevisionsVerFromC220_VVTF4_HY` | 🟢 Giống (1 char) | Dùng chung được nhưng _HY đã có |
| `usp_NCR_Report_HY_iud` | 🟢 Giống (1 char) | Dùng chung được nhưng _HY đã có |
| `usp_QcDefectIQCReport_HY_get` | 🟢 Giống (3 chars) | Dùng chung được nhưng _HY đã có |
| `usp_UpdateDefectDetailIQC_VVT_HY` | 🟢 Giống (9 chars) | Dùng chung được nhưng _HY đã có |
| `usp_GetMaterialQcInfo_ForReport_HY` | 🟢 Giống (1 char) | Dùng chung được nhưng _HY đã có |
| 11 popup SPs | ⚪ Shared | Giữ nguyên trong layout |

**Tables:** `STB_MaterialQcInfo`, `STB_MaterialQcDetail`, `STB_MaterialQcSampleResult`, `STB_MaterialMaster`, `STB_IQcDefectReport` — dùng chung

> **Ghi chú:** 16/20 SPs _HY gần giống hệt gốc. Tuy nhiên vì đã tạo sẵn _HY nên cứ dùng _HY — layout sẽ reference _HY names. 2 SPs **PHẢI** dùng _HY vì logic khác.

---

### 4. B310 → `HY310` — Create PO

**Clone từ:** `ProductionOrderInfo` (B310)  
**Layout gốc:** 677,500 chars | **Parent HY:** `Production_HY`

> **Lưu ý:** `HY311` (PO_Electrode_HY) đã tồn tại nhưng là **PO Electrode** (2 objects, simplified) — KHÁC với B310 (General PO, 17 objects).

#### Cần tạo:
- [x] SPs _HY: 7 SPs — **ĐÃ ĐỦ** trong DB
- [ ] Screen registration → TCode `HY310`, Name `ProductionOrderInfo_HY`
- [ ] Layout clone + replace SP names
- [ ] Screen objects → ~17 objects
- [ ] Permission → Admin

#### SPs:

| SP HY | So với gốc | Hành động |
|---|---|---|
| `usp_ProductionOrderInfo_HY_get` | 🔴 Khác lớn (911 chars) | **PHẢI dùng _HY** |
| `usp_ProductionOrderBom_HY_get` | 🟡 Minor diff (344 chars) | Giữ _HY an toàn |
| `usp_ProductionOrderRouting_HY_get` | 🟡 Minor diff (276 chars) | Giữ _HY an toàn |
| `usp_ProductionOrderRouting_HY_iud` | 🔴 Khác lớn (679 chars) | **PHẢI dùng _HY** |
| `usp_DoFixProductionOrder_HY` | 🟡 Minor diff (298 chars) | Giữ _HY an toàn |
| `usp_DoCancelPO_HY` | 🟡 Minor diff (481 chars) | Giữ _HY an toàn |
| `usp_GetMaterialGIForPO_HY` | 🟡 Minor diff (296 chars) | Giữ _HY an toàn |
| 5 popup SPs | ⚪ Shared | Giữ nguyên |

**Tables:** `STB_ProductionOrderInfo`, `STB_ProductionOrderBom`, `STB_ProductionOrderRouting`, `STB_MaterialMaster`, `STB_BasicRoutingInfo` — dùng chung

---

### 5. B442 → `HY442` — Daily Plan Electrode

**Clone từ:** `ElectrodePlan_Vietnam` (B442)  
**Layout gốc:** 1,158,611 chars | **Parent HY:** `ElectrodeHY`

#### Cần tạo:
- [x] SPs _HY: 7 SPs — **ĐÃ ĐỦ** trong DB
- [ ] Screen registration → TCode `HY442`, Name `ElectrodePlan_HY`
- [ ] Layout clone + replace SP names
- [ ] Screen objects
- [ ] Permission → Admin
- [ ] ⚠️ **Prerequisite:** Electrode Lines cần tạo trước

#### SPs:

| SP HY | So với gốc | Hành động |
|---|---|---|
| `usp_DayProdPlan_HY_get` | 🟢 Giống gốc (3 chars) | Dùng chung được nhưng _HY đã có |
| `usp_DayProdPlan_HY_iud` | 🔴 Khác lớn (1473 chars) | **PHẢI dùng _HY** |
| `usp_DoCancelDayProdPlan_HY` | 🟡 Minor diff (329 chars) | Giữ _HY an toàn |
| `usp_DoFixDayProdPlan_HY` | 🟡 Minor diff (330 chars) | Giữ _HY an toàn |
| `usp_SetInfo_HY_get` | 🟡 Minor diff (175 chars) | Giữ _HY an toàn |
| `usp_SetInfo_HY_iud_VNT` | 🔴 Khác lớn (2526 chars) | **PHẢI dùng _HY** |
| `usp_MainAssemblePartWeight_HY_get` | 🟢 Giống (1 char) | Dùng chung được nhưng _HY đã có |
| 8 popup SPs | ⚪ Shared | Giữ nguyên |

**Tables:** `STB_DayProdPlan`, `STB_SetInfo`, `STB_ProductionOrderInfo`, `STB_MaterialMaster`, `STB_LineInfo`, `STB_RouteInfo`, `STB_MachineMaster`, `STB_CompanyInfo`, `STB_WorkCenterInfo` — dùng chung  
**Functions:** `fnGetLocalTime`, `fnSplitToTable` — dùng chung

---

### 6. B470 → `HY470` — Electrode Process Steps (Mixing)

**Clone từ:** `VNT_ElectrodePrcsCard` (B470)  
**Layout gốc:** 848,754 chars | **Parent HY:** `ElectrodeHY`

#### Cần tạo:
- [x] SPs _HY: 6 SPs — **ĐÃ ĐỦ** trong DB
- [ ] Screen registration → TCode `HY470`, Name `ElectrodePrcsCard_HY`
- [ ] Layout clone + replace SP names
- [ ] Screen objects
- [ ] Permission → Admin
- [ ] ⚠️ **Prerequisite:** Electrode Lines

#### SPs:

| SP HY | So với gốc | Hành động |
|---|---|---|
| `usp_ElectrodeStep_HY_get` | 🟡 Minor diff (306 chars) | Giữ _HY an toàn |
| `usp_ElectrodeStep_HY_iud` | 🔴 Khác lớn (880 chars) | **PHẢI dùng _HY** |
| `usp_ElectrodeCommon_HY_get` | 🟡 Minor diff (397 chars) | Giữ _HY an toàn |
| `usp_ElectrodeCommon_HY_iud` | 🔴 Khác lớn (1584 chars) | **PHẢI dùng _HY** |
| `usp_ElectrodeOven_HY_get` | 🟡 Minor diff (281 chars) | Giữ _HY an toàn |
| `usp_ElectrodeOven_HY_iud` | 🔴 Khác lớn (818 chars) | **PHẢI dùng _HY** |
| `usp_ElectrodeStep_popup` | ⚪ Shared | Giữ nguyên |
| `usp_MaterialMasterByMaterialType_popup` | ⚪ Shared | Giữ nguyên |

**Tables:** `STB_ElectrodeStep`, `STB_ElectrodeCommon`, `STB_ElectrodeOven`, `STB_MaterialMaster` — dùng chung

---

### 7. B552 → `HY552` — Electrode Measure Results (Phức tạp nhất)

**Clone từ:** `Vietnam_ElectrodeMeasureResult` (B552)  
**Layout gốc:** 2,760,010 chars | **Parent HY:** `ElectrodeHY`

#### Cần tạo:
- [x] SPs _HY: 25 SPs — **ĐÃ ĐỦ** trong DB
- [ ] Screen registration → TCode `HY552`, Name `ElectrodeMeasureResult_HY`
- [ ] Layout clone + replace SP names (2-phase do NVARCHAR(MAX) limit)
- [ ] Screen objects → ~76 objects
- [ ] Permission → Admin
- [ ] ⚠️ **Prerequisite:** Electrode Lines

#### SPs:

**TẤT CẢ 25 SPs _HY gần GIỐNG HỆT gốc** (size diff 1-9 chars) — nhưng vì đã tạo sẵn nên layout sẽ reference _HY names.

| SP HY | Size Diff | Phân loại |
|---|---|---|
| `usp_ElectrodeCoatingInfo_HY_get` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeCoatingInfo_HY_iud` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_get` | 3 | 🟢 Giống gốc |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_iud` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeMixInfo_HY_get` | 2 | 🟢 Giống gốc |
| `usp_ElectrodeMixInfo_HY_iud` | 3 | 🟢 Giống gốc |
| `usp_ElectrodeMixStepInfo_HY_get` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeMixStepInfo_HY_iud` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeRollPressingInfo_HY_get` | 3 | 🟢 Giống gốc |
| `usp_ElectrodeRollPressingInfo_HY_iud` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_get` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeSlittingInfo_HY_get` | 3 | 🟢 Giống gốc |
| `usp_ElectrodeSlittingInfo_HY_iud` | 3 | 🟢 Giống gốc |
| `usp_ElectrodeSlittingResult_HY_get` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeSlittingResult_HY_iud` | 3 | 🟢 Giống gốc |
| `usp_ElectrodeWasteInfoNew_HY_iud` | 3 | 🟢 Giống gốc |
| `usp_ElectrodeWastePriceNewByBarcode_HY_get` | 3 | 🟢 Giống gốc |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | 3 | 🟢 Giống gốc |
| `usp_DoUpdateCoatingBarcodePrintYn_HY` | 3 | 🟢 Giống gốc |
| `usp_DoUpdateRollPressBarcodePrintYn_HY` | 3 | 🟢 Giống gốc |
| `usp_DoUpdateSlitingBarcodePrintYn_HY` | 3 | 🟢 Giống gốc |
| `usp_LocationElectric_HY` | 9 | 🟢 Giống gốc |
| `usp_test_check_expired_HY` | 1 | 🟢 Giống gốc |
| `usp_Vietnam_RollPressingSlitting_HY_get` | 2 | 🟢 Giống gốc |
| 13+ popup SPs | — | ⚪ Shared |

**Tables:** `STB_ElectrodeCoatingInfo`, `STB_ElectrodeCoatingVisualInspectionInfo`, `STB_ElectrodeMixInfo`, `STB_ElectrodeMixStepInfo`, `STB_ElectrodeRollPressingInfo`, `STB_ElectrodeRollPressingVisualInspectionInfo`, `STB_ElectrodeSlittingInfo`, `STB_ElectrodeSlittingResult`, `STB_ElectrodeWasteInfo`, `STB_SlittingLocationConfig_VVT`, `STB_CoatingToSlittingMaster`, `STB_ProdRouteHist` — dùng chung  
**Functions:** `fnGetElectrodeDensity`, `fnGetElectrodeDensityAvg`, `fnGetElectrodeDensityNew`, `fnGetElectrodeThickness01/02/03` — dùng chung

---

### 8. B802 → `HY802` — Electrode Report

**Clone từ:** `Vietnam_EletrodeProdRouteHist` (B802)  
**Layout gốc:** 1,857,876 chars | **Parent HY:** `ElectrodeHY`

#### Cần tạo:
- [x] SPs _HY: 2 SPs — **ĐÃ ĐỦ**
- [ ] Screen registration → TCode `HY802`, Name `ElectrodeProdRouteHist_HY`
- [ ] Layout clone + replace SP names
- [ ] Screen objects → ~6 objects
- [ ] Permission → Admin
- [ ] ⚠️ **Prerequisite:** Electrode Lines

#### SPs:

| SP HY | So với gốc | Hành động |
|---|---|---|
| `usp_Vietnam_ElectrodeProdRouteHist_HY_get` | 🟡 Minor diff (57 chars) | Giữ _HY |
| `usp_Vietnam_ElectrodeDefectHist_HY_get` | 🟢 Giống gốc (1 char) | Dùng chung được nhưng _HY đã có |
| 5 popup SPs | ⚪ Shared | Giữ nguyên |

**Tables:** `STB_ProdRouteHist`, `STB_ElectrodeCoatingInfo`, `STB_ElectrodeRollPressingInfo`, `STB_ElectrodeSlittingInfo`, `STB_ElectrodeMixInfo` — dùng chung  
**Functions:** `fnGetJobDateShiftTime` — dùng chung

---

### 9. C460 → `HY460` — Electrode QC Inspection

**Clone từ:** `ElectrodeInspectionHistoryForBarcode` (C460)  
**Layout gốc:** 935,087 chars | **Parent HY:** `QC_HY`

> **Lưu ý:** `HY443` (CommInspectionHistoryForBarcode_HY) đã tồn tại nhưng là **General CommInsp** — KHÁC với C460 (Electrode Inspection).

#### Cần tạo:
- [x] SPs _HY: 7 SPs — **ĐÃ ĐỦ**
- [ ] Screen registration → TCode `HY460`, Name `ElectrodeInspectionHistoryForBarcode_HY`
- [ ] Layout clone + replace SP names (⚠️ cần 3-phase: longest-first để tránh double-replace `DoFinishCommInspDoc` vs `DoFinishCommInspDoc_VNT`)
- [ ] Screen objects → ~19 objects
- [ ] Permission → Admin
- [ ] ⚠️ **Prerequisite:** Electrode Lines

#### SPs:

**TẤT CẢ 7 SPs _HY GIỐNG HỆT gốc** (size diff 1-3 chars)

| SP HY | Size Diff | Phân loại |
|---|---|---|
| `usp_GetElectrodeInspectionHistoryForBarcode_HY` | 1 | 🟢 Giống gốc |
| `usp_DoAddCommInspMeasureHistForBarcode_HY` | 3 | 🟢 Giống gốc |
| `usp_DoFinishCommInspDoc_HY` | 3 | 🟢 Giống gốc |
| `usp_DoFinishCommInspDoc_VNT_HY` | 3 | 🟢 Giống gốc |
| `usp_DoLossElectrodeProcess_HY_iud` | 3 | 🟢 Giống gốc |
| `usp_ElectrodeCoatingInfo_HY_get` | 1 | 🟢 Giống gốc |
| `usp_ElectrodeDivision_popup_HY` | 3 | 🟢 Giống gốc |
| 8 popup SPs | — | ⚪ Shared |

**Tables:** `STB_CommInspDocHistory`, `STB_CommInspDocItem`, `STB_CommInspMeasureHist`, `STB_ElectrodeCoatingInfo`, `STB_ProdRouteHist` — dùng chung

---

## Scripts đã tạo sẵn (trong `sql/scripts/hy_clone/`)

| Script | Mô tả | Trạng thái |
|---|---|---|
| `01_register_hy_screens.sql` | INSERT 7 screens vào STB_ScreenInfo | ✅ Sẵn sàng |
| `02_clone_hy_layouts.sql` | Clone layouts + REPLACE SP names | ✅ Sẵn sàng (đã fix double-replace) |
| `03_clone_hy_screen_objects.sql` | Clone ~200 ScreenObjects | ✅ Sẵn sàng |
| `04_grant_hy_permissions.sql` | Grant Admin permissions | ✅ Sẵn sàng |
| `deploy_phase1_screens.sql` | Deploy-ready version (no transaction) | ⚠️ Đã chạy + rollback |
| `rollback_phase1.sql` | Rollback script | ✅ Đã chạy thành công |

---

## Tổng kết: Phân loại toàn bộ SPs

| Phân loại | Số lượng | % | Chi tiết |
|---|---|---|---|
| 🟢 **Giống gốc** (diff < 50 chars) | 30 SPs | 44% | Chỉ khác tên SP, dùng chung được |
| 🟡 **Minor diff** (50-500 chars) | 20 SPs | 29% | Có sửa nhỏ, giữ _HY an toàn |
| 🔴 **Khác lớn** (> 500 chars) | 12 SPs | 18% | **PHẢI dùng _HY**, logic IUD khác |
| 🔵 **HY-only** (không có gốc) | 5 SPs | 7% | Chỉ HY mới có |
| ⚪ **Popup/Shared** | 36+ SPs | — | Dùng chung tất cả nhà máy |

### 12 SPs BẮT BUỘC dùng riêng (_HY):

| # | SP | Diff | Màn |
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

### Tables & Functions: 100% DÙNG CHUNG

- **39 tables** — Phân biệt data HY bằng `WorkCenterCode = 'VVT_F5'` hoặc `LineCode LIKE 'VVHY%'`
- **10 functions** — Shared, không có version _HY
