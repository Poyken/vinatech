# 9 Màn Hình HY — Danh Sách Sử Dụng

> **Ngày:** 2026-06-23 | **Nhà máy:** Hưng Yên (VVT_F5)  
> **Nguyên tắc:** Tất cả SPs dùng bản `_HY`. Tables & Functions dùng chung.

---

## Tổng quan

| # | Gốc | TCode HY | Tên Screen HY | Trạng thái |
|---|---|---|---|---|
| 1 | C121 | `HY121` | `HYQcInspectionGroup` | ❌ Cần tạo |
| 2 | C122 | `HY122` | `HYMaterialQcInspectionItemByMaterial` | ❌ Cần tạo |
| 3 | C220 | `HY220` | `HYMaterialIqcInfoSampleManagement` | ❌ Cần tạo |
| 4 | B310 | `HY310` | `HYProductionOrderInfo` | ❌ Cần tạo |
| 5 | B442 | `HY442` | `HYElectrodePlan` | ❌ Cần tạo |
| 6 | B470 | `HY470` | `HYElectrodePrcsCard` | ❌ Cần tạo |
| 7 | B552 | `HY552` | `HYElectrodeMeasureResult` | ❌ Cần tạo |
| 8 | B802 | `HY802` | `HYElectrodeProdRouteHist` | ❌ Cần tạo |
| 9 | C460 | `HY460` | `HYElectrodeInspectionHistoryForBarcode` | ❌ Cần tạo |

---

## 1. C121 → `HY121` — Quản lý nhóm & hạng mục kiểm tra ❌ CẦN TẠO

**Clone từ:** `QcInspectionGroup` (C121, 6 objects, 273K layout) | **Parent:** `HYQC`

> ⚠️ **CONFLICT:** TCode `HY121` đã tồn tại = `HYQCInspectionGroupCode` (3 objects, 69K layout — chỉ có Group, thiếu Item). Cần **xóa HY121 cũ** hoặc đặt TCode khác.

### Nghiệp vụ

Màn hình cấu hình **nền tảng QC** — thiết lập các nhóm kiểm tra (Inspection Group) và hạng mục kiểm tra (Inspection Item) dùng cho toàn bộ quy trình QC.

**Flow vận hành:**
1. Tạo **nhóm kiểm tra** (vd: "Kiểm tra ngoại quan", "Kiểm tra kích thước")
2. Trong mỗi nhóm, thêm **các hạng mục kiểm tra** (vd: "Chiều dài", "Chiều rộng", "Bề mặt")
3. Mỗi hạng mục có thông số: loại dữ liệu (số/checkbox), đơn vị đo, giới hạn trên/dưới
4. Data từ C121 được C122 reference để gán cho từng loại nguyên liệu

**Cấu trúc UI:** 2 grid — trên: danh sách Group | dưới: danh sách Item trong Group đang chọn

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

## 2. C122 → `HY122` — Tiêu chuẩn kiểm tra nguyên liệu ✅ ĐÃ TẠO (cần deploy layout)

**Clone từ:** `MaterialQcInspectionItemByMaterial` (C122, 9 objects, 664K layout) | **Parent:** `HYQC`

> ⚠️ **HY151 (`HYMaterialQcInspectionItem`) — KHÔNG DÙNG.** HY151 dùng bảng CHUNG (`STB_MaterialQcInspectionItem`, `STB_QcInspectionItem`) → data lẫn với nhà máy khác. HY122 dùng bảng RIÊNG (`_HY`) → an toàn, tách biệt data.

> 📋 **Clone method:** Dùng script `fix_hy122_clone_full.sql` — clone layout từ C122 + REPLACE 2 SP names + clone đầy đủ 9 objects. **Không thể** clone bằng tay trong Designer vì thiếu objects.

### Nghiệp vụ

Thiết lập **tiêu chuẩn kiểm tra cho từng mã nguyên liệu** — mapping mã NVL → bộ hạng mục QC cần kiểm.

**Flow vận hành:**
1. Chọn **mã nguyên liệu** (MaterialCode) từ popup
2. Gán các **hạng mục kiểm tra** từ C121 cho mã NVL đó
3. Thiết lập AQL level, Inspection Level, số lượng mẫu
4. Khi NVL nhập kho (F330) → C220 tự động tạo phiếu IQC theo config tại C122

**Quan hệ:** C121 (định nghĩa hạng mục) → C122 (gán cho NVL) → C220 (kiểm tra thực tế)

**Make View:** Cần nhập MaterialCode hợp lệ (vd: `EDVTMD-188`) — SP sẽ error nếu không có tham số.

