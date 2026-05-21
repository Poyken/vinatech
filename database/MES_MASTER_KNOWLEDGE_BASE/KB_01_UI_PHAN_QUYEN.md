# KB_01 — UI / Đăng nhập / Phân quyền / Stage Prices

> **Màn hình liên quan:** Login, A460, A419, B260, Z410, Z220, Z330, B682, B781, B789, B791
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🖥️ UI & Đăng nhập

### 1.1 Lỗi không đăng nhập được vào MES

**Triệu chứng:** Màn hình login bị lỗi, không vào được hệ thống NAIS.

**Debug theo thứ tự:**
1. **Chạy Update:** Chạy file Update trong folder cài đặt → vào lại NAIS
2. **Xóa cache hoàn toàn:** Xóa **tất cả** thư mục trong `C:\AwooSystem` → cài lại:
   - Link cài: `http://mes.hycap.co.kr:9952/`
   - Setting: `Alias: nais` | `Url: http://mes.hycap.co.kr:9952`
3. **Kiểm tra tài khoản DB:**
```sql
SELECT UserID, UserName, AllowFlag FROM SmartFramework.dbo.STB_UserInfo WHERE UserID = 'tên_user'
-- AllowFlag = 0 → tài khoản bị khóa → vào Z410 bật lại
-- ⚠️ Cột là AllowFlag, KHÔNG PHẢI IsUse
```

---

### 1.2 Lỗi không in được tem ở màn B450

**Triệu chứng:** Tạo Lot thành công nhưng nhấn "In Tem" không ra, không có lỗi.

**Debug:**
1. Vào **A460** → Kiểm tra cột **"Format Type"**:
   - Sản xuất (B450/B540): `AssembleLabel` (dòng 2)
   - Kho (F330): `PartLabel`
2. Kiểm tra mẫu tem bằng SQL:
```sql
SELECT * FROM SmartFramework.dbo.STB_LabelInfo
WHERE FormatName LIKE '%[Tên Model]%' AND IsApproval = 1
```
3. Nếu chưa có format → liên hệ anh Huy thêm cấu hình tem

---

### 1.3 Lỗi popup trống trên B270

**Triệu chứng:** Popup chọn Route/Machine hiện ra rỗng.

**Nguyên nhân:** Máy chưa được mapping vào Line/Route.

```sql
-- Kiểm tra mapping
SELECT * FROM STB_ProductMachine WHERE MachineCode = 'Mã_Máy'
-- Nếu trống → vào B230 thêm mapping (xem KB_06 Mục 7)
```

---

## 2. 👤 Quản lý User & Phân quyền

| Tác vụ | Màn hình | Ghi chú |
|--------|----------|---------|
| Thêm công nhân | **B260** | Gán vào Line |
| Tạo tài khoản MES mới | **Z410** | UserID + password |
| Phân quyền (Role) | **Z220** | Gán quyền theo User |
| Thêm màn hình cho User | **Z330** | Khi user báo "không thấy màn hình X" |

**SQL kiểm tra quyền user (SmartFramework):**
```sql
-- Xem user đang có quyền vào màn hình nào
SELECT UserID, ScreenID, FuncID, Allow
FROM SmartFramework.dbo.STB_UserPermission
WHERE UserID = 'tên_user' AND Allow = 1

-- Kiểm tra thông tin user (AllowFlag thay cho IsUse)
SELECT UserID, UserName, AllowFlag
FROM SmartFramework.dbo.STB_UserInfo
WHERE UserID = 'tên_user'
-- AllowFlag = 0 → tài khoản bị khóa
```

> ⚠️ **Xác minh DB (2026-05-17):** Không có bảng `STB_UserRole` hay `STB_RoleScreenMapping` trong SmartFramework. Phân quyền dùng bảng `STB_UserPermission` (UserID, ScreenID, FuncID, Allow).

---

## 3. 💰 Giá & Stage Prices

### 3.1 Add giá lên màn B682 & B781 (Cell Line)

**Triệu chứng:** Cột "Giá/Chi phí" bị trống dù có sản lượng.

```sql
-- Kiểm tra xem model đã có giá chưa
SELECT * FROM STB_VVT_StagePrices WHERE model = 'Mã_Model'

-- Nếu trống → Thêm giá
INSERT INTO STB_VVT_StagePrices 
    (model, RouteV22, PriceV22, RouteV23, PriceV23, RouteV24, PriceV24,
     RouteV25, PriceV25, RouteV26, PriceV26, RouteV27, PriceV27, RouteV28, PriceV28, CreateDate)
VALUES 
    ('MÃ_MODEL', 'V-22', 0.065, 'V-23', 0.071, 'V-24', 0.089, 'V-25', 0.094, 
     'V-26', 0.094, 'V-27', 0.110, 'V-28', 0.118, GETDATE());
```
> Điều chỉnh giá trị theo đơn giá từ kế toán.

---

### 3.2 Add giá Module (B789 & B791)

Sửa trực tiếp Function `fn_VVT_StagePricesMODULE`:
```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('fn_VVT_StagePricesMODULE'))
-- Tìm dòng SELECT → Thêm UNION ALL với Model mới và giá mới
```

---

### 3.3 Sửa số lượng Packing ở B789

```sql
-- Bước 1: Tìm bản ghi sai
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = 'Mã_Barcode'

-- Bước 2: Sửa số lượng (dùng id cụ thể)
UPDATE STB_SavePackingTime_VVT SET PackQty = [Số_Đúng]
WHERE LotNo = 'Mã_Barcode' AND id = [ID_Cụ_Thể]

-- Bước 3: Xóa bản ghi thừa
DELETE FROM STB_SavePackingTime_VVT WHERE id = [ID_Thừa]
```

---

### 3.4 Tắt in VV → VJ cho model

```sql
UPDATE STB_Vietnam_PackingPrinting SET PrintVJ = 0
WHERE MaterialCode = '[Mã NVL]'
```

---

### 3.5 Lỗi Packing Qty âm ở B523

**SP liên quan:** `usp_savePackingLabelQty_VVT`

```sql
-- Kiểm tra trạng thái Lot
SELECT * FROM STB_MaterialLotInfo WHERE LotNo = 'Mã_Lot'
SELECT * FROM STB_SavePackingTime_VVT WHERE LotNo = 'Mã_Lot'
```

---

## 4. 🔧 Debug Nâng Cao

### 4.1 Tìm màn hình theo TCode

```sql
-- ScreenInfo uses Name (acts as ScreenID) and Caption (acts as ScreenName)
SELECT Name AS ScreenID, Caption AS ScreenName, TCode 
FROM SmartFramework.dbo.STB_ScreenInfo
WHERE Name LIKE '%B597%' OR TCode LIKE '%597%'
```

### 4.2 Tìm Action Button trên màn hình

```sql
-- Tìm action button trên màn hình (STB_ScreenObjects không chứa cột ProcedureName)
SELECT ObjectName, Caption, ObjectType
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName LIKE '%[Tên màn hình]%' AND ObjectType = 'Action'
```

*Cập nhật: 2026-05-20*
