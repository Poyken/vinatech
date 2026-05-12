# 🗺️ MES Unified Debug Map

> **Mục tiêu:** Tra cứu nhanh mối liên hệ giữa Màn hình (Screen ID), Stored Procedure (SP), Bảng Database và Logic xử lý.

## 1. Kho & Nguyên Vật Liệu (WMS)

| Màn Hình | Chức Năng | Stored Procedure | Bảng Chính | Logic Cần Nhớ |
|----------|-----------|-------------------|------------|---------------|
| **F330** | Nhập kho NVL | `usp_DoChangeMaterialDocLotInfo` | `STB_MaterialLotInfo`, `STB_MaterialDocLotInfo` | Đặc tính 10: Format mã Lot NCC. Kiểm tra `fn_VVT_getdatebyVendorLot_MergeCode`. |
| **F312** | Chỉnh sửa NVL | - | `STB_MaterialDocDetail`, `STB_MaterialDocLotInfo` | Sửa `MaterialCode` hoặc `Qty`. |
| **F430** | Xuất kho NVL | `usp_MaterialWarehouseInOutHist_get` | `STB_MaterialWarehouseInOutHist` | Sửa `CreateDateTime` để chỉnh ngày xuất. |
| **F721** | Tra cứu Lot NVL | `usp_vvt_MaterialLotInfo_get` | `STB_MaterialLotInfo` | Tra cứu `LotAttr09` (Location). |
| **F110** | FIFO Kho TP | `usp_VN_Update_ExportExcel` | - | Bật/tắt option FIFO cho kho thành phẩm. |

## 2. Sản Xuất & Lịch Sử Routing

| Màn Hình | Chức Năng | Stored Procedure | Bảng Chính | Logic Cần Nhớ |
|----------|-----------|-------------------|------------|---------------|
| **B782** | Lịch sử Routing | `usp_LotTrackingInfo_VVT2_get` | `STB_ProdRouteHist` | Sửa `JobDate` và `ProdDateTime`. |
| **B781** | Lịch sử Packing | `usp_Vietnam_PackPrintTime_get` | `STB_SavePackingTime_VVT` | Sửa `PrintTime`. |
| **B598** | Production Error | - | `STB_VN_PRODUCTION_ERROR` | `JobDate` gen theo `CreateDateTime`. |
| **B310/B450** | Quản lý PO | - | `STB_ProductionOrderInfo`, `STB_DayProdPlan`, `STB_SetInfo` | Xóa PO phải xóa đồng thời cả 2 màn hình. |
| **B791** | NG / Defect | - | `STB_DefectRepairInfo` | Sửa `DefectQty` phải sửa `ProdQty` ở công đoạn sau. |

## 3. Đóng Gói & In Tem

| Màn Hình | Chức Năng | Stored Procedure | Bảng Chính | Logic Cần Nhớ |
|----------|-----------|-------------------|------------|---------------|
| **B523** | In tem Packing | `usp_Vietnam_checkbarcode_2624` | `STB_MaterialLotInfo`, `STB_SavePackingTime_VVT` | Kiểm tra barcode VV/VJ. |
| **B767** | Sanmina Label | `usp_SanminaLabelPrint_get_Vietnam` | - | In tem xuất đi Sanmina India. |
| **A410** | Model Basic Info | - | `STB_ModelBasicInfo` | Cấu hình Vol/Farad cho model mới. |

---

## 🔑 Bảng Tra Cứu Tables Theo Nhóm

- **Material:** `STB_MaterialMaster`, `STB_MaterialLotInfo`, `STB_MaterialDocInfo`
- **Production:** `STB_SetInfo`, `STB_ProdRouteHist`, `STB_ProductionOrderInfo`
- **Packing:** `STB_SavePackingTime_VVT`, `STB_VN_FINISHGOODS_BG`
- **Log:** `STB_LogInfo`, `STB_ProcedureLog` (Dùng để trace lỗi SP)
