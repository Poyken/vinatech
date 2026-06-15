# KB_06 - Master Data, SQL Tools & Manual Bypass

> **Màn hình liên quan:** A230, A310, A410, B250, B270, SQL Server, STB_ModelBasicInfo
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 📐 Master Data & Model

### 1.1 Thêm Model mới vào STB_ModelBasicInfo (A410)

> ⚠️ Nếu model có trong `STB_MaterialMaster` (A230) nhưng **không có** trong `STB_ModelBasicInfo` -> C512 không tìm thấy, B597 không chọn được, Vol/Farad không hiện.

**Checklist khi thêm model mới:**
```
□ 1. A230 (STB_MaterialMaster) - Mã vật tư và tên
□ 2. A310 (STB_BomHeader/Detail) - BOM nguyên liệu - Anh Huy phụ trách
□ 3. A320 (STB_RouteInfo) - Công đoạn sản xuất
□ 4. A410 (STB_ModelBasicInfo) - Thông số kỹ thuật (Vol, Farad, OQC Type)
□ 5. A419 (STB_PackingStandard) - Tiêu chuẩn đóng gói
□ 6. A460 (STB_LabelInfo) - Mẫu tem in
□ 7. STB_VVT_StagePrices - Giá công đoạn (cho B682/B781)
□ 8. Cấu hình Vỏ nhôm - ⚠️ Bảng STB_AluCaseMapping_VVT KHÔNG TỒN TẠI; logic mapping được hardcode trong SP usp_Vietnam_RawMaterialInputHist_uid.
```

**SQL thêm ModelBasicInfo:**
```sql
-- Kiểm tra đã có chưa
SELECT * FROM STB_ModelBasicInfo WHERE ModelCode = 'ECVT30-367'

-- Thêm mới nếu chưa có
INSERT INTO STB_ModelBasicInfo (
    ModelCode, ModelName, MaterialTypeCode, ProductGroupCode,
    MBISizeH, MBISizeW, IsClosed, OqcType, OqcInspectionRuleType,
    InspectionType, InspectionLevel,
    MBIExtText01, MBIExtText02, MBIExtText03, MBIExtText04, MBIExtText05,
    CreateDateTime
)
VALUES (
    'ECVT30-367',       -- ModelCode (= MaterialCode)
    'HY-CAP WEC...',    -- ModelName
    'CEL',              -- MaterialTypeCode: CEL = Cell, MDL = Module
    'HC-EDLC',          -- ProductGroupCode
    30,                 -- MBISizeH (chiều cao mm)
    10,                 -- MBISizeW (chiều rộng mm)
    0,                  -- IsClosed
    'MANUAL',           -- OqcType
    'BY_MODEL',         -- OqcInspectionRuleType
    'SAMPLE',           -- InspectionType
    'SAMPLE',           -- InspectionLevel
    '9R0',              -- MBIExtText01 (Voltage raw)
    '335',              -- MBIExtText02 (Farad raw)
    'WEC',              -- MBIExtText03 (Prefix)
    '9.0',              -- MBIExtText04 (Voltage hiển thị)
    '3.3',              -- MBIExtText05 (Farad hiển thị)
    GETDATE()
);
```

---

### 1.2 Lỗi không hiển thị Vol, Farad

**Nguyên nhân:** View `VW_ModelBasicInfo` không tìm thấy mapping vì:
- `MaterialTypeCode` sai (phải là MDL hoặc CEL)
- `MBIExtText04`, `MBIExtText05` bị trống

```sql
-- Kiểm tra
SELECT ModelCode, MaterialTypeCode, MBIExtText04 AS Voltage, MBIExtText05 AS Farad
FROM STB_ModelBasicInfo
WHERE ModelCode = 'Mã_Model'

-- Fix nếu bị trống
UPDATE STB_ModelBasicInfo
SET MBIExtText04 = '9.0', MBIExtText05 = '3.3'
WHERE ModelCode = 'Mã_Model'
```

---

### 1.3 Đăng ký mã vật tư mới vào STB_MaterialMaster (A230) qua SQL
Nếu dữ liệu chưa tự động đồng bộ từ SAP/Groupware sang MES và cần chèn khẩn cấp bằng SQL để sản xuất:
```sql
INSERT INTO STB_MaterialMaster (
    MaterialCode, 
    MaterialName, 
    MaterialTypeCode, 
    ProductGroupCode, 
    IsProdPlan, 
    BasicRoutingCode
)
VALUES (
    '50VHV39MD12XXXVC01', 
    N'Polymer AL-Cap', 
    'FERT', 
    'SMD', 
    1, 
    'VE_ChipRouting'
);
```

---

### 1.4 Giải mã quy tắc đặt tên Model Name (Model Name Anatomy)

Trong hệ thống MES Vinatech, một sản phẩm thường có hai loại mã định danh:
1. **ModelCode:** Mã quản lý nội bộ của hệ thống (Ví dụ: `ECVT30-197` hoặc `ECVT30-098`). Khi truy vấn SQL hoặc viết code, bắt buộc phải dùng `ModelCode`.
2. **ModelName:** Tên thương mại hiển thị cho người dùng, chứa thông số kỹ thuật chi tiết.
   * *Ví dụ:* `HY-CAP VEC3R0367QG (3562)` đại diện cho:
     * **HY-CAP:** Thương hiệu sản phẩm tụ điện của Vinatech.
     * **VEC:** Viết tắt của dòng sản phẩm (Dòng tụ điện EDLC).
     * **3R0:** Ký hiệu mức Điện áp (Voltage) là `3.0V` (`R` tương ứng dấu phẩy).
     * **367:** Ký hiệu Điện dung (Capacitance) là `360 Farad` (`36` nhân với `10^7` pF, tương đương `360F`).
     * **QG:** Mã quy định kiểu chân pin hoặc tiêu chuẩn đóng gói của sản phẩm.
     * **(3562):** Mã dự án (Project Code) do bộ phận Sales quản lý.

