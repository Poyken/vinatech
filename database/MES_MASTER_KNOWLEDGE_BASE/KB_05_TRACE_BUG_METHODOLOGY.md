# KB_TRACE — Phương pháp Truy vết Bug & Dữ liệu trong Vinatech MES
> Cập nhật: 2026-05-22

**Gửi yêu cầu trace:** dùng form [`BUG_REPORT_TEMPLATE.md`](../BUG_REPORT_TEMPLATE.md) ở thư mục gốc `database`.

---

## 1. NGUYÊN TẮC CỐT LÕI

> **"Không đoán mò — Chỉ tin vào dữ liệu thực tế trong DB"**

Mọi câu trả lời đều phải được **Verify** bằng cách SELECT trực tiếp vào database trước khi đưa ra kết luận.

---

## 2. QUY TRÌNH TRACE 5 BƯỚC

### BƯỚC 1 — Xác định bề mặt vấn đề (Surface)

- User báo lỗi ở màn hình nào? (HN523, B450, B523...)
- Thao tác nào gây ra lỗi? (Quét mã, Gộp box, In tem...)
- Thông báo lỗi cụ thể là gì?

**Ví dụ:** "SP260507-002 không gộp được ở màn HN523"
→ Màn HN523, thao tác Gộp box, mã Lot SP260507-002

---

### BƯỚC 2 — Tra cứu điểm vào (Entry Point)

```sql
-- Tìm màn hình theo TCode
SELECT Name, Caption, TCode FROM SmartFramework.dbo.STB_ScreenInfo
WHERE TCode = 'HN523'

-- Tìm action button trên màn hình
SELECT ObjectName, Caption FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName = 'Vietnam_Donggoi_Hnam' AND ObjectType = 'Action'

-- Xem nội dung SP
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_DoProcessProdPacking_VVT_F3'))
```

---

### BƯỚC 3 — Kiểm tra trạng thái dữ liệu (Data State Check)

```sql
-- TEMPLATE CHUẨN: Kiểm tra "sức khỏe" của 1 Barcode
SELECT
    Barcode,
    MaterialCode,
    ProdQty,
    LotDecisionResult,  -- NULL/Fail = chưa qua QC
    IsDefect,           -- 1 = đang có hàng lỗi
    DefectQty,
    IsProdFinish        -- 0 = chưa hoàn thành sx
FROM STB_SetInfo
WHERE Barcode = 'SP260507-002'
```

| Giá trị | Ý nghĩa | Hành động |
|---------|---------|-----------|
| `LotDecisionResult = NULL` | Chưa QC | Yêu cầu QC đánh giá |
| `IsDefect = 1` | Có hàng lỗi | Xử lý hàng lỗi trước |
| `IsProdFinish = 0` | Chưa hoàn thành | Nhập đủ sản lượng |

---

### BƯỚC 4 — Kiểm tra Master Data (Cấu hình)

```sql
-- Kiểm tra F110: Vật tư có được phép dùng Lot không?
SELECT MaterialCode, IsUseBarcode, IsLotUse
FROM STB_MaterialStockAttributeInfo
WHERE MaterialCode = '10VHV1000MD12XVC01'
-- 0 dòng → Chưa cấu hình F110 → User vào F110 nhập mã và nhấn Save
-- IsLotUse = 0 → Chưa bật → Vào F110 tích chọn và Save
```

---

### BƯỚC 5 — Đọc Log hệ thống (Root Cause)

```sql
-- Log 1: Gói tin từ UI gửi lên Server
SELECT ProcessDateTime, IPAddress, Data, ProcessResult
FROM STB_ProcessTerminalDataLog
WHERE CAST(ProcessDateTime AS DATE) = CAST(GETDATE() AS DATE)
  AND Data LIKE '%SP260507-002%'
ORDER BY ProcessDateTime DESC

-- Log 2: Biến số trong Store Procedure
SELECT ProcedureName, VariableName, VariableValue, CreateDateTime
FROM STB_ProcedureLog
WHERE CAST(CreateDateTime AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY CreateDateTime DESC
```

