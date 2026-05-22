# KB_01 — UI / Đăng nhập / Phân quyền / Stage Prices

> **Màn hình liên quan:** Login, A460, A419, B260, Z410, Z220, Z330, B682, B781, B789, B791, B786, B934, B935, FG02
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
-- Nếu trống → vào B230 thêm mapping
```

**Fix — Thêm mapping Route cho máy:**
```sql
BEGIN TRANSACTION;
-- Thêm mapping Route (B270) — link đủ V22→V28
INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode, CreateDateTime, CreateUserID)
SELECT 'MÃ_MÁY', 'MÃ_LINE', r.RouteCode, GETDATE(), 'vinaadmin'
FROM (
    SELECT 'V-22_BG' AS RouteCode UNION ALL SELECT 'V-23_BG' UNION ALL SELECT 'V-24_BG' UNION ALL
    SELECT 'V-25_BG' UNION ALL SELECT 'V-26_BG' UNION ALL SELECT 'V-27_BG' UNION ALL SELECT 'V-28_BG'
) r
WHERE NOT EXISTS (
    SELECT 1 FROM STB_ProductMachine WHERE MachineCode = 'MÃ_MÁY' AND RouteCode = r.RouteCode
);
COMMIT;
```

---

## 2. 👤 Quản lý User & Phân quyền

| Tác vụ | Màn hình | Ghi chú |
|--------|----------|---------|
| Thêm công nhân | **B260** | Gán vào Line, WorkerGroupCode='VE-01' |
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

**Thêm UserID vào whitelist đổi Line (B452):**
```sql
-- SP usp_Set_VVT_Info_get có danh sách UserID hardcode được phép đổi Line
-- Khi cần thêm user mới → sửa SP, tìm đoạn:
-- IF @pProcessUserID LIKE '%phuong%' OR @pProcessUserID = 'mrluan' OR ...
-- Thêm: OR @pProcessUserID = 'user_mới'
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Set_VVT_Info_get'))
```

---

## 3. 💰 Giá & Stage Prices

### 3.1 Add giá lên màn B682 & B781 (Cell Line)

**Triệu chứng:** Cột "Giá/Chi phí" bị trống dù có sản lượng.

> ⚠️ **Xác minh DB (2026-05-17):** Bảng `STB_VVT_StagePrices` có thêm nhiều cột: `RouteV29`→`RouteV34`, `RouteVE01`→`RouteVE10` (cho Hà Nam), `WorkCenterCode` (để phân biệt nhà máy).

```sql
-- Kiểm tra xem model đã có giá chưa
SELECT * FROM STB_VVT_StagePrices WHERE model = 'Mã_Model'

-- Thêm giá cho Cell Line (B682/B781) — Bắc Ninh và Bắc Giang (V routes)
INSERT INTO STB_VVT_StagePrices (
    model, RouteV22, PriceV22, RouteV23, PriceV23, RouteV24, PriceV24,
    RouteV25, PriceV25, RouteV26, PriceV26, RouteV27, PriceV27, RouteV28, PriceV28,
    WorkCenterCode, CreateDate)
VALUES (
    'MÃ_MODEL', 'V-22', 0.065, 'V-23', 0.071, 'V-24', 0.089, 'V-25', 0.094,
    'V-26', 0.094, 'V-27', 0.110, 'V-28', 0.118,
    'VVT_F2',  -- VVT_F1=Bắc Ninh, VVT_F2=Bắc Giang, VVT_F3=Hà Nam
    GETDATE());
```
> Điều chỉnh giá trị theo đơn giá từ kế toán.

---

### 3.2 Add giá Module (B789 & B791)

```sql
-- Sửa trực tiếp Function fn_VVT_StagePricesMODULE
SELECT OBJECT_DEFINITION(OBJECT_ID('fn_VVT_StagePricesMODULE'))
-- Tìm dòng SELECT → Thêm UNION ALL với Model mới và giá mới
-- Ví dụ:
-- SELECT 'RDMD00-368', '0.254127629071929', '0.257442076659429', '0.258507610420299' UNION ALL ...
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
-- Kiểm tra số lượng hiện tại trong từng bảng
SELECT CurrentQty, InitialQty FROM STB_MaterialLotInfo WHERE LotNo = 'Mã_Lot'
SELECT PackQty FROM STB_SavePackingTime_VVT WHERE LotNo = 'Mã_Lot'

