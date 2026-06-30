# 🛡️ RULES — Vinatech MES Agent (Bắt buộc đọc mỗi phiên)

> **Mục đích:** File này chứa TẤT CẢ quy tắc bắt buộc, nén gọn nhất.
> **Cập nhật:** 2026-06-19

---

## 1. SELECT-ONLY (TUYỆT ĐỐI)

- ❌ KHÔNG INSERT/UPDATE/DELETE trực tiếp trên production DB
- ❌ KHÔNG ALTER/CREATE/DROP bất kỳ object nào (SP, Table, View, Trigger)
- ✅ CHỈ chạy SELECT (kèm `WITH(NOLOCK)` trên bảng giao dịch)
- ✅ Viết script sửa đổi → hướng dẫn USER tự chạy qua SSMS
- ✅ Mọi script IUD phải có `BEGIN TRAN ... ROLLBACK` (user đổi COMMIT sau khi xác nhận)

## 2. SQL CODING RULES

- Không dùng `SELECT *` → liệt kê cột rõ ràng
- Không dùng Triggers → MES dùng SP chain recursive
- Luôn `WITH(NOLOCK)` trên: `STB_ProdRouteHist`, `STB_MaterialLotInfo`, `STB_SetInfo`, `STB_MaterialDocDetail`
- Dùng PK/ID cụ thể trong WHERE, không dùng điều kiện mơ hồ
- Sửa đồng bộ đủ bảng liên quan (VD: sửa SetInfo phải check MaterialLotInfo)

## 3. WORKFLOW XỬ LÝ BUG

```
Bước 1: Thu thập — Màn hình? Barcode? Thao tác? Lỗi gì? Ai/Khi nào?
Bước 2: Tra cứu KB cục bộ (BẮT BUỘC TRƯỚC KHI TRUY VẤN DB)
        - Chạy: .\search_kb.ps1 -Query "mã lỗi / TCode / SP / Triệu chứng"
        - Đọc tài liệu màn hình, KB_31 (Bug Fixbook) và HOTFIX_LOG.md trước khi phán đoán.
Bước 3: Xác minh DB — SELECT trạng thái Barcode/Lot bằng tool .\run_query.ps1 để đối chiếu thực tế.
Bước 4: Impact check — KI:deep_system_map (SP callers, table sizes) trước khi sửa
Bước 5: Script Fix — Viết SQL template bọc trong TRANSACTION, kiểm tra an toàn bằng .\validate_sql.ps1
Bước 6: Ghi chép nhật ký — Cập nhật con bug mới vá vào file AI_AGENT_CONFIG/HOTFIX_LOG.md để học hỏi qua thời gian.
Bước 7: Xác nhận & Dọn dẹp — Kiểm tra kết quả, chạy .\db_sync_tool.ps1 -Clean để giữ Git sạch
```

## 4. CẤM & HẠN CHẾ
- ❌ Đoán mò — Mọi kết luận phải có SELECT chứng minh (sử dụng `.\run_query.ps1` để truy vấn nhanh).
- ❌ Ghi nhớ/dùng SP cũ — Luôn query định nghĩa mới nhất từ `sys.sql_modules` hoặc dùng `db_sync_tool.ps1`.
- ❌ Tự ý reformat toàn bộ code/SP — chỉ thực hiện sửa đổi cục bộ (Surgical Changes) tại đúng dòng/khu vực cần thiết để giữ sạch Git diff.
- ❌ Lưu trữ Stored Procedure trên Git — Cấm check-in các file stored procedure (.sql) vào Git. Khi làm việc, AI chỉ được phép tải tạm thời bằng `db_sync_tool.ps1` để phân tích cục bộ và bắt buộc phải xóa/revert các file SQL tạm thời này trước khi thực hiện commit (hoặc chạy nhanh `.\db_sync_tool.ps1 -Clean`).
- ❌ Phức tạp hóa — Ưu tiên sự đơn giản, không tự ý viết thêm các tính năng/tối ưu hóa khi chưa được yêu cầu (Simplicity First).
- ❌ Deploy không validate — Cấm deploy file SQL trực tiếp mà không chạy qua `.\deploy_tool.ps1` (đã tích hợp tự động bộ validate).

## 5. KẾT NỐI DB

| Key | Value |
|-----|-------|
| Server | `dbserver.hycap.co.kr,5398` |
| DB chính | `SmartFactoryV2` |
| DB framework | `SmartFramework` |
| DB file storage | `SmartFramework_File` |
| User | `vinaadmin` |
| Nhà máy | VVT_F1=Bắc Ninh, VVT_F2=Bắc Giang, VVT_F3=Hà Nam, VVT_BG2=Bắc Giang 2 |
