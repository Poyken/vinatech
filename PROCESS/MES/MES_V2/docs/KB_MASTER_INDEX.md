# 🗺️ MES_V2 — Master Knowledge & TCode Routing Index

> **Hệ thống CSDL:** `SmartFactoryV2` + `SmartFramework`  
> **Server:** `dbserver.hycap.co.kr,5398`

---

## ⚡ 1. Tra Cứu Nhanh Theo Triệu Chứng Lỗi (Symptom Quick Lookup)

| Triệu Chứng | Nguyên Nhân Gốc | Màn Hình | Tài Liệu & Kịch Bản |
|---|---|:---:|---|
| **Không gộp được Box (B523)** | Cờ `IsLotUse=0` tại F110 hoặc QC chưa `PASS` hoặc thiếu `STB_PackingStandard` | B523 | [03_packaging_labels.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/03_packaging_labels.md) |
| **"Not found label type"** | Chưa map Model với định dạng tem trong `STB_ModelLabelInfo` tại A460 | A460 / B523 | [03_packaging_labels.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/03_packaging_labels.md) |
| **B530 kẹt công đoạn V25** | Cột Status chưa chọn chữ `Making` | B530 | [02_production_pop.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/02_production_pop.md) |
| **B450 không sinh được Lot** | Chưa tích chọn `IsFixed = 1` | B450 | [02_production_pop.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/02_production_pop.md) |
| **NVL báo hết hạn sử dụng** | Quá ngày `LotAttr10` + `ValidMonth`. Ân xá qua `stb_vvt_OpenExpiredMaterial` | B597 / F330 | [01_wms_warehouse.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/01_wms_warehouse.md) |
| **Xuất kho chặn FIFO** | Tồn tại Lot cùng mã nhập trước. Bypass tại `STB_MaterialStockAttributeInfo` | F430 | [01_wms_warehouse.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/01_wms_warehouse.md) |
| **Lỗi vỏ nhôm không khớp** | Logic hardcode trong `usp_Vietnam_RawMaterialInputHist_uid` (không có bảng rười) | B597 | [04_qc_electrode.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/operations/04_qc_electrode.md) |
| **B351 đổi Lot nhưng in mã cũ** | Lệch giữa `STB_SetInfo` và `STB_MaterialLotInfo`/`STB_ProdRouteHist` | B351 / B523 | [bug_playbook.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/MES_V2/docs/troubleshooting/bug_playbook.md) |

---

## 📺 2. Bảng Ánh Xạ Screen ID (TCode Master Reference)

### 🅰️ Phân Hệ Master Data & Cấu Hình
| TCode | Tên Màn Hình | Search SP (`_get`) | Execute SP (`_iud`) | Bảng DB Chính |
|---|---|---|---|---|
| **A230** | Material Master | `usp_MaterialMaster_get` | `usp_MaterialMaster_iud` | `STB_MaterialMaster` |
| **A310** | BOM Header/Detail | `usp_BomHeader_get` | `usp_BomHeader_iud` | `STB_BomHeader`, `STB_BomDetail` |
| **A320** | Route Info | `usp_RouteInfo_get` | `usp_RouteInfo_iud` | `STB_RouteInfo` |
| **A410** | Model Basic Info | `usp_ModelBasicInfo_get` | `usp_ModelBasicInfo_iud` | `STB_ModelBasicInfo` (Vol/Farad) |
| **A419** | Tiêu chuẩn đóng gói | `usp_PackingStandard_get` | `usp_PackingStandard_iud` | `STB_PackingStandard` |
| **A460** | Cấu hình In Tem | `usp_ModelLabelInfo_get` | `usp_DoMakeModelLabelInfo` | `STB_ModelLabelInfo`, `STB_LabelInfo` |

