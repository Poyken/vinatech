# KB_06 — Master Data, SQL Tools & Manual Bypass

> **Màn hình liên quan:** A410, SQL Server, STB_ModelBasicInfo, STB_MaterialMaster
> ← [Về INDEX](KB_INDEX.md)

---

## 9. 📐 Master Data & Model

### 9.1 Thêm Model mới vào STB_ModelBasicInfo

> ⚠️ Chú ý: Một số Model có trong `STB_MaterialMaster` nhưng **không có** trong `STB_ModelBasicInfo` → Phải thêm tay.

```sql
-- Kiểm tra xem model đã có trong MaterialMaster chưa
SELECT * FROM STB_MaterialMaster WHERE MaterialCode = 'RDMD00-358'

-- Thêm Model mới vào ModelBasicInfo
INSERT INTO STB_ModelBasicInfo (
    ModelCode, ModelName, MaterialTypeCode, ProductGroupCode,
    MBISizeH, MBISizeW, IsClosed, OqcType, OqcInspectionRuleType,
    InspectionType, InspectionLevel,
    MBIExtText01, MBIExtText02, MBIExtText03, MBIExtText04, MBIExtText05,
    CreateDateTime
)
VALUES (
    'EDVTMD-247',       -- ModelCode
    'HY-CAP WEC9R0335QG-LG', -- ModelName
    'MDL', 'HC-EDLC',  -- MaterialTypeCode, ProductGroupCode
    30, 10,             -- H, W (size)
    0,                  -- IsClosed
    'MANUAL', 'BY_MODEL', 'SAMPLE', 'SAMPLE',
    '9R0', '335', 'WEC', '9.0', '3.3',  -- Vol, Farad, Type, VolNum, FaradNum
    GETDATE()
)
```

---

### 9.2 Lỗi không hiển thị Vol, Farad khi tạo Lot/In tem

**Nguyên nhân:** Do Views `VW_ModelBasicInfo` không hiển thị được.

**Cần sửa:** `MaterialTypeCode` ở bảng `STB_MaterialMaster` hoặc `STB_ModelBasicInfo`.

---

### 9.3 Lỗi NVL mới không gộp Box được

**Xử lý:** Vào **F110** → Tick chọn option gộp box.

---

### 9.4 Chỉnh số LotNo, Vol, Farad khi tạo Lot / In tem

Xem và sửa trong bảng `STB_ModelBasicInfo`.

---

### 9.5 Sửa giá lên B781 (ví dụ thực tế)

```sql
INSERT INTO STB_VVT_StagePrices (
    model, RouteV22, PriceV22, RouteV23, PriceV23,
    RouteV24, PriceV24, RouteV25, PriceV25,
    RouteV26, PriceV26, RouteV27, PriceV27, RouteV28, PriceV28, CreateDate
)
VALUES (
    'ECVT27-399',
    'V-22', 0.0657356,
    'V-23', 0.0718827,
    'V-24', 0.0897135,
    'V-25', 0.0945566,
    'V-26', 0.0945566,
    'V-27', 0.1100989,
    'V-28', 0.1183676,
    GETDATE()
);
```

---

## 10. 🔎 Công cụ & Truy vấn Hỗ trợ

### 10.1 Lấy Part No từ tên Model

```sql
-- Lấy mã model (bỏ prefix HY-CAP)
SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    'HY-CAP VEC3R0606QG (1840)', 'HY-CAP ', ''), 'HY-CAP', ''),
    '-C', ''), '-M', ''), 'MSP', ''), '(CY)', '') AS model

-- Lấy PartNo (12 ký tự sau dấu cách đầu)
SELECT RTRIM(LTRIM(SUBSTRING('HY-CAP VEC3R0606QG (1840)',
    CHARINDEX(' ', 'HY-CAP VEC3R0606QG (1840)'), 12))) AS partno
```

---

### 10.2 Tra tên Model và Size (B597)

```sql
DECLARE @ModelSize VARCHAR(10) = '';
DECLARE @ModelName NVARCHAR(200) = '';

-- Lấy size
SELECT @ModelSize = RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2)
    + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
FROM STB_ModelBasicInfo WITH (NOLOCK)
WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WITH (NOLOCK) WHERE Barcode IN ('VVPR293R018602'))

-- Lấy tên model đã clean
SELECT @ModelName = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    ModelName, @ModelSize, ''), '(', ''), ')', ''), ' ', ''), 'HY-CAP ', ''), 'HY-CAP', ''), '-', '%')
FROM STB_ModelBasicInfo WITH (NOLOCK)
WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WITH (NOLOCK) WHERE Barcode IN ('VVPR293R018602'))

PRINT(@ModelName + ' ' + @ModelSize)
```