**Cách đọc log:**
- `ProcessResult = 'OK'` → Thao tác thành công
- `ProcessResult = 'NG'` → Thao tác thất bại, xem cột `Data` để biết tham số
- Data: `PRODPACKING | VELINE-01 | VE10 | SP260507-002 | 0 | PKQN...` → Qty = 0 (bất thường)

---

## 3. TRACE CHUỖI STORE PROCEDURE

```
[User nhấn nút trên UI]
        ↓
[STB_ProcessTerminalDataLog] ← Ghi log gói tin thô
        ↓
usp_Vietnam_DoProcessProdPacking_VVT_F3  ← Entry SP (F3/HN)
        ↓
usp_DoProcessProdPackingByOne_VNT        ← Xử lý từng Lot
        ↓
usp_DoProcessTerminalData                ← Router (PRODPACKING)
        ↓
usp_DoProcessProdRouteHistForBarcode
        ↓
usp_DoProcessProdRouteHist               ← Ghi vào STB_ProdRouteHist
        ↓
[STB_ProdRouteHist]  [STB_SetInfo]  [STB_MaterialLotInfo]
```

---

## 4. AUDIT HOẠT ĐỘNG USER (IUD TRACKING)

```sql
DECLARE @User NVARCHAR(50) = 'vanduc';
DECLARE @Date VARCHAR(10) = CONVERT(VARCHAR, GETDATE(), 120);
DECLARE @Sql NVARCHAR(MAX) = '';

SELECT @Sql = @Sql +
    'SELECT ''' + t.name + ''' AS [Table], COUNT(*) AS [Rows], MAX(CreateDateTime) AS [LastUpdate] ' +
    'FROM ' + QUOTENAME(t.name) + ' WHERE (' +
    STUFF((SELECT ' OR ' + QUOTENAME(c.name) + ' = ''' + @User + ''''
           FROM sys.columns c
           WHERE c.object_id = t.object_id
             AND c.name IN ('CreateUserID', 'ChangeUserID', 'EmpNo', 'EmpChange')
           FOR XML PATH('')), 1, 4, '') +
    ') AND (CAST(CreateDateTime AS DATE) = ''' + @Date + ''' ' +
    CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = t.object_id AND name = 'ChangeDateTime')
         THEN 'OR CAST(ChangeDateTime AS DATE) = ''' + @Date + '''' ELSE '' END +
    ') HAVING COUNT(*) > 0; '
FROM sys.tables t
WHERE EXISTS (SELECT 1 FROM sys.columns WHERE object_id = t.object_id AND name IN ('CreateUserID', 'ChangeUserID', 'EmpNo', 'EmpChange'))
  AND EXISTS (SELECT 1 FROM sys.columns WHERE object_id = t.object_id AND name = 'CreateDateTime')

EXEC sp_executesql @Sql
```

---

## 5. TRACE TỪ TEM IN (LABEL)

```sql
SELECT
    SI.Barcode, SI.MaterialCode, MM.MaterialName,
    SI.ProdQty, SI.InputLineCode, SI.DayPlanNo, SI.PONo,
    MBI.MBIExtText04 AS Voltage, MBI.MBIExtText05 AS Farad
FROM STB_SetInfo SI
JOIN STB_MaterialMaster MM ON SI.MaterialCode = MM.MaterialCode
LEFT JOIN STB_ModelBasicInfo MBI ON SI.MaterialCode = MBI.ModelCode
WHERE SI.Barcode = 'VE260507-007'
```

---

## 6. CÁC BẢNG QUAN TRỌNG CẦN NHỚ

| Bảng | Chức năng | Khi nào dùng |
|------|-----------|-------------|
| `STB_SetInfo` | Thông tin Barcode/Lot gốc | Kiểm tra trạng thái, QC, IsDefect |
| `STB_MaterialLotInfo` | Thông tin gộp Lot/PackingID | Kiểm tra Box đã gộp chưa |
| `STB_ProdRouteHist` | Lịch sử công đoạn sản xuất | Kiểm tra đã qua đủ công đoạn chưa |
| `STB_ProcessTerminalDataLog` | Log gói tin từ UI | Tìm nguyên nhân lỗi gốc rễ |
| `STB_ProcedureLog` | Log biến số trong SP | Debug logic bên trong SP |
| `STB_MaterialStockAttributeInfo` | Cấu hình F110 (IsLotUse...) | Khi không gộp/quét được |
| `STB_ModelBasicInfo` | Thông số kỹ thuật sản phẩm | Voltage, Farad, kích thước |
| `SmartFramework.STB_ScreenInfo` | Danh sách màn hình | Tìm TCode, tên màn hình |
| `SmartFramework.STB_ScreenObjects` | Danh sách nút bấm | Tìm SP được gọi khi bấm nút |
| `SmartFramework.STB_LabelInfo` | Cấu hình mẫu tem in | Khi in tem bị lỗi format |

