<!--
AI-READY METADATA
Purpose: Hướng dẫn quản trị UI, tạo màn hình mới (Z110/Z220/Z330), phân quyền, đa ngôn ngữ & màn hình B786/B934
Scope: SmartFramework Architecture & UI Management
Single Source of Truth: KB_01_UI_AND_SCREENS.md (Menu & UI Permission Framework)
Target Screens: Login, A460, A419, B260, Z110, Z220, Z330, B682, B781, B789, B791, B786, B934, B935, FG02
Target Tables: SmartFramework.dbo.STB_UserInfo, STB_UserPermission, STB_ScreenInfo, STB_ScreenObjects, STB_StringResources
Related Files:
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/BOOTSTRAP.md)
-->

# KB_01 — UI, Screen Creation & Permission Guide (SmartFramework)

> **Màn hình:** Login, A460, A419, B260, Z110, Z220, Z330, B682, B781, B789, B791, B786, B934, B935, FG02
> **Bảng chính:** `STB_UserInfo`, `STB_UserPermission`, `STB_ScreenInfo`, `STB_ScreenObjects`, `STB_StringResources`
> **🔑 Keywords:** login, đăng nhập, phân quyền, user, permission, screen objects, string resources, Z220, Z330, Z110, screen creation, tạo màn hình
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)


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

### 1.3 [B452] — Whitelist đổi Line sản xuất ()
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

### [Z110] — Bước 1: Khai báo Màn hình mới ( / STB_ScreenInfo)
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

### [Z220]/[Z330] — Bước 3: Phân quyền truy cập ( / )
Để tài khoản người dùng nhìn thấy và sử dụng được màn hình:
1.  **Publish màn hình (Z330):** Đảm bảo cờ `IsPublish = 1` trong `STB_ScreenInfo`.
2.  **Gán quyền cho User (Z220 / STB_UserPermission):**
    ```sql
    INSERT INTO SmartFramework.dbo.STB_UserPermission (UserID, ScreenID, FuncID, Allow)
    VALUES ('tên_user', 'Vietnam_NewScreen', 'ALL', 1); -- Hoặc FuncID = 'Search' / 'Save'
    ```

### Bước 4: Chi tiết cấu hình thuộc tính hàm tìm kiếm (SearchFunction Properties)

Khi cấu hình một đối tượng `SearchFunction` (hàm tìm kiếm dữ liệu dạng `get`) trên giao diện thiết kế NAIS MES, bảng thuộc tính **Property (F4)** bên phải cung cấp các trường thiết lập hoạt động:

*   **Author (Tác giả):** Tên lập trình viên thiết kế hàm (Ví dụ: `Mr.Manh`).
*   **CLR사용 (Sử dụng CLR):** Xác định hàm có gọi đến thư viện .NET CLR được cài đặt dưới SQL Server hay không (`True`/`False`).
*   **CreateDate (Ngày tạo):** Ngày đăng ký Stored Procedure vào màn hình.
*   **Description (Mô tả):** Đoạn văn bản mô tả chức năng nghiệp vụ của hàm (Ví dụ: `Get Sanmina label`).
*   **검색시 동작 (Tự chạy khi load):**
    *   `True`: Hàm tìm kiếm tự động kích hoạt ngay khi mở màn hình (không cần nhấn nút Search).
    *   `False`: Chờ người dùng nhập tham số và click nút Tìm kiếm thủ công.
*   **대상시스템 (Hệ thống đích):** Chỉ định Database Server đích để thực thi câu lệnh (mặc định là `SmartFactory`).
*   **데이터 추가 (Nối tiếp dữ liệu - Append):**
    *   `True` (Append): Dữ liệu tìm kiếm mới sẽ được **thêm nối tiếp** vào cuối lưới đang hiển thị. Nếu dữ liệu có chứa số Serial tự tăng thay đổi theo từng lần tìm kiếm, chế độ này sẽ gây ra lỗi đúp dòng dữ liệu (dup value).
    *   `False` (Clear & Rebind): Lưới sẽ tự động xóa sạch dữ liệu cũ hiển thị trước đó rồi mới nạp dữ liệu mới vào.
*   **데이터셋 (Dataset):** Kiểu đối tượng Dataset trong .NET dùng để nhận cấu trúc dữ liệu trả về từ DB.
*   **데이터셋 포맷 (Định dạng Dataset):** Định dạng truyền nhận dữ liệu giữa Client và Server (Ví dụ: `Xml` hoặc `Json`).
*   **메인함수 (Hàm chính):** Xác định đây có phải là hàm tìm kiếm chính của màn hình này hay không (`True`/`False`).
*   **반환테이블 (Table trả về):** Định nghĩa cấu trúc danh sách các bảng kết quả trả về từ Stored Procedure.
*   **배치처리 맵갯수 (Số map Batch):** Số lượng mapping dữ liệu phục vụ cho xử lý theo lô (Batch Processing).
*   **원본모듈 (Module gốc):** Module chứa định nghĩa hàm gốc (mặc định là `Default`).
*   **이름 (Tên đối tượng):** Tên đặt cho đối tượng hàm hiển thị trên cây giao diện (thường trùng tên SP).
*   **타임아웃(초) (Thời gian chờ):** Thời gian chờ tối đa (giây) trước khi ngắt kết nối và báo lỗi Query Timeout (mặc định là `30` giây).
*   **트랜잭션사용 (Sử dụng Transaction):** Có bọc truy vấn trong Transaction hay không (thường đặt là `False` cho các hàm GET để tránh khóa bảng và tối ưu hóa hiệu suất đọc).
*   **파라미터 (Tham số):** Tập hợp danh sách các tham số đầu vào được ánh xạ từ UI vào Stored Procedure.
*   **파라미터 매핑 (Mapping tham số):** Thiết lập chi tiết cách truyền dữ liệu từ các điều khiển (controls) nhập liệu trên UI vào tham số tương ứng.
*   **함수명 (Tên Stored Procedure):** Tên chính xác của Stored Procedure dưới Database SQL Server (Ví dụ: `usp_SanminaLabelPrint_get_Vietnam`).

