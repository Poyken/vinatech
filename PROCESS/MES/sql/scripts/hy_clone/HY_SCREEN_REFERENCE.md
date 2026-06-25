# 9 Màn Hình HY — Danh Sách Sử Dụng

> **Ngày:** 2026-06-25 | **Nhà máy:** Hưng Yên (VVT_F5)  
> **Nguyên tắc:** 
> - Các SPs nghiệp vụ chính (GET, IUD, Action DB) được clone sang bản `_HY` nhằm phân tách dữ liệu hoặc áp dụng logic phân quyền/bộ lọc riêng cho nhà máy Hưng Yên (VVT_F5).
> - Các SPs danh mục chung, popups trợ giúp (Lookup/Popup), bảng dữ liệu chính (trừ các bảng cấu hình QC nền tảng) và các scalar/table-valued functions được dùng chung giữa các nhà máy.

---

## Tổng quan

| # | Gốc | TCode HY | Tên Screen HY | Trạng thái |
|---|---|---|---|---|
| 1 | C121 | `HY121` | `HYQcInspectionGroup` | ✅ Đã tạo (6 objects) |
| 2 | C122 | `HY122` | `HYMaterialQcInspectionItemByMaterial` | ✅ Đã tạo (Chờ đồng bộ/thiết kế lại layout) |
| 3 | C220 | `HY220` | `MaterialIqcInfoSampleManagement_HY` | ❌ Cần tạo (Đã có sẵn script clone) |
| 4 | B310 | `HY310` | `ProductionOrderInfo_HY` | ❌ Cần tạo (Đã có sẵn script clone) |
| 5 | B442 | `HY442` | `ElectrodePlan_HY` | ❌ Cần tạo (Đã có sẵn script clone) |
| 6 | B470 | `HY470` | `ElectrodePrcsCard_HY` | ❌ Cần tạo (Đã có sẵn script clone) |
| 7 | B552 | `HY552` | `ElectrodeMeasureResult_HY` | ❌ Cần tạo (Đã có sẵn script clone) |
| 8 | B802 | `HY802` | `ElectrodeProdRouteHist_HY` | ❌ Cần tạo (Đã có sẵn script clone) |
| 9 | C460 | `HY460` | `ElectrodeInspectionHistoryForBarcode_HY` | ❌ Cần tạo (Đã có sẵn script clone) |

---

## 1. C121 → `HY121` — Quản lý nhóm & hạng mục kiểm tra ✅ ĐÃ TẠO

**Clone từ:** `QcInspectionGroup` (C121, 6 objects, 273K layout) | **Parent:** `QC_HY`

> ⚠️ **CONFLICT:** TCode `HY121` đã tồn tại = `QCInspectionGroupCode_HY` (3 objects, 69K layout — chỉ có Group, thiếu Item). Đã giải quyết bằng cách tạo màn hình đầy đủ `HYQcInspectionGroup` (6 objects).

### Nghiệp vụ

Màn hình cấu hình **nền tảng QC** — thiết lập các nhóm kiểm tra (Inspection Group) và hạng mục kiểm tra (Inspection Item) dùng cho toàn bộ quy trình QC.

**Flow vận hành:**
1. Tạo **nhóm kiểm tra** (vd: "Kiểm tra ngoại quan", "Kiểm tra kích thước")
2. Trong mỗi nhóm, thêm **các hạng mục kiểm tra** (vd: "Chiều dài", "Chiều rộng", "Bề mặt")
3. Mỗi hạng mục có thông số: loại dữ liệu (số/checkbox), đơn vị đo, giới hạn trên/dưới
4. Data từ C121 được C122 reference để gán cho từng loại nguyên liệu

**Cấu trúc UI:** 2 grid — trên: danh sách Group | dưới: danh sách Item trong Group đang chọn

### Objects (6 — clone đầy đủ từ C121)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_QcInspectionGroup_HY_get` | SearchFunction | **_HY** |
| `usp_QcInspectionGroup_HY_iud` | ExecuteFunction | **_HY** |
| `usp_QcInspectionItem_HY_get` | SearchFunction | **_HY** |
| `usp_QcInspectionItem_HY_iud` | ExecuteFunction | **_HY** |
| `QcInspectionGroup_HY` | View | **_HY** |
| `QcInspectionItem_HY` | View | **_HY** |

### SPs dùng _HY

| SP | Mô tả |
|---|---|
| `usp_QcInspectionGroup_HY_get` | Lấy danh sách nhóm QC |
| `usp_QcInspectionGroup_HY_iud` | Thêm/Sửa/Xóa nhóm QC |
| `usp_QcInspectionGroup_HY_popup` | Popup chọn nhóm QC |
| `usp_QcInspectionItem_HY_get` | Lấy hạng mục QC theo nhóm |
| `usp_QcInspectionItem_HY_iud` | Thêm/Sửa/Xóa hạng mục QC |

### SPs dùng chung

| SP | Mô tả |
|---|---|
| `usp_GetAql_popup` | Popup chọn AQL level |
| `usp_GetInspectionLevel_popup` | Popup chọn Inspection Level |
| `usp_GetInspectionType_popup` | Popup chọn Inspection Type |

### Tables

| Bảng | Loại | Ghi chú |
|---|---|---|
| `STB_QcInspectionGroup_HY` | **Riêng HY** | Tách riêng nhóm kiểm tra QC |
| `STB_QcInspectionItem_HY` | **Riêng HY** | Tách riêng hạng mục kiểm tra QC |
| `STB_CommInspSelectGroup` | Dùng chung | Bảng cấu hình tùy chọn nhóm chung |
| `STB_CommInspSelectItem` | Dùng chung | Bảng cấu hình tùy chọn hạng mục chung |

---

## 2. C122 → `HY122` — Tiêu chuẩn kiểm tra nguyên liệu ✅ ĐÃ TẠO (Cần đồng bộ/thiết kế lại layout)

**Clone từ:** `MaterialQcInspectionItemByMaterial` (C122, 9 objects, 664K layout) | **Parent:** `QC_HY`

> ⚠️ **HY151 (`HYMaterialQcInspectionItem`) — KHÔNG DÙNG.** HY151 dùng bảng CHUNG (`STB_MaterialQcInspectionItem`, `STB_QcInspectionItem`) → data lẫn với nhà máy khác. HY122 dùng bảng RIÊNG (`_HY`) → an toàn, tách biệt data.

> 📋 **Clone method:** Dùng script `fix_hy122_clone_full.sql` — clone layout từ C122 + REPLACE 2 SP names + clone đầy đủ 9 objects. **Không thể** clone bằng tay trong Designer vì thiếu objects. Hiện tại chỉ có 1 object trên DB do người dùng đang thiết kế lại.

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

| SP | Mô tả |
|---|---|
| `usp_MaterialQcInspectionItem_ByMaterial_HY_get` | Lấy hạng mục QC đã gán cho NVL |
| `usp_MaterialQcInspectionItem_HY_iud` | Thêm/Sửa/Xóa hạng mục QC gán cho NVL |

