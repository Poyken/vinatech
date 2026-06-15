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