---

## 7. CÁC LỖI THƯỜNG GẶP & CÁCH XỬ LÝ NHANH

### Không gộp box được ở HN523 / B523

```sql
-- 1. F110 đã cấu hình chưa?
SELECT * FROM STB_MaterialStockAttributeInfo WHERE MaterialCode = 'MÃ_VẬT_TƯ'
-- Rỗng → Vào F110 Save

-- 2. QC đã Pass chưa?
SELECT LotDecisionResult, IsDefect FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE'
-- NULL hoặc Fail → Yêu cầu QC đánh giá

-- 3. Đã gộp vào Box khác chưa?
SELECT PackingID, CurrentQty FROM STB_MaterialLotInfo WHERE LotNo = 'MÃ_LOT'
-- Có PackingID → Đã gộp rồi
```

### Số lượng sai ở B789

```sql
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = 'MÃ_LOT'
-- Tìm id bị sai → UPDATE hoặc DELETE theo id cụ thể
UPDATE STB_SavePackingTime_VVT SET PackQty = [Số_Đúng]
WHERE LotNo = 'MÃ_LOT' AND id = [ID_Cụ_Thể]
```

### Không in được tem ở B450

```sql
-- Kiểm tra mẫu tem có tồn tại không
SELECT FormatName, IsApproval, ApplyDate
FROM SmartFramework.dbo.STB_LabelInfo
WHERE FormatName LIKE '%HN%' AND IsApproval = 1
```

### Lỗi kế hoạch ngày chọn nhầm Line (B450) — Time Window technique

**Triệu chứng:** 2 Model khác nhau nhảy chung vào 1 Line trên báo cáo.

**Kỹ thuật Quét cửa sổ thời gian (Time Window):**
```sql
-- Tìm 1 mã DayPlanNo bị sai → lấy CreateUserID và CreateDateTime
-- Quét tất cả kế hoạch của User đó trong vòng 5-10 giây xung quanh
SELECT DayPlanNo, PlanDate, LineCode, MaterialCode, CreateDateTime
FROM STB_DayProdPlan
WHERE CreateUserID = 'ID_Người_Lập'
  AND CreateDateTime BETWEEN '2026-05-16 08:00:00' AND '2026-05-16 08:00:10'
ORDER BY DayPlanNo ASC
```

**Fix:**
- Chưa có sản lượng → Hủy kế hoạch sai tại B450 → Tạo lại đúng Line
- Đã có sản lượng → Chuyển Line bằng script (xem KB_03 §5.9)

---

## 8. NGUYÊN TẮC AN TOÀN KHI IUD

> ⚠️ **LUÔN SELECT TRƯỚC — IUD SAU**

```sql
BEGIN TRANSACTION
    -- 1. SELECT để xác nhận đúng dòng
    SELECT * FROM STB_MaterialLotInfo WHERE MaterialLotNo = '20260507000337'

    -- 2. UPDATE với PK cụ thể
    UPDATE STB_MaterialLotInfo
    SET CurrentQty = 20
    WHERE MaterialLotNo = '20260507000337'

    -- 3. SELECT lại để xác nhận kết quả
    SELECT * FROM STB_MaterialLotInfo WHERE MaterialLotNo = '20260507000337'

ROLLBACK  -- Đổi thành COMMIT khi chắc chắn đúng
```

**Quy tắc:**
1. SELECT ra đúng dòng cần sửa trước
2. Đếm số dòng bị ảnh hưởng (`COUNT(*)`)
3. Đặt điều kiện WHERE thật cụ thể (dùng ID/PrimaryKey)
4. Chạy trong Transaction

*Cập nhật: 2026-05-22*
