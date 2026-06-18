# 📚 KNOWLEDGE — Vinatech MES Quick Reference (Load khi cần)

> **Mục đích:** Cheat sheet nén gọn để AI trả lời nhanh mà không phải đọc 30 KB files
> **Cập nhật:** 2026-06-19

---

## 1. BẢNG DỮ LIỆU TRỌNG TÂM

| Bảng | Mục đích | Dùng khi |
|------|----------|----------|
| `STB_SetInfo` | Barcode sản phẩm (ControlNo, ProdQty, LotDecisionResult, IsDefect) | Debug mọi lỗi sản xuất |
| `STB_ProdRouteHist` | Lịch sử scan công đoạn (RouteCode, ProdQty, JobDate) | Trace routing |
| `STB_MaterialLotInfo` | NVL + thành phẩm (LotNo, CurrentQty, PackingID) | Kho, đóng gói |
| `STB_MaterialMaster` | Thông tin master vật tư | Check mã NVL |
| `STB_ModelBasicInfo` | Model + Vol/Farad (MBIExtText04/05) | Lỗi in tem thiếu thông số |
| `STB_PackingStandard` | Tiêu chuẩn đóng gói (VinylBagQty, InnerBoxQty, OutBoxQty) | Lỗi gộp box |
| `STB_MaterialStockAttributeInfo` | IsLotUse, IsUseBarcode | Lỗi F110 |
| `STB_ProductionOrderRouting` | Route config của PO (IsOutputRoute) | Lỗi không gộp box |
| `STB_DayProdPlan` | Kế hoạch sản xuất ngày | Trace PO |
| `STB_CommInspDocHistory` | Lịch sử QC | Check QC pass/fail |
| `STB_BomHeader` / `STB_BomDetail` | BOM sản phẩm | Check NVL |
| `STB_RawMaterialInputHist` | Scan NVL tại V-23/V-24 | Lỗi chưa scan NVL |
| `STB_DividePackaging` | Box đóng gói | Trace packing |
| `STB_VN_PRODUCTION_ERROR` | Phế NVL báo cáo | B598 |
| `STB_ElectrodeStep` | Cấu hình bước cân điện cực | B552/Mixing |
| `STB_VietNam_CheckBarcode_2624` | Barrel barcode (thùng NVL) | Trace thùng |

## 2. SP PATTERN NAMING

| Prefix | Loại |
|--------|------|
| `usp_Get...` / `usp_..._get` | SELECT/Load data |
| `usp_Do...` | Execute/Save/Process |
| `usp_Vietnam_...` / `usp_VN_...` | Customized cho VN |
| `usp_VVT_...` | Vinatech-specific |
| `usp_HN_...` | Hà Nam-specific |

## 3. FACTORY MATRIX

| Nhà máy | CompanyCode | Route prefix | Barcode format | Kho TP |
|---------|-------------|--------------|----------------|--------|
| Bắc Ninh (Electrode) | VNT | `E-xx` | `VV...` | — |
| Bắc Giang (Cell) | VVT (F1/F2) | `V-xx` | `VV...(Cell)` `VJ...(convert)` | `STB_VN_FINISHGOODS_BG` |
| Hà Nam | VVT_F3 | `VE-xx` | `VE260507-001` | `FinishGoodMESInstock_HN` |

## 4. GOLDEN QUERY — Full Trace Barcode (Truy vết 360°)

Để tối ưu và bao phủ 100% các trường hợp (không bị sót khi quét nguyên vật liệu hoặc cuộn điện cực vốn chạy ở các bảng khác nhau), hãy sử dụng đúng mẫu truy vấn phù hợp với loại Barcode cần kiểm tra:

