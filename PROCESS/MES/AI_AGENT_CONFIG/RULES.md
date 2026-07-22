<!--
AI-READY METADATA
Purpose: Quy tắc bắt buộc không thể vi phạm cho AI Agent khi thao tác trên DB & Workspace MES
Scope: Safety & Execution Rules
Single Source of Truth: RULES.md
Related Files:
  - [BOOTSTRAP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md)
  - [GEMINI.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/GEMINI.md)
  - [db_config.json](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/db_config.json)
-->

# 🛡️ RULES — Vinatech MES Agent (Bắt buộc đọc mỗi phiên)

> **Mục đích:** File này chứa TẤT CẢ quy tắc bắt buộc, nén gọn nhất.
> **Cập nhật:** 2026-07-02

---

## 1. SELECT-ONLY (TUYỆT ĐỐI)

> [!CAUTION]
> **QUY TẮC AN TOÀN SẢN XUẤT NGUYÊN TẮC VÀNG:**
> - ❌ KHÔNG INSERT/UPDATE/DELETE trực tiếp trên production DB.
> - ❌ KHÔNG ALTER/CREATE/DROP bất kỳ object nào (SP, Table, View, Trigger).
> - ✅ CHỈ chạy SELECT (kèm `WITH(NOLOCK)` trên bảng giao dịch).
> - ✅ Viết script sửa đổi → hướng dẫn USER tự chạy qua SSMS hoặc `deploy_tool.ps1`.
> - ✅ Mọi script IUD phải có `BEGIN TRAN ... ROLLBACK` (user đổi COMMIT sau khi xác nhận).


---

## 2. SQL CODING RULES

- Không dùng `SELECT *` → liệt kê cột rõ ràng
- Không dùng Triggers → MES dùng SP chain recursive
- Luôn `WITH(NOLOCK)` trên: `STB_ProdRouteHist`, `STB_MaterialLotInfo`, `STB_SetInfo`, `STB_MaterialDocDetail`
- Dùng PK/ID cụ thể trong WHERE, không dùng điều kiện mơ hồ
- Sửa đồng bộ đủ bảng liên quan (VD: sửa SetInfo phải check MaterialLotInfo)
- **Unicode & Font**: Luôn viết chuỗi Unicode (tiếng Việt có dấu, tiếng Hàn,...) có tiền tố `N` phía trước (ví dụ: `N'Tiếng Việt'`, `N'한글'`).
- **File Encoding**: Mọi file SQL phải lưu dưới dạng mã hóa `UTF-8 with BOM` (UTF-8-BOM) để SSMS và VS Code không bị lỗi font khi đọc/ghi.

---

## 3. WORKFLOW XỬ LÝ BUG

→ Quy trình 7 bước chi tiết: Xem [`BOOTSTRAP.md`](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/AI_AGENT_CONFIG/BOOTSTRAP.md) § WORKFLOW XỬ LÝ BUG

---

## 4. CẤM & HẠN CHẾ

- ❌ Đoán mò — Mọi kết luận phải có SELECT chứng minh (sử dụng `run_query.ps1` để truy vấn nhanh).
- ❌ Ghi nhớ/dùng SP cũ — Luôn query định nghĩa mới nhất từ `sys.sql_modules` hoặc dùng `db_sync_tool.ps1`.
- ❌ Tự ý reformat toàn bộ code/SP — chỉ thực hiện sửa đổi cục bộ (Surgical Changes) tại đúng dòng/khu vực cần thiết để giữ sạch Git diff.
- ❌ Lưu trữ Stored Procedure trên Git — Cấm check-in các file stored procedure (.sql) vào Git. Khi làm việc, AI chỉ được phép tải tạm thời bằng `db_sync_tool.ps1` để phân tích cục bộ và bắt buộc phải xóa/revert các file SQL tạm thời này trước khi thực hiện commit (hoặc chạy nhanh `.\db_sync_tool.ps1 -Clean`).
- ❌ Phức tạp hóa — Ưu tiên sự đơn giản, không tự ý viết thêm các tính năng/tối ưu hóa khi chưa được yêu cầu (Simplicity First).
- ❌ Deploy không validate — Cấm deploy file SQL trực tiếp mà không chạy qua `.\deploy_tool.ps1` (đã tích hợp tự động bộ validate).

---

## 5. KẾT NỐI DB

→ Xem chi tiết cấu hình và thông tin kết nối tại [`db_config.json`](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES/db_config.json)

