# KB_06 — Master Data, SQL Tools & Manual Bypass

> **Màn hình liên quan:** A230, A310, A410, B250, B270, SQL Server, STB_ModelBasicInfo
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 📐 Master Data & Model

### 1.1 Thêm Model mới vào STB_ModelBasicInfo (A410)

> ⚠️ Nếu model có trong `STB_MaterialMaster` (A230) nhưng **không có** trong `STB_ModelBasicInfo` → C512 không tìm thấy, B597 không chọn được, Vol/Farad không hiện.

**Checklist khi thêm model mới:**
```
□ 1. A230 (STB_MaterialMaster) — Mã vật tư và tên
□ 2. A310 (STB_BomHeader/Detail) — BOM nguyên liệu — Anh Huy phụ trách
□ 3. A320 (STB_RouteInfo) — Công đoạn sản xuất
□ 4. A410 (STB_ModelBasicInfo) — Thông số kỹ thuật (Vol, Farad, OQC Type)
□ 5. A419 (STB_PackingStandard) — Tiêu chuẩn đóng gói
□ 6. A460 (STB_LabelInfo) — Mẫu tem in
□ 7. STB_VVT_StagePrices — Giá công đoạn (cho B682/B781)
□ 8. STB_AluCaseMapping_VVT — Mapping vỏ nhôm (nếu là Cell)
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

## 2. ⚙️ Cấu hình Vận hành (F110)

### 2.1 Lỗi NVL mới không gộp Box được

**Nguyên nhân:** Bảng `STB_MaterialStockAttributeInfo` chưa có dòng cho mã NVL mới, hoặc `IsLotUse = 0`.

**Debug & Fix:**
```sql
-- Kiểm tra
SELECT MaterialCode, IsUseBarcode, IsLotUse
FROM STB_MaterialStockAttributeInfo
WHERE MaterialCode = 'Mã_NVL'

-- Nếu không có dòng → Vào F110 nhập và Save
-- Nếu IsLotUse = 0 → Vào F110 tích và Save
-- Hoặc INSERT/UPDATE trực tiếp:
UPDATE STB_MaterialStockAttributeInfo
SET IsLotUse = 1, IsUseBarcode = 1
WHERE MaterialCode = 'Mã_NVL'
```

---

## 3. 💰 Fix Giá Công Đoạn (Stage Prices)

> Áp dụng khi màn hình B682, B781, B789 không hiện giá hoặc sai đơn giá.

> ⚠️ **Xác minh DB (2026-05-17):** Bảng `STB_VVT_StagePrices` thực tế có thêm nhiều cột: `RouteV29`→`RouteV34`, `RouteVE01`→`RouteVE10` (cho Hà Nam), `WorkCenterCode` (để phân biệt nhà máy). Hà Nam cần dùng `WorkCenterCode = 'VVT_F3'` và điền các route VE.

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

-- Với Module (B789/B791) → Sửa trong Function:
SELECT OBJECT_DEFINITION(OBJECT_ID('fn_VVT_StagePricesMODULE'))
-- Tìm dòng SELECT → Thêm UNION ALL với Model và giá mới
```

---

## 4. 🛢️ Lỗi Vỏ Nhôm (Aluminum Case Mapping)

→ Xem [KB_05 Mục 7.4](KB_05_QC_ELECTRODE.md#74-b597-báo-lỗi-không-tồn-tại-thiết-lập-vỏ-nhôm) để debug và fix.

---

## 5. 🔎 SQL Utilities — Truy vấn hỗ trợ

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

**Khi nào dùng:** Tình huống khẩn cấp cần in tem nhưng hệ thống chưa có Lot (VD: sự cố B450 không tạo được Lot nhưng hàng đã đóng gói xong).

**Quy trình 3 bước:**

**Bước 1 — Khởi tạo Lot thủ công:**
```sql
-- Tạo bản ghi trong SetInfo
INSERT INTO STB_SetInfo (Barcode, MaterialCode, PONo, DayPlanNo, ProdQty, InputLineCode, InputJobDate, CreateDateTime, CreateUserID)
VALUES ('VVXX123R000001', 'Mã_Model', 'PONo', 'DayPlanNo', 1000, 'LineCode', CONVERT(CHAR(8), GETDATE(), 112), GETDATE(), 'vinaadmin')
```

**Bước 2 — QC Pass:**
```sql
UPDATE STB_SetInfo
SET LotDecisionResult = 'PASS', IsDefect = 0
WHERE Barcode = 'VVXX123R000001'
```

**Bước 3 — Link Packing:**
```sql
INSERT INTO STB_MaterialLotInfo (LotID, LotNo, MaterialCode, InitialQty, CurrentQty, CreateDateTime, CreateUserID)
VALUES ('VVXX123R000001', 'VVXX123R000001', 'Mã_Model', 1000, 1000, GETDATE(), 'vinaadmin')
```

> ⚠️ Chỉ làm khi có sự phê duyệt của quản lý. Ghi lại tất cả thao tác này để audit sau.

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

-- Bước 4: Thêm mapping Route (B270) — link đủ V22→V28
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

> ⚠️ **LUÔN SELECT TRƯỚC — IUD SAU**

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