-- Nếu CurrentQty âm → Reset về số lượng đúng
UPDATE STB_MaterialLotInfo
SET CurrentQty = [Số_Lượng_Thực]
WHERE LotNo = 'Mã_Lot'
```

---

## 4. 🔧 Debug Nâng Cao

### 4.1 Tìm màn hình theo TCode

```sql
SELECT Name AS ScreenID, Caption AS ScreenName, TCode
FROM SmartFramework.dbo.STB_ScreenInfo
WHERE Name LIKE '%B597%' OR TCode LIKE '%597%'
```

### 4.2 Tìm Action Button trên màn hình

```sql
SELECT ObjectName, Caption, ObjectType
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName LIKE '%[Tên màn hình]%' AND ObjectType = 'Action'
```

### 4.3 Tìm SP đằng sau 1 nút bấm

```sql
-- Bước 1: Tìm tên màn hình kỹ thuật
SELECT Name AS ScreenID, Caption AS ScreenName
FROM SmartFramework.dbo.STB_ScreenInfo
WHERE Caption LIKE '%B597%'

-- Bước 2: Tìm SP tương ứng
SELECT ScreenName, ObjectName, ObjectType, Description
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName = 'Tên_Màn_Hình_Kỹ_Thuật'
-- SearchFunction: SP nạp dữ liệu vào Grid
-- ExecuteFunction: SP khi nhấn Save/Delete/Process
```

---

## 5. 📊 Màn Hình Báo Cáo & Monitoring

### 5.1 B786 — ESR Monitoring Online

**Tab Online Monitoring:**
- Cột **Status Online**: `OK` = đang lấy dữ liệu, `OFF` = ngừng lấy
- Cột **Mã công ty**: Version phần mềm ESR. Không có = đang chạy version thấp
- Phần mềm ESR mới nhất: `https://192.168.1.234/svn/Document/ESR`
- ESR mới nhất update 2-3 phút/lần (thay vì liên tục) → giảm tải cho SQL bên Hàn

**Tab ESR:** Hiển thị giá trị đo ESR và OCV (Open Circuit Voltage).

---

### 5.2 B934 / B935 — Import Dữ Liệu Máy Phân Cấp Bigsize (ESR AgingSD)

**B934 — Import Data:**

> ⚠️ Hệ thống MES **không hỗ trợ file CSV** → Phải đổi sang `.xlsx` trước khi import.

**Quy trình:**
1. Mở file CSV gốc → **Save As .xlsx**
2. Vào B934 → Nhập `LotNo` + `FileName` → Tìm kiếm
3. Ấn nút **Import Data** → Import Wizard hiện ra
4. Chọn `Source Type: Excel Source` → Chọn file .xlsx → Chọn sheet → OK → Next
5. **Map các cột:** Bảng trái (DB field) ↔ Cột phải (Excel column)
   - **Không chọn** LotNo, FileName
   - Các trường từ CH trở xuống: chọn lần lượt theo thứ tự
6. Next → OK → **Ấn Save** để lưu

**B935 — Xem Lịch Sử Import:**
- Nếu không nhập LotNo → Tìm theo ngày đẩy dữ liệu
- Có thể nhập LotNo hoặc FileName vào ô LotNo đều được

---

### 5.3 FG02 — Tổng Hợp Kho Thành Phẩm (BN + BG)

**Chức năng:** Báo cáo tổng hợp tồn kho thành phẩm cả 2 nhà máy: Bắc Ninh (BN) + Bắc Giang (BG).

| SP | Tab |
|----|-----|
| `usp_VN_SummaryFinishedGood` | Tổng hợp chung |
| `usp_FinishGoodReportTK` | Tab BN — báo cáo tồn kho Bắc Ninh |
| `usp_FinishGoodReportTK_BG` | Tab BG — báo cáo tồn kho Bắc Giang |

**Các cột chính:** TonDauKy, NhapTrongKy, XuatBan, XuatSanXuat, XuatTieuHuy, XuatTraLai, XuatKhac, TonCuoiKy

```sql
-- Bật/tắt thành phẩm xuất excel BG (FG00/FG02)
-- Bắc Giang: usp_VN_Update_ExportExcel_BG
-- Bắc Ninh: usp_VN_Update_ExportExcel

-- Sửa ngày nhập/xuất kho thành phẩm BG
UPDATE STB_VN_FINISHGOODS_BG
SET CreateDate = CAST('2025-01-11' AS DATE),
    DateExport = CAST('2025-01-11' AS DATE)
WHERE IDCODE = 'FGVN_BG20250211054041195484931'
```

*Cập nhật: 2026-05-22*
