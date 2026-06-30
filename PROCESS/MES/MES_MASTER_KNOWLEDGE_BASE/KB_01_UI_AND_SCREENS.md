# KB_01 — UI, Screen Creation & Permission Guide (SmartFramework)

> **Màn hình:** Login, A460, A419, B260, Z110, Z220, Z330, B682, B781, B789, B791, B786, B934, B935, FG02
> **Bảng chính:** `STB_UserInfo`, `STB_UserPermission`, `STB_ScreenInfo`, `STB_ScreenObjects`, `STB_StringResources`
> **🔑 Keywords:** login, đăng nhập, phân quyền, user, permission, screen objects, string resources, Z220, Z330, Z110, screen creation, tạo màn hình
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🖥️ UI & Đăng nhập

### 1.1 Lỗi không đăng nhập được vào MES
**Triệu chứng:** Màn hình login bị lỗi, không vào được hệ thống NAIS.
**Khắc phục:**
1. **Chạy Update:** Chạy file Update trong folder cài đặt → vào lại NAIS.
2. **Xóa cache:** Xóa thư mục `C:\AwooSystem` → cài lại từ `http://mes.hycap.co.kr:9952/`.
3. **Kiểm tra tài khoản DB:**
   ```sql
   SELECT UserID, UserName, AllowFlag FROM SmartFramework.dbo.STB_UserInfo WHERE UserID = 'tên_user'
   -- AllowFlag = 'Deny' hoặc 0 -> tài khoản bị khóa -> vào Z410 bật lại
   ```

### 1.2 Lỗi không in được tem (Not found label type)
**Triệu chứng:** Nhấn "In Tem" không ra tem và popup báo `"Not found label type"`.
**Khắc phục:**
1. Kiểm tra cấu hình tại **A460** hoặc chạy SQL:
   ```sql
   SELECT ModelCode, LabelType, FormatName FROM STB_ModelLabelInfo WITH(NOLOCK) WHERE ModelCode = 'MÃ_MODEL';
   ```
2. Nếu trả về 0 dòng → Model chưa được map tem. Copy cấu hình từ model cũ cùng loại:
   - `AssembleLabel` dùng cho tem sản xuất (B450/B540).
   - `PartLabel` dùng cho tem kho nguyên vật liệu (F330).
   - `ElectLabel` dùng cho tem điện cực (B442).

### 1.3 Whitelist đổi Line sản xuất (B452)
**Triệu chứng:** Nhân viên báo không đổi được Line trên màn hình B452.
**Khắc phục:** Danh sách User được phép đổi Line được hardcode trực tiếp trong SP `usp_Set_VVT_Info_get`. Sửa SP để bổ sung UserID của nhân viên:
```sql
-- Tìm đoạn: IF @pProcessUserID LIKE '%phuong%' OR @pProcessUserID = 'mrluan'
-- Bổ sung: OR @pProcessUserID = 'UserID_mới'
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Set_VVT_Info_get'))
```

---

## 2. 🛠️ Quy Trình Tạo Màn Hình Mới & Phân Quyền

Hệ thống MES NAIS chạy trên cơ chế **Metadata-Driven**. Giao diện (UI) không chứa logic tĩnh; mọi hành vi (nút bấm, lưới hiển thị, Stored Procedure được gọi) đều được cấu hình dưới DB thông qua metadata.

### Bước 1: Khai báo Màn hình mới (Z110 / STB_ScreenInfo)
Mỗi màn hình mới cần có một định danh (ScreenID/TCode) và tên kỹ thuật (Name).
```sql
INSERT INTO SmartFramework.dbo.STB_ScreenInfo (Name, TCode, Caption, ParentName, IsPublish, CreateDateTime)
VALUES (
    'Vietnam_NewScreen',   -- Tên kỹ thuật của màn hình (Name)
    'B999',                 -- TCode hiển thị trên menu
    N'Màn Hình Mới Của Bạn', -- Tên hiển thị (Caption)
    'Vietnam_MenuRoot',     -- Thư mục menu cha (ParentName)
    1,                      -- IsPublish = 1 để kích hoạt hiển thị
    GETDATE()
);
```

### Bước 2: Liên kết Stored Procedure vào Màn hình (STB_ScreenObjects)
Các nút bấm, lưới dữ liệu (Grid) trên UI giao tiếp với Database qua các SP được khai báo trong `STB_ScreenObjects`:
*   `SearchFunction`: SP load dữ liệu lên lưới (thường có hậu tố `_get`).
*   `ExecuteFunction`: SP thực thi thao tác khi nhấn nút Save/Process/Delete (hậu tố `_iud` hoặc `_uid`).
*   `Action`: Các nút bấm trên giao diện gọi đến `ExecuteFunction`.