### 🅱️ Phân Hệ Sản Xuất (B-Series)
| TCode | Tên Màn Hình | Search SP (`_get`) | Execute SP (`_iud`) | Bảng DB Chính |
|---|---|---|---|---|
| **B310** | PO Master | `usp_ProductionOrderInfo_get` | `usp_ProductionOrderInfo_iud` | `STB_ProductionOrderInfo` |
| **B351** | Chuyển đổi Lot | `usp_GetSetInfoForChangeMaterial` | `usp_DoChangeMaterialForSetInfo` | `STB_LotChangeMaterialHistory` |
| **B442** | Kế hoạch Điện cực | `usp_DayProdPlan_get` | `usp_DoCreateSetInfoForProdQty_VNT` | `STB_SetInfo`, `STB_MaterialMaster` |
| **B450** | Kế hoạch ngày (Tạo Lot) | `usp_DayProdPlan_get` | `usp_DoCreateSetInfoForProdQty_VNT` | `STB_DayProdPlan`, `STB_SetInfo` |
| **B523** | Đóng gói Cell & In tem | `usp_Vietnam_GetBoxIDForLotNo_VVT` | `usp_Vietnam_DoProcessProdPacking_VVT` | `STB_DividePackaging`, `STB_SavePackingTime_VVT` |
| **B530** | Nhập SL sản xuất (Core) | `usp_GetProdRouteHistForBarcode_VNT` | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | `STB_ProdRouteHist` (7 GATES) |
| **B540** | Assy Card Info (V22-V28) | `usp_RawMaterialInputHist_get` | `usp_Vietnam_RawMaterialInputHist_uid` | `STB_RawMaterialInputHist` |
| **B552** | Slitting Điện cực | `usp_SlittingLocationConfig_VVT_get` | `usp_SlittingLocationConfig_VVT_iud` | `STB_SlittingStock_VVT` |
| **B597** | Scan NVL QC Inline | `usp_RawMaterialInputHist_get` | `usp_Vietnam_RawMaterialInputHist_uid` | `STB_MaterialLotInfo` |
| **B767** | In tem Sanmina | `usp_SanminaLabelPrint_get_Vietnam` | `usp_SanminaLabelPrint_iud_Vietnam` | `STB_SanminaIndiaLabelPrintHist` |

### 🆂 Phân Hệ Quản Lý Chất Lượng (C-Series)
| TCode | Tên Màn Hình | Search SP (`_get`) | Execute SP (`_iud`) | Bảng DB Chính |
|---|---|---|---|---|
| **C220** | IQC Confirmation | `usp_MaterialQcInfo_get` | `usp_DoUpdateMaterialQcInfo_Success` | `STB_MaterialQcInfo` |
| **C321** | Defect Repair & Scrap | `usp_Vietnam_GetDefectRepairInfo_ForRepair` | `usp_DoProcessLossForBarcode_VNT` | `STB_DefectRepairInfo` |
| **C443** | PQC Verification | `usp_GetCommInspection_HistoryForBarcode_Vietnam` | `usp_DoFinishCommInspDoc_VNT` | `STB_CommInspDocHistory` |
| **C512** | OQC Lot Management | `usp_GetMaterialOQcInfo` | `usp_DoMakeMaterialQcSampleResult` | `STB_MaterialQcInfo` |
| **C530** | OQC Audit (Core OQC) | `usp_MaterialQcDetail_get` | `usp_DoUpdateMaterialQcInfo_Success` | `STB_MaterialQcInfo` |
| **C546** | FOQC OCV / ESR | `usp_MaterialQcSampleResult_get` | `usp_Vietnam_MaterialFOQcDetail_get` | `STB_MaterialQcSampleResult` |

### 📦 Phân Hệ Quản Lý Kho (F-Series)
| TCode | Tên Màn Hình | Search SP (`_get`) | Execute SP (`_iud`) | Bảng DB Chính |
|---|---|---|---|---|
| **F110** | Thuộc tính vật tư | `usp_MaterialStockAttributeInfo_get` | `usp_MaterialStockAttributeInfo_iud` | `STB_MaterialStockAttributeInfo` |
| **F312** | Sửa SL kho | `usp_MaterialDocInfo_get` | `usp_MaterialDocInfo_iud` | `STB_MaterialDocInfo` |
| **F330** | Nhập kho NVL | `usp_MaterialDeliveryList_get` | `usp_DoCreateMaterialDoc` | `STB_MaterialLotInfo`, `STB_MaterialDocDetail` |
| **F430** | Xuất kho ra Line | `usp_MaterialIssueList_get` | `usp_DoProcessMaterialIssue` | `STB_MaterialStock` |
| **F721** | Tồn kho thực | `usp_vvt_MaterialLotInfo_get` | — | `STB_MaterialLotInfo` |