---

### 10.3 Tra cứu SP theo màn hình

```sql
-- Tìm SP của 1 màn hình cụ thể
SELECT ScreenName, ObjectName, ObjectType, Description
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName = '[Tên màn hình]'
-- SearchFunction = SP đọc dữ liệu
-- ExecuteFunction = SP khi bấm Save/Delete
```

---

### 10.4 Kiểm tra lịch sử toàn bộ 1 Barcode (Golden Query)

```sql
SELECT
    PRH.ControlNo AS [Mã vạch SP],
    PRH.PONo AS [Lệnh SX],
    RI.RouteName AS [Công đoạn],
    PRH.CreateDateTime AS [Giờ quét],
    DP.PackingID AS [Mã Thùng],
    DP.ParentPackingID AS [Mã BigBox]
FROM STB_ProdRouteHist PRH WITH(NOLOCK)
LEFT JOIN STB_RouteInfo RI WITH(NOLOCK) ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_DividePackaging DP WITH(NOLOCK) ON PRH.ControlNo = DP.LotNo
WHERE PRH.ControlNo = '[Barcode cần tra]'
ORDER BY PRH.CreateDateTime ASC
```

---

## 11. 🆘 Xử lý Lot không tồn tại trên hệ thống (Manual Lot Bypass)

**Tình huống:** Lot hàng (VD: `VVQK273R025601`) không có trên hệ thống MES (không tạo được từ B597), nhưng thực tế hàng đã sản xuất xong và cần in tem/gộp Box gấp để xuất hàng.

### Giai đoạn 1: Khởi tạo Lot & Cấu hình Hạng mục kiểm tra (Bypass B597)
**Vấn đề:** Màn hình B597 báo lỗi "Lot không tồn tại" hoặc không hiện các hạng mục để kiểm tra (ngoại quan, kích thước...).

**1. Đăng ký hạng mục kiểm tra:**
*   **Script:**
    ```sql
    INSERT INTO STB_CommInspItem (CommInspItemCode, CommInspItemName, CommInspTypeCode, MaterialCode, ...)
    SELECT CommInspItemCode, CommInspItemName, 'ROUTE_TEST2_BG', 'Mã_Sản_Phẩm_Mới', ...
    FROM STB_CommInspItem WHERE MaterialCode = 'Mã_Sản_Phẩm_Mẫu'
    ```
*   **Lý do:** Hệ thống MES chỉ cho phép in tem/kiểm tra nếu Model đó đã được định nghĩa các hạng mục kiểm tra (Inspection Items). Nếu thiếu, màn hình B597 sẽ bị trắng hoặc báo lỗi.

**2. Khởi tạo bản ghi Lot Master:**
*   **Script:**
    ```sql
    INSERT INTO STB_SetInfo (ControlNo, PONo, DayPlanNo, MaterialCode, Barcode, ProdQty, ...)
    VALUES ('20260505000501', 'PO_Hợp_Lệ', 'DayPlan_Hợp_Lệ', 'Mã_NVL', 'Barcode_Cần_Tạo', 800, ...)
    ```
*   **Lý do:** Đây là bảng "gốc" quản lý mọi mã vạch sản phẩm. Nếu không có bản ghi ở đây, tất cả các màn hình sản xuất (B523, B597...) sẽ báo lỗi "Mã không tồn tại".

---

### Giai đoạn 2: Cấp quyền Chất lượng (QC) & Sản xuất (Bypass B523)
**Vấn đề:** Khi nhấn "Gộp box" ở màn B523, hệ thống báo lỗi *"Ngoại quan (Appearance) công đoạn thực chưa nhập"*.

**1. Tạo phiếu kết quả QC (Pass):**
*   **Script:**
    ```sql
    -- Tạo Header cho phiếu kiểm tra
    INSERT INTO STB_CommInspDocHistory (CommInspDocNo, CommInspTypeCode, ProdNo, IsFinished, ...)
    VALUES ('INS_RANDOM_ID', 'ROUTE_QUALITY2_BG', 'ControlNo_Của_Lot', 1, ...);

    -- Cập nhật kết quả Pass vào bảng Master
    UPDATE STB_SetInfo SET LotDecisionResult = 'Pass' WHERE Barcode = 'Barcode_Cần_Xử_Lý';
    ```
