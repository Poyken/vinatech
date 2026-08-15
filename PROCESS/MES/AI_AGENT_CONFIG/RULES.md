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

## 🛡️ Quy Tắc Cốt Lõi


> [!CAUTION]
> **1. SELECT-ONLY** — KHÔNG INSERT/UPDATE/DELETE/ALTER/DROP trực tiếp trên production DB.
> **2. Script → User chạy** — Viết SQL fix bọc `BEGIN TRAN...ROLLBACK` → user tự chạy qua SSMS hoặc `deploy_tool.ps1`.
> **3. KNOWLEDGE-FIRST HARD STOP** — CẤM CHẠY SQL QUERY KHI CHƯA TRA KB! Khi nhận báo lỗi, AI BẮT BUỘC phải mở `KB_09_SCREEN_BUG_FIXBOOK.md` hoặc KI `vinatech_bug_fix_patterns` để tra cứu trước. (1) Tra tài liệu RA ➔ Trình bày căn cứ KB & thực hiện SELECT verify tài liệu. (2) Tra tài liệu KHÔNG RA ➔ Báo cáo rõ đã tra KB nhưng chưa thấy & đề xuất câu SELECT khảo sát DB để truy vết.
> **4. TOKEN OPTIMIZATION** — CẤM đọc full file >50KB hoặc `SELECT *` tràn lan! Dùng KI context / `grep_search` đọc đúng đoạn lỗi. Chỉ SELECT đúng 3-5 cột cần verify. Phản hồi chuẩn 3 khối: (1) Root Cause từ KB, (2) SELECT verify ngắn gọn, (3) SQL fix `BEGIN TRAN...ROLLBACK`.
> **5. Hỏi trước khi làm** — Thiếu thông tin hoặc nghi ngờ → dừng hỏi user ngay.
> **6. GOLDEN QUERY FIRST** — BẮT BUỘC DÙNG GOLDEN QUERY TRUY VẾT 360° NGAY LẦN SELECT ĐẦU TIÊN! Khi user đưa mã Barcode/LotNo bất kỳ (Cell, Module, Cuộn cực Slitting, NVL kho), CẤM SELECT đơn lẻ tẻ từng bảng. Bắt buộc dùng Golden Query (Mẫu 1/2/3/4 trong KNOWLEDGE.md §4) ngay ở câu SELECT đầu tiên để quét sạch 100% PO, Routing, Kho, Slitting Stock, Packing trong 1 lần duy nhất!
> **7. IMMEDIATE SCREEN & SP MAPPING** — CẤM CẮM ĐẦU ĐI TÌM LẠI TỪ ĐẦU! Khi user gửi ảnh thiết kế màn hình hoặc nhập Screen ID (VD: B523, B530, B351, B597, F330, C530...), AI BẮT BUỘC tra cứu ngay lập tức từ `screen_id_reference` / `KB_09` để xác định ngay 100%: (1) Tên & Phân hệ màn hình, (2) Search SP (`_get`), (3) Execute SP (`_iud`), (4) Bảng DB chính & UI Grid layout. Cấm tìm kiếm mơ hồ hay hỏi lại thông tin đã có trong KB!
> **8. CẤM CHÈN BẢN GHI GIẢ LẬP (DUMMY)** — CẤM TỰ Ý INSERT/UPDATE dữ liệu suy đoán vào DB sản xuất khi chưa tra cứu chuẩn kiến trúc SoT (`KB_04_01_CORE_PACKAGING.md`). Mọi thao tác fix dữ liệu phải tuân thủ 100% quy trình từ tài liệu SoT!
> **9. CẤM CẮM ĐẦU VÀO SELECT DATABASE** — CẤM CẮM ĐẦU VÀO SELECT DATABASE NGAY KHI NHẬN YÊU CẦU! AI BẮT BUỘC phải đọc và tra cứu tài liệu KB / SoT trước: Nếu tra RA ➔ Trình bày căn cứ KB rồi mới SELECT verify tài liệu; Nếu tra KHÔNG RA ➔ Báo cáo đã tra các tài liệu nào nhưng không có, sau đó mới đề xuất hoặc thực thi SELECT khảo sát DB.
> **10. CẤM TẠO FILE DƯ THỪA & BẮT BUỘC DÙNG FILE CÓ SẴN** — CẤM tự ý tạo các file script test tạm, file SQL rác hay file rác dư thừa trong workspace. BẮT BUỘC chỉ sử dụng các file/công cụ sẵn có trong hệ thống (`query_db.ps1`, `deploy_tool.ps1`, `check_db.ps1`...). Dọn dẹp sạch sẽ nguyên trạng ngay sau khi hoàn thành công việc.



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