### Mẫu 1: Dành cho sản phẩm Cell & Module (Chiếm 80% trường hợp)
```sql
SELECT 
    SI.Barcode,
    SI.ControlNo,
    SI.PONo,
    SI.MaterialCode,
    SI.InputLineCode,
    SI.LotDecisionResult,
    SI.IsDefect,
    PRH.RouteCode,
    RI.RouteName,
    PRH.ProdQty,
    PRH.CreateDateTime,
    MLI.CurrentQty,
    MLI.MaterialWarehouseCode,
    MLI.MaterialLocationCode,
    DP.PackingID,
    DP.ParentPackingID
FROM STB_SetInfo SI WITH(NOLOCK)
LEFT JOIN STB_ProdRouteHist PRH WITH(NOLOCK) ON SI.ControlNo = PRH.ControlNo
LEFT JOIN STB_RouteInfo RI WITH(NOLOCK) ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_MaterialLotInfo MLI WITH(NOLOCK) ON SI.Barcode = MLI.MaterialLotNo
LEFT JOIN STB_DividePackaging DP WITH(NOLOCK) ON SI.Barcode = DP.LotNo
WHERE SI.Barcode = 'MÃ_BARCODE_CELL_MODULE' 
   OR SI.ControlNo = 'MÃ_BARCODE_CELL_MODULE'
ORDER BY PRH.CreateDateTime ASC;
```

### Mẫu 2: Dành cho cuộn điện cực (Coating/Slitting/Curling - Electrode)
```sql
SELECT 
    MLI.MaterialLotNo,
    MLI.MaterialCode,
    MLI.CurrentQty,
    MLI.MaterialWarehouseCode,
    MLI.MaterialLocationCode,
    C.MachineCode,
    C.WorkDate,
    P.MachineCode,
    P.WorkDate,
    S.ProductionQty,
    S.CreateDateTime
FROM STB_MaterialLotInfo MLI WITH(NOLOCK)
LEFT JOIN STB_ElectrodeCoatingInfo C WITH(NOLOCK) ON MLI.MaterialLotNo = C.ElectrodeLotNumber
LEFT JOIN STB_ElectrodeRollPressingInfo P WITH(NOLOCK) ON MLI.MaterialLotNo = P.ElectrodeLotNumber
LEFT JOIN STB_ElectrodeSlittingResult S WITH(NOLOCK) ON MLI.MaterialLotNo = S.ElectrodeLotNumber
WHERE MLI.MaterialLotNo = 'MÃ_LOT_CUỘN_ĐIỆN_CỰC';
```

### Mẫu 3: Dành cho Nguyên Vật Liệu (Raw Materials - WMS & Line Input)
```sql
SELECT 
    MLI.MaterialLotNo,
    MLI.MaterialCode,
    MM.MaterialName,
    MLI.CurrentQty,
    MLI.MaterialWarehouseCode,
    MLI.MaterialLocationCode,
    RMIH.MachineCode,
    RMIH.RouteCode,
    RMIH.CreateDateTime
FROM STB_MaterialLotInfo MLI WITH(NOLOCK)
LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MLI.MaterialCode = MM.MaterialCode
LEFT JOIN STB_RawMaterialInputHist RMIH WITH(NOLOCK) ON MLI.MaterialLotNo = RMIH.MaterialLotNo
WHERE MLI.MaterialLotNo = 'MÃ_LOT_NGUYÊN_VẬT_LIỆU'
ORDER BY RMIH.CreateDateTime DESC;
```


## 5. TOP 10 LỖI THƯỜNG GẶP → KB FILE

| Triệu chứng | KB |
|--------------|----|
| Không đăng nhập MES | KB_01 §1.1 |
| Không in được tem | KB_01 §1.2, KB_04 §6.12 |
| Gộp box lỗi | KB_04 §6.4, §6.13 |
| Lỗi QC/chưa pass | KB_05 §9 |
| NVL hết hạn | KB_02 §4.10 |
| Chốt công đoạn lỗi | KB_14 §4.4 |
| Model mới chưa cấu hình | KB_06 §1 |
| Phế NVL B598 | KB_03 §6.12 |
| Kho HN lỗi | KB_08 |
| ESR/Aging | KB_05 §9.7 |

## 6. KNOWLEDGE ITEMS (KI) — Tra trước KB

| KI | Khi nào dùng |
|---|---|
| `screen_id_reference` | Nhận TCode → biết ngay SP + Table + KB nào (106 screens) |
| `deep_system_map` | Cần trace SP chain, xem impact, table sizes |
| `kb_verification` | Check tên SP/table đúng chưa (known typos + SmartFramework list) |
| `cellline_operations` | Nghiệp vụ thực tế CellLine (logic Module vs Cell, bypass) |
| `new_model_checklist` | Thêm model mới (8 bước) |
| `system_environment` | Connection info, IP, URL |

## 7. KB FILES MAP (37 files)

