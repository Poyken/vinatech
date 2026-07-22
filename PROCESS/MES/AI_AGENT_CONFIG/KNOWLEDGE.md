# 📚 KNOWLEDGE — Vinatech MES Quick Reference (Load khi cần)

> **Mục đích:** Cheat sheet nén gọn để AI trả lời nhanh mà không phải đọc 30 KB files
> **Cập nhật:** 2026-06-19

---

## 1. BẢNG DỮ LIỆU TRỌNG TÂM & BẢNG GIAO DỊCH LỚN (NOLOCK TARGETS)

### 1.1 Các Bảng Dữ Liệu Lớn Nhất Cần Dùng WITH(NOLOCK) Triệt Để
*Dữ liệu kiểm tra thực tế trên SmartFactoryV2:*
- **`STB_VVT_ESRDATA`** (~401M dòng): Chứa kết quả đo ESR lớn nhất hệ thống. Luôn dùng NOLOCK và WHERE cụ thể.
- **`STB_ProductStockInfo`** (~65M dòng): Thông tin tồn kho sản phẩm.
- **`STB_CommInspMeasureHist`** (~60M dòng): Lịch sử đo kiểm chất lượng QA.
- **`STB_ESRInspectionData`** (~39M dòng): Dữ liệu kiểm định điện trở ESR.
- **`STB_CommInspDocItem`** (~33M dòng): Các hạng mục của chứng từ kiểm định.
- **`STB_IoTMeasureHist`** (~28M dòng): Lịch sử đo đạc từ thiết bị IoT.
- **`STB_Vvt_SdProds`** (~22M dòng): Dữ liệu sản lượng / bán thành phẩm.
- **`STB_ProcedureLog`** (~19M dòng): Log thực thi các Stored Procedure hệ thống.
- **`STB_VN_FINISHGOODS_CAPTURE`** (~13M dòng): Bảng snapshot thành phẩm Việt Nam.
- **`stb_DetailAgaingHN`** (~11M dòng): Chi tiết công đoạn Aging tại Hà Nam.

### 1.2 Bảng Dữ Liệu Nghiệp Vụ Trọng Tâm
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

## 2. SP PATTERN NAMING & ACTIVE SP REFERENCE

### 2.1 SP Naming Conventions
| Prefix | Loại |
|--------|------|
| `usp_Get...` / `usp_..._get` | SELECT/Load data |
| `usp_Do...` | Execute/Save/Process |
| `usp_Vietnam_...` / `usp_VN_...` | Customized cho VN |
| `usp_VVT_...` | Vinatech-specific |
| `usp_HN_...` | Hà Nam-specific |

### 2.2 Active & Critical SPs (Đang Bảo Trì/Sửa Đổi Gần Đây)
- **`usp_ChangeLotnoPrintTem`**: Dùng khi cần đổi số lô (Lot No) và in lại tem tương ứng trên UI.
- **`usp_DoCheckLabelPrintCount`**: Kiểm tra và kiểm soát số lần in tem nhãn để ngăn chặn in thừa hoặc in lậu tem tại hiện trường.
- **`usp_DoAddTempAndHumRemindMail_VVTF3`**: Tự động gửi email nhắc nhở về các thông số nhiệt độ và độ ẩm vượt ngưỡng tại nhà máy Hà Nam F3.
- **`usp_StrippingElectrode_get_V1`**: Truy vấn thông tin Stripping điện cực ở công đoạn Electrode.
- **`usp_GetMaterialOQcInfo_VVTF4`**: Lấy thông tin OQC của Lot vật tư tại nhà máy Hưng Yên F4.
- **`usp_Vietnam_GetLabelsForLotNo_HN`**: Lấy danh sách các mẫu nhãn dán tương ứng với số Lot tại Hà Nam.
- **`usp_GetProdRouteHistForBarcode_VNT`**: Xem lịch sử định tuyến (Route History) cho một barcode tại nhà máy Bắc Ninh.
- **`usp_DoMakeRawMaterialInputHistBE`**: Tạo lịch sử nạp nguyên vật liệu cho backend xử lý.
- **`usp_DoChangeMaterialDocLotInfo`**: Chỉnh sửa thông tin chứng từ lô vật tư.

### 2.3 Core Mapped SPs (Màn Hình Core & SP Đăng Ký)
- **B523 — Divide Packaging (Gộp Box nhỏ/Đóng gói)**:
  - *Search / Load data*: `usp_Vietnam_GetProdPackingForBarcode_VVT` (tải danh sách đóng gói theo barcode), `usp_Vietnam_GetBoxIDForLotNo_VVT` (lấy BoxID cho Lot).
  - *Execute / Save / Process*: `usp_Vietnam_DoProcessProdPacking_VVT` (logic gộp box chính), `usp_DoCancelProdPacking_LotNo` (hủy gộp box), `usp_DoCreatePackingLabelInfo` (tạo tem đóng gói).
- **B530 — Production Route Input (Chốt sản lượng công đoạn)**:
  - *Search & Execute*: `usp_DoProcessProdRouteHist_VNT` (logic chốt sản lượng và tự động trừ kho ảo Backflush).


