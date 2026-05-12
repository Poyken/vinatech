# KB_05 — Phương pháp Truy vết Bug & Dữ liệu trong Vinatech MES
> Tác giả: Antigravity AI | Cập nhật: 2026-05-07

**Gửi yêu cầu trace:** dùng form [`BUG_REPORT_TEMPLATE.md`](../BUG_REPORT_TEMPLATE.md) ở thư mục gốc `database` (đủ field = ít vòng hỏi lại).

---

## 1. NGUYÊN TẮC CỐT LÕI

Khi nhận bất kỳ yêu cầu nào, tôi luôn tuân theo nguyên tắc:

> **"Không đoán mò — Chỉ tin vào dữ liệu thực tế trong DB"**

Mọi câu trả lời đều phải được **Verify (xác minh)** bằng cách SELECT trực tiếp vào database trước khi đưa ra kết luận.

---

## 2. QUY TRÌNH TRACE 5 BƯỚC

### BƯỚC 1 — Xác định bề mặt vấn đề (Surface)
**Câu hỏi cần trả lời:**
- User báo lỗi ở màn hình nào? (HN523, B450, B523...)
- Thao tác nào gây ra lỗi? (Quét mã, Gộp box, In tem...)
- Thông báo lỗi cụ thể là gì?

**Ví dụ thực tế:**
> "SP260507-002 không gộp được ở màn HN523"
→ Bề mặt: Màn HN523, thao tác Gộp box, mã Lot SP260507-002

---

### BƯỚC 2 — Tra cứu điểm vào (Entry Point)
**Cách làm:** Tìm Store Procedure được gọi khi thực hiện thao tác đó.

```sql
-- Tìm màn hình theo TCode
SELECT Name, Caption, TCode FROM SmartFramework.dbo.STB_ScreenInfo 
WHERE TCode = 'HN523'

-- Tìm action button trên màn hình
SELECT ObjectName, Caption FROM SmartFramework.dbo.STB_ScreenObjects 
WHERE ScreenName = 'Vietnam_Donggoi_Hnam' AND ObjectType = 'Action'
```

**Ví dụ thực tế:**
> Nút "Gộp box tùy chỉnh" → ObjectName = `MergeBoxCustom`
→ SP được gọi: `usp_Vietnam_DoProcessProdPacking_VVT_F3`

---

### BƯỚC 3 — Kiểm tra trạng thái dữ liệu (Data State Check)
**Nguyên tắc:** Kiểm tra trạng thái của mã Lot/Barcode từ nhiều bảng.

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

**Kết quả phân tích:**

| Giá trị | Ý nghĩa | Hành động |
|---------|---------|-----------|
| `LotDecisionResult = NULL` | Chưa QC | Yêu cầu QC đánh giá |
| `IsDefect = 1` | Có hàng lỗi | Xử lý hàng lỗi trước |
| `IsProdFinish = 0` | Chưa hoàn thành | Nhập đủ sản lượng |

---

### BƯỚC 4 — Kiểm tra Master Data (Cấu hình)
**Nguyên tắc:** Nhiều lỗi xuất phát từ việc thiếu cấu hình, không phải từ dữ liệu nghiệp vụ.

```sql
-- Kiểm tra F110: Vật tư có được phép dùng Lot không?
SELECT MaterialCode, IsUseBarcode, IsLotUse
FROM STB_MaterialStockAttributeInfo
WHERE MaterialCode = '10VHV1000MD12XVC01'

-- Nếu không có dòng nào → Chưa cấu hình F110 → CHẶN NGAY
-- Nếu IsLotUse = 0 → Chưa bật → Vào F110 tích chọn và Save
```

**Ví dụ thực tế:**
> Mã `10VHV1000MD12XVC01` → Query trả về 0 dòng
→ Kết luận: Chưa cấu hình F110 → User vào F110 nhập mã và nhấn Save

---

### BƯỚC 5 — Đọc Log hệ thống (Root Cause)
**Nguyên tắc:** Log là bằng chứng khách quan nhất về những gì đã xảy ra.

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
- `ProcessResult = 'OK'` → Thao tác thành công, dữ liệu đã vào DB
- `ProcessResult = 'NG'` → Thao tác thất bại, xem cột `Data` để biết tham số
- Data chứa: `PRODPACKING | VELINE-01 | VE10 | SP260507-002 | 0 | PKQN...`
  → Đây là gói tin gộp box với Qty = 0 (bất thường)

---

## 3. TRACE CHUỖI STORE PROCEDURE