### Objects (9 — clone đầy đủ từ C122)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_MaterialQcInspectionItem_ByMaterial_HY_get` | SearchFunction | **_HY** — đọc từ bảng `_HY` |
| `usp_MaterialQcInspectionItem_HY_iud` | ExecuteFunction | **_HY** — ghi vào bảng `_HY` |
| `MaterialQcInspectionItem_ByMaterial_HY` | View | **_HY** — grid chính |
| `MaterialInformation` | View | Dùng chung — grid info NVL |
| `ImportFromInspectionItem` | Action | Dùng chung — import từ Group/Item |
| `ImportFromMaterialInspectionItem` | Action | Dùng chung — import từ NVL khác |
| `SetAql` | Action | Dùng chung — `usp_GetAql_popup` |
| `SetLevel` | Action | Dùng chung — `usp_GetInspectionLevel_popup` |
| `SetInspectionType` | Action | Dùng chung — `usp_GetInspectionType_Popup` |

### SPs dùng _HY

| SP |
|---|
| `usp_MaterialQcInspectionItem_ByMaterial_HY_get` |
| `usp_MaterialQcInspectionItem_HY_iud` |

### SPs dùng chung (Popup)

| SP |
|---|
| `usp_MaterialMaster_popup` |
| `usp_GetAql_popup` |
| `usp_GetInspectionLevel_popup` |
| `usp_GetInspectionType_Popup` |

### Tables

| Bảng | Loại |
|---|---|
| `STB_MaterialQcInspectionItem_HY` | **Riêng HY** — data QC items |
| `STB_QcInspectionItem_HY` | **Riêng HY** — hạng mục kiểm tra |
| `STB_QcInspectionGroup_HY` | **Riêng HY** — nhóm kiểm tra |
| `STB_MaterialMaster` | Dùng chung |

---

## 3. C220 → `HY220` — IQC Confirmation ❌ CẦN TẠO

**Clone từ:** `MaterialIqcInfoSampleManagement` | **Parent:** `HYQC`

### Nghiệp vụ

Màn hình **kiểm tra chất lượng đầu vào (IQC)** — khi nguyên liệu nhập kho qua F330, QC kiểm tra chất lượng trước khi cho phép sử dụng.

**Flow vận hành:**
1. NVL nhập kho (F330) → hệ thống tự tạo **phiếu IQC** (`STB_MaterialQcInfo`) với hạng mục từ C122
2. QC chọn phiếu → bấm **"Make Detail"** (`DoMakeMaterialIQCDetailList`) → tạo danh sách chi tiết kiểm tra
3. QC nhập kết quả đo từng hạng mục (`MaterialQcSampleResult_iud`)
4. Quyết định: **Pass** (`DoUpdateMaterialQcInfo_Success`) hoặc **Fail** (`DoUpdateMaterialQcInfo_Fail`)
5. Fail → tạo **Defect Report** (`IQcDefectReport_iud`) → gửi email thông báo
6. Có thể **đổi Pass** sau khi Fail (`DoChangeMaterialQcToPass`) nếu được phê duyệt

**Cấu trúc UI:**
- **Tab 1 (IQC List):** Grid chính — filter theo ngày, mã NVL, kết quả. Mỗi row = 1 phiếu IQC
- **Tab 2 (Detail):** Chi tiết hạng mục kiểm tra cho phiếu đang chọn
- **Tab 3 (Sample):** Kết quả đo từng mẫu
- **Popup Defect Report:** Báo cáo lỗi khi Fail
- **Popup NCR:** Non-Conformance Report

**Lưu ý vận hành:**
- Lỗi "Receiving Confirmation" thường do F330 chưa gộp lot đúng
- SP `DoConfirmCancelQc2` = client-side action (confirm/cancel), không phải DB SP

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

**Clone từ:** `ProductionOrderInfo` | **Parent:** `HYProduction`

> HY311 (HYPOElectrode) đã có nhưng là PO Electrode simplified (2 objects) — KHÁC B310 (General PO, 17 objects).

### Nghiệp vụ

Màn hình **Lệnh sản xuất (Production Order)** — tạo, quản lý, xác nhận PO cho toàn bộ dây chuyền.

