# 🛡️ 10 QUY TẮC VÀNG BẤT BIẾN — VINATECH DATABASE AGENT

## 1. RULE 0: ZERO SELECT WITHOUT PRIOR KB
- Trước khi chạy bất kỳ câu lệnh `SELECT` nào trên Live DB, **BẮT BUỘC** tra cứu L1 Cache qua `.\db.ps1 find "<Keyword>"` hoặc kiểm tra tài liệu trong `DATABASE_KNOWLEDGE_BASE/`.

## 2. RULE 1: SELECT-ONLY TRÊN TẤT CẢ 15 CƠ SỞ DỮ LIỆU
- Nghiêm cấm chạy bất kỳ câu lệnh DML (`INSERT`, `UPDATE`, `DELETE`, `MERGE`) hoặc DDL (`DROP`, `ALTER`, `TRUNCATE`).
- Mọi script kiểm thử/đề xuất sửa chữa phải bọc trong khối transaction `BEGIN TRAN ... ROLLBACK`.

## 3. RULE 2: ĐÚNG PROFILE CƠ SỞ DỮ LIỆU
- Luôn truyền đúng `-Profile` trong `.\db.ps1` (ví dụ: `-Profile ERP` cho `NEOE`, `-Profile Bizbox` cho `DZICUBE`, `-Profile Groupware` cho `VINATECH_GROUP`).

## 4. RULE 4: SURGICAL RETRIEVAL & L1 FIRST
- Ưu tiên đọc `DATABASE_MATRIX.json` trước để định vị bảng, cột, khóa chính (<0.001s). Chỉ đọc 20-40 dòng cần thiết trong file Markdown KB.

## 5. RULE 5: WITH(NOLOCK) TOÀN DIỆN
- Bắt buộc gắn `WITH(NOLOCK)` sau tên bảng trên mọi câu lệnh `SELECT` để không giữ Shared Lock làm nghẽn giao dịch sản xuất hoặc hạch toán.

## 6. RULE 6: BẢO VỆ PHÉP TOÁN SỐ HỌC (NULL HANDLING)
- Bắt buộc bọc `ISNULL(col, 0)` trên mọi phép tính cộng, trừ, nhân, chia (ví dụ tiền tệ, số lượng, tỷ giá) để tránh giá trị `NULL` làm hỏng tổng lũy kế.

## 7. RULE 7: GIỚI HẠN DÒNG KẾT QUẢ (TOP 50)
- Mọi câu lệnh SELECT khám phá bắt buộc có mệnh đề `TOP 50` hoặc phân trang để tránh tràn RAM và nghẽn băng thông mạng.

## 8. RULE 8: UNICODE TIẾNG VIỆT & TIẾNG HÀN
- Luôn đặt tiền tố `N` trước chuỗi ký tự Unicode: `N'Tiếng Việt'`, `N'한글'`. Khi join với CSDL `erpdb`, chú ý Collation tiếng Hàn.

## 9. RULE 10: ZERO JUNK SCRIPTS
- Không tạo các file `.ps1` rời rạc. Chỉ sử dụng CLI Hub `.\db.ps1`. Các script tạm phải để trong `tools/scratch/` và xóa sạch sau phiên làm việc.

## 10. RULE 14: TỐC ĐỘ PHẢN HỒI (<5-10s)
- Tối đa 1-2 tool calls cho mỗi câu hỏi tra cứu/kiểm tra. Lấy xong data là DỪNG NGAY và trả lời người dùng.

## 11. RULE 15: BẢO VỆ CÁC BẢNG KHỔNG LỒ (MONSTER TABLES GUARD)
- **`STB_VVT_ESRDATA` (423 Triệu rows, 64.8 GB):** CẤM TUYỆT ĐỐI câu lệnh `SELECT` không có điều kiện `id` (ví dụ `WHERE id > ...`). Bảng CHỈ CÓ 1 Clustered Index duy nhất trên `id`. Quét theo ngày hoặc mã máy mà không có `id` sẽ gây Clustered Index Scan toàn bộ 64.8 GB, đóng băng hệ thống nhà xưởng!
- **`STB_ProductStockInfo` (69 Triệu rows, 13.1 GB):** BẮT BUỘC luôn luôn lọc theo `BaseDate` trong mệnh đề `WHERE` (ví dụ `WHERE BaseDate = '...'`). `BaseDate` là cột đứng đầu trong Clustered Index `(BaseDate, ProductStockNo)`. Bỏ quên `BaseDate` sẽ quét qua 69 triệu dòng.
- **`STB_SetInfo` (789K rows, HEAP structure):** Bảng không có Clustered Index (lưu dưới dạng HEAP). Luôn tìm kiếm theo `Barcode`, `LotNumber`, hoặc `DayPlanNo` (là các cột đã có Nonclustered Index). Tránh tìm kiếm theo cột tự do không có chỉ mục.

## 12. RULE 21: BẮT BUỘC DÙNG TOOL CHUYÊN DỤNG — CẤM QUERY DÒ DẪM (ZERO BLIND SQL)
- Bắt buộc dùng `.\db.ps1 [find|schema|sp|lineage|locks]`. Cấm chạy chuỗi SELECT thử sai. Tra cứu qua `DATABASE_MATRIX.json`. Giới hạn 1-2 tool calls.

## 13. RULE 22: ĐỊNH DANH SỰ CỐ (POP BẮT BUỘC GHI POP)
- Tách bạch: `POP` (Kiosk & Web POP) vs `MES` (Core MES Sản Xuất WinForm).

## 14. RULE 23: TIER-0 ENTERPRISE MASTER ORCHESTRATION (ops.ps1 FIRST)
- Điểm tiếp nhận đầu tiên: `ops health` hoặc `ops trace <Mã>`.

## 15. RULE 24: ZERO IRREVERSIBLE HOTFIX (SNAPSHOT & 1-CLICK ROLLBACK)
- Pre-flight Snapshot tự sinh `undo_<Target>.sql`. Hoàn tác bằng `ops rollback -Target <TargetID> -Deploy`.

## 16. RULE 25: WORKSPACE MODULARITY & ZERO ROOT POLLUTION
- Root `PROCESS/` bất khả xâm phạm. Cấm lưu file rác.

## 17. RULE 26: ACTIVE KNOWLEDGE RETENTION & ANTI-DRIFT
- Nghiệm thu xong cập nhật L1 Cache JSON & `hotfix_audit.jsonl`. Định kỳ chạy `ops audit-kb`.

## 18. RULE 27: MULTI-ROOT WORKSPACE SYNCHRONIZATION
- Mở IDE qua `vinatech-enterprise.code-workspace` và tích hợp Universal Root Detection.

## 19. SLASH COMMANDS & LEARNING GOVERNANCE
- `/plan`: Lập kế hoạch chi tiết, chờ duyệt `Proceed` trước khi can thiệp lớn.
- `/learn`: Dạy bài học mới, tự động lưu vào `.agents/rules/02_learned_patterns.md`.
- Sổ tay vận hành: `OPERATOR_COPILOT_GUIDE.md`.