### SPs dùng chung (Popup)

| SP | Mô tả |
|---|---|
| `usp_MaterialMaster_popup` | Popup chọn nguyên liệu từ Master data |
| `usp_GetAql_popup` | Popup chọn AQL level |
| `usp_GetInspectionLevel_popup` | Popup chọn Inspection Level |
| `usp_GetInspectionType_Popup` | Popup chọn Inspection Type |

### Tables

| Bảng | Loại | Ghi chú |
|---|---|---|
| `STB_MaterialQcInspectionItem_HY` | **Riêng HY** | Dữ liệu cấu hình hạng mục QC cho NVL |
| `STB_QcInspectionItem_HY` | **Riêng HY** | Hạng mục kiểm tra QC |
| `STB_QcInspectionGroup_HY` | **Riêng HY** | Nhóm kiểm tra QC |
| `STB_MaterialMaster` | Dùng chung | Danh mục nguyên vật liệu |

---

## 3. C220 → `HY220` — IQC Confirmation ❌ CẦN TẠO

**Clone từ:** `MaterialIqcInfoSampleManagement` (C220, 51 objects, 2,018,736 layout) | **Parent:** `QC_HY`

### Nghiệp vụ

Màn hình **kiểm tra chất lượng đầu vào (IQC)** — khi nguyên liệu nhập kho qua F330, QC kiểm tra chất lượng trước khi cho phép sử dụng.

**Flow vận hành:**
1. NVL nhập kho (F330) → hệ thống tự tạo **phiếu IQC** (`STB_MaterialQcInfo`) với hạng mục từ C122.
2. QC chọn phiếu → bấm **"Make Detail"** (`DoMakeMaterialIQCDetailList`) → tạo danh sách chi tiết kiểm tra.
3. QC nhập kết quả đo từng hạng mục (`MaterialQcSampleResult_iud`).
4. Quyết định: **Pass** (`DoUpdateMaterialQcInfo_Success`) hoặc **Fail** (`DoUpdateMaterialQcInfo_Fail`).
5. Fail → tạo **Defect Report** (`IQcDefectReport_iud`) → gửi email thông báo.
6. Có thể **đổi Pass** sau khi Fail (`DoChangeMaterialQcToPass`) nếu được phê duyệt.

**Cấu trúc UI:**
- **Tab 1 (IQC List):** Grid chính — filter theo ngày, mã NVL, kết quả. Mỗi row = 1 phiếu IQC.
- **Tab 2 (Detail):** Chi tiết hạng mục kiểm tra cho phiếu đang chọn.
- **Tab 3 (Sample):** Kết quả đo từng mẫu.
- **Popup Defect Report:** Báo cáo lỗi khi Fail.
- **Popup NCR:** Non-Conformance Report.

### Objects (51 — clone đầy đủ từ C220)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_MaterialQcInfo_HY_get` | SearchFunction | **_HY** — đọc từ bảng shared nhưng filter theo Plant |
| `usp_MaterialQcInfo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_MaterialQcDetail_HY_get` | SearchFunction | **_HY** |
| `usp_MaterialQcDetail_HY_iud` | ExecuteFunction | **_HY** |
| `usp_MaterialQcSampleResult_HY_get` | SearchFunction | **_HY** |
| `usp_MaterialQcSampleResult_HY_iud` | ExecuteFunction | **_HY** |
| `usp_DoChangeMaterialQcToPass_HY` | ExecuteFunction | **_HY** |
| `usp_DoMakeMaterialIQCDetailList_HY` | ExecuteFunction | **_HY** |
| `usp_DoMakeMaterialQcSampleResult_HY` | ExecuteFunction | **_HY** |
| `usp_DoUpdateMaterialQcInfo_Fail_HY` | ExecuteFunction | **_HY** |
| `usp_DoUpdateMaterialQcInfo_Success_HY` | ExecuteFunction | **_HY** |
| `usp_DoSendEmailForDefectReportIQC_HY` | ExecuteFunction | **_HY** |
| `usp_IQcDefectReport_HY_iud` | ExecuteFunction | **_HY** |
| `usp_DefectReportNoChange_HY_iud` | ExecuteFunction | **_HY** |
| `usp_MaterialQcInfoChangeLotNo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ModifyRevisionsVerFromC220_VVTF4_HY` | ExecuteFunction | **_HY** |
| `usp_NCR_Report_HY_iud` | ExecuteFunction | **_HY** |
| `usp_QcDefectIQCReport_HY_get` | SearchFunction | **_HY** |
| `usp_UpdateDefectDetailIQC_VVT_HY` | ExecuteFunction | **_HY** |
| `usp_GetMaterialQcInfo_ForReport_HY` | SearchFunction | **_HY** |
| `usp_DoCancelIQC` | ExecuteFunction | Dùng chung (Client-side action) |
| `usp_DoConfirmIQC` | ExecuteFunction | Dùng chung (Client-side action) |
| `MaterialQcInfoSampleList` | View | Grid chính phiếu IQC |
| `MaterialQcDetailSampleList` | View | Chi tiết hạng mục kiểm tra |
| `MaterialSampleResult` | View | Kết quả mẫu |
| `NonconformingReport` | View | NCR Report View |
| `QcDefectIQCEnrollment` | View | Đăng ký báo cáo lỗi IQC |
| *(Các Actions)* | Action | 24 actions phụ trợ (AllRefresh, SearchLotNo, ChangetoPass, v.v. - Dùng chung) |

### SPs dùng _HY

| SP | Mô tả |
|---|---|
| `usp_MaterialQcInfo_HY_get` | Lấy danh sách phiếu IQC lọc theo nhà máy HY |
| `usp_MaterialQcInfo_HY_iud` | Thêm/Sửa/Xóa phiếu IQC |
| `usp_MaterialQcDetail_HY_get` | Lấy chi tiết hạng mục đo IQC |
| `usp_MaterialQcDetail_HY_iud` | Thêm/Sửa/Xóa chi tiết đo IQC |
| `usp_MaterialQcSampleResult_HY_get` | Lấy kết quả đo mẫu của từng lot |
| `usp_MaterialQcSampleResult_HY_iud` | Lưu kết quả đo mẫu |
| `usp_DoChangeMaterialQcToPass_HY` | Đổi trạng thái quyết định IQC sang Pass |
| `usp_DoMakeMaterialIQCDetailList_HY` | Tạo danh sách chi tiết các hạng mục IQC |
| `usp_DoMakeMaterialQcSampleResult_HY` | Tạo mẫu đo cho phiếu IQC |
| `usp_DoUpdateMaterialQcInfo_Fail_HY` | Cập nhật kết quả IQC là Fail |
| `usp_DoUpdateMaterialQcInfo_Success_HY` | Cập nhật kết quả IQC là Pass/Success |
| `usp_DoSendEmailForDefectReportIQC_HY` | Gửi email thông báo lỗi IQC |
| `usp_IQcDefectReport_HY_iud` | Thêm/Sửa/Xóa báo cáo lỗi IQC |
| `usp_DefectReportNoChange_HY_iud` | Điều chỉnh mã lỗi IQC |
| `usp_MaterialQcInfoChangeLotNo_HY_iud` | Thay đổi Lot No cho phiếu IQC |
| `usp_ModifyRevisionsVerFromC220_VVTF4_HY` | Cập nhật Revision Version cho nguyên vật liệu |
| `usp_NCR_Report_HY_iud` | Thêm/Sửa/Xóa báo cáo NCR |
| `usp_QcDefectIQCReport_HY_get` | Lấy báo cáo lỗi IQC |
| `usp_UpdateDefectDetailIQC_VVT_HY` | Cập nhật chi tiết lỗi IQC |
| `usp_GetMaterialQcInfo_ForReport_HY` | Lấy thông tin in báo cáo IQC |

