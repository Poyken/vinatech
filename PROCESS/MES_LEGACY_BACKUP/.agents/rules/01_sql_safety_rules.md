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