## 3. FACTORY MATRIX (SoT: KB_10, DB verified)

| Nhà máy | WorkCenter | Route prefix | Barcode format | Kho TP |
|---------|------------|--------------|----------------|--------|
| Bắc Ninh | VNT_F1 / VVT_F1 | `V-xx` | `VJ`(VNT) / `VV`(VVT) | `PROD_VN_WH` |
| Electrode/MEA | VNT_F2 | `E-xx` | `MEA` | — |
| Bắc Giang 1 | VVT_F2 | `V-xx_BG` | `VV` | `PROD_BG_WH` |
| Hà Nam | VNT_F3 / VVT_F3 | `VE-xx` | `VE` | `PROD_HN_WH` |
| Bắc Giang 2 | VNT_F4 / VVT_F4 | `VP-xx`, `ND-xx` | `K` | *(chưa setup)* |
| Hưng Yên | VNT_F5 | `D-xxx` | — | *(chưa setup)* |

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

### Mẫu 4: Truy vết Lot chờ chia cuộn Slitting Hà Nam (F742/F743)
Dùng để kiểm tra lý do một Lot cuộn nguyên liệu (Foil/ConPaper) không hiển thị trên danh sách "Chờ cắt" màn hình [F742] / [F743]:
```sql
SELECT 
    MLI.LotID,
    MLI.MaterialLotNo,
    MLI.MaterialCode,
    MM.MaterialName,
    MM.ProductGroupCode,
    MLI.InitialQty,
    MLI.CurrentQty,
    MLI.MaterialWarehouseCode,
    MLI.IsParrent,
    MLI.IsSlitting
FROM STB_MaterialLotInfo MLI WITH(NOLOCK)
INNER JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MLI.MaterialCode = MM.MaterialCode
WHERE MLI.LotID = 'MÃ_LOT' OR MLI.MaterialLotNo = 'MÃ_BARCODE';

-- Các điều kiện bắt buộc để Lot hiển thị tại tab "Chờ cắt" (F742):
-- 1. MaterialWarehouseCode = 'SLITTING_HN_WH' (Đã điều chuyển sang kho slitting)
-- 2. IsParrent = '1' (hoặc NOT NULL - phải là cuộn mẹ)
-- 3. IsSlitting = 0 (hoặc NULL - chưa bị chốt chia cuộn)
-- 4. CurrentQty > 0 (Số lượng tồn kho phải còn)
-- 5. ProductGroupCode IN ('CON-PAPER','ANODE-FOIL','CATHODE-FOIL')
```


## 5. TOP 10 LỖI THƯỜNG GẶP → KB FILE

| Triệu chứng | KB |
|--------------|----| 
| **Mọi lỗi → tra mã màn hình** | **KB_09 (Bug Fixbook, đọc trước)** |
| Không đăng nhập MES | KB_01 §1.1 |
| Không in được tem | KB_01 §1.2, KB_04 §6.12 |
| Gộp box lỗi | KB_04 §6.4, §6.13 |
| Lỗi QC/chưa pass | KB_05 §9 |
| NVL hết hạn | KB_02 §4.10 |
| Chốt công đoạn lỗi | KB_03 §6.3 |
| Model mới chưa cấu hình | KB_06 §1 |
| Phế NVL B598 | KB_03 §6.12 |
| Kho HN lỗi | KB_02/ → 01_WMS_CORE §5 |
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

## 7. KB FILES MAP (12 items, 5 chunked folders)

| # | File | Phạm vi | Size |
|---|------|---------|------|
| 01 | KB_01_UI_AND_SCREENS | Login, phân quyền, Z110/Z220/Z330 tạo màn hình, B786, B934 | 7KB |
| **02** | **KB_02/ ⚡CHUNKED** | Kho WMS: NVL, TP, FIFO, Holding | 78KB→2c |
| **03** | **KB_03/ ⚡CHUNKED** | Sản xuất Cell/Module, B530/B597 | 150KB→4c |
| **04** | **KB_04/ ⚡CHUNKED** | Đóng gói B523/B525, in tem | 71KB→2c |
| **05** | **KB_05/ ⚡CHUNKED** | QC IQC/PQC/OQC, Electrode, ESR, Slitting | 109KB→2c |
| 06 | KB_06_MASTER_DATA_TOOLS | Master data, model mới | 28KB |
| **07** | **KB_07/ ⚡CHUNKED** | Hưng Yên, D-series | 41KB→3c |
| 08 | KB_08_CORE_SP_ENGINE | Core SP (DoProcess/Backflush/Packing) | 24KB |
| **09** | **KB_09_SCREEN_BUG_FIXBOOK** | **★ Bug fix 70+ bugs** | **31KB** |
| 10 | KB_10_FACTORY_WORKCENTER | Ma trận nhà máy/WorkCenter | 9KB |
| 11 | KB_11_HANAM_FACTORY_SCREENS | Hà Nam 83 screens | 21KB |


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
| `STB_HN_AccountingPrice` | KHÔNG TỒN TẠI | Dùng STB_PublicCodeAndPrice |