### SPs dùng chung (Popup & Helpers)

| SP | Mô tả |
|---|---|
| `usp_CompanyInfo_popup` | Chọn nhà máy/công ty |
| `usp_DecisionResult_popup` | Chọn kết quả quyết định IQC |
| `usp_DefectCauseGroup_popup` | Chọn nhóm nguyên nhân lỗi |
| `usp_DefectCauseGroup` | Lấy danh mục nhóm nguyên nhân lỗi |
| `usp_DoConfirmCancelQc2` | Xác nhận hoặc hủy xác nhận QC |
| `usp_GetBaseCode_popup` | Popup lấy danh mục dùng chung (BaseCode) |
| `usp_GetBaseCodeRemarkFilter_popup` | Popup lấy BaseCode lọc theo Remark |
| `usp_GetTestResult_popup` | Lọc kết quả đo |
| `usp_MaterialTypeCode_popup` | Lọc theo loại nguyên vật liệu |
| `usp_NameErrorIQC` | Lấy tên lỗi IQC |
| `usp_ProdIInspectionWorkerInfo_Popup` | Chọn nhân viên kiểm tra chất lượng |
| `usp_ProductGroup_get` | Lấy danh sách nhóm sản phẩm |
| `usp_ProdWorkerInfo_Popup` | Chọn nhân viên sản xuất |
| `usp_PurchaseMaterialMaster_popup` | Chọn nguyên vật liệu mua ngoài |
| `usp_VendorCustomerInfo_popup` | Chọn nhà cung cấp / khách hàng |
| `usp_WorkCenterInfo_popup` | Chọn Work Center |

### Tables (Dùng chung, phân tách bằng CompanyCode/WorkCenterCode)

| Bảng | Mô tả |
|---|---|
| `STB_MaterialQcInfo` | Bảng chính chứa thông tin các phiếu kiểm tra IQC |
| `STB_MaterialQcDetail` | Bảng chi tiết các hạng mục cần đo theo phiếu IQC |
| `STB_MaterialQcSampleResult` | Bảng lưu kết quả đo thực tế của từng mẫu |
| `STB_IQcDefectReport` | Bảng lưu báo cáo lỗi phát sinh (Defect Report) |
| `STB_NCR_REPORT` | Bảng lưu báo cáo không phù hợp (NCR) |
| `STB_MaterialMaster` | Danh mục nguyên vật liệu |
| `STB_UserInfo` | Danh sách người dùng hệ thống |
| `STB_MaterialDocDetail` | Chi tiết chứng từ nhập kho nguyên liệu |
| `STB_MaterialDocInfo` | Thông tin chứng từ nhập kho nguyên liệu |
| `STB_MaterialDocLotInfo` | Thông tin lot nhập kho nguyên liệu |
| `STB_MaterialWarehouse` | Danh mục kho nguyên liệu |

---

## 4. B310 → `HY310` — Tạo PO ❌ CẦN TẠO

**Clone từ:** `ProductionOrderInfo` (B310, 17 objects, ~200K layout) | **Parent:** `Production_HY`

### Nghiệp vụ

Màn hình **Lệnh sản xuất (Production Order - PO)** — dùng để lập kế hoạch, tạo, duyệt và hủy lệnh sản xuất cho toàn bộ nhà máy.

**Flow vận hành:**
1. Bộ phận kế hoạch tạo PO mới → chọn **sản phẩm, số lượng, ngày SX**
2. Hệ thống tự tạo **BOM** (`ProductionOrderBom`) và **Routing** (`ProductionOrderRouting`) theo master data
3. PO được **Fix** (xác nhận) → `DoFixProductionOrder` → đóng băng PO, chuẩn bị sản xuất
4. PO fix → B442/B450 sử dụng để tạo **kế hoạch ngày**
5. Hủy PO → `DoCancelPO` (chỉ hủy được khi chưa phát sinh sản lượng)
6. Tab BOM: xem danh sách NVL cần xuất kho (`GetMaterialGIForPO`)

**Cấu trúc UI:**
- **Grid chính:** Lọc theo tháng, nhóm SP, mã SP, trạng thái Fix/Cancel
- **Tab BOM:** Chi tiết nguyên vật liệu định mức cho PO đang chọn
- **Tab Routing:** Các công đoạn sản xuất (routing) của PO
- **Grid GI:** Danh sách NVL cần xuất kho cho PO

### Objects (17 — clone đầy đủ từ B310)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_ProductionOrderInfo_HY_get` | SearchFunction | **_HY** — đọc từ bảng shared lọc theo HY |
| `usp_ProductionOrderBom_HY_get` | SearchFunction | **_HY** |
| `usp_ProductionOrderRouting_HY_get` | SearchFunction | **_HY** |
| `usp_GetMaterialGIForPO_HY` | SearchFunction | **_HY** |
| `usp_ProductionOrderRouting_HY_iud` | ExecuteFunction | **_HY** |
| `usp_DoFixProductionOrder_HY` | ExecuteFunction | **_HY** |
| `usp_DoCancelPO_HY` | ExecuteFunction | **_HY** |
| `ProductionOrderInfo` | View | Grid chính lệnh sản xuất |
| `ProductionOrderBom` | View | Grid danh sách BOM của PO |
| `ProductionOrderRouting` | View | Grid danh sách Routing của PO |
| `MaterialGIForPO` | View | Grid thông tin cấp phát NVL |
| `CreateManualPO` | Action | Action tạo manual PO (Dùng chung) |
| `DoGI` | Action | Thực hiện xuất kho NVL (Dùng chung) |
| `Fix` | Action | Xác nhận/Fix PO (Dùng chung) |
| `POCancel` | Action | Hủy PO (Dùng chung) |
| `Refresh` | Action | Làm mới Grid (Dùng chung) |
| `Tao_PO_ReDroping` | Action | Tạo PO cho cuộn sấy lại (Re-dropping) (Dùng chung) |

