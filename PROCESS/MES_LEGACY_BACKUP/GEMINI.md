# 🛡️ VINATECH MES WORKSPACE RULES (MES_LEGACY_BACKUP)

> **Mục đích:** Tự động kích hoạt các quy tắc vận hành bắt buộc ngay khi mở Workspace MES_LEGACY_BACKUP.

## ⛔ QUY TẮC SỐ 0: ZERO SELECT WITHOUT PRIOR KB CONSULTATION (BẤT BIẾN)
- **CẤM TUYỆT ĐỐI** việc cắm đầu chạy lệnh `SELECT` ngay khi vừa nhận Screen ID, mã lỗi, mã Lot hay câu hỏi nghiệp vụ từ người dùng!
- **QUY TRÌNH 4 BƯỚC BẮT BUỘC TRONG MỌI PHẢN HỒI:**
  1. **Bước 1 (Tra cứu KB trước):** Dùng `.\find_kb.ps1 "<Keyword>"` hoặc tra cứu trực tiếp trong `MES_MASTER_KNOWLEDGE_BASE` / `KB_09_SCREEN_BUG_FIXBOOK.md` / `DATABASE_KNOWLEDGE_BASE`.
  2. **Bước 2 (Trích dẫn căn cứ):** Nêu rõ tên file tài liệu, vị trí dòng, Root Cause và giải pháp chuẩn hóa đã được ghi nhận.
  3. **Bước 3 (Kiểm chứng có mục đích):** CHỈ chạy câu lệnh `SELECT` (giới hạn 3-5 cột hoặc dùng `.\mes.ps1 trace <Lot>`) để KIỂM CHỨNG LẠI kết quả đã tìm thấy trong tài liệu trên DB thực tế.
  4. **Bước 4 (Trường hợp KB chưa có):** Nếu tra cứu tài liệu KHÔNG THẤY ➔ AI BẮT BUỘC phải báo cáo rõ danh sách các file KB đã tra cứu nhưng chưa có, sau đó mới được đề xuất câu SELECT khảo sát DB để truy vết.

## ⚡ BỘ CÔNG CỤ ĐIỀU PHỐI VẬN HÀNH HỢP NHẤT:
- `.\mes.ps1 help` : Xem hướng dẫn
- `.\mes.ps1 find "<Keyword>"` : Tra cứu nhanh trong 78+ file KB
- `.\mes.ps1 trace "<LotID>"` : Golden Query 360° quét Lot, Routing, Kho, Thùng
- `.\mes.ps1 screen "<ScreenID>"` : Debug màn hình MES
- `.\mes.ps1 audit` : Audit độ tin cậy tài liệu vs Live DB
- `.\mes.ps1 health` : Morning Health Check
- `.\mes.ps1 new-fix "<Issue>"` : Sinh template SQL Hotfix chuẩn UTF-8-BOM có `BEGIN TRAN...ROLLBACK`
- `.\mes.ps1 deploy <file.sql>` : Deploy SQL kèm Pre-flight Snapshot backup