*   **Lý do:** Màn hình B523 có cơ chế bảo mật: chỉ cho phép đóng gói những Lot đã được QC xác nhận là **PASS**. Lệnh này giúp "đánh lừa" hệ thống rằng QC đã kiểm tra và đồng ý cho đi tiếp.

**2. Tạo lịch sử sản xuất công đoạn (Production History):**
*   **Script:**
    ```sql
    INSERT INTO STB_ProdRouteHist (ProdRouteHistNo, ControlNo, RouteCode, ProdQty, LineCode, ...)
    VALUES ('PR_RANDOM_ID', 'ControlNo_Của_Lot', 'V-27_BG', 800, 'Mã_Line', ...);
    ```
*   **Lý do:** Hệ thống yêu cầu kiểm tra "Thực tế sản xuất". Nó sẽ nhìn vào bảng `STB_ProdRouteHist` xem công đoạn trước đó (Ngoại quan - Route `V-27_BG`) đã báo cáo sản lượng chưa. Nếu sản lượng = 0, nó sẽ chặn không cho Gộp box.

---

### Giai đoạn 3: Liên kết dữ liệu In ấn & Sinh mã Thùng (Packing ID)
**Vấn đề:** Gộp box xong nhưng lưới bên dưới trống trơn hoặc nhấn "In tem" báo lỗi thiếu tham số `@pPackingID`.

**1. Liên kết vào bảng Quản lý In ấn:**
*   **Script:**
    ```sql
    INSERT INTO STB_MaterialLotInfo (MaterialLotNo, LotID, MaterialCode, LotNo, InitialQty, CurrentQty, ...)
    VALUES ('ControlNo_Lot', 'LotID_Tự_Sinh', 'Mã_NVL', 'Barcode_Lot', 800, 800, ...);
    ```
*   **Lý do:** Màn hình B523 không lấy dữ liệu trực tiếp từ bảng sản xuất để in tem, mà lấy từ bảng `STB_MaterialLotInfo`. Nếu thiếu bản ghi này, lưới dữ liệu bên dưới sẽ bị trống, dẫn đến không có gì để chọn in.

**2. Gán mã thùng (PackingID) chính thức:**
*   **Script:**
    ```sql
    UPDATE STB_MaterialLotInfo SET PackingID = 'PK_NĂM_THÁNG_NGÀY_SERIAL' WHERE LotNo = 'Barcode_Lot';
    ```
*   **Lý do:** Lỗi `@pPackingID` xảy ra khi hệ thống gọi Procedure in ấn nhưng tham số truyền vào bị RỖNG. Việc gán mã `PK...` giúp hoàn thiện dữ liệu cuối cùng để máy in tem có thể hiểu và xuất lệnh in.

---

## 11.5 🏷️ Fix Part No in tem bỏ hậu tố model (1625 Low ESR)

**Tình huống:** Model `1625 Low ESR` trên hệ thống có tên `HY-CAP WEC3R0256QG-D(1625)` nhưng khi in tem đóng gói tại B523 lại hiện Part No là `WEC3R0256QG` (bỏ mất đuôi `-D`).

**Nguyên nhân:** SP `usp_GetBoxIDForLotNo_VNT` dùng `SUBSTRING` cắt cứng 12 ký tự → đủ chỗ cho `WEC3R0256QG` nhưng không còn chỗ cho `-D`. Danh sách `CASE WHEN` nối thêm đuôi cũng chưa có case `-D`.

**Giải pháp nhanh (Override Part No):**
```sql
-- Ghi đè Part No in tem — hệ thống sẽ ưu tiên lấy MMExtText05 thay vì tự tính
UPDATE STB_MaterialMaster
SET MMExtText05 = 'WEC3R0256QG'
WHERE MaterialCode = 'ECVT30-379';
-- Xác nhận
SELECT MaterialCode, MaterialName, MMExtText05 FROM STB_MaterialMaster WHERE MaterialCode = 'ECVT30-379';
```

> **Áp dụng cho các model khác:** Cột `MMExtText05` trong `STB_MaterialMaster` là cơ chế override Part No cho tất cả model. Khi cần in Part No khác với tên hệ thống → điền vào đây.