### SPs dùng _HY

| SP | Mô tả |
|---|---|
| `usp_ProductionOrderInfo_HY_get` | Lấy danh sách lệnh sản xuất của nhà máy HY |
| `usp_ProductionOrderBom_HY_get` | Lấy danh sách BOM cho PO nhà máy HY |
| `usp_ProductionOrderRouting_HY_get` | Lấy quy trình công đoạn cho PO nhà máy HY |
| `usp_GetMaterialGIForPO_HY` | Lấy danh sách NVL cần cấp phát cho PO nhà máy HY |
| `usp_ProductionOrderRouting_HY_iud` | Sửa/Cập nhật quy trình công đoạn của PO |
| `usp_DoFixProductionOrder_HY` | Thực hiện xác nhận (Fix) PO |
| `usp_DoCancelPO_HY` | Thực hiện hủy (Cancel) PO |

### SPs dùng chung (Popup & Helpers)

| SP | Mô tả |
|---|---|
| `usp_DoCreateProductionOrder` | Xử lý tạo lệnh sản xuất chính thức |
| `usp_BasicRoutingInfo_popup` | Popup chọn quy trình công nghệ cơ bản |
| `usp_CompanyInfo_popup` | Popup chọn Công ty/Plant |
| `usp_GetRouteInfoAll_popup` | Popup chọn quy trình công nghệ |
| `usp_ProductionMaterialPopup` | Popup chọn vật tư sản xuất |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Tables (Dùng chung, phân tách bằng CompanyCode/WorkCenterCode)

| Bảng | Mô tả |
|---|---|
| `STB_ProductionOrderInfo` | Bảng chính lưu trữ thông tin Lệnh sản xuất |
| `STB_ProductionOrderBom` | Bảng định mức vật tư (BOM) đi theo từng PO |
| `STB_ProductionOrderRouting` | Bảng quy trình công nghệ (Routing) đi theo từng PO |
| `STB_MaterialMaster` | Danh mục nguyên vật liệu và sản phẩm |
| `STB_BasicRoutingInfo` | Danh mục quy trình công nghệ chuẩn |
| `STB_RouteInfo` | Danh mục công đoạn |
| `STB_SetInfo` | Thông tin các cuộn / lot sản phẩm tạo ra từ PO |

---

## 5. B442 → `HY442` — Daily Plan Electrode ❌ CẦN TẠO

**Clone từ:** `ElectrodePlan_Vietnam` (B442, 21 objects) | **Parent:** `ElectrodeHY`

### Nghiệp vụ

Màn hình **kế hoạch sản xuất hàng ngày cho Electrode** — chia PO thành các Set/Lot sản xuất thực tế theo ngày, máy và ca làm việc.

**Flow vận hành:**
1. Chọn **PO** đã Fix từ B310 → nhập kế hoạch theo **ngày + line + ca**
2. Tạo **DayProdPlan** → chỉ định sản phẩm, số lượng, dây chuyền Electrode
3. Tạo **SetInfo** (Lot/Cuộn) → gán vào Plan → `SetInfo_iud_VNT`
4. **Fix** Plan (`DoFixDayProdPlan`) → Đóng băng Lot chính thức để cho phép in tem barcode
5. Cancel Plan nếu cần (`DoCancelDayProdPlan`)
6. Xem trọng lượng phụ kiện lắp ráp (`MainAssemblePartWeight_get`)

**Cấu trúc UI:**
- **Grid trên:** Kế hoạch ngày — filter theo ngày, line, nhóm SP
- **Grid dưới:** SetInfo (Lot) — chi tiết từng Lot/Cuộn trong kế hoạch đang chọn
- **Grid Weight:** Trọng lượng phụ kiện lắp ráp

### Objects (21 — clone đầy đủ từ B442)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_DayProdPlan_HY_get` | SearchFunction | **_HY** — đọc từ bảng shared lọc theo HY |
| `usp_DayProdPlan_HY_iud` | ExecuteFunction | **_HY** |
| `usp_DoCancelDayProdPlan_HY` | ExecuteFunction | **_HY** |
| `usp_DoFixDayProdPlan_HY` | ExecuteFunction | **_HY** |
| `usp_SetInfo_HY_get` | SearchFunction | **_HY** |
| `usp_SetInfo_HY_iud_VNT` | ExecuteFunction | **_HY** |
| `usp_MainAssemblePartWeight_HY_get` | SearchFunction | **_HY** |
| `DayProdPlan` | View | Grid kế hoạch ngày |
| `SetInfo` | View | Grid thông tin lot/cuộn |
| `MainAssemblePartWeight` | View | Grid trọng lượng phụ kiện |
| `AddMainAssemblePart` | Action | Gán phụ kiện lắp ráp (Dùng chung) |
| `AddPartWeight` | Action | Ghi nhận trọng lượng phụ kiện (Dùng chung) |
| `CancelDayPlan` | Action | Hủy kế hoạch ngày (Dùng chung) |
| `CopyLot` | Action | Nhân bản thông tin lot (Dùng chung) |
| `DoGI` | Action | Xuất vật tư phụ (Dùng chung) |
| `FixDayPlan` | Action | Xác nhận kế hoạch ngày (Dùng chung) |
| `InputLabelQty` | Action | Nhập số lượng in nhãn (Dùng chung) |
| `LabelPrint` | Action | Thực hiện in nhãn barcode (Dùng chung) |
| `POSelectDialog` | Action | Popup chọn PO từ B310 (Dùng chung) |
| `Refresh` | Action | Làm mới Grid kế hoạch (Dùng chung) |
| `RefreshSetInfo` | Action | Làm mới Grid Lot (Dùng chung) |

### SPs dùng _HY

| SP | Mô tả |
|---|---|
| `usp_DayProdPlan_HY_get` | Lấy kế hoạch sản xuất ngày của nhà máy HY |
| `usp_DayProdPlan_HY_iud` | Thêm/Sửa/Xóa kế hoạch sản xuất ngày |
| `usp_DoCancelDayProdPlan_HY` | Hủy kế hoạch sản xuất ngày |
| `usp_DoFixDayProdPlan_HY` | Xác nhận (Fix) kế hoạch ngày để cho in nhãn |
| `usp_SetInfo_HY_get` | Lấy danh sách Lot/Set cuộn Electrode của kế hoạch |
| `usp_SetInfo_HY_iud_VNT` | Tạo/Cập nhật thông tin Lot/Set cuộn Electrode |
| `usp_MainAssemblePartWeight_HY_get` | Lấy trọng lượng phụ kiện lắp ráp chính |

### SPs dùng chung (Popup & Helpers)

