# ⚡ CHUYÊN ĐỀ 4: HIỆU NĂNG CSDL LỚN, CẤU TRÚC INDEX & CÁC CẠM BẪY CHẾT NGƯỜI

> **Tài liệu tham chiếu chuyên sâu CSDL Vinatech**  
> **Nguồn xác minh:** Truy vấn trực tiếp từ `sys.indexes`, `sys.partitions`, `sys.allocation_units`, và SQL Server DMV `sys.dm_db_missing_index_*` trên máy chủ `dbserver.hycap.co.kr,5398`  
> **Cập nhật ngày:** 21/09/2026

---

## 1. Bảng Xếp Hạng Các Bảng Khổng Lồ (High-Volume Monster Tables)

| Tên Bảng | CSDL | Số Lượng Dòng | Dung Lượng Vật Lý | Cấu Trúc Khóa Chính (PK) | Cấu Trúc Lưu Trữ |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`STB_VVT_ESRDATA`** | `SmartFactoryV2` | **423,056,097 rows** | **64,895 MB (64.8 GB)** | `id` (int, IDENTITY) | **CLUSTERED INDEX** trên duy nhất cột `id`. Không có Index phụ! |
| **`STB_ProductStockInfo`** | `SmartFactoryV2` | **69,378,135 rows** | **13,192 MB (13.1 GB)** | `(BaseDate, ProductStockNo)` | **CLUSTERED INDEX** trên cặp `(BaseDate, ProductStockNo)`. |
| **`STB_CommInspMeasureHist`**| `SmartFactoryV2` | **62,000,134 rows** | **9,450 MB (9.4 GB)** | `MeasureHistNo` | **CLUSTERED INDEX** lưu kết quả đo kiểm chất lượng từng chu kỳ. |
| **`PR_BOM_LOG`** | `NEOE` | **3,948,222 rows** | **1,120 MB (1.1 GB)** | `(CD_COMPANY, CD_ITEM, ...)` | **CLUSTERED INDEX** lưu toàn bộ lịch sử biến động BOM của ERP. |
| **`MA_PITEM_LOG`** | `NEOE` | **2,760,843 rows** | **850 MB** | `(CD_COMPANY, CD_ITEM, ...)` | Lưu vết thay đổi danh mục thông số vật tư. |
| **`VINA_DOCUMENT_APPROVAL_SAVE`** | `VINATECH_GROUP` | **967,141 rows** | **620 MB** | `DOCUMENT_SAVE_CODE` | Bảng lưu trữ toàn bộ văn bản phê duyệt điện tử từ khi thành lập. |
| **`STB_SetInfo`** | `SmartFactoryV2` | **789,798 rows** | **355 MB** | `ControlNo` (NONCLUSTERED) | **HEAP (IndexId = 0)**. Lưu bảng gốc quản lý Lot & Barcode. |

---

## 2. Cạm Bẫy Chết Người Cần Tránh Khi Viết Truy Vấn (Anti-Patterns)

### 🚨 CẠM BẪY 1: Quét Bảng `STB_VVT_ESRDATA` Không Có Điều Kiện `id`
- **Thực tế vật lý:** Bảng này chứa **423 triệu bản ghi đo kiểm siêu tụ điện**, chiếm 64.8 GB trên ổ đĩa. Nó **CHỈ CÓ DUY NHẤT 1 CLUSTERED INDEX** trên cột `id`.
- **Hậu quả:** Nếu bạn viết:
  ```sql
  -- ❌ NGUY CƠ ĐÓNG BĂNG HỆ THỐNG SẢN XUẤT!
  SELECT TOP 50 * 
  FROM STB_VVT_ESRDATA WITH(NOLOCK) 
  WHERE linecode = 'L01' AND inspecttime >= '2026-09-01'
  ```
  SQL Server sẽ buộc phải thực hiện **CLUSTERED INDEX SCAN**, đọc toàn bộ 64.8 GB từ đĩa vào RAM (Buffer Pool), đẩy toàn bộ cache của các bảng bán hàng, kế toán ra ngoài, khiến I/O máy chủ chạm 100% và gây tê liệt xưởng!
- **Đề xuất từ DMV:** SQL Server DMV ghi nhận điểm cải thiện **517,402 điểm** đề xuất bổ sung Index trên `(linecode, inspecttime)` kèm INCLUDE các cột đo kiểm.
- **Quy tắc an toàn tuyệt đối:** Chỉ truy vấn `STB_VVT_ESRDATA` khi lọc trực tiếp theo khoảng `id` (ví dụ `WHERE id > 423000000`) hoặc chỉ lấy `TOP 10` với điều kiện `id` giảm dần.

---

### 🚨 CẠM BẪY 2: Bỏ Quên Cột `BaseDate` Khi Truy Vấn `STB_ProductStockInfo`
- **Thực tế vật lý:** Bảng tồn kho thành phẩm chứa **69.3 triệu bản ghi**. Clustered Index của bảng là `(BaseDate ASC, ProductStockNo ASC)`.
- **Hậu quả:** Cột đứng đầu trong chỉ mục cụm là `BaseDate`. Nếu câu lệnh tìm kiếm theo `MaterialCode` hoặc `PackingID` mà không chỉ định `BaseDate`:
  ```sql
  -- ❌ QUÉT QUA 69 TRIỆU BẢN GHI!
  SELECT * 
  FROM STB_ProductStockInfo WITH(NOLOCK) 
  WHERE MaterialCode = 'ECVT30-260'
  ```
  sẽ dẫn đến Full Scan 13.1 GB dữ liệu!
- **Quy tắc an toàn tuyệt đối:** Luôn truyền ngày cơ sở:
  ```sql
  --  TỐI ƯU VÀ AN TOÀN (INDEX SEEK)
  SELECT TOP 50 * 
  FROM STB_ProductStockInfo WITH(NOLOCK) 
  WHERE BaseDate = '2026-09-20' AND MaterialCode = 'ECVT30-260'
  ```

---

### 🚨 CẠM BẪY 3: Cấu Trúc HEAP Của Bảng `STB_SetInfo`
- **Thực tế vật lý:** Bảng `STB_SetInfo` được thiết kế dưới dạng **HEAP (`IndexId = 0`)**. Khóa chính `ControlNo` là `NONCLUSTERED`.
- **Đặc điểm:** Dữ liệu bản ghi không được sắp xếp vật lý theo thứ tự nào. Khi truy vấn tìm kiếm theo các cột không có Index, SQL Server phải quét toàn bộ RID (Row Identifier).
- **Index hỗ trợ:** Bảng may mắn có các Nonclustered Index độc lập sau:
  - `XS_Barcode` (Tìm theo `Barcode`) -> Rất nhanh!
  - `XS_LotNumber` (Tìm theo `LotNumber`) -> Rất nhanh!
  - `IX_SetInfo_DayPlanNo_Barcode` (Tìm theo `DayPlanNo`, `Barcode`) -> Rất nhanh!
- **Quy tắc:** Luôn dùng `Barcode`, `LotNumber` hoặc `DayPlanNo` trong mệnh đề `WHERE` khi đọc `STB_SetInfo`. Tránh tìm kiếm theo các cột ghi chú hoặc thuộc tính mở rộng không có chỉ mục.
