# KB_32: Bản Đồ Ánh Xạ Screen → SP → Table

> **📌 Mục đích:** Khi debug bất kỳ màn hình nào → tra đây → biết ngay SP nào chạy, bảng nào bị ảnh hưởng.
> **🔑 Keywords:** screen, SP, table, map, ánh xạ, mapping, ScreenObjects, Action, SearchFunction, ExecuteFunction
> Dữ liệu từ `SmartFramework.dbo.STB_ScreenObjects` + phân tích code SP.

---

## Cách Tra Cứu

```sql
-- Tra SP của bất kỳ màn hình nào
SELECT SI.TCode, SI.Name, SO.ObjectName, SO.ObjectType
FROM SmartFramework.dbo.STB_ScreenInfo SI
JOIN SmartFramework.dbo.STB_ScreenObjects SO ON SI.Name = SO.ScreenName
WHERE SI.TCode = 'MÃ_MÀN_HÌNH'
AND SO.ObjectType IN ('ExecuteFunction','SearchFunction')
ORDER BY SO.ObjectType
```

---

## B523 — Đóng Gói (Vietnam_Donggoi)

### Execute SPs (Ghi dữ liệu)

| SP | Chức năng |
|---|---|
| `usp_Vietnam_DoProcessProdPacking_VVT` | **CORE** — Gộp box: OPENXML→CURSOR→PackingByOne |
| `usp_DoProcessProdPackingByOne_VNT` | Sub-SP: xử lý đóng gói từng barcode |
| `usp_DoCancelProdPacking_LotNo` | Hủy đóng gói theo LotNo |
| `usp_savePackingLabelQty_VVT` | Lưu SL in tem đóng gói |
| `usp_BoxCheckSetupValue` | Kiểm tra cấu hình box (SL/box, Size) |
| `usp_BoxCheckSetupValueTwo` | Kiểm tra cấu hình box (variant 2) |
| `usp_SplitPackingBox` | Tách box (ngược lại gộp) |
| `usp_PackingLabelPrintInfo` | Ghi nhận lịch sử in tem |

### Search SPs (Đọc dữ liệu)

| SP | Chức năng |
|---|---|
| `usp_Vietnam_GetProdPackingForBarcode_VVT` | **Tìm barcode** → lấy thông tin đóng gói |
| `usp_ProdRouteHist_get` | Lấy lịch sử Routing |
| `usp_Vietnam_GetBoxIDForLotNo_VVT` | Lấy BoxID theo LotNo |

### Bảng DB chính

| Bảng | Vai trò |
|---|---|
| `STB_DividePackaging` | Phân chia đóng gói (gộp/tách) |
| `STB_SavePackingTime_VVT` | Thời gian Takt đóng gói |
| `STB_PackingQtyPerSize` | SL đóng gói theo Size |
| `STB_PackingStandard` | Tiêu chuẩn đóng gói chung |
| `STB_PackingLabelPrintHist` | Lịch sử in tem |
| `STB_Vietnam_PackingPrinting` | In tem VN |
| `STB_SetInfo` | Barcode → ControlNo mapping |
| `STB_ProdRouteHist` | Lịch sử công đoạn |

---

## B530 — Nhập Sản Lượng (ProdRouteByBarcode)

### Execute SPs