| SP | Mô tả |
|---|---|
| `usp_BomVersion_popup` | Popup chọn phiên bản BOM |
| `usp_CompanyInfo_popup` | Popup chọn Company/Plant |
| `usp_LineInfo_popup` | Popup chọn Dây chuyền sản xuất (Line) |
| `usp_ProductGroup_popup` | Popup chọn nhóm sản phẩm |
| `usp_ProductionMaterialPopup` | Popup chọn bán thành phẩm/vật tư |
| `usp_RouteInfoForLine_popup` | Popup chọn công đoạn thuộc Line |
| `usp_ShiftCode_popup` | Popup chọn ca làm việc (Shift) |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Tables (Dùng chung, phân tách bằng CompanyCode/WorkCenterCode)

| Bảng | Mô tả |
|---|---|
| `STB_DayProdPlan` | Bảng lưu kế hoạch sản xuất ngày |
| `STB_SetInfo` | Bảng lưu thông tin các Lot/Cuộn Electrode được tạo ra |
| `STB_ProductionOrderInfo` | Lệnh sản xuất |
| `STB_MaterialMaster` | Danh mục nguyên vật liệu/sản phẩm |
| `STB_LineInfo` | Danh mục Line |
| `STB_RouteInfo` | Danh mục công đoạn |
| `STB_MachineMaster` | Danh mục máy móc thiết bị |
| `STB_CompanyInfo` | Danh mục công ty |
| `STB_WorkCenterInfo` | Danh mục Work Center |
| `STB_MainAssemblePartWeight` | Trọng lượng phụ kiện lắp ráp |
| `STB_LabelInfo` | Cấu hình in nhãn |
| `STB_ModelLabelInfo` | Cấu hình nhãn mác sản phẩm |
| `STB_MainAssemblePartInfo` | Chi tiết cấu thành phụ kiện |
| `STB_ElectrodeSetInfoHist` | Lịch sử lot/cuộn electrode |

---

## 6. B470 → `HY470` — Mixing Process Steps ❌ CẦN TẠO

**Clone từ:** `VNT_ElectrodePrcsCard` (B470, 10 objects) | **Parent:** `ElectrodeHY`

### Nghiệp vụ

Màn hình **thiết lập công đoạn trộn (Mixing)** cho sản xuất Electrode — dùng để định nghĩa quy trình trộn khô, trộn ướt, khuấy, cấu hình thông số kỹ thuật (thời gian, tốc độ, nhiệt độ sấy) và gán nguyên vật liệu cho từng bước trộn.

**Flow vận hành:**
1. Tạo **công đoạn Electrode** (`ElectrodeStep_iud`) — vd: Trộn khô, Trộn ướt, Khuấy.
2. Thiết lập **thông số vận hành** cho công đoạn (`ElectrodeCommon_iud`) — nhiệt độ, tốc độ, thời gian.
3. Cấu hình **lò sấy** (`ElectrodeOven_iud`) — nhiệt độ sấy, thời gian sấy.
4. Gán **NVL cần dùng** cho mỗi step (popup MaterialMasterByMaterialType).

**Cấu trúc UI:** 3 tab tương ứng:
- **Tab 1 (Step):** Danh sách công đoạn trộn, thứ tự trộn.
- **Tab 2 (Common):** Thông số chung của bước trộn đang chọn (tốc độ, thời gian).
- **Tab 3 (Oven):** Cấu hình nhiệt độ và thời gian sấy.

### Objects (10 — clone đầy đủ từ B470)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_ElectrodeStep_HY_get` | SearchFunction | **_HY** — đọc từ bảng shared lọc theo HY |
| `usp_ElectrodeStep_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeCommon_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeCommon_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeOven_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeOven_HY_iud` | ExecuteFunction | **_HY** |
| `ElectrodeStep` | View | Tab cấu hình các bước trộn |
| `ElectrodeCommon` | View | Tab cấu hình thông số bước trộn |
| `ElectrodeOven` | View | Tab cấu hình lò sấy |
| `ElectrodePrcsCardPrint` | Action | Action in Process Card (Dùng chung) |

### SPs dùng _HY

| SP | Mô tả |
|---|---|
| `usp_ElectrodeStep_HY_get` | Lấy danh sách các bước trộn cấu hình cho HY |
| `usp_ElectrodeStep_HY_iud` | Thêm/Sửa/Xóa các bước trộn |
| `usp_ElectrodeCommon_HY_get` | Lấy danh sách thông số bước trộn cho HY |
| `usp_ElectrodeCommon_HY_iud` | Thêm/Sửa/Xóa thông số bước trộn |
| `usp_ElectrodeOven_HY_get` | Lấy cấu hình lò sấy cho HY |
| `usp_ElectrodeOven_HY_iud` | Thêm/Sửa/Xóa cấu hình lò sấy |

### SPs dùng chung (Popup & Helpers)

| SP | Mô tả |
|---|---|
| `usp_ElectrodeStep_popup` | Popup chọn bước trộn Electrode |
| `usp_MaterialMasterByMaterialType_popup` | Popup chọn vật tư theo loại nguyên vật liệu |

### Tables (Dùng chung, phân tách bằng CompanyCode/WorkCenterCode)

| Bảng | Mô tả |
|---|---|
| `STB_ElectrodeStep` | Bảng lưu cấu hình các bước trộn Electrode |
| `STB_ElectrodeCommon` | Bảng lưu cấu hình thông số kỹ thuật của từng bước trộn |
| `STB_ElectrodeOven` | Bảng lưu cấu hình lò sấy của công đoạn trộn |
| `STB_MaterialMaster` | Danh mục nguyên vật liệu |
| `STB_BaseCode` | Bảng lưu danh mục code hệ thống |

---

## 7. B552 → `HY552` — Electrode Measure Results ❌ CẦN TẠO

**Clone từ:** `Vietnam_ElectrodeMeasureResult` (B552, 76 objects) | **Parent:** `ElectrodeHY`

### Nghiệp vụ

Màn hình **phức tạp nhất quy trình Electrode** — nhập toàn bộ kết quả sản xuất Electrode qua tất cả các công đoạn: Mixing (Trộn), Coating (Phủ), RollPressing (Cán), Slitting (Cắt), đo Viscosity, in tem barcode cho từng cuộn và ghi nhận phế liệu phát sinh (Waste).

**Flow vận hành theo từng công đoạn sản xuất:**
1. **Mixing (Trộn):** Chọn mẻ kế hoạch ngày → nhập kết quả trộn thực tế + chi tiết nhiệt độ/tốc độ từng bước (MixInfo & MixStepInfo).
2. **Coating (Phủ):** Quét lot bột trộn → nhập kết quả phủ cuộn + kết quả kiểm tra ngoại quan (Visual Inspection) + đo độ nhớt bột (Viscosity) → in tem barcode cuộn phủ.
3. **RollPressing (Cán):** Quét cuộn phủ → nhập kết quả cán + kiểm tra ngoại quan cán → in tem barcode cuộn cán.
4. **Slitting (Cắt):** Quét cuộn cán → nhập kết quả cắt cuộn chia đôi/nhiều phần (Slitting Location) → in tem barcode cuộn cắt con.
5. **Waste (Phế liệu):** Ghi nhận lượng phế liệu thu hồi (bột thừa, lá đồng/nhôm lỗi) theo barcode cuộn.