**Flow vận hành:**
1. Bộ phận kế hoạch tạo PO mới → chọn **sản phẩm, số lượng, ngày SX**
2. Hệ thống tự tạo **BOM** (`ProductionOrderBom`) và **Routing** (`ProductionOrderRouting`) theo master data
3. PO được **Fix** (xác nhận) → `DoFixProductionOrder` → không sửa được nữa
4. PO fix → B442/B450 dùng để tạo **kế hoạch ngày**
5. Cần hủy → `DoCancelPO` (yêu cầu chưa có sản lượng)
6. Tab BOM: xem danh sách NVL cần xuất kho (`GetMaterialGIForPO`)

**Cấu trúc UI:**
- **Grid chính:** Filter theo tháng, nhóm SP, mã SP, trạng thái Fix/Cancel
- **Tab BOM:** Chi tiết NVL cần cho PO
- **Tab Routing:** Các công đoạn SX theo PO
- **Nút:** Create PO | Fix | Cancel | Refresh

**Lưu ý:** Xóa PO phải xóa cả 3 bảng (`ProductionOrderInfo` + `Bom` + `Routing`) + liên quan B450

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

### Nghiệp vụ

Màn hình **kế hoạch sản xuất hàng ngày cho Electrode** — chia PO thành các Set/Lot sản xuất theo ngày.

**Flow vận hành:**
1. Chọn **PO** đã Fix từ B310 → nhập kế hoạch theo **ngày + line + ca**
2. Tạo **DayProdPlan** → chỉ định sản phẩm, số lượng, dây chuyền Electrode
3. Tạo **SetInfo** (Lot) → gán vào Plan → `SetInfo_iud_VNT`
4. **Fix** Plan (`DoFixDayProdPlan`) → Lot chính thức, có thể in tem
5. Cancel nếu cần (`DoCancelDayProdPlan`)
6. Xem trọng lượng phụ kiện (`MainAssemblePartWeight_get`)

**Cấu trúc UI:**
- **Grid trên:** Kế hoạch ngày — filter theo ngày, line, nhóm SP
- **Grid dưới:** SetInfo (Lot) — chi tiết từng Set trong Plan đang chọn
- **Các popup:** Chọn Line, Route, Shift, BOM Version, Material

**Quan hệ:** B310 (PO) → B442 (Plan ngày) → B552 (nhập kết quả SX)

**Lưu ý:**
- `SIExtReal03` = độ dày electrode, auto-fill
- Lỗi `Not found label type` → check `STB_ModelLabelInfo` (A460)

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

### Nghiệp vụ

Màn hình **thiết lập công đoạn trộn (Mixing)** cho sản xuất Electrode — cấu hình quy trình, thông số, NVL cho từng bước trộn.

**Flow vận hành:**
1. Tạo **công đoạn Electrode** (`ElectrodeStep_iud`) — vd: Trộn khô, Trộn ướt, Khuấy
2. Mỗi công đoạn có **thông số chung** (`ElectrodeCommon_iud`) — nhiệt độ, tốc độ, thời gian
3. Cấu hình **lò sấy** (`ElectrodeOven_iud`) — nhiệt độ sấy, thời gian sấy
4. Gán **NVL cần dùng** cho mỗi step (popup MaterialMasterByMaterialType)

**Cấu trúc UI:**
- **Tab 1 (Step):** Danh sách công đoạn, thứ tự
- **Tab 2 (Common):** Thông số chung cho step đang chọn
- **Tab 3 (Oven):** Cấu hình lò sấy

**Quan hệ:** B470 (config step) → B552 (nhập kết quả theo step)

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

### Nghiệp vụ

Màn hình **phức tạp nhất** (25 SPs, 12 tables, 6 functions) — nhập kết quả sản xuất electrode ở **mọi công đoạn**: Mixing → Coating → RollPressing → Slitting.

**Flow vận hành (theo công đoạn sản xuất Electrode):**

```
Mixing (Trộn)        → nhập kết quả Mixing        → Tab MixInfo + MixStepInfo
    ↓
Coating (Phủ)        → nhập kết quả Coating       → Tab CoatingInfo + Visual Inspection
    ↓                    + đo Viscosity             → ElectrodCoatingInfo_Viscosity
    ↓                    + in tem barcode           → DoUpdateCoatingBarcodePrintYn
RollPressing (Cán)   → nhập kết quả RollPressing   → Tab RollPressingInfo + Visual Inspection
    ↓                    + in tem barcode           → DoUpdateRollPressBarcodePrintYn
Slitting (Cắt)       → nhập kết quả Slitting       → Tab SlittingInfo + SlittingResult
    ↓                    + in tem barcode           → DoUpdateSlitingBarcodePrintYn
    ↓
Phế liệu             → ghi nhận waste              → ElectrodeWasteInfoNew_iud
```