---

## 2. ⚙️ Cấu hình Vận hành (F110)

### 2.1 Lỗi NVL mới không gộp Box được

**Nguyên nhân:** Bảng `STB_MaterialStockAttributeInfo` chưa có dòng cho mã NVL mới, hoặc `IsLotUse = 0`.

**Debug & Fix:**
```sql
-- Kiểm tra
SELECT MaterialCode, IsUseBarcode, IsLotUse
FROM STB_MaterialStockAttributeInfo
WHERE MaterialCode = 'Mã_NVL'

-- Nếu không có dòng -> Vào F110 nhập và Save
-- Nếu IsLotUse = 0 -> Vào F110 tích và Save
-- Hoặc INSERT/UPDATE trực tiếp:
UPDATE STB_MaterialStockAttributeInfo
SET IsLotUse = 1, IsUseBarcode = 1
WHERE MaterialCode = 'Mã_NVL'
```

---

## 3. 💰 Fix Giá Công Đoạn (Stage Prices)

> Áp dụng khi màn hình B682, B781, B789 không hiện giá hoặc sai đơn giá.

> ⚠️ **Xác minh DB (2026-05-17):** Bảng `STB_VVT_StagePrices` thực tế có thêm nhiều cột: `RouteV29`->`RouteV34`, `RouteVE01`->`RouteVE10` (cho Hà Nam), `WorkCenterCode` (để phân biệt nhà máy). Hà Nam cần dùng `WorkCenterCode = 'VVT_F3'` và điền các route VE.

```sql
-- Kiểm tra đã có giá chưa
SELECT * FROM STB_VVT_StagePrices WHERE model = 'Mã_Model'

-- Thêm giá cho Cell Line (B682/B781) -- Bắc Ninh và Bắc Giang (V routes)
INSERT INTO STB_VVT_StagePrices (
    model, RouteV22, PriceV22, RouteV23, PriceV23, RouteV24, PriceV24,
    RouteV25, PriceV25, RouteV26, PriceV26, RouteV27, PriceV27, RouteV28, PriceV28, 
    WorkCenterCode, CreateDate
)
VALUES (
    'MÃ_MODEL', 'V-22', 0.065, 'V-23', 0.071, 'V-24', 0.089, 'V-25', 0.094,
    'V-26', 0.094, 'V-27', 0.110, 'V-28', 0.118, 
    'VVT_F2',  -- VVT_F1=Bắc Ninh, VVT_F2=Bắc Giang, VVT_F3=Hà Nam
    GETDATE()
);

-- Với Module (B789/B791) -> Sửa trong Function:
SELECT OBJECT_DEFINITION(OBJECT_ID('fn_VVT_StagePricesMODULE'))
-- Tìm dòng SELECT -> Thêm UNION ALL với Model và giá mới
```

---

## 4. 🛢️ Lỗi Vỏ Nhôm (Aluminum Case Mapping)

