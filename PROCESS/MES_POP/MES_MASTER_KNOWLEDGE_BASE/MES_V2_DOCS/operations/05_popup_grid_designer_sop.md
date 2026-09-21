# 📖 Hướng Dẫn Chuẩn (SOP) — Tạo Popup Grid & Gán Tham Số Trên SmartFramework Designer UI

> **Mục đích:** Tài liệu hướng dẫn chuẩn từ A đến Z cách tạo một ô chọn danh sách (Popup Grid / Dropdown) trên thanh tìm kiếm của bất kỳ màn hình nào trong hệ thống NAIS MES Vinatech bằng công cụ **SmartFramework Developer**.

---

## 🏗️ 1. Kiến Trúc 2 Tầng Của Popup Grid

Trong SmartFramework MES, một ô chọn danh sách (Popup Grid) bao gồm **2 thành phần độc lập**:

```
[1. SQL Server SmartFactoryV2]
   └── Stored Procedure (usp_..._Popup) ──> Cung cấp dữ liệu (Rows / Columns)
              │
              ▼
[2. SmartFramework Developer UI]
   ├── Object: Popup Grid (F7) ───────────> Đối tượng lưới hiển thị bảng chọn
   └── Object: Screen Layout (Search) ────> Gán tham số EditorType = GridEdit & PopupGridName
```

---

## 🛠️ 2. Quy Trình 4 Bước Tạo Mới Popup Grid Từ UI

### 🔹 BƯỚC 1: Viết Stored Procedure Cung Cấp Dữ Liệu (`SmartFactoryV2`)
Viết SP trả về các cột cần hiển thị. Bắt buộc có ít nhất 1 cột đóng vai trò là **Key** (giá trị được điền vào ô khi user click chọn).

* **Ví dụ mẫu 1 (Danh sách cố định từ UNION - Case Sanmina):**
  ```sql
  CREATE PROCEDURE dbo.usp_SanminaPartNumber_Popup
  AS
  BEGIN
      SET NOCOUNT ON;
      CREATE TABLE #PartList (
          Id INT IDENTITY(1,1),
          PartNumber NVARCHAR(200)
      );
      INSERT INTO #PartList (PartNumber)
      VALUES (N'LFIBE164855'), (N'LFIBLM164855');

      SELECT Id, PartNumber FROM #PartList;
  END
  ```

* **Ví dụ mẫu 2 (Case Mực In Hà Nam - Mr. Triều `SelectedColorMarking_Popup`):**
  ```sql
  CREATE PROCEDURE dbo.usp_SelectedColorMarking_Popup
  AS
  BEGIN
      SET NOCOUNT ON;
      CREATE TABLE #ColorList (ColorId INT IDENTITY(1,1), Color NVARCHAR(200));
      INSERT INTO #ColorList (Color) VALUES (N'Mực đen'), (N'Mực hồng');
      SELECT ColorId, Color FROM #ColorList;
  END
  ```

---

### 🔹 BƯỚC 2: Tạo Đối Tượng Popup Grid Trên SmartFramework Designer

1. Mở **SmartFramework Developer Tool** $\rightarrow$ Nhìn xuống thanh tab dưới cùng:
2. Chọn tab **`Functions(F6)`**:
   * Tìm kiếm tên SP vừa tạo (ví dụ: `usp_SanminaPartNumber_Popup`).
   * **Click đúp chuột** vào SP $\rightarrow$ Bấm **OK** để nạp Function vào Designer.
3. Chuyển sang tab **`Popup Grid(F7)`**:
   * **Click chuột phải vào vùng danh sách** $\rightarrow$ Chọn **`New`** (hoặc `Add`).
   * Cửa sổ thuộc tính của Popup Grid sẽ mở ra.

4. **Thiết lập các thuộc tính trong cửa sổ Popup Grid Editor:**