```sql
-- 1. Liên kết SP tìm kiếm (Search)
INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectName, ObjectType, Caption)
VALUES ('Vietnam_NewScreen', 'usp_Vietnam_NewScreenData_get', 'SearchFunction', 'Search data');

-- 2. Liên kết SP thực thi (Execute)
INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectName, ObjectType, Caption)
VALUES ('Vietnam_NewScreen', 'usp_Vietnam_NewScreenData_iud', 'ExecuteFunction', 'Execute action');
```

### Bước 3: Phân quyền truy cập (Z220 / Z330)
Để tài khoản người dùng nhìn thấy và sử dụng được màn hình:
1.  **Publish màn hình (Z330):** Đảm bảo cờ `IsPublish = 1` trong `STB_ScreenInfo`.
2.  **Gán quyền cho User (Z220 / STB_UserPermission):**
    ```sql
    INSERT INTO SmartFramework.dbo.STB_UserPermission (UserID, ScreenID, FuncID, Allow)
    VALUES ('tên_user', 'Vietnam_NewScreen', 'ALL', 1); -- Hoặc FuncID = 'Search' / 'Save'
    ```

---

## 3. 💬 Cơ Chế Lỗi Đa Ngôn Ngữ (String Resources)

Mọi thông báo lỗi và popup hiển thị trên Client MES đều xuất phát từ các SP trong Database thông qua bảng `STB_StringResources` của `SmartFramework`.

### Quy trình hiển thị lỗi:
1.  SP trong DB phát hiện lỗi → Gọi `EXEC usp_RaiseLocalizedError @pLanguage, '^Key_Tiếng_Hàn^'`.
2.  Pipeline của `SmartFramework` tìm kiếm `Key_Tiếng_Hàn` trong bảng `STB_StringResources`.
3.  Trả về chuỗi tiếng Việt/tiếng Anh tương ứng → Chạy lệnh `RAISERROR` → Client hiển thị popup.

### Sửa lỗi hiển thị tiếng Hàn (Chưa dịch):
Nếu hệ thống hiện popup tiếng Hàn, nghĩa là thông báo đó chưa được dịch sang tiếng Việt. Sửa bằng cách INSERT bản dịch:
```sql
-- Tìm Key tiếng Hàn gốc của thông báo lỗi
SELECT Name, Value FROM SmartFramework.dbo.STB_StringResources WHERE Name LIKE N'%이미 Lot%' AND Language = 'Default';

-- Thêm bản dịch tiếng Việt
INSERT INTO SmartFramework.dbo.STB_StringResources (Language, Type, Name, Value, ChangeDateTime)
VALUES ('Vietnamese', 'Addon', '^Key_Tiếng_Hàn_Gốc^', N'Lot này đã được tạo trước đó!', GETDATE());
```

---

## 4. 📊 Màn Hình Phụ Trợ Nghiệp Vụ

### 4.1 B786 — ESR Online Monitoring
*   **Status Online**: `OK` = đang chạy, `OFF` = ngừng lấy dữ liệu.
*   **Update Rate**: Phần mềm ESR mới nhất tự động đẩy dữ liệu đo 2-3 phút/lần về DB để tránh deadlock hệ thống.

### 4.2 B934 / B935 — Import dữ liệu Bigsize (ESR AgingSD)
*   **⚠️ Chỉ nhận file Excel:** MES không nhận file `.csv` trực tiếp. Phải mở file CSV và **Save As sang `.xlsx`** trước khi import.
*   **Map cột:** Khi import tại B934, không map cột `LotNo` và `FileName` (hệ thống tự điền), chỉ map các cột dữ liệu điện từ CH trở xuống.

---

## Appendix — Schema Hệ Thống Phân Quyền (SmartFramework)

*   `STB_UserInfo`: Thông tin tài khoản người dùng (`AllowFlag` quản lý trạng thái khóa).
*   `STB_UserPermission`: Phân quyền chi tiết theo User + ScreenID + FuncID.
*   `STB_UserPermissionGroup`: Gán User vào nhóm quyền (`UserType`).
*   `STB_ScreenObjects`: Ánh xạ nút bấm/lưới trên màn hình tới các Stored Procedure tương ứng.