-> Xem [KB_05 Mục 7.4](KB_05_QC_ELECTRODE.md#74-b597-báo-lỗi-không-tồn-tại-thiết-lập-vỏ-nhôm) để debug và fix.

---

## 5. 🔎 SQL Utilities - Truy vấn hỗ trợ

### 5.1 Golden Query: Kiểm tra lịch sử toàn bộ 1 Barcode

```sql
SELECT
    SI.Barcode,
    SI.MaterialCode,
    MM.MaterialName,
    SI.ProdQty,
    SI.InputLineCode,
    SI.PONo,
    SI.LotDecisionResult AS [KQ_QC],
    PRH.RouteCode,
    RI.RouteName AS [Ten_Cong_Doan],
    PRH.ProdDateTime AS [Thoi_Gian],
    DP.PackingID AS [Ma_Thung]
FROM STB_SetInfo SI
JOIN STB_MaterialMaster MM ON SI.MaterialCode = MM.MaterialCode
LEFT JOIN STB_ProdRouteHist PRH ON SI.ControlNo = PRH.ControlNo
LEFT JOIN STB_RouteInfo RI ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_DividePackaging DP ON SI.ControlNo = DP.LotNo
WHERE SI.Barcode = '[Barcode]'
ORDER BY PRH.ProdDateTime ASC
```

---

### 5.2 Lấy PartNo & Size từ tên Model

```sql
-- Lấy PartNo
SELECT RTRIM(LTRIM(SUBSTRING('HY-CAP VEC3R0606QG (1840)',
    CHARINDEX(' ', 'HY-CAP VEC3R0606QG (1840)'), 12))) AS PartNo

-- Lấy Size (Width + Height, dạng 0813)
SELECT RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2)
    + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)) AS [Size]
FROM STB_ModelBasicInfo WHERE ModelCode = '...'
```

---

### 5.3 Tìm tất cả hoạt động của 1 User trong ngày

```sql
DECLARE @User NVARCHAR(50) = 'vanduc'
DECLARE @Date DATE = CAST(GETDATE() AS DATE)

-- Xem trong các bảng chính
SELECT 'STB_SetInfo' AS [Bảng], COUNT(*) AS [Số_Dòng], MAX(CreateDateTime) AS [Cập_Nhật_Cuối]
FROM STB_SetInfo
WHERE (CreateUserID = @User OR ChangeUserID = @User)
AND CAST(CreateDateTime AS DATE) = @Date
HAVING COUNT(*) > 0

UNION ALL
SELECT 'STB_ProdRouteHist', COUNT(*), MAX(CreateDateTime)
FROM STB_ProdRouteHist
WHERE CreateUserID = @User AND CAST(CreateDateTime AS DATE) = @Date
HAVING COUNT(*) > 0

UNION ALL
SELECT 'STB_MaterialLotInfo', COUNT(*), MAX(CreateDateTime)
FROM STB_MaterialLotInfo
WHERE CreateUserID = @User AND CAST(CreateDateTime AS DATE) = @Date
HAVING COUNT(*) > 0
```

---

### 5.4 Tìm SP theo tên (khi quên tên chính xác)

```sql
-- Tìm SP chứa từ khóa
SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
AND ROUTINE_NAME LIKE '%Packing%VVT%'
ORDER BY ROUTINE_NAME

-- Xem nội dung SP
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_DoProcessProdPacking_VVT'))
```

---

### 5.5 Kiểm tra log gói tin từ UI (debug khi không biết lỗi ở đâu)

```sql
-- Log 1: Gói tin từ UI gửi lên Server
SELECT TOP 50 ProcessDateTime, IPAddress, Data, ProcessResult
FROM STB_ProcessTerminalDataLog
WHERE CAST(ProcessDateTime AS DATE) = CAST(GETDATE() AS DATE)
AND Data LIKE '%Mã_Barcode%'
ORDER BY ProcessDateTime DESC

-- Log 2: Biến số trong SP
SELECT TOP 50 ProcedureName, VariableName, VariableValue, CreateDateTime
FROM STB_ProcedureLog
WHERE CAST(CreateDateTime AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY CreateDateTime DESC
```

---

## 6. 🆘 Manual Lot Bypass (In tem khẩn khi không có Lot trên hệ thống)

*   **Khi nào dùng:** Tình huống khẩn cấp cần in tem đóng gói gấp cho lô hàng thực tế đã đóng xong nhưng trên hệ thống MES bị lỗi không sinh được Lot (ví dụ: do sự cố đồng bộ PO ở B450).
*   **Chi tiết & Giải pháp:** Xem quy trình cứu hộ 3 bước (INSERT/UPDATE SQL) chi tiết tại [KB_04_DONG_GOI_IN_TEM.md#615-lỗi-không-in-được-tem-vì-không-có-lot-trên-hệ-thống-bypass-thủ-công](KB_04_DONG_GOI_IN_TEM.md#615-lỗi-không-in-được-tem-vì-không-có-lot-trên-hệ-thống-bypass-thủ-công).

---

## 7. 🏗️ Thêm Cell/Line mới (B250, B270)

> Khi có yêu cầu thêm Cell mới (VD: VVBNTC-05), cần cập nhật **3 bảng** Master để đồng bộ.

**Quy trình đầy đủ (chạy trong 1 Transaction):**
```sql
BEGIN TRANSACTION;

-- Bước 1: Kiểm tra đã tồn tại chưa
SELECT * FROM STB_LineInfo WHERE LineCode = 'VVBNTC-05'
SELECT * FROM STB_MachineMaster WHERE MachineCode = 'VVBNTC-05'

-- Bước 2: Thêm LineInfo
IF NOT EXISTS (SELECT 1 FROM STB_LineInfo WHERE LineCode = 'VVBNTC-05')
INSERT INTO STB_LineInfo (LineCode, CompanyCode, WorkCenterCode, LineName, LineDesc, LineType, IsUsed, CreateDateTime, CreateUserID)
VALUES ('VVBNTC-05', 'VVT', 'VVT_F2', 'BN Manual (P20)', 'Thủ công Bắc Ninh', 'Medium', 1, GETDATE(), 'vinaadmin');

-- Bước 3: Thêm MachineMaster (B250)
IF NOT EXISTS (SELECT 1 FROM STB_MachineMaster WHERE MachineCode = 'VVBNTC-05')
INSERT INTO STB_MachineMaster (MachineCode, CompanyCode, WorkCenterCode, MachineName, IsProdMachine, MachineTypeCode, IsUsed, CreateDateTime, CreateUserID)
VALUES ('VVBNTC-05', 'VVT', 'VVT_F2', 'BN Manual (P20)', 1, 'M00001', 1, GETDATE(), 'vinaadmin');

-- Bước 4: Thêm mapping Route (B270) - link đủ V22->V28
INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode, CreateDateTime, CreateUserID)
SELECT 'VVBNTC-05', 'VVBNTC-05', r.RouteCode, GETDATE(), 'vinaadmin'
FROM (
    SELECT 'V-22_BG' AS RouteCode UNION ALL SELECT 'V-23_BG' UNION ALL SELECT 'V-24_BG' UNION ALL
    SELECT 'V-25_BG' UNION ALL SELECT 'V-26_BG' UNION ALL SELECT 'V-27_BG' UNION ALL SELECT 'V-28_BG'
) r
WHERE NOT EXISTS (
    SELECT 1 FROM STB_ProductMachine WHERE MachineCode = 'VVBNTC-05' AND RouteCode = r.RouteCode
);

-- Bước 5: Xác nhận
SELECT 'LineInfo' AS T, LineCode, LineName FROM STB_LineInfo WHERE LineCode = 'VVBNTC-05'
UNION ALL
SELECT 'Machine', MachineCode, MachineName FROM STB_MachineMaster WHERE MachineCode = 'VVBNTC-05'
UNION ALL
SELECT 'Route_Mapping', RouteCode, MachineCode FROM STB_ProductMachine WHERE LineCode = 'VVBNTC-05'

COMMIT;
```

**Rollback nếu cần:**
```sql
DELETE FROM STB_ProductMachine WHERE MachineCode = 'VVBNTC-05' AND LineCode = 'VVBNTC-05'
DELETE FROM STB_MachineMaster WHERE MachineCode = 'VVBNTC-05'
DELETE FROM STB_LineInfo WHERE LineCode = 'VVBNTC-05'
```

---

## 8. 🔧 Nguyên Tắc An Toàn Khi IUD

> ⚠️ **LUÔN SELECT TRƯỚC - IUD SAU**

```sql
-- Mẫu an toàn tuyệt đối:
BEGIN TRANSACTION
    -- 1. SELECT để xác nhận đúng dòng
    SELECT * FROM STB_MaterialLotInfo WHERE MaterialLotNo = '20260507000337'

    -- 2. UPDATE
    UPDATE STB_MaterialLotInfo
    SET CurrentQty = 20
    WHERE MaterialLotNo = '20260507000337'  -- Luôn dùng PK, không dùng điều kiện mờ

    -- 3. SELECT lại để xác nhận kết quả
    SELECT * FROM STB_MaterialLotInfo WHERE MaterialLotNo = '20260507000337'

ROLLBACK  -- Đổi thành COMMIT khi chắc chắn đúng
```

*Cập nhật: 2026-05-17*

---

## 9. 🚀 Quick Start - Checklist Đầy Đủ Khi Thêm Model / Hàng Mới

### 9.1 Checklist Thêm Model Mới (7 bước)

```
BƯỚC 1 - Master Data (Groupware/SAP)
□ Đăng ký MaterialCode mới trong Groupware
□ Đăng ký BOM trong Groupware
□ Chờ sync sang MES (thường 1-2 ngày làm việc)

BƯỚC 2 - Cấu hình MES (IT thực hiện)
□ A210: Kiểm tra MaterialTypeCode đúng chưa (FERT/HALB/MDL/ROH?)
□ A230: Kiểm tra Material đã sync chưa
□ A310: Kiểm tra BOM đã sync chưa
□ A410:
   □ Nhập MBISizeD (kích thước = Length x Diameter)
   □ Chọn InspectionType = SAMPLE
   □ Chọn OqcType = MANUAL
   □ Chọn OqcInspectionRuleType = BY_MODEL
□ A418: Thêm ProdSize (= MBISizeD) -> PackQty (số lượng mỗi box)
□ B210/B220/B230: Kiểm tra Line và Route đã cấu hình chưa
□ B260: Kiểm tra công nhân Line mới đã đăng ký chưa (WorkerGroupCode='VE-01')

BƯỚC 3 - Cấu hình QC
□ C141: Kiểm tra hạng mục PQC đã có chưa
□ C143: Thêm hạng mục PQC riêng cho model nếu cần
□ C121: Kiểm tra nhóm hạng mục OQC đã có chưa
□ C151: Thêm hạng mục OQC cho model mới

BƯỚC 4 - Cấu hình Giá Thành
□ INSERT INTO STB_VVT_StagePrices (MaterialCode, RouteCode, Price, IsUsed)
   -> Mỗi RouteCode 1 dòng, Price từ kế toán cung cấp

BƯỚC 5 - Cấu hình Slitting (nếu là model điện cực mới)
□ F744: Thêm thiết lập chiều rộng Slitting
□ stb_slittinglocationconfig_vvt: INSERT config mới
□ B552: Test nhập dữ liệu Mixing -> Coating -> Rollpress -> Slitting

BƯỚC 6 - Cấu hình NVL đặc biệt (nếu dùng electrolyte/sleeve/terminal mới)
□ Thêm vào stb_vvt_materialbo (qua UI nếu có, hoặc INSERT SQL)
□ NẾU dùng electrolyte mới -> PHẢI sửa SP usp_Vietnam_RawMaterialInputHist_uid
   -> Thêm dòng: SELECT 'GBEC00-0XX' AS electrolyte, 'NEW_MODEL_CODE' AS model, 'SIZE' AS size

BƯỚC 7 - Test
□ B310: Tạo PO test
□ B450: Tạo kế hoạch ngày test
□ B540: Tạo Lot test
□ B530: Nhập sản lượng từng công đoạn
□ B597: Scan NVL tại V-23/V-24
□ B523: Gộp Box
□ C512: Tạo Lot OQC
□ C530: Nhập kết quả kiểm tra
```

---

### 9.2 Checklist Onboard User Mới

```
□ Z410: Tạo tài khoản User
□ Z220: Phân nhóm quyền phù hợp theo vai trò:
   - Công nhân SX: Chỉ xem B530, B540, B597
   - Tổ trưởng: B530, B540, B597, B523, B598, B717
   - QC: C141-C530-C540 range
   - Kho: F312, F330, F430, F721
   - IT: Tất cả + Z410, Z220
□ Z330: Kiểm tra màn hình đã publish ra production chưa
□ B260: Đăng ký nhân viên SX (nếu là công nhân) với WorkerGroupCode='VE-01'
□ usp_Set_VVT_Info_get: Thêm UserID vào whitelist nếu cần đổi Line (B452)
```

---

## 10. 🏗️ Thiết Lập Line & Route (B210/B220/B230/B240)

> Bộ tứ màn hình Master Data quan trọng nhất về Thiết lập Định tuyến sản xuất.

| Màn Hình | Tên Chức Năng | Mục Đích | Bảng Tác Động |
|----------|---------------|----------|---------------|
| **B210** | Đăng ký Line | Khai báo tên chuyền vật lý thuộc công ty nào | `STB_LineInfo` |
| **B220** | Đăng ký Route | Khai báo tên công đoạn (V-01, V-23, MV-01) | `STB_RouteInfo` |
| **B230** | Phân quyền Route vào Line | Map chuyền VVBNC-01 chạy những công đoạn nào | `STB_LineRouteMapping` |
| **B240** | Đăng ký Máy | Phân quyền Máy móc vào Công đoạn | `STB_MachineMaster` |

**Lỗi phổ biến:**
- **B450 không thấy Line:** B210 chưa gán `IsUse=1` hoặc sai WorkCenterCode
- **B530 không cho chọn Máy:** B240 chưa phân bổ Máy đó thuộc Route hiện tại
- **In tem lỗi không ra Tên Line (B525):** `STB_LineInfo.LineName` bị sai ở B210

### 10.1 Hướng dẫn Thay đổi/Loại bỏ công đoạn trong Quy trình (Routing Bypass/Change)

Khi có yêu cầu điều chỉnh quy trình sản xuất (ví dụ: **bỏ công đoạn Ngoại quan V-27/VE-xx** và **thêm công đoạn Kiểm tra lại V-34**), IT cần thực hiện cập nhật đồng bộ các bảng CSDL sau để tránh chặn đứng hoạt động chốt sản lượng hoặc gộp box ở hiện trường:

#### 1. Định cấu hình Định tuyến gốc (Basic Routing Master - Phase 0)
*   **`STB_BasicRoutingInfo`**: Nếu cần tạo luồng định tuyến mới (ví dụ: `MainRoutingRubAging_New`) để tránh ảnh hưởng đến các model khác đang chạy luồng cũ.
*   **`STB_BasicRoutingDetail`**:
    1. `DELETE` dòng chứa công đoạn cũ (ví dụ: `V-27` / `V-27_BG`).
    2. `INSERT` công đoạn mới (ví dụ: `V-34` / `V-34_BG`) nếu cần.
    3. `UPDATE` lại chỉ số `RouteIndex` của các công đoạn đứng sau để đảm bảo chỉ mục tăng dần liên tục không có khoảng trống.
    4. Thiết lập cờ `IsInputRoute = 1` ở công đoạn đầu và `IsOutputRoute = 1` ở công đoạn cuối mới.
*   **`STB_MaterialMaster`**: Cập nhật gán `BasicRoutingCode` mới cho Model sản phẩm.

#### 2. Cấu hình Lệnh sản xuất PO đang chạy (Phase 3 WIP)
Để thay đổi có hiệu lực ngay lập tức đối với các PO đang sản xuất dở dang:
*   **`STB_ProductionOrderInfo`**: Cập nhật `BasicRoutingCode` mới cho các PO chưa cancel (`IsCancel = 0`) và chưa kết thúc (`IsFinish = 0`).
*   **`STB_ProductionOrderRouting`**:
    1. Xóa công đoạn cũ và chèn công đoạn mới tương thích với cấu hình `BasicRoutingDetail`.
    2. **QUAN TRỌNG:** Sắp xếp lại chỉ số `RouteIndex` tuần tự cho PO.
    3. **QUAN TRỌNG:** Phải đảm bảo công đoạn cuối cùng mới của PO có cờ `IsOutputRoute = 1` (ví dụ công đoạn `V-34`). Nếu thiếu cờ này, SP chốt sản lượng cuối (`usp_DoProcessProdGRMaterialByOne`) sẽ trả về sản lượng bằng 0, làm chặn đứng chức năng gộp box của công nhân tại trạm đóng gói B523.

#### 3. Cấu hình Đơn giá Công đoạn (Stage Prices - Phase 5 / Finance Integration)
*   **`STB_VVT_StagePrices`**: Cập nhật lại ánh xạ công đoạn để phục vụ báo cáo lương/giá thành (B682, B781, B789):
    1. Cập nhật cột công đoạn cũ (ví dụ `RouteV27`) thành `NULL`.
    2. Thiết lập đơn giá của công đoạn cũ (ví dụ `PriceV27`) về `0`.
    3. Cập nhật hoặc khai báo bổ sung đơn giá công đoạn mới (ví dụ `PriceV34`).

---

## 11. 📐 A418 - Số Lượng Đóng Gói Theo Size

**Luồng dữ liệu:** A410 (MBISizeD) -> A418 (PackQty) -> B523 (popup số lượng gộp box)

```sql
-- Kiểm tra đã có tiêu chuẩn đóng gói chưa
SELECT * FROM STB_PackingStandard WHERE ProdSize = 'MBISizeD_của_model'

-- Lỗi "Chưa có tiêu chuẩn đóng gói ở B523":
-- -> Vào A418 -> thêm ProdSize mới -> nhập PackQty -> Lưu
-- -> Cũng phải thêm tiêu chuẩn cân vào SP: usp_Vvt_TieuChuanPacking_Vvt
```

---

## 12. 👥 B260 - Thông Tin Nhân Viên Sản Xuất

> ⚠️ **WorkerGroupCode PHẢI là `VE-01`** - Nếu điền sai -> nhân viên không hiển thị trong dropdown tại B530, B540

| Thao tác | Bước thực hiện |
|----------|---------------|
| Thêm | (+) -> Điền thông tin -> WorkerGroupCode='VE-01' -> Lưu |
| Sửa | Click vào field -> Sửa -> Lưu |
| Xóa | Chọn dòng -> (-) -> Yes -> Lưu |

**Filter tìm kiếm:** Mã công ty `VVT`, Mã địa điểm `VVT_F1`, `VVT_F2`, `VVT_F3` (Hà Nam)

---

## 13. 🌐 Địa Chỉ Truy Cập Hệ Thống VINATECH

| Hệ thống | URL | Ghi chú |
|----------|-----|---------|
| MES chính | `http://mes.hycap.co.kr:9952` | Link tải + cấu hình MES |
| ESR SVN | `https://192.168.1.234/svn/Document/ESR` | Phần mềm ESR mới nhất |
| Location BG2 | `http://192.168.112.254:6005` | Hệ thống Locations nhà máy BG2 |
| ANDON BG1 | `http://192.168.112.254:8006/andon` | Màn ANDON nhà máy BG1 |
| Kho NVL BG1 | `http://192.168.112.254:7006` | Kho Nguyên Vật Liệu BG1 |
| Kho TP BG1 | `http://192.168.112.254:9006` | Kho Thành Phẩm BG1 |
| ANDON BN | `http://192.168.112.254:8000/andon` | Màn ANDON nhà máy Bắc Ninh |
| Kho NVL BN | `http://192.168.112.254:7000` | Kho Nguyên Vật Liệu Bắc Ninh |
| Kho TP BN | `http://192.168.112.254:9999` | Kho Thành Phẩm Bắc Ninh |
| Location SX | `http://192.168.1.234:9000/tv` | Màn hình Location tại SX |

---


## 14. 📊 Tóm Tắt Màn Hình MES Trọng Điểm (Quick Ref)

> 📌 Chi tiết toàn bộ 90+ Screen ID, vui lòng tra cứu tại tài liệu master: [screen_id_reference.md](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/knowledge/vinatech_screen_id_reference/artifacts/screen_id_reference.md).

Dưới đây là 10 màn hình cốt lõi nhất thường gặp sự cố hoặc cần debug:

| Màn hình | Tên Chức Năng | Phân Hệ | Bảng CSDL Chính |
|----------|---------------|---------|-----------------|
| **A230** | Đăng ký NVL Master | Master Data | `STB_MaterialMaster` |
| **A410** | Model Basic Info | Master Data | `STB_ModelBasicInfo` |
| **B310** | PO Kế Hoạch Tháng | Kế hoạch | `STB_ProductionOrderInfo` |
| **B450** | Kế hoạch SX Ngày & Tạo Lot | Kế hoạch | `STB_DayProdPlan` |
| **B530** | Nhập sản lượng công đoạn | Sản xuất | `STB_ProdRouteHist` |
| **B597** | Scan NVL & Kiểm tra thường xuyên | QC & SX | `STB_RawMaterialInputHist`, `STB_CommInspDocHistory` |
| **B523** | Gộp Box Cell & Chia Box | Đóng gói | `STB_DividePackaging`, `STB_MaterialLotInfo` |
| **C512** | Quản lý Lot OQC | QC | `STB_ModelBasicInfo` |
| **F330** | Nhập kho + In tem NVL | Kho (WMS) | `STB_MaterialDocInfo`, `STB_MaterialLotInfo` |
| **F721** | Tồn kho NVL thực tế | Kho (WMS) | `STB_MaterialLotInfo` |

---
*Cập nhật: 2026-06-12 | Cô đọng tài liệu & loại bỏ danh mục màn hình trùng lặp*


---

## 🔴 Cẩm nang khắc phục lỗi theo Screen ID (Gộp từ KB_SCREEN_BUG_REF)

## A230 / A410 — Master Data Model (Đăng ký vật tư & Thông tin cơ bản)

### Lỗi 1: Model mới thêm không hiện Vol/Farad, QC C512 không tìm thấy Lot, B597 không quét được
*   **Triệu chứng:** Model mới đã được khai báo trên màn hình **A230** nhưng khi sản xuất công nhân không thấy hiện thông số Vol/Farad, QC không tìm thấy Lot hàng ở màn hình OQC **C512**, hoặc trạm quét NVL **B597** báo lỗi sai chủng loại.
*   **Nguyên nhân gốc:** Mã sản phẩm mới chỉ được tạo ở bảng danh mục chung `STB_MaterialMaster` nhưng chưa được khai báo các thông số cơ bản (Vol, Farad, kích thước...) trong bảng thuộc tính chi tiết `STB_ModelBasicInfo` (Màn hình **A410**).
*   **Cách khắc phục:**
    Khai báo bổ sung thuộc tính model bằng cách chạy script chèn dữ liệu trực tiếp:
    ```sql
    INSERT INTO STB_ModelBasicInfo (ModelCode, ModelName, MaterialTypeCode, ProductGroupCode, MBISizeH, MBISizeW, CreateDateTime, MBIExtText04, MBIExtText05)
    VALUES ('MÃ_MODEL_MỚI', 'TÊN_MODEL', 'MDL', 'HC-EDLC', 40, 18, GETDATE(), 'Vol_Ví_Dụ_9R0', 'Farad_Ví_Dụ_166');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 1.3](KB_06_MASTER_DATA_TOOLS.md#13-sửa-mã-vật-tư-mới-chưa-khai-báo-volfarad-stb_modelbasicinfo).

---


## A310 — BOM Registration (Đăng ký cấu trúc BOM sản phẩm)

### Lỗi 1: Trạm quét NVL B597 báo lỗi đỏ "Mã nguyên vật liệu không khớp với BOM"
*   **Triệu chứng:** Khi OP quét mã vạch NVL tại chuyền ở trạm **B597**, hệ thống báo lỗi đỏ chặn không cho lưu vì NVL không nằm trong BOM.
*   **Nguyên nhân gốc:** Cấu trúc định mức vật tư (BOM) của sản phẩm/model chưa được đăng ký hoặc đồng bộ thiếu trong các bảng `STB_BomHeader` và `STB_BomDetail` tại màn hình **A310**.
*   **Cách khắc phục:** Vào màn hình **A310**, kiểm tra cấu hình BOM của Model, gán bổ sung mã NVL bị thiếu hoặc yêu cầu bộ phận quản lý đồng bộ lại BOM từ Groupware.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md § 4](KB_25_VINAENESSOL_HUNG_YEN.md#4-màn-hình-a310-thông-tin-bom).

---


## Z530 / A460 — Label Layout & Mapping (Thiết kế mẫu in và mapping tem)

### Lỗi 1: Bấm nút in tem nhãn nhưng máy in không chạy hoặc in ra tem trống/không đúng mẫu khách hàng
*   **Triệu chứng:** In tem Inner/Outer/PAC/Digi-Key không hoạt động hoặc tem in bị thiếu thông số Voltage/Farad/Serial.
*   **Nguyên nhân gốc:** Layout tem chưa được phê duyệt ở **Z530** (cờ `IsApproval = 0` trong `STB_LabelInfo`) hoặc chưa map mã Model với mẫu tem tương ứng ở **A460** (`STB_ModelLabelInfo`).
*   **Cách khắc phục:**
    1. Check trạng thái phê duyệt của layout tem:
       ```sql
       SELECT FormatName, IsApproval FROM SmartFramework.dbo.STB_LabelInfo WHERE FormatName = 'TÊN_LAYOUT_TEM';
       ```
    2. Check mapping mã vật tư:
       ```sql
       SELECT ModelCode, FormatName FROM STB_ModelLabelInfo WHERE ModelCode = 'MÃ_MODEL';
       ```
    3. Thực hiện map lại hoặc Approve layout tem trên giao diện UI cấu hình tem.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.16](KB_04_DONG_GOI_IN_TEM.md#616-màn-hình--cấu-hình-thiết-kế-tem-z530a460).

---


## Z410 / Z220 / Z330 — User Accounts & Role Permissions (Quản lý tài khoản & phân quyền người dùng)

### Lỗi 1: User báo lỗi tài khoản bị khóa không đăng nhập được hệ thống MES
*   **Triệu chứng:** Người dùng đăng nhập hệ thống báo lỗi tài khoản bị khóa hoặc thông báo không thể truy cập.
*   **Nguyên nhân gốc:** Cờ kích hoạt hoạt động của tài khoản bị tắt (`AllowFlag = 0`) trong bảng quản lý người dùng `STB_UserInfo` (Màn hình cấu hình **Z410**).
*   **Cách khắc phục:** Vào màn hình **Z410**, tìm tài khoản tương ứng, tích chọn cờ kích hoạt hoạt động và nhấn Lưu. Hoặc chạy SQL cập nhật trực tiếp:
    ```sql
    UPDATE STB_UserInfo SET AllowFlag = 1 WHERE UserID = 'MÃ_USER';
    ```

### Lỗi 2: Người dùng báo không nhìn thấy hoặc bị chặn không vào được màn hình nghiệp vụ
*   **Triệu chứng:** Người dùng đăng nhập thành công vào MES nhưng không thấy màn hình chức năng trên menu, hoặc bị văng cảnh báo không có quyền truy cập.
*   **Nguyên nhân gốc:** Menu/Màn hình đó chưa được phân quyền cho Nhóm Role của User tại **Z220** (Role Screen Mapping) hoặc chưa được kích hoạt hiển thị tại màn hình cấu hình hệ thống **Z330** (Screen Config).
*   **Cách khắc phục:**
    1. Truy cập **Z220**, kiểm tra và gán quyền truy cập Screen ID cho Nhóm Role của người dùng.
    2. Truy cập **Z330**, kiểm tra xem Screen ID đã được publish hoạt động trên Production chưa.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.1 và § 1.4](KB_01_UI_PHAN_QUYEN.md#11-lỗi-không-đăng-nhập-được-mes-allowflag).

---


## A210 — Material Master Registration (Đăng ký mã vật tư mới)

> 🔗 **Xem thêm:** Mục [F130 / F140 / A210](#f130--f140--a210--supplier-mapping--material-sync) phía trên đã có chi tiết luồng tích hợp NCC & đồng bộ vật tư.

### Lỗi 1: Mã vật tư mới đăng ký trên A210 nhưng không hiển thị khi nhập kho F330
*   **Triệu chứng:** Thủ kho tạo phiếu nhập kho mới, nhập mã vật tư mà không tìm thấy trong popup chọn MaterialCode.
*   **Nguyên nhân gốc:** Mã vật tư được tạo trong `STB_MaterialMaster` nhưng chưa được mapping nhà cung cấp trong `STB_MaterialVendorMapping` (F130/F140) và chưa khai báo thuộc tính kho `STB_MaterialStockAttributeInfo` (F110).
*   **Cách khắc phục:** Chạy checklist 3 bước: (1) Đăng ký A210, (2) Map NCC tại F130/F140, (3) Bật cờ F110.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_07_GROUPWARE_INTEGRATION.md § 6](KB_07_GROUPWARE_INTEGRATION.md) và [KB_06_MASTER_DATA_TOOLS.md § 1.3](KB_06_MASTER_DATA_TOOLS.md).

---


## A320 — Route Configuration (Cấu hình Route sản xuất)

### Lỗi 1: Thêm Route mới trong A320 nhưng không hiển thị tại B530 khi chốt sản lượng
*   **Triệu chứng:** OP không thấy công đoạn mới trong danh sách chọn Route để chốt sản lượng.
*   **Nguyên nhân gốc:** Route mới chỉ được khai báo ở bảng `STB_RouteInfo` nhưng chưa được gán vào Production Order Routing (`STB_ProductionOrderRouting`) của PO hiện tại.
*   **Cách khắc phục:** Vào A320 kiểm tra Route đã active (`IsUsed=1`), sau đó gán Route mới vào PO tại B310.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_10_KIEN_TRUC_VA_DATAFLOW.md § 2.1](KB_10_KIEN_TRUC_VA_DATAFLOW.md) và [KB_06_MASTER_DATA_TOOLS.md § 10](KB_06_MASTER_DATA_TOOLS.md).

---


## A410 — Model Basic Info (Thông tin cơ bản Model)

> 🔗 **Xem thêm:** Mục [A230 / A410](#a230--a410--master-data-model) phía trên đã có chi tiết lỗi thiếu Vol/Farad khi thêm model mới.

### Lỗi 1: Model mới không hiện Vol/Farad, C512 không tìm Lot, B597 lỗi sai chủng loại
*   **Triệu chứng:** Các thông số Vol/Farad trống, QC không tìm thấy Lot ở C512, B597 chặn quét NVL.
*   **Nguyên nhân gốc:** Chưa khai báo `STB_ModelBasicInfo` cho model mới.
*   **Cách khắc phục:**
    ```sql
    INSERT INTO STB_ModelBasicInfo (ModelCode, ModelName, MaterialTypeCode, ProductGroupCode, MBISizeH, MBISizeW, CreateDateTime, MBIExtText04, MBIExtText05)
    VALUES ('MÃ_MODEL', 'TÊN', 'MDL', 'HC-EDLC', 40, 18, GETDATE(), 'Vol', 'Farad');
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 1.3](KB_06_MASTER_DATA_TOOLS.md).

### Lỗi 2: Thiếu cấu hình OqcType/InspectionType dẫn đến lỗi QC OQC
*   **Triệu chứng:** Khi tạo hồ sơ OQC tại C512, hệ thống không biết loại kiểm tra nào áp dụng.
*   **Nguyên nhân gốc:** Cột `OqcType` và `InspectionType` trong `STB_ModelBasicInfo` bị NULL.
*   **Cách khắc phục:** Cập nhật giá trị OqcType và InspectionType cho model tại A410.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_05_QC_ELECTRODE.md § 7.2](KB_05_QC_ELECTRODE.md).