Khi một thao tác gọi nhiều SP lồng nhau, tôi trace theo sơ đồ:

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

**Để lấy code SP:**
```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vietnam_DoProcessProdPacking_VVT_F3'))
```

---

## 4. AUDIT HOẠT ĐỘNG USER (IUD TRACKING)

Khi User hỏi "tôi đã làm gì hôm nay?", dùng script này:

```sql
DECLARE @User NVARCHAR(50) = 'vanduc';  -- Thay tên user
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

**Kết quả mẫu (User: vanduc, ngày 07/05/2026):**

| Table | Rows | LastUpdate |
|-------|------|-----------|
| STB_ProdRouteHist | 1 | 2026-05-07 10:37:44 |
| STB_MaterialLotInfo | 1 | 2026-05-07 11:57:18 |

---

## 5. TRACE TỪ TEM IN (LABEL)

Khi nhận một cái tem vật lý, tôi trace ngược lại DB như sau:

```
Tem in (Lot No: VE260507-007)
        ↓
STB_SetInfo WHERE Barcode = 'VE260507-007'
  → MaterialCode, ProdQty, InputLineCode, CreateUserID
        ↓
STB_ModelBasicInfo WHERE ModelCode = MaterialCode
  → MBIExtText04 (Voltage), MBIExtText05 (Farad)
        ↓
STB_MaterialMaster WHERE MaterialCode = MaterialCode
  → MaterialName (Tên sản phẩm đầy đủ)
        ↓
STB_DayPlanInfo WHERE DayPlanNo = SI.DayPlanNo
  → PONumber, LineCode, PlanQty, PlanDate
```

**Query tổng hợp từ 1 tem:**
```sql
SELECT 
    SI.Barcode, SI.MaterialCode, MM.MaterialName,
    SI.ProdQty, SI.InputLineCode, SI.DayPlanNo, SI.PONo,
    MBI.MBIExtText04 AS Voltage, MBI.MBIExtText05 AS Farad
FROM STB_SetInfo SI
JOIN STB_MaterialMaster MM   ON SI.MaterialCode = MM.MaterialCode
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

### Lỗi: Không gộp box được ở HN523
```sql
-- Check 3 điều kiện theo thứ tự
-- 1. F110 đã cấu hình chưa?
SELECT * FROM STB_MaterialStockAttributeInfo WHERE MaterialCode = 'MÃ_VẬT_TƯ'
-- Nếu rỗng → Vào F110 Save

-- 2. QC đã Pass chưa?
SELECT LotDecisionResult, IsDefect FROM STB_SetInfo WHERE Barcode = 'MÃ_BARCODE'
-- Nếu NULL hoặc Fail → Yêu cầu QC đánh giá

-- 3. Đã gộp vào Box khác chưa?
SELECT PackingID, CurrentQty FROM STB_MaterialLotInfo WHERE LotNo = 'MÃ_LOT'
-- Nếu có PackingID → Đã gộp rồi
```

### Lỗi: Số lượng sai ở B789
```sql
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = 'MÃ_LOT'
-- Tìm id bị sai → UPDATE hoặc DELETE theo id cụ thể
```

### Lỗi: Không in được tem ở B450
```sql
-- Kiểm tra mẫu tem có tồn tại không
SELECT FormatName, IsApproval, ApplyDate 
FROM SmartFramework.dbo.STB_LabelInfo 
WHERE FormatName LIKE '%HN%' AND IsApproval = 1
```

---

## 8. NGUYÊN TẮC AN TOÀN KHI IUD

> ⚠️ **LUÔN SELECT TRƯỚC — IUD SAU**

Trước khi UPDATE/DELETE bất kỳ bảng nào, luôn:
1. SELECT ra đúng dòng cần sửa
2. Đếm số dòng bị ảnh hưởng (`COUNT(*)`)
3. Đặt điều kiện WHERE thật cụ thể (dùng ID/PrimaryKey)
4. Chạy trong Transaction nếu có thể

```sql
-- Mẫu an toàn:
BEGIN TRANSACTION
    UPDATE STB_MaterialLotInfo 
    SET CurrentQty = 20
    WHERE MaterialLotNo = '20260507000337'  -- Dùng PK, không dùng điều kiện mờ
    
    -- Kiểm tra trước khi commit
    SELECT * FROM STB_MaterialLotInfo WHERE MaterialLotNo = '20260507000337'
ROLLBACK  -- Đổi thành COMMIT khi chắc chắn
```
