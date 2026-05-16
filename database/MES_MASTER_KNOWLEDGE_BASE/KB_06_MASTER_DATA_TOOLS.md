# KB_06 — Master Data, SQL Tools & Manual Bypass

> **Màn hình liên quan:** A410, SQL Server, STB_ModelBasicInfo, STB_MaterialMaster
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 📐 Master Data & Model

### 1.1 Thêm Model mới vào STB_ModelBasicInfo
> ⚠️ Chú ý: Một số Model có trong `STB_MaterialMaster` nhưng **không có** trong `STB_ModelBasicInfo` → Phải thêm tay để hiển thị Vol/Farad.

```sql
-- Thêm Model mới vào ModelBasicInfo
INSERT INTO STB_ModelBasicInfo (
    ModelCode, ModelName, MaterialTypeCode, ProductGroupCode,
    MBISizeH, MBISizeW, IsClosed, OqcType, OqcInspectionRuleType,
    InspectionType, InspectionLevel,
    MBIExtText01, MBIExtText02, MBIExtText03, MBIExtText04, MBIExtText05,
    CreateDateTime
)
VALUES (
    'EDVTMD-247', 'HY-CAP WEC9R0335QG-LG', 'MDL', 'HC-EDLC',
    30, 10, 0, 'MANUAL', 'BY_MODEL', 'SAMPLE', 'SAMPLE',
    '9R0', '335', 'WEC', '9.0', '3.3', GETDATE()
);
```

### 1.2 Lỗi không hiển thị Vol, Farad
**Nguyên nhân:** Views `VW_ModelBasicInfo` không tìm thấy mapping.
**Xử lý:** Kiểm tra `MaterialTypeCode` (phải là MDL/CEL) và Vol/Farad trong `STB_ModelBasicInfo`.

---

## 2. ⚙️ Cấu hình Vận hành (F110)

### 2.1 Lỗi NVL mới không gộp Box được
**Xử lý:** Vào **F110** → Tìm mã vật tư → Tick chọn `IsLotUse` và `IsUseBarcode`.

---

## 3. 💰 Fix Giá Công Đoạn (Stage Prices)
> Áp dụng khi màn hình B682, B781, B789 không hiện giá hoặc sai đơn giá.

```sql
-- 1. Với Sản xuất (B682/B781)
INSERT INTO STB_VVT_StagePrices (
    model, RouteV22, PriceV22, RouteV23, PriceV23, RouteV24, PriceV24,
    RouteV25, PriceV25, RouteV26, PriceV26, RouteV27, PriceV27, RouteV28, PriceV28, CreateDate
)
VALUES (
    'MÃ_MODEL', 'V-22', 0.065, 'V-23', 0.071, 'V-24', 0.089, 'V-25', 0.094, 
    'V-26', 0.094, 'V-27', 0.110, 'V-28', 0.118, GETDATE()
);

-- 2. Với Module (B789/B791)
-- Sửa trực tiếp trong Function: fn_VVT_StagePricesMODULE
SELECT 'MÃ_MODEL', 'GIÁ_1', 'GIÁ_2', 'GIÁ_3' UNION ALL ...
```

---

## 4. 🛢️ Lỗi thiết lập Vỏ Nhôm (Aluminum Case Mapping)
- **Triệu chứng:** B597 báo lỗi *"Không tồn tại thiết lập Vỏ Nhôm..."*.
- **Cách xử lý:** Thêm mapping vào bảng `STB_AluCaseMapping_VVT`.
```sql
-- Kiểm tra mapping hiện tại
SELECT * FROM STB_AluCaseMapping_VVT WHERE ModelCode = 'MÃ_MODEL'

-- Thêm mapping mới
INSERT INTO STB_AluCaseMapping_VVT (AluCaseCode, ModelCode, CreateUserID, CreateDateTime)
VALUES ('GBDYAC-004', 'ECVT30-367', 'Admin', GETDATE());
```

---

## 5. 🔎 Công cụ & Truy vấn Hỗ trợ (SQL Tools)

### 5.1 Golden Query: Kiểm tra lịch sử toàn bộ 1 Barcode
```sql
SELECT
    PRH.ControlNo AS [Mã vạch SP], PRH.PONo AS [Lệnh SX], RI.RouteName AS [Công đoạn],
    PRH.CreateDateTime AS [Giờ quét], DP.PackingID AS [Mã Thùng]
FROM STB_ProdRouteHist PRH WITH(NOLOCK)
LEFT JOIN STB_RouteInfo RI WITH(NOLOCK) ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_DividePackaging DP WITH(NOLOCK) ON PRH.ControlNo = DP.LotNo
WHERE PRH.ControlNo = '[Barcode]'
ORDER BY PRH.CreateDateTime ASC
```

### 5.2 Lấy Part No & Size từ tên Model
```sql
-- Lấy PartNo
SELECT RTRIM(LTRIM(SUBSTRING('HY-CAP VEC3R0606QG (1840)', CHARINDEX(' ', 'HY-CAP VEC3R0606QG (1840)'), 12))) AS partno

-- Lấy Size (Width + Height)
SELECT RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
FROM STB_ModelBasicInfo WHERE ModelCode = '...'
```

---

## 7. 🏗️ Thêm Cell/Line mới (B250, B270)
> Khi có yêu cầu thêm Cell mới (VD: VVBNTC-05), cần cập nhật 3 bảng Master để dữ liệu đồng bộ.

```sql
-- 1. STB_LineInfo (Master Line)
INSERT INTO STB_LineInfo (LineCode, CompanyCode, WorkCenterCode, LineName, LineDesc, LineType, IsUsed, CreateDateTime, CreateUserID) 
VALUES ('VVBNTC-05', 'VVT', 'VVT_F2', 'BN Manual (P20)', 'Thủ công Bắc Ninh', 'Medium', 1, GETDATE(), 'vinaadmin');

-- 2. STB_MachineMaster (B250 - Master Máy)
INSERT INTO STB_MachineMaster (MachineCode, CompanyCode, WorkCenterCode, MachineName, IsProdMachine, MachineTypeCode, IsUsed, CreateDateTime, CreateUserID) 
VALUES ('VVBNTC-05', 'VVT', 'VVT_F2', 'BN Manual (P20)', 1, 'M00001', 1, GETDATE(), 'vinaadmin');

-- 3. STB_ProductMachine (B270 - Mapping Route)
-- Cần link đủ các công đoạn V22 -> V28
INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode, CreateDateTime, CreateUserID)
SELECT 'VVBNTC-05', 'VVBNTC-05', r.RouteCode, GETDATE(), 'vinaadmin'
FROM (
    SELECT 'V-22_BG' AS RouteCode UNION ALL SELECT 'V-23_BG' UNION ALL SELECT 'V-24_BG' UNION ALL 
    SELECT 'V-25_BG' UNION ALL SELECT 'V-26_BG' UNION ALL SELECT 'V-27_BG' UNION ALL SELECT 'V-28_BG'
) r;
```