---


## A418 — Packing Standard by Size (Tiêu chuẩn đóng gói theo kích thước)

> 🔗 **Xem thêm:** Mục [B418](#b418--packing-quantity-standards) phía trên đã có chi tiết lỗi tiêu chuẩn đóng gói.

### Lỗi 1: B523 báo "Chưa có tiêu chuẩn đóng gói" do Size mới chưa khai báo A418
*   **Triệu chứng:** Gộp Box tại B523 bị chặn với thông báo lỗi.
*   **Nguyên nhân gốc:** `STB_PackingStandard` chưa có dòng cho `MBISizeD` của Model mới.
*   **Cách khắc phục:** Vào A418, đăng ký Size mới và thiết lập PackQty.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_06_MASTER_DATA_TOOLS.md § 11](KB_06_MASTER_DATA_TOOLS.md).

---


## A419 — Packing Standard Configuration (Cấu hình số lượng đóng gói)

### Lỗi 1: Thêm model mới nhưng không đóng gói được tại B523
*   **Triệu chứng:** B523 không cho gộp Box, báo lỗi chưa có tiêu chuẩn đóng gói.
*   **Nguyên nhân gốc:** Chưa khai báo quy cách đóng gói (VinylBagQty, InnerBoxQty, OutBoxQty) cho model mới trong `STB_PackingStandard` tại A419.
*   **Cách khắc phục:** Vào A419, chọn MaterialTypeCode = `FERT`, nhập Size và các thông số đóng gói, nhấn Lưu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.1](KB_04_DONG_GOI_IN_TEM.md) và [KB_14_TRACE_BUG_METHODOLOGY.md](KB_14_TRACE_BUG_METHODOLOGY.md).

---


## P111 — Attendance Time (Chấm công nhân viên)

### Lỗi 1: Dữ liệu chấm công không đồng bộ với thực tế
*   **Triệu chứng:** Bảng chấm công P111 hiển thị thiếu hoặc sai giờ vào/ra.
*   **Nguyên nhân gốc:** Thiết bị chấm công (máy quẹt thẻ) bị mất kết nối hoặc dữ liệu chưa được đồng bộ vào DB.
*   **Cách khắc phục:** Kiểm tra kết nối thiết bị chấm công, chạy đồng bộ lại dữ liệu.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_19_ALL_DATABASES_MAP.md](KB_19_ALL_DATABASES_MAP.md).

---