**Cấu trúc UI:** Multi-tab phức tạp:
- **Tab Mixing:** Kết quả trộn + chi tiết từng bước (Step)
- **Tab Coating:** Kết quả phủ + Visual Inspection + Viscosity
- **Tab RollPressing:** Kết quả cán + Visual Inspection
- **Tab Slitting:** Kết quả cắt + chi tiết vị trí cắt (`SlittingLocationConfig`)
- **Tab Waste:** Quản lý phế liệu
- Mỗi tab có nút **in barcode** riêng

**Tính toán tự động:**
- Mật độ electrode: `fnGetElectrodeDensity`, `fnGetElectrodeDensityAvg`, `fnGetElectrodeDensityNew`
- Độ dày: `fnGetElectrodeThickness01/02/03`
- Hết hạn NVL: `usp_test_check_expired`
- Mapping Coating→Slitting: `STB_CoatingToSlittingMaster`

**Lưu ý:** Lỗi "Chưa CONFIG STB_SLITTINGLOCATIONCONFIG_VVT" → cần config vị trí cắt trước

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

### Nghiệp vụ

Màn hình **báo cáo tổng hợp** kết quả sản xuất electrode — xem lại toàn bộ dữ liệu đã nhập ở B552 dưới dạng report.

**Flow vận hành:**
1. Filter theo **ngày, công đoạn** (Electrode Route), **nhà máy**, R&D/Production
2. Xem **lịch sử routing sản xuất** (`Vietnam_ElectrodeProdRouteHist_get`) — join nhiều bảng Electrode
3. Xem **lịch sử lỗi** (`Vietnam_ElectrodeDefectHist_get`) — defect theo công đoạn
4. Export report

**Cấu trúc UI:**
- **Grid chính:** Lịch sử routing sản xuất — filter theo khoảng ngày + route
- **Grid phụ:** Chi tiết lỗi/defect cho row đang chọn
- **Bộ lọc:** Ngày, Route, Company, WorkCenter, R&D/Production

**Quan hệ:** B552 (nhập data) → B802 (xem report). B802 chỉ **READ-ONLY**, không sửa data.

**Đặc biệt:** SP `Vietnam_ElectrodeProdRouteHist_get` là SP lớn nhất (55K chars) — join 5+ bảng Electrode + ProdRouteHist

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

**Clone từ:** `ElectrodeInspectionHistoryForBarcode` | **Parent:** `HYQC`  
⚠️ Cần Electrode Lines. Layout cần 3-phase replace (tránh double-replace `DoFinishCommInspDoc`).

> HY443 (HYCommInspectionHistoryForBarcode) đã có nhưng là **General CommInsp** (kiểm tra Cell/Module) — KHÁC C460 (**Electrode Inspection** — kiểm tra điện cực).

### Nghiệp vụ

Màn hình **QC kiểm tra electrode nhập kho** — QC worker quét barcode điện cực và kiểm tra chất lượng theo tiêu chuẩn.

**Flow vận hành:**
1. QC quét **barcode Electrode** → hệ thống load lịch sử kiểm tra (`GetElectrodeInspectionHistoryForBarcode`)
2. Nếu chưa có phiếu kiểm tra → tạo mới tự động
3. QC nhập **kết quả đo** (`DoAddCommInspMeasureHistForBarcode`) — theo từng hạng mục
4. Kết thúc kiểm tra:
   - **OK** → `DoFinishCommInspDoc` hoặc `DoFinishCommInspDoc_VNT` (version VN mở rộng) → cho phép đưa vào sản xuất
   - **NG** → ghi lỗi, chọn **mã lỗi** (DefectInfo popup)
   - **Loss** → `DoLossCommInspDoc_VNT` — hủy electrode
5. Chia nhỏ electrode nếu cần (`DoLossElectrodeProcess_iud` — chia cuộn lỗi)
6. Xem thông tin coating gốc (`ElectrodeCoatingInfo_get`) để đối chiếu

**Cấu trúc UI:**
- **Input barcode:** Ô quét barcode ở đầu
- **Grid trên:** Lịch sử kiểm tra cho barcode đang chọn
- **Grid dưới:** Chi tiết kết quả đo từng hạng mục
- **Popup:** Chọn Line, Route, Worker, Defect Code, OK/NG
- **Nút:** Finish (xác nhận) | Hold | Loss (hủy)

**Quan hệ trong flow Electrode:**
```
B442 (Plan) → B470 (Config Step) → B552 (SX & nhập kết quả)
    → C460 (QC kiểm tra) → B802 (Report)
```

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