### Bước 5: Chi tiết cấu hình tham số đầu vào tìm kiếm (Search Parameters)

Khi nhấn mở thuộc tính **파라미터 (Parameters)** của hàm tìm kiếm, bảng cấu hình tham số hiện ra với các cột điều khiển hành vi hiển thị và nhập liệu:

*   **Name (Tên tham số):** Tên chính xác của tham số đầu vào khai báo trong Stored Procedure dưới SQL Server (Ví dụ: `ProcessUserID`, `PONumber`, `LotNo`).
*   **Caption (Nhãn đa ngôn ngữ):** Nhãn đại diện dùng để ánh xạ đa ngôn ngữ từ bảng `STB_StringResources` (Ví dụ: `^PONumber^`, `^LotNo^`).
*   **Display Text (Nhãn hiển thị):** Nhãn hiển thị thực tế trên giao diện vùng tìm kiếm để người dùng đọc (Ví dụ: `Số lot no`, `Số lượng hoàn thành`, `Số thùng trên pallet`).
*   **Editor Type (Loại điều khiển):** Kiểu ô nhập liệu trên giao diện:
    *   `None`/`TextEdit`: Ô nhập văn bản/số thông thường.
    *   `ComboBox`: Hộp chọn thả xuống (Dropdown list).
    *   `DateEdit`: Ô chọn ngày tháng (Calendar).
*   **Mandatory (Bắt buộc):** Nếu tick chọn, người dùng bắt buộc phải điền thông tin vào ô này thì nút Tìm kiếm mới hoạt động.
*   **Visible (Hiển thị):** Quyết định tham số này có hiển thị trên vùng điều khiển tìm kiếm ở phía trên màn hình hay không.
*   **ReadOnly (Chỉ đọc):** Nếu tick chọn, ô nhập liệu sẽ bị khóa (grey out) và người dùng chỉ có thể xem giá trị mặc định, không thể tự sửa.
*   **New Line (Xuống dòng):** Nếu tick chọn, điều khiển nhập liệu tiếp theo sẽ tự động xuống dòng mới trên UI thiết kế tìm kiếm để căn chỉnh giao diện đẹp hơn.
*   **Default Value Type (Kiểu giá trị mặc định):** Loại nguồn cấp dữ liệu mặc định:
    *   `Const`: Giá trị cố định (Ví dụ: số `1`).
    *   `Session`: Lấy từ thông tin phiên đăng nhập hiện tại (như User ID).
    *   `None`: Không có giá trị mặc định.
*   **Default Value (Giá trị mặc định):** Giá trị cụ thể được điền sẵn khi mở màn hình (Ví dụ: `1` cho tham số `TotalBox`).
*   **Width (Chiều rộng):** Độ rộng hiển thị của ô nhập liệu trên giao diện (tính bằng pixel, Ví dụ: `100`, `120`).
*   **Popup Grid Name (Lưới Popup):** Tên màn hình/lưới popup liên kết để chọn giá trị nâng cao (dùng cho các trường chọn mã phức tạp).
*   **Use Scan (Cho phép quét):** Nếu tick chọn, ô nhập liệu này sẽ được cấu hình để lắng nghe tín hiệu từ máy quét barcode (quét một phát tự điền và tự động kích hoạt tìm kiếm nếu được thiết lập).

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

### 4.1 [B786] — ESR Online Monitoring
*   **Status Online**: `OK` = đang chạy, `OFF` = ngừng lấy dữ liệu.
*   **Update Rate**: Phần mềm ESR mới nhất tự động đẩy dữ liệu đo 2-3 phút/lần về DB để tránh deadlock hệ thống.

### 4.2 [B934] / [B935] — Import dữ liệu Bigsize (ESR AgingSD)
*   **⚠️ Chỉ nhận file Excel:** MES không nhận file `.csv` trực tiếp. Phải mở file CSV và **Save As sang `.xlsx`** trước khi import.
*   **Map cột:** Khi import tại B934, không map cột `LotNo` và `FileName` (hệ thống tự điền), chỉ map các cột dữ liệu điện từ CH trở xuống.

---

## Appendix — Schema Hệ Thống Phân Quyền (SmartFramework)

*   `STB_UserInfo`: Thông tin tài khoản người dùng (`AllowFlag` quản lý trạng thái khóa).
*   `STB_UserPermission`: Phân quyền chi tiết theo User + ScreenID + FuncID.
*   `STB_UserPermissionGroup`: Gán User vào nhóm quyền (`UserType`).
*   `STB_ScreenObjects`: Ánh xạ nút bấm/lưới trên màn hình tới các Stored Procedure tương ứng.
