# 🛡️ SQL SAFETY & PERFORMANCE RULES (VINATECH 15-DATABASE)

## 1. TRANSACTION CONTROLS
- Mọi câu lệnh phân tích hoặc script can thiệp kiểm thử bắt buộc bọc trong khối transaction:
  ```sql
  BEGIN TRANSACTION;
  -- Thao tác kiểm tra
  ROLLBACK TRANSACTION;
  GO
  ```

## 2. ANTI-LOCK & QUERY OPTIMIZATION
- Luôn gắn `WITH(NOLOCK)` trên tất cả các bảng khi SELECT, đặc biệt các bảng giao dịch lớn:
  - `SmartFactoryV2`: `STB_ProdRouteHist`, `STB_SetInfo`, `STB_MaterialStock`
  - `NEOE`: `FI_DOCU_D`, `PU_POL`, `SA_SOL`, `MA_ITEM`
  - `DZICUBE`: `ABDOCU_D`, `ABASSET`
  - `VINATECH_GROUP`: `VINA_DOCUMENT_SAVE`, `VINA_DOCUMENT_POH`
  - `WCMS_STANDARD_NEW`: `WCMS_ACCOUNT_TRNX_LOG`
- **CẤM** dùng `SELECT *` không giới hạn; luôn chỉ định `TOP 50` và danh sách cột cần thiết.

## 3. UNICODE & COLLATION
- Luôn thêm tiền tố `N` cho chuỗi tiếng Việt/tiếng Hàn (ví dụ: `N'Tiếng Việt'`, `N'한글'`).
- Khi join với `erpdb` hoặc trường chuỗi tiếng Hàn, lưu ý Collation `Korean_Wansung_Unicode_CS_AS`.
- Mọi file SQL lưu dưới dạng UTF-8 with BOM (UTF-8-BOM).

## 4. SAFE NULL HANDLING
- Mọi phép tính số học (tiền tệ, số lượng, tỷ giá) bắt buộc bọc `ISNULL(col, 0)`. Không để `NULL` lan truyền làm sai lệch tổng lũy kế.
