# Tài Liệu Chi Tiết 9 Màn Hình Gốc — Clone Sang HY

> **Ngày tạo:** 2026-06-27  
> **Nguồn dữ liệu:** DB thực tế `SmartFramework.dbo.STB_ScreenObjects` + `SmartFactoryV2`  
> **Mục đích:** Tài liệu đầy đủ từng object (View, SearchFunction, ExecuteFunction, Action/Button) của 9 màn hình gốc đang clone sang nhà máy Hưng Yên (VVT_F5).

---

## Mục Lục

1. [C121 — QcInspectionGroup](#1-c121--qcinspectiongroup)
2. [C122 — MaterialQcInspectionItemByMaterial](#2-c122--materialqcinspectionitembymaterial)
3. [C220 — MaterialIqcInfoSampleManagement](#3-c220--materialiqcinfosamplemanagement)
4. [B310 — ProductionOrderInfo](#4-b310--productionorderinfo)
5. [B442 — ElectrodePlan_Vietnam](#5-b442--electrodeplan_vietnam)
6. [B470 — VNT_ElectrodePrcsCard](#6-b470--vnt_electrodeprcscard)
7. [B552 — Vietnam_ElectrodeMeasureResult](#7-b552--vietnam_electrodemeasureresult)
8. [B802 — Vietnam_EletrodeProdRouteHist](#8-b802--vietnam_eletrodeprodRoutehist)
9. [C460 — ElectrodeInspectionHistoryForBarcode](#9-c460--electrodeinspectionhistoryforbarcode)

---

## 1. C121 — QcInspectionGroup

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C121` |
| **Screen Name** | `QcInspectionGroup` |
| **Parent Menu** | `QM_BI_IQC_MENU` |
| **Caption** | Quản lý nhóm/hạng mục QC |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 2 ExecuteFunction) |

### Nghiệp vụ

Màn hình cấu hình **nền tảng QC** — thiết lập danh mục nhóm kiểm tra (Inspection Group) và hạng mục kiểm tra (Inspection Item) cho toàn bộ quy trình QC.

**Workflow:**
1. Tạo **nhóm kiểm tra** (vd: "Kiểm tra ngoại quan", "Kiểm tra kích thước")
2. Trong mỗi nhóm, thêm các **hạng mục kiểm tra** (vd: "Chiều dài", "Chiều rộng")
3. Mỗi hạng mục có: loại dữ liệu (số/checkbox), đơn vị đo, giới hạn USL/LSL/UCL/LCL, AQL, Inspection Level
4. Data C121 → C122 reference → C220 tự động áp dụng khi tạo phiếu IQC

### Cấu Trúc UI

```
┌───────────────────────────────────────────────┐
│  QcInspectiongroupList (Grid trên)            │
│  ─ Danh sách nhóm kiểm tra QC                │
│  ─ Chọn 1 row → load grid dưới               │
├───────────────────────────────────────────────┤
│  QcInspectionItem (Grid dưới)                 │
│  ─ Các hạng mục trong nhóm đang chọn         │
│  ─ Inline edit: Thêm/Sửa/Xóa hạng mục       │
└───────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `QcInspectiongroupList` | QcInspectiongroupList | Grid hiển thị danh sách nhóm kiểm tra QC. Chọn 1 row → trigger load grid Item bên dưới. |
| 2 | `QcInspectionItem` | QcInspectionItem | Grid hiển thị danh sách hạng mục kiểm tra thuộc nhóm đang chọn. Hỗ trợ inline edit. |

### SearchFunctions (2)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_QcInspectionGroup_get` | Lấy danh sách nhóm kiểm tra QC | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pQcInspectionGroupCode` varchar(20) |
| 2 | `usp_QcInspectionItem_get` | Lấy danh sách hạng mục QC theo nhóm | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pQcInspectionGroupCode` varchar(20) |

### ExecuteFunctions (2)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_QcInspectionGroup_iud` | Thêm/Sửa/Xóa nhóm kiểm tra QC | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pProcessViewName` varchar(50), `@pXml` nvarchar(MAX) |
| 2 | `usp_QcInspectionItem_iud` | Thêm/Sửa/Xóa hạng mục QC | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pProcessViewName` varchar(50), `@pXml` nvarchar(MAX) |

### Actions/Buttons (0)

> Màn hình C121 **không có Action/Button riêng**. Thao tác CRUD được thực hiện trực tiếp trên grid (inline edit) thông qua các ExecuteFunction ở trên.

### Bảng DB Chính

| Bảng | Cột chính | Mô tả |
|---|---|---|
| `STB_QcInspectionGroup` | `QcInspectionGroupCode` (PK), `QcInspectionGroupName`, `QcInspectionGroupDesc`, `IsUsed` | Danh mục nhóm kiểm tra |
| `STB_QcInspectionItem` | `QcInspectionItemCode` (PK), `QcInspectionGroupCode` (FK), `QcInspectionItemName`, `InspectionType`, `SpecValue`, `USL`, `LSL`, `UCL`, `LCL`, `AQL`, `InspectionLevel` | Danh mục hạng mục kiểm tra thuộc nhóm |

---

## 2. C122 — MaterialQcInspectionItemByMaterial

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C122` |
| **Screen Name** | `MaterialQcInspectionItemByMaterial` |
| **Parent Menu** | `QM_BI_IQC_MENU` |
| **Caption** | Tiêu chuẩn kiểm tra nguyên liệu |
| **Tổng Objects** | **9** (2 View + 1 SearchFunction + 1 ExecuteFunction + 5 Action) |

### Nghiệp vụ

Thiết lập **tiêu chuẩn kiểm tra cho từng mã nguyên liệu** — mapping mã NVL → bộ hạng mục QC cần kiểm.

**Workflow:**
1. Chọn **MaterialCode** từ popup (`usp_MaterialMaster_popup`)
2. Gán **hạng mục kiểm tra** từ C121 cho NVL đó (Import)
3. Thiết lập **AQL level**, **Inspection Level**, **số lượng mẫu**
4. Khi NVL nhập kho → C220 tự động tạo phiếu IQC dựa trên config tại C122

**Quan hệ:** C121 (định nghĩa hạng mục) → **C122 (gán cho NVL)** → C220 (kiểm tra thực tế)

### Cấu Trúc UI

```
┌───────────────────────────────────────────────┐
│  MaterialInformation (Grid header)            │
│  ─ Thông tin NVL đang chọn (readonly)         │
├───────────────────────────────────────────────┤
│  MaterialQcInspectionItem_ByMaterial (Grid)   │
│  ─ Danh sách hạng mục QC gán cho NVL         │
│  ─ Inline edit + 5 Action buttons             │
├───────────────────────────────────────────────┤
│  [Import Group/Item] [Import NVL khác]        │
│  [Set AQL] [Set Level] [Set InspType]         │
└───────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `MaterialInformation` | Material Information | Grid header hiển thị thông tin mã NVL đang xem (readonly). |
| 2 | `MaterialQcInspectionItem_ByMaterial` | MaterialQcInspectionItem_ByMaterial | Grid chính hiển thị danh sách hạng mục QC đã gán cho NVL. Hỗ trợ inline edit. |

### SearchFunctions (1)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_ByMaterial_get` | Lấy hạng mục QC đã gán cho NVL | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pMaterialCode` varchar(50) |

### ExecuteFunctions (1)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_MaterialQcInspectionItem_iud` | Thêm/Sửa/Xóa hạng mục QC gán cho NVL | `@pProcessUserID` varchar(20), `@pProcessLanguage` varchar(20), `@pProcessViewName` varchar(50), `@pXml` nvarchar(MAX) |

### Actions/Buttons (5)

| # | ObjectName | Caption | Mô tả | SP/Logic |
|---|---|---|---|---|
| 1 | **`ImportFromInspectionItem`** | Import từ Group/Item | Mở popup cho phép import hàng loạt hạng mục QC từ một nhóm kiểm tra (Group) đã tạo ở C121 vào NVL đang chọn. | Đọc từ `STB_QcInspectionItem` → insert vào `STB_MaterialQcInspectionItem` |
| 2 | **`ImportFromMaterialInspectionItem`** | Import từ NVL khác | Mở popup chọn MaterialCode khác → copy toàn bộ cấu hình hạng mục QC từ NVL đó sang NVL hiện tại. | Copy rows từ `STB_MaterialQcInspectionItem` WHERE MaterialCode = @source → insert WHERE MaterialCode = @target |
| 3 | **`SetAql`** | AQL 설정 | Mở popup `usp_GetAql_popup` → chọn AQL level → apply cho các hạng mục đang chọn (multi-select). | `usp_GetAql_popup` → cập nhật cột `AQL` |
| 4 | **`SetLevel`** | Inspection Level 설정 | Mở popup `usp_GetInspectionLevel_popup` → chọn Inspection Level → apply cho các hạng mục đang chọn. | `usp_GetInspectionLevel_popup` → cập nhật cột `InspectionLevel` |
| 5 | **`SetInspectionType`** | Inspection Type 설정 | Mở popup `usp_GetInspectionType_Popup` → chọn Inspection Type → apply cho các hạng mục đang chọn. | `usp_GetInspectionType_Popup` → cập nhật cột `InspectionType` |

### Popup SPs Dùng Chung

| SP | Mô tả | Params chính |
|---|---|---|
| `usp_MaterialMaster_popup` | Popup chọn NVL từ Master | `@pMaterialCode`, `@pMaterialTypeCode`, `@pProductGroupCode`, `@pIsPurchase` |
| `usp_GetAql_popup` | Popup chọn AQL level | *(system params only)* |
| `usp_GetInspectionLevel_popup` | Popup chọn Inspection Level | *(system params only)* |
| `usp_GetInspectionType_Popup` | Popup chọn Inspection Type | *(system params only)* |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_MaterialQcInspectionItem` | Bảng chính: mapping MaterialCode → QcInspectionItemCode + AQL + InspectionLevel + SpecValue |
| `STB_QcInspectionItem` | Bảng ref: danh mục hạng mục QC (từ C121) |
| `STB_QcInspectionGroup` | Bảng ref: danh mục nhóm QC (từ C121) |
| `STB_MaterialMaster` | Bảng ref: danh mục nguyên vật liệu |

---

## 3. C220 — MaterialIqcInfoSampleManagement

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C220` |
| **Screen Name** | `MaterialIqcInfoSampleManagement` |
| **Parent Menu** | `IQC_Inspection` |
| **Caption** | IQC 검사 확인 (IQC Confirmation) |
| **Tổng Objects** | **51** (5 View + 5 SearchFunction + 17 ExecuteFunction + 24 Action) |

### Nghiệp vụ

Màn hình **kiểm tra chất lượng đầu vào (IQC)** — khi nguyên liệu nhập kho qua F330, QC kiểm tra chất lượng trước khi cho phép sử dụng.

**Workflow:**
1. NVL nhập kho (F330) → hệ thống tự tạo **phiếu IQC** (`STB_MaterialQcInfo`)
2. QC chọn phiếu → **Make Detail** → tạo danh sách hạng mục kiểm tra từ C122
3. **Make Sample** → tạo các mẫu để đo
4. QC nhập **kết quả đo** cho từng mẫu, từng hạng mục
5. Quyết định: **Pass** hoặc **Fail**
6. Fail → tạo **Defect Report** → gửi email
7. Có thể **Change to Pass** sau khi Fail nếu được phê duyệt

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  Tab 1: MaterialQcInfoSampleList (Grid chính)                │
│  ─ Filter: FromDate, ToDate, MaterialCode, DecisionResult    │
│  ─ Mỗi row = 1 phiếu IQC                                    │
│  ─ Toolbar: [AllRefresh] [MakeDetail] [Pass] [Fail]          │
│             [ChangeToPass] [SearchLotNo] [ChangeIQCNo]       │
│             [Confirm] [Cancel] [SendEmail] [PrintLabel]      │
│             [SaveRevisionVer] [ImportItem] [ImagePopup]      │
├──────────────────────────────────────────────────────────────┤
│  Tab 2: MaterialQcDetailSampleList (Grid chi tiết)           │
│  ─ Các hạng mục cần đo cho phiếu IQC đang chọn              │
│  ─ [SetAllPass] [SetAllPassByItem]                           │
├──────────────────────────────────────────────────────────────┤
│  Tab 3: MaterialSampleResult (Grid kết quả mẫu)             │
│  ─ Kết quả đo từng mẫu cho hạng mục đang chọn               │
│  ─ [MakeSampleResult] [RefreshSampleList]                    │
├──────────────────────────────────────────────────────────────┤
│  Tab 4: QcDefectIQCEnrollment (Grid đăng ký lỗi)            │
│  ─ Thêm/sửa báo cáo lỗi IQC (Defect Report)                │
│  ─ [SaveDefectDetail]                                        │
├──────────────────────────────────────────────────────────────┤
│  Tab 5: NonconformingReport (NCR View)                       │
│  ─ Non-Conformance Report                                    │
└──────────────────────────────────────────────────────────────┘
```

### Views (5)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `MaterialQcInfoSampleList` | IQC Sample List | Grid chính — danh sách phiếu IQC. Filter theo ngày, mã NVL, kết quả. |
| 2 | `MaterialQcDetailSampleList` | Detail Sample | Grid chi tiết — các hạng mục kiểm tra cho phiếu IQC đang chọn. |
| 3 | `MaterialSampleResult` | Sample Result | Grid kết quả đo — từng mẫu cho hạng mục đang chọn ở Tab 2. |
| 4 | `QcDefectIQCEnrollment` | QcDefectIQCEnrollment | Grid đăng ký/xem báo cáo lỗi IQC (Defect Report). |
| 5 | `NonconformingReport` | NonconformingReport | Grid NCR — Non-Conformance Report cho các lỗi không phù hợp. |

### SearchFunctions (5)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_MaterialQcInfo_get` | Lấy danh sách phiếu IQC theo bộ lọc | `@pMaterialDocNo`, `@pMaterialCode`, `@pCustomerCode`, `@pFromDate` date, `@pToDate` date, `@pDecisionResult`, `@pInspectionDocType`, `@pCompanyCode`, `@pWorkCenterCode`, `@pMaterialTypeCode`, `@pProductGroupCode`, `@pDecisionFromDate` date, `@pDecisionToDate` date, `@pProdInspWorkerCode` |
| 2 | `usp_MaterialQcDetail_get` | Lấy chi tiết hạng mục đo của phiếu IQC | `@pMaterialQcNo` varchar(20) |
| 3 | `usp_MaterialQcSampleResult_get` | Lấy kết quả đo từng mẫu | `@pMaterialQcNo` varchar(20), `@pMaterialQcDetailNo` varchar(20) |
| 4 | `usp_QcDefectIQCReport_get` | Lấy báo cáo lỗi IQC | `@pDefectReportNo` varchar(20), `@pLotNo` varchar(MAX), `@pIQCSampleLotList` varchar(MAX) |
| 5 | `usp_GetMaterialQcInfo_ForReport` | Lấy thông tin in báo cáo IQC | `@pMaterialQcNo` varchar(20) |

### ExecuteFunctions (17)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_MaterialQcInfo_iud` | Thêm/Sửa/Xóa phiếu IQC | `@pProcessViewName`, `@pXml` nvarchar(MAX) |
| 2 | `usp_MaterialQcDetail_iud` | Thêm/Sửa/Xóa chi tiết hạng mục IQC | `@pProcessViewName`, `@pXml` |
| 3 | `usp_MaterialQcSampleResult_iud` | Lưu kết quả đo mẫu | `@pProcessViewName`, `@pXml` |
| 4 | `usp_DoMakeMaterialIQCDetailList` | Tạo danh sách chi tiết hạng mục từ C122 config | `@pMaterialQcNo` varchar(20) |
| 5 | `usp_DoMakeMaterialQcSampleResult` | Tạo mẫu đo cho phiếu IQC | `@pProcessViewName`, `@pXml` |
| 6 | `usp_DoUpdateMaterialQcInfo_Success` | Đánh dấu IQC **PASS** | `@pCompanyCode`, `@pProcessViewName`, `@pXml`, `@pProdInspWorkerCode` |
| 7 | `usp_DoUpdateMaterialQcInfo_Fail` | Đánh dấu IQC **FAIL** | `@pProcessViewName`, `@pXml`, `@pProdInspWorkerCode` |
| 8 | `usp_DoChangeMaterialQcToPass` | Đổi từ Fail → **PASS** (sau khi review) | `@pMaterialQcNo` varchar(30) |
| 9 | `usp_IQcDefectReport_iud` | Thêm/Sửa/Xóa báo cáo lỗi IQC | `@pProcessViewName`, `@pXml` |
| 10 | `usp_DoSendEmailForDefectReportIQC` | Gửi email thông báo lỗi IQC | `@pDefectReportNo` varchar(20) |
| 11 | `usp_DefectReportNoChange_iud` | Đổi mã Defect Report cho phiếu IQC | `@pMaterialQcNo`, `@pDefectReportNo` nvarchar(MAX) |
| 12 | `usp_MaterialQcInfoChangeLotNo_iud` | Thay đổi Lot No cho phiếu IQC | `@pMaterialQcNo`, `@pIQCSampleLotList` nvarchar(MAX) |
| 13 | `usp_ModifyRevisionsVerFromC220_VVTF4` | Cập nhật Revision Version cho NVL | `@pProcessViewName`, `@pXml` |
| 14 | `usp_NCR_Report_iud` | Thêm/Sửa/Xóa báo cáo NCR | `@pProcessViewName`, `@pXml` |
| 15 | `usp_UpdateDefectDetailIQC_VVT` | Cập nhật chi tiết lỗi IQC (VVT custom) | `@pProcessViewName`, `@pXml` |
| 16 | `usp_DoCancelIQC` | Hủy phiếu IQC (client-side action) | *(inline client logic)* |
| 17 | `usp_DoConfirmIQC` | Xác nhận phiếu IQC (client-side action) | *(inline client logic)* |

### Actions/Buttons (24)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`AllRefresh`** | AllRefresh | Làm mới toàn bộ các grid trên màn hình (Grid IQC + Detail + Sample). |
| 2 | **`RefreshMaterialQcInfo`** | RefreshMaterialQcInfo | Làm mới riêng grid phiếu IQC (Tab 1). |
| 3 | **`RefreshMIIList`** | Refresh | Làm mới grid Detail hạng mục (Tab 2). |
| 4 | **`RefreshSampleList`** | Refresh | Làm mới grid Sample Result (Tab 3). |
| 5 | **`SearchLotNo`** | SearchLotNo | Popup tìm kiếm phiếu IQC theo Lot Number. Nhập Lot No → tìm phiếu IQC tương ứng. |
| 6 | **`MIIDoSuccess`** | 판정합격 (Pass) | **Button PASS** — khi QC xác nhận NVL đạt chất lượng. Gọi `usp_DoUpdateMaterialQcInfo_Success`. Yêu cầu chọn InspWorkerCode. |
| 7 | **`MIIDoFailure`** | 판정불합격 (Fail) | **Button FAIL** — khi QC xác nhận NVL không đạt. Gọi `usp_DoUpdateMaterialQcInfo_Fail`. Tự động tạo Defect Report. |
| 8 | **`ChangetoPass`** | ChangeToPass | **Đổi Fail → Pass** — sau khi phiếu IQC bị đánh Fail, nếu review lại và phê duyệt → đổi sang Pass. Gọi `usp_DoChangeMaterialQcToPass`. |
| 9 | **`MakeSampleResult`** | Mẫu tạo 생성 | **Tạo mẫu đo** — sau khi đã Make Detail, bấm nút này để tạo N mẫu cho từng hạng mục. Gọi `usp_DoMakeMaterialQcSampleResult`. |
| 10 | **`ImportIqcInspectionItem`** | 검사항목 불러오기 | **Import hạng mục IQC** — nếu chưa có detail, bấm nút này thay vì Make Detail. Gọi `usp_DoMakeMaterialIQCDetailList` để import từ C122 config. |
| 11 | **`ChangeIQCNo`** | ChangeIQCNo | **Đổi Lot No** — thay đổi Lot Number gắn với phiếu IQC. Gọi `usp_MaterialQcInfoChangeLotNo_iud`. |
| 12 | **`DoConfirmProd`** | DoConfirmProd | **Xác nhận phiếu IQC** (Production Confirm). Xác nhận từ phía sản xuất rằng phiếu IQC hợp lệ. Gọi `usp_DoConfirmIQC`. |
| 13 | **`DoCancelProd`** | DoCancelProd | **Hủy xác nhận** (Production Cancel). Hủy xác nhận phiếu IQC. Gọi `usp_DoCancelIQC`. |
| 14 | **`DoConfirmQc`** | DoConfirmQc | **Xác nhận từ QC** — QC confirm phiếu IQC từ phía chất lượng. |
| 15 | **`DoRejectQc`** | DoRejectQc | **Từ chối từ QC** — QC reject phiếu IQC. |
| 16 | **`DoSendEmail`** | DoSendEmail | **Gửi email** — gửi email thông báo cho các bên liên quan về kết quả IQC Fail. Gọi `usp_DoSendEmailForDefectReportIQC`. |
| 17 | **`SaveDefectDetail`** | SaveDefectDetail | **Lưu chi tiết lỗi** — lưu thông tin chi tiết lỗi IQC vào Defect Report. Gọi `usp_UpdateDefectDetailIQC_VVT`. |
| 18 | **`SaveRevisionVer`** | SaveRevisionVer | **Lưu Revision** — cập nhật phiên bản revision cho NVL từ phiếu IQC. Gọi `usp_ModifyRevisionsVerFromC220_VVTF4`. |
| 19 | **`SetAllPass`** | 전체합격 (All Pass) | **All Pass** — đánh dấu Pass cho TẤT CẢ hạng mục trong phiếu IQC cùng lúc. Client-side → cập nhật toàn bộ detail rows. |
| 20 | **`SetAllPassByItem`** | 항목합격 (Pass by Item) | **Pass theo Item** — đánh dấu Pass cho các hạng mục đang chọn (multi-select). |
| 21 | **`InputLabelQty`** | LabelPrint | **Nhập số lượng in nhãn** — mở popup nhập số lượng label NG cần in. |
| 22 | **`PrintLabelSelected`** | NG_Label | **In nhãn NG** — in nhãn dán cho NVL bị đánh Fail (NG label). |
| 23 | **`ImagePopup`** | ImagePopup | **Popup hình ảnh 1** — mở popup xem/upload hình ảnh đính kèm phiếu IQC. |
| 24 | **`ImagePopup2`** | ImagePopup2 | **Popup hình ảnh 2** — mở popup xem/upload hình ảnh đính kèm thứ 2 cho phiếu IQC. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_CompanyInfo_popup` | Chọn nhà máy/công ty |
| `usp_DecisionResult_popup` | Chọn kết quả quyết định (Pass/Fail/Pending) |
| `usp_DefectCauseGroup_popup` | Chọn nhóm nguyên nhân lỗi |
| `usp_DefectCauseGroup` | Lấy danh mục nhóm nguyên nhân |
| `usp_DoConfirmCancelQc2` | Xác nhận/Hủy xác nhận QC. Params: `@pDefectReportNo`, `@pIsConfirm` bit |
| `usp_GetBaseCode_popup` | Popup lấy BaseCode |
| `usp_GetBaseCodeRemarkFilter_popup` | Popup BaseCode lọc Remark |
| `usp_GetTestResult_popup` | Lọc kết quả đo |
| `usp_MaterialTypeCode_popup` | Lọc theo loại NVL |
| `usp_NameErrorIQC` | Lấy tên lỗi IQC |
| `usp_ProdIInspectionWorkerInfo_Popup` | Chọn nhân viên QC |
| `usp_ProductGroup_get` | Lấy nhóm sản phẩm |
| `usp_ProdWorkerInfo_Popup` | Chọn nhân viên SX |
| `usp_PurchaseMaterialMaster_popup` | Chọn NVL mua ngoài |
| `usp_VendorCustomerInfo_popup` | Chọn NCC/khách hàng |
| `usp_WorkCenterInfo_popup` | Chọn Work Center |

### Bảng DB Chính

| Bảng | PK/FK | Mô tả |
|---|---|---|
| `STB_MaterialQcInfo` | PK: `MaterialQcNo` | Phiếu IQC chính. Key cols: `CompanyCode`, `WorkCenterCode`, `MaterialCode`, `DecisionResult`, `DecisionDateTime` |
| `STB_MaterialQcDetail` | FK: `MaterialQcNo` | Chi tiết hạng mục đo theo phiếu |
| `STB_MaterialQcSampleResult` | FK: `MaterialQcNo`, `MaterialQcDetailNo` | Kết quả đo thực tế từng mẫu |
| `STB_IQcDefectReport` | FK: `MaterialQcNo` | Báo cáo lỗi IQC |
| `STB_NCR_REPORT` | — | Báo cáo không phù hợp (NCR) |
| `STB_MaterialMaster` | — | Danh mục NVL |
| `STB_UserInfo` | — | Người dùng hệ thống |

---

## 4. B310 — ProductionOrderInfo

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B310` |
| **Screen Name** | `ProductionOrderInfo` |
| **Parent Menu** | `PM_ProductionOrder_MENU` |
| **Caption** | PO管理登録 (Quản lý PO) |
| **Tổng Objects** | **17** (4 View + 4 SearchFunction + 3 ExecuteFunction + 6 Action) |

### Nghiệp vụ

Màn hình **Lệnh sản xuất (Production Order - PO)** — dùng để lập kế hoạch, tạo, duyệt, Fix và hủy lệnh sản xuất.

**Workflow:**
1. Tạo PO mới → chọn sản phẩm, số lượng, ngày SX
2. Hệ thống tự tạo **BOM** + **Routing** theo master data
3. PO được **Fix** → đóng băng, chuẩn bị sản xuất
4. PO fix → B442/B450 sử dụng để tạo kế hoạch ngày
5. Hủy PO → chỉ hủy được khi chưa phát sinh sản lượng

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  ProductionOrderInfo (Grid chính)                            │
│  ─ Filter: FromYearMonth, ToYearMonth, ProductGroupCode,     │
│            MaterialCode, IsFix, CompanyCode, WorkCenterCode  │
│  ─ Toolbar: [CreateManualPO] [Fix] [POCancel] [Refresh]     │
│             [DoGI] [Tao_PO_ReDroping]                        │
├──────────────────────────────────────────────────────────────┤
│  Tab BOM: ProductionOrderBom                                 │
│  ─ Danh sách NVL định mức cho PO đang chọn                   │
├──────────────────────────────────────────────────────────────┤
│  Tab Routing: ProductionOrderRouting                          │
│  ─ Các công đoạn sản xuất. Inline edit → iud                 │
├──────────────────────────────────────────────────────────────┤
│  Tab GI: MaterialGIForPO                                     │
│  ─ Danh sách NVL cần xuất kho                                │
└──────────────────────────────────────────────────────────────┘
```

### Views (4)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ProductionOrderInfo` | ProductionOrderInfo | Grid chính — danh sách PO. Filter theo tháng, nhóm SP, mã SP, trạng thái Fix/Cancel. |
| 2 | `ProductionOrderBom` | ProductionOrderBom | Tab BOM — chi tiết NVL định mức cho PO đang chọn. |
| 3 | `ProductionOrderRouting` | ProductionOrderRouting | Tab Routing — các công đoạn sản xuất. Hỗ trợ inline edit. |
| 4 | `MaterialGIForPO` | MaterialGIForPO | Tab GI — danh sách NVL cần xuất kho cho PO. |

### SearchFunctions (4)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_ProductionOrderInfo_get` | Lấy danh sách PO | `@pFromYearMonth` date, `@pToYearMonth` date, `@pProductGroupCode`, `@pMaterialCode`, `@pIsFix` bit, `@pCompanyCode`, `@pWorkCenterCode` |
| 2 | `usp_ProductionOrderBom_get` | Lấy BOM theo PO | `@pPONo` varchar(20), `@pMaterialCode` varchar(50), `@pIsUseAll` bit |
| 3 | `usp_ProductionOrderRouting_get` | Lấy Routing theo PO | `@pPONo` varchar(20) |
| 4 | `usp_GetMaterialGIForPO` | Lấy NVL cần cấp phát | `@pPONo` varchar(20) |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_DoFixProductionOrder` | Fix (xác nhận) PO | `@pPONo` varchar(20), `@pBasicRoutingCode` varchar(20) |
| 2 | `usp_DoCancelPO` | Hủy PO | `@pPONo` varchar(20), `@pDefectSummaryNo` varchar(20) |
| 3 | `usp_ProductionOrderRouting_iud` | Sửa/cập nhật Routing | `@pProcessViewName`, `@pXml` |

### Actions/Buttons (6)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`CreateManualPO`** | 수동PO생성 (Tạo PO thủ công) | Mở dialog tạo PO mới bằng tay. Nhập: MaterialCode, BomVersion, PlanYearMonth, StartDate, EndDate, POQty, CompanyCode, WorkCenterCode. Gọi `usp_DoCreateProductionOrder`. |
| 2 | **`Fix`** | 확정 (Xác nhận) | **Fix PO** — xác nhận lệnh sản xuất. PO đã Fix → không thể sửa, chỉ có thể hủy. Gọi `usp_DoFixProductionOrder(@pPONo, @pBasicRoutingCode)`. Sau Fix → B442 có thể tạo kế hoạch ngày. |
| 3 | **`POCancel`** | POCancel | **Hủy PO** — chỉ hủy được khi chưa phát sinh sản lượng thực tế. Gọi `usp_DoCancelPO(@pPONo, @pDefectSummaryNo)`. |
| 4 | **`Refresh`** | Refresh | Làm mới grid chính và tất cả tab phụ. |
| 5 | **`DoGI`** | 자재불출확인 (Xuất kho NVL) | **Goods Issue** — thực hiện xuất kho NVL cho PO. Lấy data từ tab MaterialGIForPO → tạo phiếu xuất kho. |
| 6 | **`Tao_PO_ReDroping`** | Tao_PO_ReDroping | **Tạo PO Re-Dropping** — tạo PO mới cho cuộn sấy lại (re-dropping). Chức năng đặc biệt cho quy trình Electrode. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_DoCreateProductionOrder` | Xử lý tạo PO. Params: `@pPlanYearMonth`, `@pPlanStartDate`, `@pPlanEndDate`, `@pMaterialCode`, `@pBomVersion`, `@pPOQty`, `@pCompanyCode`, `@pWorkCenterCode`, `@pPONos`, `@pIgnoreMaxPlanQty` |
| `usp_BasicRoutingInfo_popup` | Popup chọn quy trình công nghệ |
| `usp_CompanyInfo_popup` | Popup chọn Company/Plant |
| `usp_GetRouteInfoAll_popup` | Popup chọn công đoạn |
| `usp_ProductionMaterialPopup` | Popup chọn vật tư SX |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProductionOrderInfo` | PK: `PONo`. Lệnh sản xuất chính. Key cols: `CompanyCode`, `WorkCenterCode`, `MaterialCode`, `POQty`, `IsFix`, `IsCancel` |
| `STB_ProductionOrderBom` | FK: `PONo`. Định mức NVL theo PO |
| `STB_ProductionOrderRouting` | FK: `PONo`. Quy trình công đoạn theo PO |
| `STB_MaterialMaster` | Danh mục NVL/SP |
| `STB_BasicRoutingInfo` | Danh mục quy trình công nghệ chuẩn |
| `STB_RouteInfo` | Danh mục công đoạn |
| `STB_SetInfo` | Thông tin Lot/Cuộn tạo ra từ PO |

---

## 5. B442 — ElectrodePlan_Vietnam

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B442` |
| **Screen Name** | `ElectrodePlan_Vietnam` |
| **Parent Menu** | `v_ElectrodeArea` |
| **Caption** | Ke hoach Dien cuc (Kế hoạch Điện cực) |
| **Tổng Objects** | **21** (3 View + 3 SearchFunction + 4 ExecuteFunction + 11 Action) |

### Nghiệp vụ

Màn hình **kế hoạch sản xuất hàng ngày cho Electrode** — chia PO thành các Set/Lot sản xuất thực tế theo ngày, máy và ca.

**Workflow:**
1. Chọn PO đã Fix từ B310
2. Tạo **DayProdPlan** → chỉ định sản phẩm, số lượng, dây chuyền
3. Tạo **SetInfo** (Lot/Cuộn) → gán vào Plan
4. **Fix** Plan → đóng băng Lot → cho phép in tem barcode
5. Cancel Plan nếu cần

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  DayProdPlan (Grid trên)                                     │
│  ─ Filter: CompanyCode, WorkCenterCode, LineCode, FromDate,  │
│            ToDate, MaterialTypeCode, ProductGroupCode,       │
│            CancelShow, CreateUserID                          │
│  ─ Toolbar: [POSelectDialog] [FixDayPlan] [CancelDayPlan]   │
│             [Refresh] [DoGI]                                 │
├──────────────────────────────────────────────────────────────┤
│  SetInfo (Grid giữa)                                         │
│  ─ Chi tiết Lot/Cuộn trong kế hoạch đang chọn                │
│  ─ Toolbar: [CopyLot] [LabelPrint] [InputLabelQty]          │
│             [RefreshSetInfo] [AddMainAssemblePart]           │
│             [AddPartWeight]                                  │
├──────────────────────────────────────────────────────────────┤
│  MainAssemblePartWeight (Grid dưới)                          │
│  ─ Trọng lượng phụ kiện lắp ráp                              │
└──────────────────────────────────────────────────────────────┘
```

### Views (3)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `DayProdPlan` | DayProdPlan | Grid trên — kế hoạch sản xuất ngày. Mỗi row = 1 kế hoạch ngày. |
| 2 | `SetInfo` | SetInfo | Grid giữa — danh sách Lot/Cuộn trong kế hoạch. Inline edit. |
| 3 | `MainAssemblePartWeight` | MainAssemblePartWeight | Grid dưới — trọng lượng phụ kiện lắp ráp cho Lot đang chọn. |

### SearchFunctions (3)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_DayProdPlan_get` | Lấy kế hoạch SX ngày | `@pUtcOffset` int, `@pCompanyCode`, `@pWorkCenterCode`, `@pLineCode`, `@pFromDate` date, `@pToDate` date, `@pBasicMaterialType`, `@pMaterialTypeCode`, `@pProductGroupCode`, `@pCancelShow` bit, `@pCreateUserID` |
| 2 | `usp_SetInfo_get` | Lấy Lot/Set trong Plan | `@pUtcOffset` int, `@pPONo`, `@pDayPlanNo`, `@pLabelType` nvarchar(30) |
| 3 | `usp_MainAssemblePartWeight_get` | Lấy trọng lượng phụ kiện | `@pControlNo` varchar(20) |

### ExecuteFunctions (4)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_DayProdPlan_iud` | Thêm/Sửa/Xóa kế hoạch ngày | `@pProcessViewName`, `@pXml` |
| 2 | `usp_SetInfo_iud_VNT` | Tạo/Cập nhật Lot/Set (VNT version) | `@pProcessViewName`, `@pCompanyCode`, `@pXml` |
| 3 | `usp_DoFixDayProdPlan` | Fix kế hoạch ngày | `@pDayPlanNo` varchar(20) |
| 4 | `usp_DoCancelDayProdPlan` | Hủy kế hoạch ngày | `@pDayPlanNo` varchar(20) |

### Actions/Buttons (11)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`POSelectDialog`** | POSelectDialog | **Chọn PO** — mở popup chọn Production Order từ B310 để gán cho kế hoạch ngày. Chỉ hiển thị PO đã Fix. |
| 2 | **`FixDayPlan`** | FixDayPlan | **Fix kế hoạch ngày** — đóng băng kế hoạch + tất cả Lot bên trong. Sau Fix → có thể in tem barcode. Gọi `usp_DoFixDayProdPlan(@pDayPlanNo)`. |
| 3 | **`CancelDayPlan`** | CancelDayPlan | **Hủy kế hoạch ngày** — chỉ hủy được khi chưa phát sinh kết quả sản xuất. Gọi `usp_DoCancelDayProdPlan(@pDayPlanNo)`. |
| 4 | **`Refresh`** | Refresh | Làm mới grid kế hoạch ngày (Grid trên). |
| 5 | **`RefreshSetInfo`** | Refresh | Làm mới grid Lot/Set (Grid giữa). |
| 6 | **`CopyLot`** | CopyLot | **Nhân bản Lot** — copy thông tin Lot đang chọn → tạo Lot mới giống hệt (giảm nhập liệu lặp lại). Client-side copy + insert. |
| 7 | **`LabelPrint`** | LabelPrint | **In nhãn barcode** — in nhãn barcode cho Lot/Cuộn Electrode đang chọn. Gửi lệnh in đến máy in đã cấu hình. |
| 8 | **`InputLabelQty`** | LabelPrint | **Nhập số lượng in nhãn** — mở popup nhập số lượng label cần in trước khi in. |
| 9 | **`DoGI`** | 자재불출확인 (Xuất kho NVL) | **Goods Issue** — xuất kho NVL phụ cho kế hoạch ngày. |
| 10 | **`AddMainAssemblePart`** | 부품Lot관리 (Quản lý Lot phụ kiện) | **Gán phụ kiện** — mở popup gán phụ kiện lắp ráp (Main Assemble Part) cho Lot Electrode. |
| 11 | **`AddPartWeight`** | 부품중량 (Trọng lượng phụ kiện) | **Ghi nhận trọng lượng** — mở popup ghi nhận trọng lượng phụ kiện. Data hiển thị ở grid dưới (MainAssemblePartWeight). |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_BomVersion_popup` | Popup chọn phiên bản BOM |
| `usp_CompanyInfo_popup` | Popup chọn Company/Plant |
| `usp_LineInfo_popup` | Popup chọn Line |
| `usp_ProductGroup_popup` | Popup chọn nhóm SP |
| `usp_ProductionMaterialPopup` | Popup chọn vật tư SX |
| `usp_RouteInfoForLine_popup` | Popup chọn công đoạn thuộc Line |
| `usp_ShiftCode_popup` | Popup chọn ca làm việc |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_DayProdPlan` | PK: `DayPlanNo`. Kế hoạch SX ngày. Key cols: `CompanyCode`, `WorkCenterCode`, `LineCode`, `PONo`, `PlanDate`, `IsFix`, `IsCancel` |
| `STB_SetInfo` | PK: `ControlNo`. Lot/Cuộn Electrode. FK: `PONo`, `DayPlanNo`. Key cols: `SetNo`, `MaterialCode`, `Barcode` |
| `STB_ProductionOrderInfo` | Lệnh sản xuất |
| `STB_MaterialMaster` | Danh mục NVL/SP |
| `STB_LineInfo` | Danh mục Line |
| `STB_MachineMaster` | Danh mục máy |
| `STB_MainAssemblePartWeight` | Trọng lượng phụ kiện |
| `STB_LabelInfo` | Cấu hình in nhãn |

---

## 6. B470 — VNT_ElectrodePrcsCard

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B470` |
| **Screen Name** | `VNT_ElectrodePrcsCard` |
| **Parent Menu** | `Plan_Management` |
| **Caption** | VNT_ElectrodePrcsCard (Process Card Electrode) |
| **Tổng Objects** | **10** (3 View + 3 SearchFunction + 3 ExecuteFunction + 1 Action) |

### Nghiệp vụ

Màn hình **thiết lập công đoạn trộn (Mixing Process Card)** cho sản xuất Electrode — định nghĩa quy trình trộn khô, trộn ướt, khuấy, cấu hình thông số kỹ thuật và gán NVL.

**Workflow:**
1. Tạo công đoạn Electrode (Trộn khô, Trộn ướt, Khuấy)
2. Thiết lập thông số vận hành (nhiệt độ, tốc độ, thời gian)
3. Cấu hình lò sấy (nhiệt độ sấy, thời gian sấy)
4. Gán NVL cần dùng cho mỗi step

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  Tab 1: ElectrodeStep (Grid bước trộn)                       │
│  ─ Danh sách công đoạn trộn, thứ tự trộn                     │
│  ─ Filter: ProdCode (mã sản phẩm electrode)                  │
│  ─ Inline edit: Thêm/Sửa/Xóa bước                           │
├──────────────────────────────────────────────────────────────┤
│  Tab 2: ElectrodeCommon (Grid thông số)                      │
│  ─ Thông số chung: tốc độ, thời gian, nhiệt độ              │
│  ─ Inline edit                                               │
├──────────────────────────────────────────────────────────────┤
│  Tab 3: ElectrodeOven (Grid lò sấy)                          │
│  ─ Cấu hình nhiệt độ sấy, thời gian sấy                     │
│  ─ Inline edit                                               │
├──────────────────────────────────────────────────────────────┤
│  Toolbar: [ElectrodePrcsCardPrint]                           │
└──────────────────────────────────────────────────────────────┘
```

### Views (3)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ElectrodeStep` | ElectrodeStep | Tab 1 — danh sách công đoạn trộn. Inline edit. |
| 2 | `ElectrodeCommon` | ElectrodeCommon | Tab 2 — thông số chung (tốc độ, thời gian). Inline edit. |
| 3 | `ElectrodeOven` | ElectrodeOven | Tab 3 — cấu hình lò sấy. Inline edit. |

### SearchFunctions (3)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_ElectrodeStep_get` | Lấy bước trộn theo sản phẩm | `@pProdCode` varchar(20) |
| 2 | `usp_ElectrodeCommon_get` | Lấy thông số bước trộn | `@pProdCode` varchar(20) |
| 3 | `usp_ElectrodeOven_get` | Lấy cấu hình lò sấy | `@pProdCode` varchar(20) |

### ExecuteFunctions (3)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_ElectrodeStep_iud` | Thêm/Sửa/Xóa bước trộn | `@pProcessViewName`, `@pXml` |
| 2 | `usp_ElectrodeCommon_iud` | Thêm/Sửa/Xóa thông số | `@pProcessViewName`, `@pXml` |
| 3 | `usp_ElectrodeOven_iud` | Thêm/Sửa/Xóa cấu hình sấy | `@pProcessViewName`, `@pXml` |

### Actions/Buttons (1)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`(Korean name)`** | ElectrodePrcsCardPrint | **In Process Card** — in phiếu công nghệ (Process Card) cho Electrode. In toàn bộ thông tin các bước trộn + thông số + cấu hình sấy của sản phẩm đang chọn ra giấy A4. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_ElectrodeStep_popup` | Popup chọn bước trộn |
| `usp_MaterialMasterByMaterialType_popup` | Popup chọn NVL theo loại |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ElectrodeStep` | PK: tương ứng ProdCode + StepCode. Danh sách bước trộn Electrode |
| `STB_ElectrodeCommon` | Thông số kỹ thuật cho từng bước trộn |
| `STB_ElectrodeOven` | Cấu hình lò sấy |
| `STB_MaterialMaster` | Danh mục NVL |
| `STB_BaseCode` | Danh mục code hệ thống |

---

## 7. B552 — Vietnam_ElectrodeMeasureResult

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B552` |
| **Screen Name** | `Vietnam_ElectrodeMeasureResult` |
| **Parent Menu** | `v_ElectrodeArea` |
| **Caption** | Vietnam_ElectrodeMeasureResult |
| **Tổng Objects** | **58** (11 View + 11 SearchFunction + 14 ExecuteFunction + 22 Action) |

### Nghiệp vụ

Màn hình **phức tạp nhất quy trình Electrode** — nhập toàn bộ kết quả sản xuất Electrode qua tất cả các công đoạn: Mixing (Trộn), Coating (Phủ), RollPressing (Cán), Slitting (Cắt), đo Viscosity, in tem barcode cho từng cuộn và ghi nhận phế liệu (Waste).

**Workflow theo công đoạn:**
1. **Mixing:** Chọn mẻ → nhập kết quả trộn + chi tiết từng bước
2. **Coating:** Quét lot bột → nhập kết quả phủ + kiểm tra ngoại quan + đo độ nhớt → in tem
3. **RollPressing:** Quét cuộn phủ → nhập kết quả cán + kiểm tra ngoại quan → in tem
4. **Slitting:** Quét cuộn cán → nhập kết quả cắt → in tem
5. **Waste:** Ghi nhận phế liệu thu hồi

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────────────┐
│  ═══ TAB MIXING ═══                                                  │
│  ElectrodeMixInfo (Grid trộn chính)                                  │
│  ─ Kết quả mẻ trộn. Filter: ElectrodeLotNumber                      │
│  ElectrodeMixStepInfo (Grid chi tiết bước)                           │
│  ─ Thông số chạy chi tiết từng bước trộn                             │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB COATING ═══                                                 │
│  ElectrodeCoatingInfo (Grid phủ chính)                               │
│  ─ Kết quả phủ cuộn. Toolbar: [PrintLabel] [CheckPrint]             │
│    [PackingLabelPrintCoating] [VietnamPackLabelCoating]               │
│    [UpdatePrintYn]                                                   │
│  ElectrodeCoatingVisualInspectionInfo (Grid ngoại quan Coating)      │
│  ─ Kết quả kiểm tra ngoại quan phủ                                   │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB ROLLPRESSING ═══                                            │
│  ElectrodeRollPressingInfo (Grid cán chính)                          │
│  ─ Toolbar: [CheckPrint2] [PackingLabelPrintRollPress]               │
│    [PackingLabelPrintRollPressNormal] [VietnamPackLabelRollPress]     │
│    [UpdatePrintYn2]                                                  │
│  ElectrodeRollPressingVisualInspectionInfo (Grid ngoại quan cán)     │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB SLITTING ═══                                                │
│  ElectrodeSlittingInfo (Grid cắt chính)                              │
│  ─ Toolbar: [CreateSlittingInfo] [ScanSlittingLocation]              │
│    [ScanSlittingLocation2] [UpdatePrintYn3]                          │
│  ElectrodeSlittingResult (Grid chi tiết cuộn con)                    │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB WASTE ═══                                                   │
│  ElectrodeWastePriceNewByBarcode (Grid phế liệu)                    │
│  ─ Toolbar: [PrintElectrodeWasteLabel] [PrintElectrodeWasteList]     │
│    [ElectrodeWasteLabelPrintAction] [FoilWasteLabelPrintAction]      │
│    [PrintFoilWasteList]                                              │
├──────────────────────────────────────────────────────────────────────┤
│  ═══ TAB PHỤ ═══                                                    │
│  LocationElectric (Grid đo điện)                                     │
│  Vietnam_RollPressingSlitting (Grid cán cắt liên tục)                │
│  ─ Toolbar: [DoElectrodeInspection] [RefreshView]                    │
│    [CheckPrintExpired]                                               │
└──────────────────────────────────────────────────────────────────────┘
```

### Views (11)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ElectrodeMixInfo` | ElectrodeMixInfo | Grid trộn chính — kết quả mẻ trộn bột Electrode. |
| 2 | `ElectrodeMixStepInfo` | ElectrodeMixStepInfo | Grid chi tiết bước — thông số chạy từng bước trộn (tốc độ, thời gian, nhiệt độ). |
| 3 | `ElectrodeCoatingInfo` | ElectrodeCoatingInfo | Grid phủ chính — kết quả phủ cuộn Electrode. |
| 4 | `ElectrodeCoatingVisualInspectionInfo` | ElectrodeCoatingVisualInspectionInfo | Grid ngoại quan Coating — kiểm tra bề mặt cuộn phủ. |
| 5 | `ElectrodeRollPressingInfo` | ElectrodeRollPressingInfo | Grid cán chính — kết quả cán cuộn Electrode. |
| 6 | `ElectrodeRollPressingVisualInspectionInfo` | ElectrodeRollPressingVisualInspectionInfo | Grid ngoại quan cán — kiểm tra bề mặt cuộn cán. |
| 7 | `ElectrodeSlittingInfo` | ElectrodeSlittingInfo | Grid cắt chính — kết quả cắt chia cuộn. |
| 8 | `ElectrodeSlittingResult` | ElectrodeSlittingResult | Grid chi tiết cuộn con — dữ liệu các cuộn nhỏ sau khi cắt. |
| 9 | `ElectrodeWastePriceNewByBarcode` | ElectrodeWastePriceNewByBarcode | Grid phế liệu — ghi nhận lượng phế liệu theo barcode. |
| 10 | `LocationElectric` | LocationElectric | Grid phụ — thông tin vị trí đo điện cực. |
| 11 | `Vietnam_RollPressingSlitting` | Vietnam_RollPressingSlitting | Grid phụ — quy trình cán cắt liên tục (combined view). |

### SearchFunctions (11)

| # | ObjectName | Mô tả | Params chính |
|---|---|---|---|
| 1 | `usp_ElectrodeMixInfo_get` | Lấy kết quả trộn | `@pElectrodeLotNumber` varchar(20) |
| 2 | `usp_ElectrodeMixStepInfo_get` | Lấy chi tiết bước trộn | `@pElectrodeLotNumber` varchar(20) |
| 3 | `usp_ElectrodeCoatingInfo_get` | Lấy kết quả phủ | `@pElectrodeLotNumber` varchar(20) |
| 4 | `usp_ElectrodeCoatingVisualInspectionInfo_get` | Lấy ngoại quan Coating | `@pElectrodeLotNumber` varchar(20) |
| 5 | `usp_ElectrodeRollPressingInfo_get` | Lấy kết quả cán | `@pElectrodeLotNumber` varchar(20) |
| 6 | `usp_ElectrodeRollPressingVisualInspectionInfo_get` | Lấy ngoại quan cán | `@pElectrodeLotNumber` varchar(20) |
| 7 | `usp_ElectrodeSlittingInfo_get` | Lấy kết quả cắt | `@pElectrodeLotNumber` varchar(20) |
| 8 | `usp_ElectrodeSlittingResult_get` | Lấy chi tiết cuộn con | `@pElectrodeLotNumber` varchar(20) |
| 9 | `usp_ElectrodeWastePriceNewByBarcode_get` | Lấy phế liệu theo barcode | `@pBarcode` varchar(20) |
| 10 | `usp_LocationElectric` | Lấy vị trí đo điện cực | `@pElectrodeLotNumber` varchar(30) |
| 11 | `usp_Vietnam_RollPressingSlitting_get` | Lấy quy trình cán cắt | `@pElectrodeLotNumber` varchar(20) |

### ExecuteFunctions (14)

| # | ObjectName | Mô tả | Params chính |
|---|---|---|---|
| 1 | `usp_ElectrodeMixInfo_iud` | Lưu kết quả trộn | `@pProcessViewName`, `@pXml` |
| 2 | `usp_ElectrodeMixStepInfo_iud` | Lưu chi tiết bước trộn | `@pProcessViewName`, `@pXml` |
| 3 | `usp_ElectrodeCoatingInfo_iud` | Lưu kết quả phủ | `@pProcessViewName`, `@pXml` |
| 4 | `usp_ElectrodeCoatingVisualInspectionInfo_iud` | Lưu ngoại quan Coating | `@pProcessViewName`, `@pXml` |
| 5 | `usp_ElectrodeRollPressingInfo_iud` | Lưu kết quả cán | `@pProcessViewName`, `@pXml` |
| 6 | `usp_ElectrodeRollPressingVisualInspectionInfo_iud` | Lưu ngoại quan cán | `@pProcessViewName`, `@pXml` |
| 7 | `usp_ElectrodeSlittingInfo_iud` | Lưu kết quả cắt | `@pProcessViewName`, `@pXml` |
| 8 | `usp_ElectrodeSlittingResult_iud` | Lưu chi tiết cuộn con | `@pProcessViewName`, `@pXml`, `@pElectrodeLotNumber` |
| 9 | `usp_ElectrodCoatingInfo_Viscosity_VVT_iud` | Lưu kết quả đo độ nhớt | `@pProcessViewName`, `@pXml` |
| 10 | `usp_DoUpdateCoatingBarcodePrintYn` | Cập nhật trạng thái in nhãn Coating | `@pElectrodeLotNumber` varchar(20) |
| 11 | `usp_DoUpdateRollPressBarcodePrintYn` | Cập nhật trạng thái in nhãn RollPress | `@pElectrodeLotNumber` varchar(20) |
| 12 | `usp_DoUpdateSlitingBarcodePrintYn` | Cập nhật trạng thái in nhãn Slitting | `@pElectrodeLotNumber` varchar(20) |
| 13 | `usp_ElectrodeWasteInfoNew_iud` | Ghi nhận phế liệu | `@pProcessViewName`, `@pXml` |
| 14 | `usp_test_check_expired` | Kiểm tra hạn sử dụng NVL trộn | `@pRawMaterialBarcode1` nvarchar(200) |

### Actions/Buttons (22)

#### Nhóm MIXING

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`RefreshView`** | RefreshView | Làm mới toàn bộ các grid trên màn hình. |
| 2 | **`CheckPrintExpired`** | CheckPrintExpiredn | **Kiểm tra hạn** — kiểm tra hạn sử dụng nguyên vật liệu trộn bột. Gọi `usp_test_check_expired(@pRawMaterialBarcode1)`. Nếu hết hạn → cảnh báo không cho trộn. |

#### Nhóm COATING

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 3 | **`PrintLabel`** | PrintLabel | **In nhãn Coating** — in tem barcode cho cuộn Electrode sau khi phủ. Ghi nhận PrintYn. |
| 4 | **`CheckPrint`** | CheckPrint | **Kiểm tra in nhãn Coating** — kiểm tra cuộn đã in nhãn chưa trước khi cho qua công đoạn tiếp. |
| 5 | **`PackingLabelPrintCoating`** | PackingLabelPrintCoating | **In nhãn đóng gói Coating** — in nhãn cho việc đóng gói cuộn Coating. |
| 6 | **`VietnamPackLabelCoating`** | VietnamPackLabelCoating | **In nhãn VN (Coating)** — bản in nhãn theo format VN cho Coating. |
| 7 | **`UpdatePrintYn`** | UpdatePrintYn | **Cập nhật trạng thái in Coating** — đánh dấu cuộn đã in nhãn. Gọi `usp_DoUpdateCoatingBarcodePrintYn(@pElectrodeLotNumber)`. |

#### Nhóm ROLLPRESSING

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 8 | **`CheckPrint2`** | CheckPrint2 | **Kiểm tra in nhãn RollPress** — kiểm tra cuộn cán đã in nhãn chưa. |
| 9 | **`PackingLabelPrintRollPress`** | PackingLabelPrintRollPress | **In nhãn đóng gói RollPress** — in nhãn cho cuộn cán. |
| 10 | **`PackingLabelPrintRollPressNormal`** | PackingLabelPrintRollPressNormal | **In nhãn RollPress thường** — bản in nhãn tiêu chuẩn cho cuộn cán (không phải special). |
| 11 | **`VietnamPackLabelRollPress`** | VietnamPackLabelRollPress | **In nhãn VN (RollPress)** — bản in nhãn theo format VN cho cuộn cán. |
| 12 | **`UpdatePrintYn2`** | UpdatePrintYn2 | **Cập nhật trạng thái in RollPress** — gọi `usp_DoUpdateRollPressBarcodePrintYn(@pElectrodeLotNumber)`. |

#### Nhóm SLITTING

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 13 | **`CreateSlittingInfo`** | CreateSlittingInfo | **Tạo Slitting Info** — tạo dữ liệu cắt cuộn từ cấu hình SlittingLocationConfig. Phải chạy trước khi nhập kết quả cắt. |
| 14 | **`ScanSlittingLocation`** | Scan Slitting Location | **Quét vị trí cắt** — quét barcode cuộn cán → hệ thống load cấu hình chia cuộn (SlittingLocationConfig) → hiển thị vị trí cắt. |
| 15 | **`ScanSlittingLocation2`** | Scan Slitting Location. | **Quét vị trí cắt (v2)** — phiên bản thứ 2 của scan slitting (có thể khác format barcode hoặc quy trình). |
| 16 | **`UpdatePrintYn3`** | UpdatePrintYn3 | **Cập nhật trạng thái in Slitting** — gọi `usp_DoUpdateSlitingBarcodePrintYn(@pElectrodeLotNumber)`. |

#### Nhóm WASTE

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 17 | **`PrintElectrodeWasteLabel`** | PrintElectrodeWasteLabel | **In nhãn phế liệu Electrode** — in nhãn cho container chứa phế liệu bột electrode. |
| 18 | **`PrintElectrodeWasteList`** | PrintElectrodeWasteList | **In danh sách phế liệu Electrode** — in báo cáo tổng hợp phế liệu electrode. |
| 19 | **`ElectrodeWasteLabelPrintAction`** | ElectrodeWasteLabelPrintAction | **In label phế liệu (Action)** — action in nhãn phế liệu electrode (có thể khác format). |
| 20 | **`FoilWasteLabelPrintAction`** | FoilWasteLabelPrintAction | **In nhãn phế liệu lá đồng/nhôm** — in nhãn cho phế liệu lá kim loại (foil waste). |
| 21 | **`PrintFoilWasteList`** | PrintFoilWasteList | **In danh sách phế liệu lá** — in báo cáo tổng hợp phế liệu lá đồng/nhôm. |

#### Nhóm QC TRIGGER

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 22 | **`DoElectrodeInspection`** | DoElectrodeInspection | **Trigger kiểm QC** — kích hoạt quy trình kiểm tra chất lượng Electrode (link sang C460). Tạo phiếu kiểm QC cho cuộn đang chọn. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_CommonCode_INOUT_popup` | Chọn trạng thái IN/OUT |
| `usp_CommonCode_OKNG_popup` | Chọn trạng thái OK/NG |
| `usp_CommonCode_OX_LEFT_popup` | Trạng thái OX trái |
| `usp_CommonCode_OX_RIGHT_popup` | Trạng thái OX phải |
| `usp_CommonCode_YesNo_popup` | Yes/No |
| `usp_CommonCode_YesNo_PushingYn_popup` | Trạng thái ép đùn |
| `usp_GetBaseCode_popup` | BaseCode |
| `usp_GetBasicRouteingDetailForRoute_popup` | Lọc routing |
| `usp_MaterialMaster_popup` | Chọn NVL |
| `usp_ProductMachine_popup` | Chọn máy SX |
| `usp_ProductMachineForRoute_popup` | Chọn máy theo công đoạn |
| `usp_ProdWorkerInfo_Popup` | Chọn nhân viên SX |
| `usp_RouteInfo_get` | Lấy danh sách công đoạn |
| `usp_Vietnam_DefectInfo_popup` | Chọn mã lỗi defect |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ElectrodeMixInfo` | PK tương ứng ElectrodeLotNumber. Kết quả mẻ trộn |
| `STB_ElectrodeMixStepInfo` | Chi tiết bước trộn |
| `STB_ElectrodeCoatingInfo` | Kết quả phủ cuộn |
| `STB_ElectrodeCoatingVisualInspectionInfo` | Ngoại quan Coating |
| `STB_ElectrodeRollPressingInfo` | Kết quả cán cuộn |
| `STB_ElectrodeRollPressingVisualInspectionInfo` | Ngoại quan cán |
| `STB_ElectrodeSlittingInfo` | Kết quả cắt cuộn |
| `STB_ElectrodeSlittingResult` | Dữ liệu cuộn con |
| `STB_ElectrodeWasteInfoNew` | Phế liệu |
| `STB_ElectrodeWastePriceNew` | Đơn giá phế liệu |
| `STB_SetInfo` | Lot/Cuộn |
| `STB_SlittingLocationConfig_VVT` | Cấu hình vị trí cắt |
| `STB_CoatingToSlittingMaster` | Mapping Coating → Slitting |
| `STB_ProdRouteHist` | Lịch sử routing |

---

## 8. B802 — Vietnam_EletrodeProdRouteHist

| Thông tin | Giá trị |
|---|---|
| **TCode** | `B802` |
| **Screen Name** | `Vietnam_EletrodeProdRouteHist` |
| **Parent Menu** | `v_ElectrodeArea` |
| **Caption** | Vietnam_EletrodeProdRouteHist |
| **Tổng Objects** | **6** (2 View + 2 SearchFunction + 0 ExecuteFunction + 2 Action) |

### Nghiệp vụ

Màn hình **báo cáo tổng hợp lịch sử sản xuất Electrode** — READ-ONLY. Xem và kết xuất dữ liệu truy xuất nguồn gốc (Traceability) cho toàn bộ quá trình sản xuất Electrode.

**Workflow:**
1. Chọn khoảng ngày, ca SX, dây chuyền Electrode
2. Lọc R&D hay Production
3. Xem lịch sử quy trình (Mixing → Coating → RollPressing → Slitting)
4. Xem lịch sử lỗi defect cho cuộn đang chọn

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  ElectrodeProdRouteHist (Grid trên)                          │
│  ─ Filter: FromDate, ToDate, ElectrodeRouteName,             │
│            CompanyCode, RnD, WorkCenterCode                  │
│  ─ Lịch sử quy trình SX Electrode (readonly)                │
│  ─ Toolbar: [MixingStep] [Thickness]                         │
├──────────────────────────────────────────────────────────────┤
│  Vietnam_ElectrodeDefectHist (Grid dưới)                     │
│  ─ Danh sách lỗi defect tương ứng cuộn đang chọn            │
│  ─ Readonly                                                  │
└──────────────────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ElectrodeProdRouteHist` | ElectrodeProdRouteHist | Grid trên — lịch sử quy trình SX Electrode. Join các công đoạn Mixing, Coating, RollPressing, Slitting. Readonly. |
| 2 | `Vietnam_ElectrodeDefectHist` | Vietnam_ElectrodeDefectHist | Grid dưới — lịch sử lỗi defect. Chọn 1 cuộn ở grid trên → grid dưới load lỗi. Readonly. |

### SearchFunctions (2)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_Vietnam_ElectrodeProdRouteHist_get` | Truy xuất lịch sử SX | `@pFromDate` date, `@pToDate` date, `@pElectrodeRouteName` varchar(20), `@pCompanyCode` varchar(20), `@pRnD` varchar(20), `@pWorkCenterCode` varchar(30) |
| 2 | `usp_Vietnam_ElectrodeDefectHist_get` | Truy xuất lịch sử lỗi | `@pFromDate` date, `@pToDate` date, `@pElectrodeRouteName` varchar(20), `@pCompanyCode` varchar(20), `@pRnD` varchar(20), `@pWorkCenterCode` nvarchar(20) |

### ExecuteFunctions (0)

> Màn hình B802 **không có ExecuteFunction** — hoàn toàn READ-ONLY.

### Actions/Buttons (2)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`MixingStep`** | Mixing Step | **Xem chi tiết bước trộn** — mở popup/dialog hiển thị chi tiết các bước trộn (MixStepInfo) của mẻ trộn tương ứng với cuộn đang chọn. Readonly — chỉ xem, không sửa. |
| 2 | **`Thickness`** | Thickness | **Xem chi tiết độ dày** — mở popup/dialog hiển thị dữ liệu đo độ dày (thickness measurement) của cuộn Electrode đang chọn. Readonly. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_CompanyInfo_get` | Lấy danh mục Company/Plant |
| `usp_GetBaseCode_popup` | Popup BaseCode |
| `usp_GetBaseCode_popup2` | Popup BaseCode v2 |
| `usp_vvt_RnDorProduction_popup` | Popup chọn R&D/Production |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_ProdRouteHist` | Lịch sử routing di chuyển SP |
| `STB_ElectrodeMixInfo` | Thông tin mẻ trộn |
| `STB_ElectrodeMixStepInfo` | Chi tiết bước trộn |
| `STB_ElectrodeCoatingInfo` | Thông tin phủ |
| `STB_ElectrodeRollPressingInfo` | Thông tin cán |
| `STB_ElectrodeSlittingResult` | Dữ liệu cuộn con |
| `STB_ElectrodeWasteInfoNew` | Phế liệu |
| `STB_DayProdPlan` | Kế hoạch ngày |
| `STB_SetInfo` | Lot/Cuộn |
| `STB_DefectInfo` | Thông tin lỗi |
| `STB_MachineMaster` | Danh mục máy |
| `STB_MaterialMaster` | Danh mục NVL |
| `STB_ProdWorkerInfo` | Nhân viên SX |

---

## 9. C460 — ElectrodeInspectionHistoryForBarcode

| Thông tin | Giá trị |
|---|---|
| **TCode** | `C460` |
| **Screen Name** | `ElectrodeInspectionHistoryForBarcode` |
| **Parent Menu** | `Process inspection` |
| **Caption** | 공정검사이력(바코드) — Lịch sử kiểm tra công đoạn (barcode) |
| **Tổng Objects** | **19** (2 View + 2 SearchFunction + 6 ExecuteFunction + 9 Action) |

> ⚠️ **Lưu ý:** TCode C460 có 2 màn hình khác nhau trong DB: `ElectrodeInspectionHistoryForBarcode` (dùng cho Electrode QC) và `VNT_CustomerComplaintManagementInfo` (dùng cho Customer Complaints). Chỉ clone `ElectrodeInspectionHistoryForBarcode`.

### Nghiệp vụ

Màn hình **QC kiểm tra chất lượng Electrode** — tại trạm QC, quét barcode cuộn → đo thông số → ra quyết định OK/NG/Loss.

**Workflow:**
1. QC quét **barcode Electrode** → hệ thống load lịch sử kiểm tra. Nếu chưa có → tạo phiếu tự động.
2. QC nhập **kết quả đo** cho từng hạng mục QC
3. Xác nhận:
   - **OK** → `DoFinishCommInspDoc` hoặc `DoFinishCommInspDoc_VNT` → cuộn đạt, cho phép dùng
   - **NG** → nhập mã lỗi (Defect Code)
   - **Loss** → `DoLossCommInspDoc_VNT` → hủy cuộn lỗi
4. Chia nhỏ cuộn lỗi nếu cần (`DoLossElectrodeProcess_iud`)
5. Xem thông tin Coating gốc để đối chiếu

### Cấu Trúc UI

```
┌──────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Barcode Input (Ô quét barcode)                         │ │
│  │  ─ Quét/nhập barcode cuộn Electrode                     │ │
│  └─────────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────────┤
│  ElectrodeInspectionHistoryForBarcode (Grid trên)            │
│  ─ Lịch sử phiếu kiểm tra cho barcode cuộn                  │
│  ─ Filter: CompanyCode, WorkCenterCode, CommInspTypeCode,    │
│            Barcode, LineCode, RouteCode, MachineCode,        │
│            MoldNumber, CategoryName, CommInspRemark          │
│  ─ Toolbar: [DoFinishCommInsp] [DoHoldCommInsp]              │
│             [DoLossCommInsp] [DoLossCommInspDialog]          │
│             [InputDefectCode] [MIIDoSuccess] [MIIDoFailure]  │
│             [Refresh] [SetHolding]                           │
├──────────────────────────────────────────────────────────────┤
│  ElectrodeCoatingInfo (Grid dưới)                            │
│  ─ Thông tin Coating gốc của cuộn (readonly, đối chiếu)      │
└──────────────────────────────────────────────────────────────┘
```

### Views (2)

| # | ObjectName | Caption | Mô tả |
|---|---|---|---|
| 1 | `ElectrodeInspectionHistoryForBarcode` | ElectrodeInspectionHistoryForBarcode | Grid trên — lịch sử phiếu kiểm QC cho barcode cuộn. Mỗi row = 1 hạng mục kiểm tra. |
| 2 | `ElectrodeCoatingInfo` | ElectrodeCoatingInfo | Grid dưới — thông tin Coating gốc. Readonly — dùng để QC đối chiếu thông số phủ. |

### SearchFunctions (2)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_GetElectrodeInspectionHistoryForBarcode` | Lấy lịch sử kiểm QC theo barcode | `@pCompanyCode`, `@pCompanyName` nvarchar(50), `@pWorkCenterCode`, `@pWorkCenterName` nvarchar(50), `@pCommInspTypeCode` varchar(50), `@pBarcode` varchar(50), `@pLineCode`, `@pRouteCode`, `@pMachineCode`, `@pMoldNumber` varchar(50), `@pCategoryName` varchar(50), `@pCommInspRemark` varchar(50) |
| 2 | `usp_ElectrodeCoatingInfo_get` | Lấy thông tin Coating gốc | `@pElectrodeLotNumber` varchar(20) |

### ExecuteFunctions (6)

| # | ObjectName | Mô tả | Parameters |
|---|---|---|---|
| 1 | `usp_DoAddCommInspMeasureHistForBarcode` | Lưu kết quả đo QC cho barcode | `@pCommInspDocNo`, `@pCommInspDocItemNo`, `@pTextMeasure` varchar(50), `@pNumericMeasure` numeric(13), `@pCheckDisplay` bit, `@pInspWorkerCode`, `@pCIDHExtText02` varchar(200) |
| 2 | `usp_DoAddCommInspMeasureHistForBarcode_TEST` | Alias đo test (cùng logic) | *(same as above)* |
| 3 | `usp_DoFinishCommInspDoc` | Phê duyệt OK phiếu QC (basic) | `@pCommInspDocNo`, `@pIsCheckItem` bit |
| 4 | `usp_DoFinishCommInspDoc_VNT` | Phê duyệt OK (VNT mở rộng) | `@pCommInspDocNo`, `@pIsCheckItem` bit, `@pIsHolding` bit, `@pIsLoss` bit, `@pIsFinished` bit, `@pDefectCode` varchar(20) |
| 5 | `usp_DoLossElectrodeProcess_iud` | Xử lý chia cuộn bị lỗi | `@pBarcode` varchar(50), `@pIsCheckItem` bit |
| 6 | `usp_ElectrodeDivision_popup` | Popup chia nhỏ cuộn | *(system params only)* |

### Actions/Buttons (9)

| # | ObjectName | Caption | Mô tả chi tiết |
|---|---|---|---|
| 1 | **`DoFinishCommInsp`** | 검사완료 (Hoàn thành kiểm tra) | **Hoàn thành QC** — xác nhận hoàn thành kiểm tra cho phiếu QC. Gọi `usp_DoFinishCommInspDoc_VNT`. Cuộn được phép chuyển sang công đoạn tiếp theo hoặc lắp ráp. |
| 2 | **`DoHoldCommInsp`** | 보류해제등록 (Giữ/Bỏ giữ) | **Hold/Unhold** — đặt cuộn vào trạng thái chờ (Hold) khi chưa thể quyết định ngay. Cuộn Hold → không được dùng cho lắp ráp. Bỏ Hold → cho phép dùng lại. |
| 3 | **`DoLossCommInsp`** | DoLossCommInsp | **Hủy cuộn (Loss)** — đánh dấu cuộn là Loss (hủy). Gọi `usp_DoLossCommInspDoc_VNT(@pCommInspDocNo, @pIsCheckItem)`. Cuộn bị hủy → không thể sử dụng. |
| 4 | **`DoLossCommInspDialog`** | 불량수리 (Sửa lỗi) | **Dialog xác nhận Loss** — mở dialog xác nhận trước khi hủy cuộn. Cho phép chọn chia nhỏ cuộn (`usp_DoLossElectrodeProcess_iud`) nếu chỉ lỗi 1 phần. |
| 5 | **`InputDefectCode`** | 불량입력 (Nhập mã lỗi) | **Nhập Defect Code** — mở popup chọn mã lỗi defect từ danh mục (`usp_DefectInfo_popup`). Gắn mã lỗi cho cuộn bị NG. |
| 6 | **`MIIDoSuccess`** | MIIDoSuccess | **Đo ĐẠT** — đánh dấu hạng mục đo hiện tại là Pass. Gọi `usp_DoAddCommInspMeasureHistForBarcode` với kết quả OK. |
| 7 | **`MIIDoFailure`** | MIIDoFailure | **Đo KHÔNG ĐẠT** — đánh dấu hạng mục đo hiện tại là Fail/NG. Gọi `usp_DoAddCommInspMeasureHistForBarcode` với kết quả NG. |
| 8 | **`Refresh`** | Refresh | Làm mới cả 2 grid (lịch sử kiểm tra + thông tin Coating). |
| 9 | **`SetHolding`** | SetHolding | **Đặt trạng thái Hold** — client-side action đặt flag Hold trên grid. Kết hợp với `DoHoldCommInsp` để lưu. |

### Popup SPs Dùng Chung

| SP | Mô tả |
|---|---|
| `usp_DoLossCommInspDoc_VNT` | Xử lý hủy phiếu QC. Params: `@pCommInspDocNo`, `@pIsCheckItem` bit |
| `usp_CommInspSelectItem_popup` | Popup chọn hạng mục QC |
| `usp_CommonCode_OKNG_popup` | Popup OK/NG |
| `usp_CompanyInfo_popup` | Popup Company |
| `usp_DefectInfo_popup` | Popup mã lỗi defect |
| `usp_LineInfo_popup` | Popup Line |
| `usp_ProdWorkerInfo_Popup` | Popup nhân viên |
| `usp_RouteInfoForLine_popup` | Popup công đoạn theo Line |
| `usp_WorkCenterInfo_popup` | Popup Work Center |

### Bảng DB Chính

| Bảng | Mô tả |
|---|---|
| `STB_CommInspDocHistory` | Phiếu kiểm QC Electrode |
| `STB_CommInspDocItemHistory` | Hạng mục trong phiếu kiểm |
| `STB_CommInspMeasureHistory` | Kết quả đo từng hạng mục |
| `STB_ElectrodeCoatingInfo` | Thông tin Coating gốc |
| `STB_SetInfo` | Lot/Cuộn |
| `STB_DefectInfo` | Danh mục mã lỗi |
| `STB_CommInspSelectGroup` | Nhóm hạng mục kiểm tra |
| `STB_CommInspSelectItem` | Hạng mục kiểm tra |

---

## Thống Kê Tổng Hợp

| Màn hình | TCode | Views | Search | Execute | Actions | **Tổng Objects** |
|---|---|---|---|---|---|---|
| QcInspectionGroup | C121 | 2 | 2 | 2 | 0 | **6** |
| MaterialQcInspectionItemByMaterial | C122 | 2 | 1 | 1 | 5 | **9** |
| MaterialIqcInfoSampleManagement | C220 | 5 | 5 | 17 | 24 | **51** |
| ProductionOrderInfo | B310 | 4 | 4 | 3 | 6 | **17** |
| ElectrodePlan_Vietnam | B442 | 3 | 3 | 4 | 11 | **21** |
| VNT_ElectrodePrcsCard | B470 | 3 | 3 | 3 | 1 | **10** |
| Vietnam_ElectrodeMeasureResult | B552 | 11 | 11 | 14 | 22 | **58** |
| Vietnam_EletrodeProdRouteHist | B802 | 2 | 2 | 0 | 2 | **6** |
| ElectrodeInspectionHistoryForBarcode | C460 | 2 | 2 | 6 | 9 | **19** |
| **TỔNG** | | **34** | **33** | **50** | **80** | **197** |

---

## Sơ Đồ Quan Hệ Giữa Các Màn Hình

```
C121 (Định nghĩa nhóm/hạng mục QC)
  │
  ▼
C122 (Gán hạng mục QC → MaterialCode)
  │
  ▼
C220 (IQC: Kiểm tra NVL đầu vào)
  │
  └──► F330 (Nhập kho NVL) ──► tự tạo phiếu IQC

B310 (Tạo PO - Lệnh sản xuất)
  │
  ▼
B442 (Kế hoạch ngày Electrode → tạo Lot/Set)
  │
  ├──► B470 (Cấu hình bước trộn → reference cho B552 Mixing)
  │
  ▼
B552 (Nhập kết quả SX: Mixing → Coating → RollPressing → Slitting → Waste)
  │
  ├──► C460 (QC Electrode: kiểm tra chất lượng cuộn theo barcode)
  │
  ▼
B802 (Báo cáo lịch sử SX Electrode — READ-ONLY)
```

---

> **Ghi chú về clone _HY:**  
> Khi clone sang HY, các SP nghiệp vụ chính (get/iud/action) sẽ thêm suffix `_HY` và thêm điều kiện filter `CompanyCode = 'VVT_F5'` hoặc đọc từ bảng riêng `_HY`. Các popup, helper SPs và functions dùng chung giữa các nhà máy.
