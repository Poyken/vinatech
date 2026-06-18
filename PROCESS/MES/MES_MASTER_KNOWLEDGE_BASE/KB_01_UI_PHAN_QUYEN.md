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


4. **Nếu lỗi "Not found label type"** (đặc biệt ở B442 Electrode):
   - Kiểm tra `STB_ModelLabelInfo`:
`sql
SELECT ModelCode, LabelType, FormatName FROM STB_ModelLabelInfo WITH(NOLOCK) WHERE ModelCode = 'MÃ_MODEL';
`
   - Nếu trả về 0 rows → model chưa config tại A460 → copy từ model cũ cùng loại
   - LabelType cần thiết: `ElectLabel` (B442), `AssembleLabel` (B450/B540), `PartLabel` (F330)

> [!TIP]
> **Stack trace chứa `Awoo.SmartFramework...PrintLabel`** → 100% thiếu record trong `STB_ModelLabelInfo`. Xem KB_04 §6.20 và KB_14 §7.2 để debug chi tiết.
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

## 3. 🔧 Debug Nâng Cao

### 3.1 Tìm màn hình theo TCode

```sql
SELECT Name AS ScreenID, Caption AS ScreenName, TCode
FROM SmartFramework.dbo.STB_ScreenInfo
WHERE Name LIKE '%B597%' OR TCode LIKE '%597%'
```

### 3.2 Tìm Action Button trên màn hình

```sql
SELECT ObjectName, Caption, ObjectType
FROM SmartFramework.dbo.STB_ScreenObjects
WHERE ScreenName LIKE '%[Tên màn hình]%' AND ObjectType = 'Action'
```

### 3.3 Tìm SP đằng sau 1 nút bấm

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

## 4. 📊 Màn Hình Báo Cáo & Monitoring

### 4.1 B786 — ESR Monitoring Online

**Tab Online Monitoring:**
- Cột **Status Online**: `OK` = đang lấy dữ liệu, `OFF` = ngừng lấy
- Cột **Mã công ty**: Version phần mềm ESR. Không có = đang chạy version thấp
- Phần mềm ESR mới nhất: `https://192.168.1.234/svn/Document/ESR`
- ESR mới nhất update 2-3 phút/lần (thay vì liên tục) → giảm tải cho SQL bên Hàn

**Tab ESR:** Hiển thị giá trị đo ESR và OCV (Open Circuit Voltage).

---

### 4.2 B934 / B935 — Import Dữ Liệu Máy Phân Cấp Bigsize (ESR AgingSD)

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

### 4.3 FG02 — Tổng Hợp Kho Thành Phẩm (BN + BG)

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

-- 👉 Sửa ngày nhập/xuất kho thành phẩm BG: Xem tại [KB_02_KHO_WMS.md § 8](KB_02_KHO_WMS.md)
```

*Cập nhật: 2026-05-22*


---

## Appendix — Permission System Schema (DB Verified 2026-06-18)

> **Database:** `SmartFramework` — 13 bảng liên quan phân quyền

### Bảng phân quyền cốt lõi:

#### `STB_UserInfo` — Tài khoản user (Z410)
| Cột | Kiểu | Mô tả |
|---|---|---|
| `UserID` | `varchar(20)` | **PK** |
| `Password` | `varbinary(256)` | Mật khẩu hash |
| `AllowFlag` | `varchar(20)` | `Allow` / `Deny` — ⚠️ KHÔNG PHẢI `IsLocked` |
| `IsDeveloper` | `bit` | Cho phép đăng nhập debug |
| `CompanyCode` | `varchar(20)` | `1000`=HQ, `2000`=VN |
| `Appendix8` | `varchar(20)` | **★ ERPUserID** — liên kết sang NEOE |

#### `STB_UserPermission` — Phân quyền chi tiết theo màn hình
| Cột | Kiểu | Mô tả |
|---|---|---|
| `UserID` | `varchar(20)` | FK → STB_UserInfo |
| `ScreenID` | `varchar(10)` | Mã màn hình (B450, C512...) |
| `FuncID` | `varchar(50)` | Chức năng cụ thể (Save, Delete, Print...) |
| `Allow` | `bit` | 1=Cho phép, 0=Chặn |

#### `STB_UserPermissionGroup` — Gán user vào nhóm quyền
| Cột | Kiểu | Mô tả |
|---|---|---|
| `UserID` | `varchar(20)` | FK → STB_UserInfo |
| `UserType` | `varchar(20)` | Mã nhóm quyền |
| `HasPermission` | `bit` | 1=Được gán, 0=Bỏ gán |

#### `STB_ScreenObjects` — Đăng ký SP cho màn hình
| Cột | Kiểu | Mô tả |
|---|---|---|
| `Id` | `bigint` | PK auto |
| `ScreenName` | `varchar(50)` | Tên màn hình (ProductionOrderInfo) |
| `ObjectType` | `varchar(50)` | `ExecuteFunction`, `SearchFunction`, etc. |
| `ObjectName` | `varchar(255)` | **★ Tên SP** (usp_ProductionOrderInfo_get) |
| `Caption` / `Description` | `nvarchar(MAX)` | Mô tả |

### Hệ thống kế thừa quyền (Permission Inheritance):

```
STB_UserType (Nhóm quyền: Admin, Operator, QC...)
    ↓
STB_UserTypeBasicPermission (Quyền mặc định của nhóm)
STB_UserTypeViewPermission  (Quyền xem của nhóm)
STB_UserTypeFunctionPermission (Quyền chức năng của nhóm)
    ↓
