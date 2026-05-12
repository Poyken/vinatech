# 🛠️ Quy Trình Điều Tra & Xử Lý Bug (AI Workflow)

Khi nhận được báo cáo lỗi từ User, AI cần thực hiện các bước sau để đảm bảo độ chính xác và an toàn dữ liệu.

## Bước 1: Thu Thập & Xác Định Phạm Vi
- **Yêu cầu User cung cấp:** Mã Barcode (VV...), Mã Lot (ML...), Screen ID (B523, F330...), và nội dung thông báo lỗi.
- **Xác định loại lỗi:** Lỗi dữ liệu (Data), Lỗi hệ thống (NAIS), hay Lỗi logic (SP/Function).

## Bước 2: Truy Vấn Dữ Liệu Gốc (Read-Only)
Sử dụng `MES_DEBUG_SCRIPTS.sql` để kiểm tra:
1. Trạng thái hiện tại của Barcode (`STB_SetInfo`).
2. Lịch sử Routing (`STB_ProdRouteHist`).
3. Log lỗi gần nhất trong `STB_ProcedureLog` hoặc `STB_LogInfo`.

## Bước 3: Phân Tích Nguyên Nhân
- So sánh dữ liệu thực tế với Knowledge Base (`MES_MASTER_KNOWLEDGE_BASE`).
- Nếu liên quan đến Warehouse: Kiểm tra WarehouseCode, LocationCode, Qty.
- Nếu liên quan đến Production: Kiểm tra RouteCode, JobDate, LineCode.

## Bước 4: Đề Xuất Giải Pháp & Backup
- **LUÔN LUÔN** viết câu lệnh `SELECT` để xem dữ liệu sẽ bị ảnh hưởng trước khi viết `UPDATE/DELETE`.
- Tạo script backup nếu cần: `SELECT * INTO [Table_Backup_Date] FROM [Table] WHERE ...`

## Bước 5: Thực Thi & Xác Nhận
- Chạy script sửa lỗi (thường bọc trong `BEGIN TRANSACTION ... ROLLBACK/COMMIT` nếu phức tạp).
- Yêu cầu User kiểm tra lại trên màn hình MES tương ứng.
- **Dọn dẹp:** Xóa các script tạm trong `scratch` và cập nhật kiến thức mới nếu đó là lỗi lạ.

---

> 💡 **Mẹo cho AI:** Luôn đọc file `MES_UNIFIED_DEBUG_MAP.md` trước khi bắt đầu để biết mình đang đối mặt với SP và Table nào.