| SP | Chức năng |
|---|---|
| `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | **CORE** — 22K chars, Gate 20 phút, Takt, cascade |
| `usp_DoProcessDefectRepairInfoByBarcode_SmartApp` | Ghi nhận lỗi theo barcode |
| `usp_DoUpdateProdRouteHistMarkingLetter` | Cập nhật MarkingCode (Hà Nam) |
| `usp_DoUpdateDRIExtText02_iud` | Cập nhật text mở rộng |
| `usp_InterimProdQtyInfo_iud` | Nhập SL tạm |
| `usp_DoCreateTaktTimeForRoute` | Tạo Takt Time cho Route |
| `usp_DoSplitLotAgingHN` | Tách Lot Aging (Hà Nam) |
| `usp_AddRepairInfor_BG2` | Thêm info sửa chữa BG2 |
| `usp_PassBarcodeForRoute` | Pass barcode qua Route |
| `usp_FailBarcodeForRoute` | Fail barcode tại Route |

### Search SPs

| SP | Chức năng |
|---|---|
| `usp_GetProdRouteHistForBarcode_VNT` | **12K** — Lấy lịch sử routing theo barcode |
| `usp_GetProdRouteBarcodeForDefect_VNT` | Lấy info lỗi theo barcode |
| `usp_DoProcessProdRouteHist_VNT` | Variant VNT — search dữ liệu routing |
| `usp_ProdRouteHist_get` | Lấy lịch sử routing chung |
| `usp_WasteWeight_get` | Lấy trọng lượng phế |

### Bảng DB chính

| Bảng | Vai trò |
|---|---|
| `STB_ProdRouteHist` | **CORE** — Lịch sử routing (INSERT mỗi lần scan) |
| `STB_SetInfo` | Barcode→ControlNo, IsLineInput, IsProdFinish |
| `STB_ProductionOrderRouting` | PO Routing config (IsInputRoute, IsOutputRoute) |
| `STB_ProductionOrderInfo` | PO header (ProdFinishQty) |
| `STB_ProcedureLog` | Audit log |
| `STB_LineRouteMapping` | Line→Route→Warehouse mapping |
| `STB_DefectRepairInfo` | Thông tin sửa lỗi |
| `STB_SavePackingTime_VVT` | Takt time |
| `STB_VVT_ESRDATA` | Dữ liệu ESR (IoT) |

---

## B597 — Scan NVL Đầu Vào (SelfInspectionRawMaterial2)

### Execute SPs

| SP | Chức năng |
|---|---|
| `usp_Vietnam_RawMaterialInputHist_uid` | **CORE** — Lưu lịch sử scan NVL + validation AluCase, Electrode, Electrolyte |
| `usp_RawMaterialInputHist_iud` | IUD NVL input history |
| `usp_DoAddCommInspMeasureHistForBarcode` | Thêm kết quả đo PQC |
| `usp_DoFinishCommInspDoc` | Hoàn thành tài liệu QC |
| `usp_DoFinishCommInspDoc_VNT` | Hoàn thành QC (variant VNT) |
| `usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_iud` | Tự kiểm tra + lưu |

### Search SPs

| SP | Chức năng |
|---|---|
| `usp_GetCommInspectionHistoryForBarcode` | **16K** — Lấy lịch sử + template hạng mục QC |
| `usp_RawMaterialInputHist_get` | Lấy lịch sử NVL đã scan |

### Bảng DB chính

| Bảng | Vai trò |
|---|---|
| `STB_InputMaterialHistory` | **CORE** — Lịch sử scan NVL (RawMaterialBarcode) |
| `STB_SetInfo` | Barcode→ControlNo |
| `STB_ProductionOrderBom` | BOM — check NVL có trong PO không |
| `STB_MaterialLotInfo` | Info Lot NVL (expiry, warehouse, QC status) |
| `STB_CommInspDocHistory` | Tài liệu QC |
| `STB_CommInspDocItem` | Hạng mục QC chi tiết |

---

## F330 — Nhập Kho NVL (MaterialReceiptAndPrintLabel)

### Execute SPs (18 SPs — nhiều nhất!)

| SP | Chức năng |
|---|---|
| `usp_MaterialDocInfo_iud` | IUD phiếu nhập kho (header) |
| `usp_MaterialDocDetail_iud` | IUD chi tiết phiếu (từng NVL) |
| `usp_DoCreateMaterialDocLot` | Tạo Lot trên phiếu nhập (⚠️ DB verified: không có `usp_MaterialDocLotInfo_iud`) |
| `usp_DoArriveMaterialDelivery` | Xác nhận hàng đến |
| `usp_DoMaterialDocMasterDetail_iud` | IUD master detail phiếu |
| `usp_DoFinishMaterialDoc` | Đóng phiếu nhập |
| `usp_DoFixMaterialDoc` | Xác nhận phiếu |
| `usp_DoCancelMaterialDoc` | Hủy phiếu |
| `usp_DoCancelFinishMaterialDoc` | Hủy đóng phiếu |
| `usp_DoCreateLabel` | In tem NVL |
| `usp_DoCreateLabelManual` | In tem thủ công |
| `usp_DoChangeMaterialDocLotInfo` | Đổi thông tin Lot |
| `usp_DoDeleteMaterialDocLotInfo` | Xóa Lot |
| `usp_GetOrderMaterialMaster_popup` | Popup chọn NVL |
| `usp_DoUpdateTradeDate_iud` | Cập nhật ngày giao dịch |
| `usp_AddDate` / `usp_AddStartDate` | Thêm ngày |
| `usp_UpdateLevelJIANGHAI` | Cập nhật Level Jianghai (KH) |

### Bảng DB chính

| Bảng | Vai trò |
|---|---|
| `STB_MaterialDocInfo` | Phiếu nhập/xuất (Header) — DocStatus, MaterialDocType |
| `STB_MaterialDocDetail` | Chi tiết phiếu (từng NVL) |
| `STB_MaterialDocLotInfo` | Lot chi tiết |
| `STB_MaterialStock` | Tồn kho (StockQty cập nhật) |
| `STB_MaterialLotInfo` | Master Lot info |
| `STB_MaterialMaster` | Master NVL |

---

## G100 — Xuất Kho Bán Hàng (SalesGI)

### Execute SPs

| SP | Chức năng |
|---|---|
| `usp_MaterialDocInfo_iud` | IUD phiếu xuất kho |
| `usp_MaterialDocDetail_iud` | IUD chi tiết xuất |
| `usp_DoCreateMaterialDocLot` | Tạo Lot trên phiếu xuất (⚠️ DB verified) |
| `usp_DoFinishMaterialDoc` | Đóng phiếu |
| `usp_DoFixMaterialDoc` | Xác nhận phiếu |
| `usp_DoCancelMaterialDoc` | Hủy phiếu |
| `usp_DoCancelFinishMaterialDoc` | Hủy đóng phiếu |
| `usp_PDADoPicking` | Picking bằng PDA |
| `usp_PDADoPickingCancel` | Hủy picking |
| `usp_DoUploadMaterialDocToERP_DL` | **★ Đẩy lên ERP** (Duzon Link) — ⚠️ SP registered in ScreenObjects nhưng KHÔNG tồn tại trong SmartFactoryV2 (có thể linked server/external) |

---

## C443 — PQC Quality Check (Vietnam_inspectionPQC)

| SP | Type | Chức năng |
|---|---|---|
| `usp_DoAddCommInspMeasureHistForBarcode` | Execute | Nhập giá trị đo (base) |
| `usp_DoAddCommInspMeasureHistForBarcode_Vietnam` | Execute | Thêm kết quả đo PQC (variant VN) |
| `usp_DoFinishCommInspDoc` | Execute | Hoàn thành QC doc (base) |
| `usp_DoFinishCommInspDoc_VNT` | Execute | Hoàn thành tài liệu QC (VNT) |
| `usp_GetCommInspection_HistoryForBarcode_Vietnam` | Search | Lấy lịch sử QC VN |

---

## C460 — Electrode QC Inspection

| SP | Type | Chức năng |
|---|---|---|
| `usp_DoAddCommInspMeasureHistForBarcode` | Execute | Nhập giá trị đo |
| `usp_DoAddCommInspMeasureHistForBarcode_TEST` | Execute | Nhập giá trị đo (test mode) |
| `usp_DoFinishCommInspDoc` | Execute | Hoàn thành QC doc |
| `usp_DoFinishCommInspDoc_VNT` | Execute | Hoàn thành VNT |
| `usp_ElectrodeDivision_popup` | Execute | Popup phân loại electrode |
| `usp_DoLossElectrodeProcess_iud` | Execute | Ghi nhận Loss electrode |
| `usp_CustomerComplaintsManagementInfo_iud` | Execute | IUD khiếu nại khách hàng |
| `usp_GetElectrodeInspectionHistoryForBarcode` | Search | Lịch sử QC electrode |
| `usp_ElectrodeCoatingInfo_get` | Search | Thông tin coating |
| `usp_CustomerComplaintsManagementInfo_get` | Search | Lấy info khiếu nại KH |

---

## C512 — OQC Lot Management

| SP | Type | Chức năng |
|---|---|---|
| `usp_DoCreateOqcInfoForLotByOne_VNT` | Execute | Tạo Lot OQC cho 1 barcode |
| `usp_DoCreateOqcInfoListForLot` | Execute | Tạo danh sách Lot OQC |
| `usp_GetSetListForOqcLot_VNT` | Search | Lấy danh sách Set cho OQC |
| `usp_GetSetListForOqcLot_VVT` | Search | Variant VVT |

### Bảng DB chính
| Bảng | Vai trò |
|---|---|
| `STB_MaterialQcInfo` | Header Lot OQC |
| `STB_MaterialQcDetail` | Hạng mục kiểm tra (SampleQty, USL, LSL) |
| `STB_SetInfo` | Barcode→ControlNo mapping |
| `STB_ProductionOrderRouting` | Check IsOutputRoute=1 |

---

## C530 — OQC Product Inspection (★ 14 SPs)

### Execute SPs
| SP | Chức năng |
|---|---|
| `usp_DoUpdateMaterialQcInfo_Success` | ✅ Đánh giá PASS |
| `usp_DoUpdateMaterialQcInfo_Fail` | ❌ Đánh giá FAIL |
| `usp_DoUpdateMaterialQcInfo_Hold` | ⏸️ Đánh giá HOLD |
| `usp_DoUpdateMaterialQcInfo_Rescreening` | 🔄 Kiểm tra lại |
| `usp_DoUpdateMaterialQcInfo_Complete` | ✔️ Hoàn thành |
| `usp_DoMakeMaterialQcSampleResult` | Tạo sample result |
| `usp_MaterialQcDetail_iud` | IUD hạng mục |
| `usp_MaterialQcSampleResult_iud` | IUD kết quả đo |
| `usp_MaterialQcInfo_iud` | IUD Lot QC |
| `usp_DoMakeMaterialIQCDetailList` | Tạo danh sách IQC |
| `usp_DoDeleteMaterialQcInfo` | Xóa Lot QC |
| `usp_DoUpdateMaterialOQcInfoRemark` | Cập nhật ghi chú |
| `usp_RecentlyCellTestResultMax_get` | Lấy kết quả test gần nhất |
| `usp_DoProcessProdInspCpkCalc` | Tính Cpk (năng lực quy trình) |

### Search SPs
| SP | Chức năng |
|---|---|
| `usp_GetMaterialOQcInfo` | Lấy info Lot OQC |
| `usp_MaterialQcDetail_get` | Lấy hạng mục kiểm tra |
| `usp_MaterialQcSampleResult_get` | **★ Lấy giá trị đo từ Stb_ESRValueMonitor** |
| `usp_GetMaterialQcInfo_ForReport` | Report QC |
| `usp_GetProdRouteBarcodeForDefect_E27` | Lấy info lỗi theo barcode (E-27) |

---

## C546 — FOQC OCV/ESR Measurement

> **Giống C530** về SP Execute (14 SPs). Khác ở Search:

| SP | Chức năng |
|---|---|
| `usp_Vietnam_GetMaterialFOQCInfo` | Lấy info FOQC (thay cho OQC) |
| `usp_Vietnam_MaterialFOQcDetail_get` | **★ Khởi tạo dòng trống + BUG OCV 20ea** |
| `usp_GetMaterialQcInfo_ForReport` | Report QC |
| `usp_MaterialQcSampleResult_get` | Lấy giá trị đo |
| `usp_GetProdRouteBarcodeForDefect_E27` | Lấy info lỗi (E-27) |

### Bảng DB chính (C530 + C546)
| Bảng | Vai trò |
|---|---|
| `STB_MaterialQcInfo` | Header Lot QC (CompanyCode, MaterialQcNo) |
| `STB_MaterialQcDetail` | Hạng mục (SampleQty, Pattern, DecisionResult) |
| `STB_MaterialQcSampleResult` | **Kết quả đo** (TestValue, TestResult) |
| `Stb_ESRValueMonitor` | **Dữ liệu nguồn từ máy đo** (value, valueocv) |
| `STB_LotChangeMaterialHistory` | Truy ngược OldBarcode |

---

## C560 — FG Receipt (Nhập Kho Thành Phẩm)

| SP | Type | Chức năng |
|---|---|---|
| `usp_ProductsReceiptHist_iud` | Execute | IUD phiếu nhập kho TP |
| `usp_ProductsReceiptHist_get` | Search | Lấy lịch sử nhập kho |
| `usp_MaterialQcDetail_get` | Search | Lấy hạng mục QC |
| `usp_MaterialQcSampleResult_get` | Search | Lấy kết quả QC |

---

## K101 — BG2 Day Plan (Kế Hoạch Ngày BG2)

| SP | Type | Chức năng |
|---|---|---|
| `usp_DayProdPlan_iud` | Execute | IUD kế hoạch ngày |
| `usp_DoCancelDayProdPlan` | Execute | Hủy kế hoạch |
| `usp_DoFixDayProdPlan` | Execute | Xác nhận kế hoạch |
| `usp_SetInfo_iud` | Execute | IUD SetInfo (barcode) |
| `usp_DoCreateSetInfoForProdQty_VNT` | Execute | **Tạo barcode + Lot** |
| `usp_DoFinishDayProdPlan` | Execute | Đóng kế hoạch |
| `usp_DayProdPlan_get` | Search | Lấy kế hoạch |
| `usp_SetInfo_get` | Search | Lấy SetInfo |

---

## K109 — BG2 Material Scan (Scan NVL BG2)

> **Giống B597** — cùng SP nhưng giao diện khác cho BG2.

| SP | Chức năng |
|---|---|
| `usp_DoAddCommInspMeasureHistForBarcode` | Nhập QC |
| `usp_DoFinishCommInspDoc` | Hoàn thành QC |
| `usp_DoFinishCommInspDoc_VNT` | VNT variant |
| `usp_RawMaterialInputHist_iud` | Lưu NVL |
| `usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_iud` | Tự kiểm tra |
| `usp_GetCommInspectionHistoryForBarcode` | Search QC |
| `usp_RawMaterialInputHist_get` | Search NVL |

---

## K110 — Module Production (Sản Xuất Module BG2)

| SP | Chức năng |
|---|---|
| `usp_ModuleProductionInfo_iud` | IUD thông tin sản xuất Module |
| `usp_ModuleProductionInfo_get` | Search Module info |

---

## BG2 (VVT_F4) — Validation Logic Đặc Biệt

> Phân tích từ SP `usp_GetProdRouteHistForBarcode_VNT` (358 dòng):

### Gate Logic cho BG2

```
1. Machine Check (BN/BG1): Phải chọn MachineCode (trừ V-28, V-27, V-33, V-28_BG, V-33_BG)
2. Machine Check (HN): Phải chọn MachineCode (mọi Route)
3. VP04 Fail → VP05 Block: Nếu VP04 status='Fail' → chặn VP05
4. Route History Check: VP02→VP03→VP04→VP05 phải đi tuần tự
5. DPP Close Check: DPPExtText01='1' → Lot đã đóng → chặn
```

### Pass/Fail Route Status (BG2 only)

```sql
-- Bảng STB_PassOrFailRouteStatus (chỉ dùng BG2)
-- SP: usp_PassBarcodeForRoute / usp_FailBarcodeForRoute
SELECT * FROM STB_PassOrFailRouteStatus
WHERE Barcode = 'mã' ORDER BY CreatedDate DESC
```

> ⚠️ **BG2 dùng route VP01→VP18 (Cell) + ND01→ND10 (Nordex)** (khác BN/BG1 dùng V-22→V-34)

---

## Sơ Đồ Tổng: Luồng Data Qua Các Màn Hình

```
A230 (Master NVL)        A310 (Route)        A410 (Model)
     │                       │                    │
     └──────────┬────────────┘                    │
                ▼                                 │
          A510 (PO) ← B310 (PO Info)              │
                │                                 │
     ┌──────────┼──────────┐                      │
     ▼          ▼          ▼                      │