**Cấu trúc UI:** Multi-tab phức tạp:
- **Tab Mixing:** Kết quả trộn + chi tiết từng bước trộn.
- **Tab Coating:** Kết quả phủ + kiểm tra ngoại quan + đo độ nhớt.
- **Tab RollPressing:** Kết quả cán + kiểm tra ngoại quan.
- **Tab Slitting:** Kết quả cắt + chi tiết vị trí cắt (`SlittingLocationConfig`).
- **Tab Waste:** Quản lý phế liệu.

### Objects (76 — clone đầy đủ từ B552)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_ElectrodeMixInfo_HY_get` | SearchFunction | **_HY** — đọc từ bảng shared lọc theo HY |
| `usp_ElectrodeMixInfo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeMixStepInfo_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeMixStepInfo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeCoatingInfo_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeCoatingInfo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeRollPressingInfo_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeRollPressingInfo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeSlittingInfo_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeSlittingInfo_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeSlittingResult_HY_get` | SearchFunction | **_HY** |
| `usp_ElectrodeSlittingResult_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | ExecuteFunction | **_HY** |
| `usp_DoUpdateCoatingBarcodePrintYn_HY` | ExecuteFunction | **_HY** |
| `usp_DoUpdateRollPressBarcodePrintYn_HY` | ExecuteFunction | **_HY** |
| `usp_DoUpdateSlitingBarcodePrintYn_HY` | ExecuteFunction | **_HY** |
| `usp_ElectrodeWasteInfoNew_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeWastePriceNewByBarcode_HY_get` | SearchFunction | **_HY** |
| `usp_LocationElectric_HY` | SearchFunction | **_HY** |
| `usp_test_check_expired_HY` | ExecuteFunction | **_HY** |
| `usp_Vietnam_RollPressingSlitting_HY_get` | SearchFunction | **_HY** |
| `ElectrodeMixInfo` | View | Tab trộn Electrode |
| `ElectrodeMixStepInfo` | View | Chi tiết các bước trộn |
| `ElectrodeCoatingInfo` | View | Tab phủ Electrode |
| `ElectrodeCoatingVisualInspectionInfo` | View | Kiểm tra ngoại quan Coating |
| `ElectrodeRollPressingInfo` | View | Tab cán Electrode |
| `ElectrodeRollPressingVisualInspectionInfo` | View | Kiểm tra ngoại quan cán |
| `ElectrodeSlittingInfo` | View | Tab cắt Electrode |
| `ElectrodeSlittingResult` | View | Chi tiết cuộn cắt con |
| `ElectrodeWastePriceNewByBarcode` | View | Tab Waste phế liệu |
| `LocationElectric` | View | Grid phụ đo điện |
| `Vietnam_RollPressingSlitting` | View | Quy trình cán cắt liên tục |
| *(Các Actions)* | Action | 40 actions phụ trợ in ấn barcode, thiết lập, kiểm tra ngoại quan (Dùng chung) |

### SPs dùng _HY

| SP | Mô tả |
|---|---|
| `usp_ElectrodeMixInfo_HY_get` | Lấy kết quả trộn Electrode |
| `usp_ElectrodeMixInfo_HY_iud` | Thêm/Sửa/Xóa kết quả trộn |
| `usp_ElectrodeMixStepInfo_HY_get` | Lấy thông số chi tiết mẻ trộn theo bước |
| `usp_ElectrodeMixStepInfo_HY_iud` | Lưu thông số mẻ trộn chi tiết |
| `usp_ElectrodeCoatingInfo_HY_get` | Lấy kết quả phủ cuộn Electrode |
| `usp_ElectrodeCoatingInfo_HY_iud` | Lưu kết quả phủ cuộn Electrode |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_get` | Lấy kết quả kiểm tra ngoại quan Coating |
| `usp_ElectrodeCoatingVisualInspectionInfo_HY_iud` | Lưu kết quả kiểm tra ngoại quan Coating |
| `usp_ElectrodeRollPressingInfo_HY_get` | Lấy kết quả cán cuộn Electrode |
| `usp_ElectrodeRollPressingInfo_HY_iud` | Lưu kết quả cán cuộn Electrode |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_get` | Lấy kết quả kiểm tra ngoại quan cán |
| `usp_ElectrodeRollPressingVisualInspectionInfo_HY_iud` | Lưu kết quả kiểm tra ngoại quan cán |
| `usp_ElectrodeSlittingInfo_HY_get` | Lấy kết quả cắt cuộn Electrode |
| `usp_ElectrodeSlittingInfo_HY_iud` | Lưu kết quả cắt cuộn Electrode |
| `usp_ElectrodeSlittingResult_HY_get` | Lấy chi tiết cuộn cắt con sau khi chia |
| `usp_ElectrodeSlittingResult_HY_iud` | Lưu kết quả cuộn cắt con |
| `usp_ElectrodCoatingInfo_Viscosity_VVT_HY_iud` | Lưu kết quả đo độ nhớt |
| `usp_DoUpdateCoatingBarcodePrintYn_HY` | Cập nhật trạng thái in nhãn phủ |
| `usp_DoUpdateRollPressBarcodePrintYn_HY` | Cập nhật trạng thái in nhãn cán |
| `usp_DoUpdateSlitingBarcodePrintYn_HY` | Cập nhật trạng thái in nhãn cắt |
| `usp_ElectrodeWasteInfoNew_HY_iud` | Ghi nhận phế liệu |
| `usp_ElectrodeWastePriceNewByBarcode_HY_get` | Lấy đơn giá phế liệu theo barcode cuộn |
| `usp_LocationElectric_HY` | Lấy thông tin vị trí lỗi điện cực |
| `usp_test_check_expired_HY` | Kiểm tra thời hạn sử dụng nguyên vật liệu trộn bột |
| `usp_Vietnam_RollPressingSlitting_HY_get` | Lấy dữ liệu quy trình cán cắt phối hợp |

### SPs dùng chung (Popup & Helpers)

| SP | Mô tả |
|---|---|
| `usp_CommonCode_INOUT_popup` | Chọn trạng thái vào/ra (IN/OUT) |
| `usp_CommonCode_OKNG_popup` | Chọn trạng thái OK/NG |
| `usp_CommonCode_OX_LEFT_popup` | Trạng thái OX bên trái |
| `usp_CommonCode_OX_RIGHT_popup` | Trạng thái OX bên phải |
| `usp_CommonCode_YesNo_popup` | Trạng thái Có/Không (Yes/No) |
| `usp_CommonCode_YesNo_PushingYn_popup` | Trạng thái ép đùn Yes/No |
| `usp_GetBaseCode_popup` | Lấy danh mục BaseCode |
| `usp_GetBasicRouteingDetailForRoute_popup` | Lọc quy trình công đoạn của PO |
| `usp_MaterialMaster_popup` | Popup chọn nguyên vật liệu |
| `usp_ProductMachine_popup` | Popup chọn máy sản xuất |
| `usp_ProductMachineForRoute_popup` | Popup chọn máy sản xuất theo công đoạn |
| `usp_ProdWorkerInfo_Popup` | Popup chọn nhân viên sản xuất |
| `usp_RouteInfo_get` | Lấy danh sách các công đoạn sản xuất |
| `usp_Vietnam_DefectInfo_popup` | Chọn mã lỗi defect |

### Tables (Dùng chung, phân tách bằng CompanyCode/WorkCenterCode)

| Bảng | Mô tả |
|---|---|
| `STB_ElectrodeMixInfo` | Kết quả mẻ trộn bột Electrode |
| `STB_ElectrodeMixStepInfo` | Thông số chạy chi tiết từng bước trộn |
| `STB_ElectrodeCoatingInfo` | Kết quả phủ cuộn Electrode (Coating) |
| `STB_ElectrodeCoatingVisualInspectionInfo` | Kết quả kiểm tra ngoại quan Coating |
| `STB_ElectrodeRollPressingInfo` | Kết quả cán cuộn Electrode (RollPressing) |
| `STB_ElectrodeRollPressingVisualInspectionInfo` | Kết quả kiểm tra ngoại quan cán |
| `STB_ElectrodeSlittingInfo` | Kết quả chia cuộn (Slitting) |
| `STB_ElectrodeSlittingResult` | Dữ liệu cuộn cắt con chia nhỏ |
| `STB_ElectrodeWasteInfoNew` | Ghi nhận lượng phế liệu phát sinh |
| `STB_ElectrodeWastePriceNew` | Đơn giá phế liệu |
| `STB_ElectrodeSlittingResultHist` | Lịch sử kết quả cắt cuộn |
| `STB_SetInfo` | Thông tin Lot/Cuộn |
| `STB_SlittingLocationConfig_VVT` | Cấu hình chia cuộn theo vị trí (Slitting Location) |
| `STB_CoatingToSlittingMaster` | Bản đồ liên kết Coating sang Slitting |
| `STB_ProdRouteHist` | Lịch sử routing sản xuất |

---

## 8. B802 → `HY802` — Báo cáo sản xuất electrode ❌ CẦN TẠO

**Clone từ:** `Vietnam_EletrodeProdRouteHist` (B802, 6 objects) | **Parent:** `ElectrodeHY`

### Nghiệp vụ

Màn hình **báo cáo tổng hợp lịch sử sản xuất Electrode** — xem và kết xuất dữ liệu truy xuất nguồn gốc (Traceability) cho toàn bộ quá trình sản xuất Electrode (từ trộn, phủ, cán, cắt, lỗi defect) nhập từ B552. Màn hình này ở chế độ **READ-ONLY**, không thực hiện thêm/sửa/xóa dữ liệu.

**Flow vận hành:**
1. Chọn ca, ngày sản xuất và dây chuyền Electrode cần xem.
2. Lọc theo trạng thái R&D hay Production.
3. Xem **lịch sử quy trình** (`Vietnam_ElectrodeProdRouteHist_get`) join các công đoạn.
4. Xem **lịch sử lỗi** (`Vietnam_ElectrodeDefectHist_get`) hiển thị các defect đi kèm cuộn đang chọn.

**Cấu trúc UI:**
- **Grid trên:** Lịch sử quy trình sản xuất Electrode.
- **Grid dưới:** Danh sách các lỗi defect phát sinh tương ứng với cuộn được chọn ở grid trên.

### Objects (6 — clone đầy đủ từ B802)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_Vietnam_ElectrodeProdRouteHist_HY_get` | SearchFunction | **_HY** — đọc từ bảng shared lọc theo HY |
| `usp_Vietnam_ElectrodeDefectHist_HY_get` | SearchFunction | **_HY** |
| `ElectrodeProdRouteHist` | View | Grid lịch sử quy trình Electrode |
| `Vietnam_ElectrodeDefectHist` | View | Grid lịch sử lỗi Electrode |
| `MixingStep` | Action | Xem chi tiết bước trộn (Dùng chung) |
| `Thickness` | Action | Xem chi tiết độ dày (Dùng chung) |