STB_UserPermissionGroup (Gán User vào nhóm)
    ↓
STB_UserPermission (Override quyền riêng cho từng User/Screen)
    ↓
STB_UserBasicPermission (Quyền cơ bản của user)
```

### Các bảng phụ trợ:
| Bảng | Mô tả |
|---|---|
| `STB_UserType` | Định nghĩa nhóm quyền |
| `STB_UserTypeBasicPermission` | Quyền mặc định theo nhóm |
| `STB_UserTypeViewPermission` | Quyền xem layout theo nhóm |
| `STB_UserTypeFunctionPermission` | Quyền chức năng theo nhóm |
| `STB_UserBasicPermission` | Quyền cơ bản riêng user |
| `STB_UserFlagUpdateHist` | Lịch sử thay đổi cờ user |
| `STB_UserPermissionGroupChangeHist` | Lịch sử thay đổi nhóm quyền |
| `STB_UserViewLayout` | Layout tuỳ chỉnh theo user |

---

*Cập nhật: 2026-06-18 — Bổ sung Appendix: Permission System Schema 13 bảng + Permission Inheritance chain. DB verified.*

## 🔴 Cẩm nang khắc phục lỗi theo Screen ID (Gộp từ KB_SCREEN_BUG_REF)

## A460 — Label Mapping (Mapping mẫu tem cho Model)

> 🔗 **Xem thêm:** Mục [Z530 / A460](#z530--a460--label-layout--mapping) phía trên đã có chi tiết lỗi in tem.

### Lỗi 1: In tem ra mẫu không đúng hoặc tem trống do chưa map mẫu tem cho Model
*   **Triệu chứng:** In tem tại B523/B754/B757 hiện ra mẫu tem sai hoặc trống thông tin.
*   **Nguyên nhân gốc:** Model chưa được map với mẫu tem tương ứng trong `STB_ModelLabelInfo` tại A460.
*   **Cách khắc phục:**
    ```sql
    SELECT ModelCode, FormatName FROM STB_ModelLabelInfo WHERE ModelCode = 'MÃ_MODEL';
    -- Nếu trống → Vào A460 chọn Model, chọn mẫu tem AssembleLabel (dòng 2) cho SX, PartLabel cho kho.
    ```
*   **Chi tiết nghiệp vụ:** Xem tại [KB_04_DONG_GOI_IN_TEM.md § 6.16](KB_04_DONG_GOI_IN_TEM.md).

---


## Z110 — Screen Configuration (Cấu hình màn hình hệ thống)

### Lỗi 1: Màn hình mới tạo không hiển thị trên menu MES
*   **Triệu chứng:** Đã đăng ký màn hình mới trong `STB_ScreenInfo` nhưng không thấy trên menu.
*   **Nguyên nhân gốc:** Cờ `IsPublish` chưa được bật hoặc chưa gán ParentName (thư mục menu cha).
*   **Cách khắc phục:** Vào Z110, tìm Screen mới, bật `IsPublish = 1`, đảm bảo ParentName đúng thư mục.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_19_ALL_DATABASES_MAP.md § 4](KB_19_ALL_DATABASES_MAP.md#4-kiến-trúc-màn-hình-động-dynamic-ui-registry-của-smartframework).

---


## Z210 — System Parameter (Tham số hệ thống)

### Lỗi 1: Thay đổi tham số hệ thống không có hiệu lực
*   **Triệu chứng:** Sau khi sửa tham số tại Z210, hệ thống vẫn chạy với cấu hình cũ.
*   **Nguyên nhân gốc:** Một số tham số hệ thống được cache và cần restart ứng dụng client để áp dụng.
*   **Cách khắc phục:** Yêu cầu người dùng đóng hoàn toàn ứng dụng MES và mở lại.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_25_VINAENESSOL_HUNG_YEN.md](KB_25_VINAENESSOL_HUNG_YEN.md).

---


## Z220 — Role Screen Mapping (Phân quyền màn hình theo vai trò)

> 🔗 **Xem thêm:** Mục [Z410 / Z220 / Z330](#z410--z220--z330--user-accounts--role-permissions) phía trên đã có chi tiết phân quyền.

### Lỗi 1: Người dùng không thấy màn hình trên menu MES
*   **Triệu chứng:** User đăng nhập nhưng thiếu nhiều màn hình so với đồng nghiệp.
*   **Nguyên nhân gốc:** Role của User chưa được gán quyền truy cập Screen ID tương ứng tại Z220.
*   **Cách khắc phục:** Vào Z220, chọn Role Group, tick chọn Screen ID cần mở quyền.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.4](KB_01_UI_PHAN_QUYEN.md).

---


## Z330 — Screen Publish (Kích hoạt/ẩn màn hình)

> 🔗 **Xem thêm:** Mục [Z410 / Z220 / Z330](#z410--z220--z330--user-accounts--role-permissions) phía trên đã có chi tiết phân quyền.

### Lỗi 1: Màn hình đã gán quyền Z220 nhưng vẫn không hiện trên menu
*   **Triệu chứng:** Đã gán quyền tại Z220 nhưng user vẫn không thấy màn hình.
*   **Nguyên nhân gốc:** Màn hình chưa được publish/kích hoạt tại Z330 (`IsPublish = 0`).
*   **Cách khắc phục:** Vào Z330, tìm Screen ID, bật `IsPublish = 1`.
*   **Chi tiết nghiệp vụ:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.4](KB_01_UI_PHAN_QUYEN.md) và [KB_06_MASTER_DATA_TOOLS.md](KB_06_MASTER_DATA_TOOLS.md).

---