| # | File | Phạm vi |
|---|------|---------|
| 00 | KB_SCREEN_BUG_REF | Cẩm nang tra cứu lỗi theo Screen ID |
| 01 | KB_01_UI_PHAN_QUYEN | Login, phân quyền, stage prices |
| 02 | KB_02_KHO_WMS | Kho NVL, FIFO, hạn dùng, tách lot |
| 03 | KB_03_SAN_XUAT | Sản xuất Cell/Module, B530/B597 |
| 04 | KB_04_DONG_GOI_IN_TEM | Đóng gói B523/B525, in tem |
| 05 | KB_05_QC_ELECTRODE | QC IQC/PQC/OQC, điện cực, ESR |
| 06 | KB_06_MASTER_DATA_TOOLS | Master data, màn hình A/B/F/C map |
| 07 | KB_07_GROUPWARE_INTEGRATION | ESM bridge, BOM sync |
| 08 | KB_08_KHO_THANH_PHAM_HN | Kho thành phẩm Hà Nam |
| 10 | KB_10_KIEN_TRUC_VA_DATAFLOW | Kiến trúc tổng quan MES & Data Flow |
| 12 | KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT | Phân tích sâu cốt lõi & Audit CSDL |
| 14 | KB_14_TRACE_BUG_METHODOLOGY | Phương pháp trace bug (5 bước + case study) |
| 19 | KB_19_ALL_DATABASES_MAP | Schema DB, cross-DB links |
| 20 | KB_20_MAY_MOC_BAO_TRI | Máy móc bảo trì |
| 21 | KB_21_NHAN_SU_WORKER | Nhân sự, worker assignment |
| 22 | KB_22_DASHBOARD_ANDON | Dashboard, monitoring |
| 23 | KB_23_4M_CHANGE_CAPA | 4M change, CAPA |
| 24 | KB_24_RELIABILITY_TEST | Reliability test |
| 25 | KB_25_VINAENESSOL | Hưng Yên factory |
| 26 | KB_26_LIEN_KET | Liên kết hệ thống & bug logic |
| 27 | KB_27_SCM_REWORK | SCM, rework, trả hàng, kiểm kê |
| 28 | KB_28_SYSTEM_OBJECTS | 976 bảng, 3314 SPs, 1442 screens map |
| 30 | KB_30_CORE_SP_ENGINE | Core SP analysis (B530/B523/F330) |
| **31** | **KB_31_SCREEN_BUG_FIXBOOK** | **★ Bug fix tra cứu theo TCode (70+ bugs, SQL verified)** |
| **32** | **KB_32_SCREEN_SP_TABLE_MAP** | **Screen→SP→Table mapping (DB verified)** |
| **33** | **KB_33_FACTORY_WORKCENTER_MATRIX** | **Ma trận nhà máy/WorkCenter/Route** |
| 36 | KB_36_HANAM_FACTORY_SCREENS | Màn hình riêng Hà Nam |
| 37 | KB_37_SP_ARCHAEOLOGY_BUGS_AND_PATTERNS | SP patterns & anti-patterns |

## 8. ⚠️ COLUMN NAME TRAPS (Hay bị sai)

| Hay viết sai | Đúng | Bảng |
|---|---|---|
| `WarehouseCode` | `MaterialWarehouseCode` | STB_MaterialLotInfo |
| `CommInspResult` | **KHÔNG TỒN TẠI** | OQC result qua SP, không phải cột |
| `WasteWeight` | `Weights` | STB_VN_PRODUCTION_ERROR |
| `Status` | `StatusError` | STB_VN_PRODUCTION_ERROR |
| `CoatingDate` | `JobDate` | STB_ElectrodeWasteInfoNew |
| `STB_CellTestResult` | `STB_CellTesterResult` | SmartFactoryIncubator |
| `FinishGoodStockOutBG` | `InvoiceFinishGoodStockOutBG` | SmartFactoryV2 |
| `STB_MaterialHoldInfo` | KHÔNG TỒN TẠI | Dùng MaterialWarehouseCode='HOLDING_*' |
| `STB_BarrelBarcodeInfo` | KHÔNG TỒN TẠI | Dùng STB_VietNam_CheckBarcode_2624 |
| `STB_HN_AccountingPrice` | KHÔNG TỒN TẠI | Table legacy đã bị xóa |