F330 (Nhập kho) B450 (DayPlan) A418 (PackQty)    │
     │          │                │                │
     ▼          ▼                │                │
B597 (Scan NVL) → B530 (SL) → B523 (Gộp Box) ←──┘
 K109 (BG2)       │              │
                   ▼              ▼
             Backflush       C512 (OQC Lot)
             (Trừ NVL)           │
                                 ▼
                            C530 (OQC Test)
                            C546 (FOQC ESR/OCV)
                                 │
                                 ▼
                            C560 (FG Receipt)
                                 │
                                 ▼
                            G610 (FG Stock)
                                 │
                                 ▼
                            G100 (Sales GI) → ERP
```

---

---

## C220 — IQC Incoming Quality Check (17 SPs — verified)

### Execute SPs (12)

| SP | Chức năng |
|---|---|
| `usp_MaterialQcInfo_iud` | IUD Lot QC header |
| `usp_MaterialQcDetail_iud` | IUD hạng mục kiểm tra |
| `usp_MaterialQcSampleResult_iud` | IUD kết quả đo |
| `usp_DoMakeMaterialIQCDetailList` | Tạo danh sách IQC |
| `usp_DoMakeMaterialQcSampleResult` | Tạo sample result |
| `usp_DoUpdateMaterialQcInfo_Success` | Đánh giá PASS ✅ |
| `usp_DoUpdateMaterialQcInfo_Fail` | Đánh giá FAIL ❌ |
| `usp_DoCancelIQC` | Hủy IQC |
| `usp_DoConfirmIQC` | Xác nhận IQC |
| `usp_DoChangeMaterialQcToPass` | Đổi từ Fail → Pass |
| `usp_DoSendEmailForDefectReportIQC` | Gửi email báo lỗi IQC |
| `usp_IQcDefectReport_iud` | IUD báo cáo lỗi IQC |
| `usp_MaterialQcInfoChangeLotNo_iud` | Đổi LotNo trong QC |
| `usp_NCR_Report_iud` | IUD báo cáo NCR |
| `usp_DefectReportNoChange_iud` | Đổi số báo cáo lỗi |
| `usp_UpdateDefectDetailIQC_VVT` | Cập nhật chi tiết lỗi VVT |
| `usp_ModifyRevisionsVerFromC220_VVTF4` | Sửa revision version (BG2 specific) |

### Search SPs (5)

| SP | Chức năng |
|---|---|
| `usp_MaterialQcInfo_get` | Lấy info Lot QC |
| `usp_MaterialQcDetail_get` | Lấy hạng mục kiểm tra |
| `usp_MaterialQcSampleResult_get` | Lấy kết quả đo |
| `usp_GetMaterialQcInfo_ForReport` | Report QC |
| `usp_QcDefectIQCReport_get` | Lấy báo cáo lỗi IQC |

> ⚠️ C220 là **cổng QC đầu vào** — kết quả PASS/FAIL ảnh hưởng trực tiếp đến khả năng sử dụng NVL tại F430 và B597.

---

*Cập nhật: 2026-06-18 | Dữ liệu từ STB_ScreenObjects + phân tích SP code — VERIFIED against live DB*

---

## Appendix — STB_ScreenObjects Statistics (DB Verified 2026-06-18)

> **Tổng: 1,231 screens → 3,429 SP mappings** (ExecuteFunction + SearchFunction)

### Top 30 Most Complex Screens (by SP count)

| # | Screen (ClassName) | SPs | Phân hệ |
|---|---|---|---|
| 1 | `Vietnam_ElectrodeMeasureResult` | **25** | QC Electrode |
| 2 | `ElectrodeMeasureResult` | 23 | QC Electrode (KR) |
| 3 | `MaterialIqcInfoSampleManagement` | 22 | IQC Sample |
| 4 | `HY_MaterialReceiptAndPrintLabel` | 21 | Kho HY |
| 5 | `MEA_ElectrodeMeasureResult` | 21 | MEA Electrode |
| 6 | `MaterialReceiptAndPrintLabel` | 21 | Kho NVL (F330) |
| 7 | `TestC220ForNewStandard` | 20 | QC C220 test |
| 8 | `VNT_SPT_MaterialOqcInfoSampleManagement` | 19 | OQC SPT |
| 9 | `HY_MaterialOqcInfoSampleManagement` | 19 | OQC HY |
| 10 | `MaterialOqcInfoSampleManagement` | 19 | OQC Sample |
| 11 | `MaterialReturnAndPrintLabel` | 18 | Trả NVL |
| 12 | `Aging_ESR_SD` | 17 | QC Aging ESR |
| 13 | `Vietnam_CheckOQCsample` | 17 | OQC VN |
| 14 | `ProductReturnAndPrintLabel` | 15 | Trả TP |
| 15 | `Vietnam_Donggoi_Hnam` | 13 | Đóng gói HN |
| 16 | `SalesGI` | 13 | Xuất bán hàng |
| 17 | `MaterialProductionGI` | 13 | Xuất NVL SX |
| 18 | `Vietnam_SalesGI` | 13 | Xuất bán VN |
| 19 | `VNT_ProdRouteByBarcode` | 13 | Scan Route VNT |
| 20 | `Kho_Donggoi2` | 12 | Đóng gói 2 |
| 21 | `Vietnam_Donggoi` | 12 | **★ B523** |
| 22 | `VVT_QC_BendingCutting` | 11 | QC Bending |
| 23 | `ProdRouteForPacking` | 11 | Route → Pack |
| 24 | `VNT_DefectStatus` | 11 | Trạng thái lỗi |
| 25 | `MRPManagement` | 9 | Kế hoạch NVL |
| 26 | `FinishGoodReport` | 9 | Báo cáo TP |
| 27 | `ScrapCEOVN` | 9 | Phế liệu VN |
| 28 | `ProductionOrderInfo` | 7 | **★ B310** |
| 29 | `VvtProductionOrderInfo` | 7 | B310 VVT |
| 30 | `BomInfo` | 8 | BOM (A310) |

> [!NOTE]
> Electrode Measure Result (25 SPs) là **màn hình phức tạp nhất** trong toàn hệ thống. Đây là nơi QC đo Viscosity, Thickness, Density cho điện cực — ảnh hưởng trực tiếp đến chất lượng sản phẩm cuối.

### Quick SQL Tra Cứu

```sql
-- Xem tất cả SPs của 1 screen (by ClassName)
SELECT ObjectType, ObjectName 
FROM SmartFramework.dbo.STB_ScreenObjects WITH(NOLOCK) 
WHERE ScreenName = 'TÊN_CLASSNAME' 
AND ObjectType IN ('ExecuteFunction','SearchFunction')
ORDER BY ObjectType, ObjectName

-- Xem tất cả SPs của 1 screen (by TCode)  
SELECT SO.ObjectType, SO.ObjectName 
FROM SmartFramework.dbo.STB_ScreenInfo SI WITH(NOLOCK)
JOIN SmartFramework.dbo.STB_ScreenObjects SO WITH(NOLOCK) ON SI.Name = SO.ScreenName
WHERE SI.TCode = 'B523'
AND SO.ObjectType IN ('ExecuteFunction','SearchFunction')
```

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: STB_ScreenObjects Statistics (1,231 screens → 3,429 mappings) + Top 30 Most Complex Screens. DB verified.*
