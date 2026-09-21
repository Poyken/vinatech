# 🛡️ SQL SAFETY & PERFORMANCE RULES (VINATECH MES)

## 1. TRANSACTION CONTROLS
- Mọi script can thiệp dữ liệu (INSERT, UPDATE, DELETE, MERGE) bắt buộc bọc trong transaction block:
  ```sql
  BEGIN TRANSACTION;
  -- Operations
  ROLLBACK TRANSACTION; -- Mặc định ROLLBACK để kiểm thử, chuyển COMMIT khi đã nghiệm thu
  GO
  ```

## 2. ANTI-LOCK & QUERY OPTIMIZATION
- Luôn gắn `WITH(NOLOCK)` khi SELECT trên các bảng giao dịch lớn:
  - `STB_ProdRouteHist`
  - `STB_MaterialLotInfo`
  - `STB_SetInfo`
  - `STB_MaterialDocDetail`
  - `STB_MaterialStock`
- Cấm dùng `SELECT *` trên môi trường Production; chỉ định danh sách 3-5 cột cần thiết.

## 3. UNICODE & FILE ENCODING
- Luôn thêm tiền tố `N` cho chuỗi tiếng Việt/tiếng Hàn (ví dụ: `N'Tiếng Việt'`, `N'한글'`).
- Mọi file SQL phải lưu dưới dạng mã hóa **UTF-8 with BOM** (UTF-8-BOM).

## 4. AUDIT TRAIL & USER ID CONVENTION
- Mọi thao tác UPDATE có cột `ChangeUserID` hoặc `UpdateUserID` **BẮT BUỘC** gán giá trị: `'vanduc'` (theo chỉ đạo của Quản trị viên).

## 5. ARITHMETIC SAFETY & NULL VALUE HANDLING
- Mọi phép tính số học (cộng, trừ, nhân, chia) trên các cột số lượng sản lượng, phế, sửa chữa (ví dụ: `DefectQty`, `RepairQty`, `ProdQty`, `LossQty`, `RemainQty`) **BẮT BUỘC** phải bọc hàm `ISNULL(col, 0)`.
- **Nguyên lý bắt buộc:** Theo chuẩn SQL ANSI, bất kỳ phép tính nào với `NULL` đều cho kết quả `NULL` (`x - NULL = NULL`). Điều này làm trắng toàn bộ ô trên WinForms DataGrid (như màn hình B782, B530, B540) hoặc gây sai lệch tổng lũy kế.
- Ví dụ chuẩn:
  ```sql
  SUM(ISNULL(a.DefectQty, 0)) - SUM(ISNULL(a.RepairQty, 0))
  ```

## 6. POP-MES DUAL-SYNC INTEGRITY RULE
- Khi can thiệp rollback/hủy sản lượng công đoạn đã chốt từ Kiosk POP Web:
  1. Thao tác trên `SmartFactoryV2.dbo.STB_ProdRouteHist`: Xóa bản ghi công đoạn downstream.
  2. Thao tác trên `SmartFactoryV2.dbo.MongoToMesPerformance`: Xóa bản ghi tương ứng (`Barcode`, `RouteCode`) để giải phóng trạng thái hoàn thành (`IsDone = 1`) và mở lại nút chốt sản xuất trên Kiosk.
  3. Cập nhật lại con trỏ công đoạn tại `STB_SetInfo.CurrentRouteCode`.