| Thuộc Tính (Tiếng Hàn) | Tên Tiếng Anh | Giá Trị Cần Điền | Ghi Chú |
| :--- | :--- | :--- | :--- |
| **`이름`** | Name | `SanminaPartNumber_Popup` | Tên định danh duy nhất của Popup |
| **`설명`** | Description | `Chọn Part Number cho khách hàng Sanmina` | Mô tả tiếng Việt |
| **`대상시스템`** | Target System | `SmartFactory` | Luôn chọn SmartFactory |
| **`함수`** | Function | Bấm dấu `+` $\rightarrow$ Chọn SP vừa nạp ở F6 | Nguồn nạp dữ liệu |
| **`키컬럼`** | Key Column | `PartNumber` (hoặc cột giá trị cần lấy) | Cột sẽ điền vào ô tìm kiếm |
| **`컬럼`** | Columns | Bấm `(Collection)` $\rightarrow$ Add các cột cần hiện | Cột hiển thị trên lưới popup |
| **`항상 새로고침`** | Always Refresh | `True` | Luôn query mới khi mở popup |
| **`팝업윈도우 크기`** | Window Size | `300, 250` (hoặc `300, 400`) | Chiều rộng, chiều cao popup |

5. Bấm **OK** $\rightarrow$ Bấm **Save (biểu tượng đĩa mềm / Ctrl+S)** $\rightarrow$ Bấm **Approve**.

---

### 🔹 BƯỚC 3: Gán Popup Grid Vào Thanh Tìm Kiếm Của Màn Hình Chính

1. Mở màn hình cần thêm ô tìm kiếm (Ví dụ: `[B767] In tem KH Sanmina India`).
2. Chọn **Search Function** $\rightarrow$ Mở danh sách tham số (`GUIParameter Collection Editor`).
3. Chọn tham số cần cấu hình (Ví dụ: `PartNumber`):
   * **`편집유형` (EditorType):** Chọn **`GridEdit`** *(Bắt buộc để kích hoạt chế độ Popup)*.
   * **`팝업` (Popup / PopupGridName):** Chọn hoặc gõ tên Popup vừa tạo: **`SanminaPartNumber_Popup`**.
   * **`기본값` (Default Value):** Điền giá trị mặc định ban đầu (Ví dụ: `LFIBLM164855`).
   * **`필수입력` (Mandatory):** Đặt **`True`** *(nếu bắt buộc phải có giá trị, không cho bỏ trống)*.
   * **`너비` (Width):** Đặt từ **`130` – `150`** *(đảm bảo không bị che khuất chữ)*.
   * **`새행시작` (IsNewLine):** Đặt `False` hoặc `True` tùy theo bố cục hàng tìm kiếm.
4. Bấm **OK** $\rightarrow$ Bấm **Save (Ctrl+S)** $\rightarrow$ Bấm **Approve**.

---

### 🔹 BƯỚC 4: Kiểm Tra Thực Tế Trên Màn Hình Vận Hành

1. Đóng Designer và mở màn hình nghiệp vụ trên Menu NAIS System.
2. Kiểm tra các tiêu chí:
   * Ô tìm kiếm xuất hiện đúng vị trí và hiển thị giá trị mặc định.
   * Khi click vào nút Popup / kính lúp ở ô đó, cửa sổ nhỏ bung ra danh sách mã.
   * Click chọn 1 dòng $\rightarrow$ Giá trị tự động điền vào ô tìm kiếm.
   * Bấm **Tìm kiếm** $\rightarrow$ Dữ liệu lọc chính xác theo mã vừa chọn.

---

## ⚠️ 3. Các Lỗi Thường Gặp & Cách Khắc Phục Nhanh

| Hiện Tượng | Nguyên Nhân | Cách Xử Lý |
| :--- | :--- | :--- |
| **Ô hiển thị `[EditValue is null]`** | Đặt `EditorType = ComboBoxEdit` nhưng không có Data Source hoặc `String 소스 = False` | Đổi `EditorType = GridEdit` và gán `PopupGridName` |
| **Không tìm thấy Popup vừa tạo trên F7** | Designer lưu danh sách Popup vào Cache RAM lúc khởi động | Tắt Designer mở lại hoặc gõ trực tiếp tên Popup vào ô `팝업` |
| **Chữ bị đè / tràn sang ô bên cạnh** | Độ rộng `너비` quá nhỏ hoặc label của ô trước quá dài | Tăng `너비` lên `140-150` hoặc bật `새행시작 = True` xuống dòng |