### SPs dùng _HY

| SP | Mô tả |
|---|---|
| `usp_Vietnam_ElectrodeProdRouteHist_HY_get` | Truy xuất báo cáo lịch sử quy trình sản xuất Electrode lọc theo HY |
| `usp_Vietnam_ElectrodeDefectHist_HY_get` | Truy xuất báo cáo lịch sử lỗi defect Electrode lọc theo HY |

### SPs dùng chung (Popup & Helpers)

| SP | Mô tả |
|---|---|
| `usp_CompanyInfo_get` | Lấy danh mục Company/Plant |
| `usp_GetBaseCode_popup` | Popup lấy danh mục BaseCode |
| `usp_GetBaseCode_popup2` | Popup lấy danh mục BaseCode bản mở rộng |
| `usp_vvt_RnDorProduction_popup` | Popup chọn loại hình R&D hay Production |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Tables (Dùng chung, phân tách bằng CompanyCode/WorkCenterCode)

| Bảng | Mô tả |
|---|---|
| `STB_ProdRouteHist` | Lịch sử routing di chuyển sản phẩm |
| `STB_ElectrodeMixInfo` | Thông tin mẻ trộn |
| `STB_ElectrodeMixStepInfo` | Chi tiết bước trộn |
| `STB_ElectrodeCoatingInfo` | Thông tin cuộn phủ |
| `STB_ElectrodeRollPressingInfo` | Thông tin cuộn cán |
| `STB_ElectrodeSlittingResult` | Dữ liệu cuộn cắt con |
| `STB_ElectrodeWasteInfoNew` | Ghi nhận phế liệu |
| `STB_DayProdPlan` | Kế hoạch ngày |
| `STB_SetInfo` | Thông tin Lot/Cuộn |
| `STB_DefectInfo` | Thông tin lỗi |
| `STB_MachineMaster` | Danh mục máy |
| `STB_MaterialMaster` | Danh mục nguyên vật liệu |
| `STB_ProdWorkerInfo` | Danh mục nhân viên |
| `STB_ElectrodePriceB802` | Cấu hình đơn giá electrode cho báo cáo |
| `STB_AggregationPeriod` | Cấu hình kỳ tổng hợp báo cáo |

---

## 9. C460 → `HY460` — QC Electrode Inspection ❌ CẦN TẠO

**Clone từ:** `ElectrodeInspectionHistoryForBarcode` (C460, 19 objects) | **Parent:** `QC_HY`

### Nghiệp vụ

Màn hình **QC kiểm tra chất lượng Electrode** — dùng tại trạm kiểm tra QC của công đoạn sản xuất điện cực. QC quét barcode cuộn để lấy thông tin nguồn gốc, đo các thông số chất lượng theo tiêu chuẩn thiết lập và ra quyết định chất lượng.

**Flow vận hành:**
1. QC quét **barcode Electrode** → hệ thống load lịch sử kiểm tra (`GetElectrodeInspectionHistoryForBarcode`). Nếu chưa có phiếu, hệ thống tạo tự động.
2. QC nhập **kết quả đo** cho từng hạng mục QC (`DoAddCommInspMeasureHistForBarcode`).
3. Xác nhận kết thúc kiểm tra:
   - **OK** → `DoFinishCommInspDoc` hoặc `DoFinishCommInspDoc_VNT` (bản mở rộng VN) → cấp chứng nhận OK cho cuộn đưa vào lắp ráp.
   - **NG** → ghi lỗi, chọn mã lỗi (Defect Code).
   - **Loss** → `DoLossCommInspDoc_VNT` (Dùng chung) → hủy cuộn lỗi.
4. Chia nhỏ cuộn lỗi khi cần thiết (`DoLossElectrodeProcess_iud`).
5. Xem thông tin Coating gốc (`ElectrodeCoatingInfo_get`) để đối chiếu thông số sản xuất.

**Cấu trúc UI:**
- **Ô quét Barcode:** Nằm ở vùng trên cùng.
- **Grid trên:** Lịch sử các phiếu kiểm tra tương ứng với barcode cuộn.
- **Grid dưới:** Kết quả đo các hạng mục của phiếu kiểm tra đang chọn.

### Objects (19 — clone đầy đủ từ C460)

| ObjectName | ObjectType | Ghi chú |
|---|---|---|
| `usp_GetElectrodeInspectionHistoryForBarcode_HY` | SearchFunction | **_HY** — đọc từ bảng shared lọc theo HY |
| `usp_ElectrodeCoatingInfo_HY_get` | SearchFunction | **_HY** |
| `usp_DoAddCommInspMeasureHistForBarcode_HY` | ExecuteFunction | **_HY** |
| `usp_DoFinishCommInspDoc_HY` | ExecuteFunction | **_HY** |
| `usp_DoFinishCommInspDoc_VNT_HY` | ExecuteFunction | **_HY** |
| `usp_DoLossElectrodeProcess_HY_iud` | ExecuteFunction | **_HY** |
| `usp_ElectrodeDivision_popup_HY` | ExecuteFunction | **_HY** (Popup chia cuộn) |
| `ElectrodeInspectionHistoryForBarcode` | View | Grid lịch sử kiểm tra barcode |
| `ElectrodeCoatingInfo` | View | Grid thông tin Coating gốc |
| `DoFinishCommInsp` | Action | Xác nhận hoàn thành kiểm QC (Dùng chung) |
| `DoHoldCommInsp` | Action | Giữ/Hold cuộn (Dùng chung) |
| `DoLossCommInsp` | Action | Hủy cuộn lỗi (Dùng chung) |
| `DoLossCommInspDialog` | Action | Hộp thoại xác nhận hủy (Dùng chung) |
| `InputDefectCode` | Action | Nhập mã lỗi defect (Dùng chung) |
| `MIIDoFailure` | Action | Xác nhận đo lỗi (Dùng chung) |
| `MIIDoSuccess` | Action | Xác nhận đo đạt (Dùng chung) |
| `Refresh` | Action | Làm mới Grid (Dùng chung) |
| `SetHolding` | Action | Đặt trạng thái Hold (Dùng chung) |
| `usp_DoAddCommInspMeasureHistForBarcode_TEST` | ExecuteFunction | Alias đo test, cùng map sang `usp_DoAddCommInspMeasureHistForBarcode_HY` |

### SPs dùng _HY

| SP | Mô tả |
|---|---|
| `usp_GetElectrodeInspectionHistoryForBarcode_HY` | Lấy lịch sử kiểm tra chất lượng theo barcode cuộn lọc theo HY |
| `usp_ElectrodeCoatingInfo_HY_get` | Lấy thông tin Coating gốc của cuộn để đối chiếu |
| `usp_DoAddCommInspMeasureHistForBarcode_HY` | Lưu kết quả đo các hạng mục QC cho barcode cuộn |
| `usp_DoFinishCommInspDoc_HY` | Phê duyệt OK cho phiếu kiểm QC Electrode |
| `usp_DoFinishCommInspDoc_VNT_HY` | Phê duyệt OK bản mở rộng (vận chuyển, ghi lịch sử routing) |
| `usp_DoLossElectrodeProcess_HY_iud` | Xử lý chia cuộn bị lỗi khi phân tích |
| `usp_ElectrodeDivision_popup_HY` | Popup chọn chia nhỏ cuộn Electrode |

### SPs dùng chung (Popup & Helpers)

| SP | Mô tả |
|---|---|
| `usp_DoLossCommInspDoc_VNT` | Xử lý hủy phiếu QC (Loss) |
| `usp_CommInspSelectItem_popup` | Popup chọn hạng mục kiểm tra QC |
| `usp_CommonCode_OKNG_popup` | Popup chọn trạng thái OK/NG |
| `usp_CompanyInfo_popup` | Popup chọn Company/Plant |
| `usp_DefectInfo_popup` | Popup chọn thông tin lỗi defect |
| `usp_LineInfo_popup` | Popup chọn dây chuyền sản xuất |
| `usp_ProdWorkerInfo_Popup` | Popup chọn nhân viên QC/Sản xuất |
| `usp_RouteInfoForLine_popup` | Popup chọn công đoạn thuộc Line |
| `usp_WorkCenterInfo_popup` | Popup chọn Work Center |

### Tables (Dùng chung, phân tách bằng CompanyCode/WorkCenterCode)

| Bảng | Mô tả |
|---|---|
| `STB_CommInspDocHistory` | Bảng chính lưu các phiếu kiểm QC Electrode |
| `STB_CommInspDocItem` | Danh sách hạng mục cần đo đi theo phiếu kiểm QC |
| `STB_CommInspMeasureHist` | Kết quả đo thực tế của các hạng mục QC |
| `STB_CommInspSelectItem` | Danh mục tùy chọn cấu hình QC |
| `STB_CommInspItem` | Danh mục hạng mục đo QC chuẩn |
| `STB_SetInfo` | Thông tin Lot/Cuộn Electrode |
| `STB_ElectrodeCommon` | Thông số kỹ thuật Electrode |
| `STB_MaterialMaster` | Danh mục nguyên vật liệu |
| `STB_ProductionOrderInfo` | Lệnh sản xuất PO |
| `STB_ProdRouteHist` | Lịch sử di chuyển / routing sản phẩm |
| `STB_ProductionOrderRouting` | Quy trình công đoạn của PO |
| `STB_RouteInfo` | Danh mục công đoạn |
| `STB_DefectRepairInfo` | Bảng lưu thông tin sửa lỗi defect |

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
