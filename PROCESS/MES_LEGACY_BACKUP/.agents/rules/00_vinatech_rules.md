# 🛡️ VINATECH MES AGENT WORKSPACE RULE DEFINITIONS (V2.1)

## QUY TẮC BẮT BUỘC KHÔNG THỂ BỎ QUA:

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB (BẤT BIẾN):**
   - Luôn tra cứu L1 `QUICK_MATRIX.json` qua `.\find_kb.ps1 "<Keyword>"` hoặc module KB trước khi chạy bất kỳ câu lệnh SQL SELECT nào.

2. **RULE 1 - SELECT-ONLY ON PRODUCTION:**
   - Cấm thực thi DML/DDL trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK` và triển khai qua `.\mes.ps1 deploy <file.sql>`.

3. **RULE 4 - SURGICAL RETRIEVAL & L1 CACHE FIRST:**
   - Ưu tiên đọc L1 JSON Matrix (<0.001s, ~150 tokens). Tuyệt đối không đọc tràn lan cả file Markdown >50KB gây nghẽn Context.

4. **RULE 6 - GOLDEN QUERY 360° FIRST:**
   - Dùng `.\mes.ps1 trace "<LotID>"` trong lần kiểm tra đầu tiên khi truy vết Lot/Barcode (quét sạch 4 bảng trong 1 lần duy nhất).

5. **RULE 7 - GIAO THỨC XỬ LÝ KHI USER CUNG CẤP THIẾU THÔNG TIN (UNDERSPECIFIED INPUT):**
   - **Trường hợp User chỉ gõ "check" / "kiểm tra hệ thống":** Tự động kích hoạt `.\mes.ps1 health -Detail` (quét Lot HOLD, WIP 24h, DB Lock) và đưa ra 4 tùy chọn tra cứu nhanh (Trace Lot / Debug Screen / Audit Schema / Inventory). CẤM chạy SELECT mò mẫm tự do.
   - **Trường hợp User chỉ gửi mã Lot nhưng không nêu hiện tượng lỗi:** Chạy ngay `.\mes.ps1 trace "<LotID>"`, xuất bảng tóm tắt 4 trạng thái cốt lõi và hỏi rõ hành động mong muốn (Mở HOLD, Hủy sản lượng, Đổi Model, hay In tem).
   - **Trường hợp User hỏi về phân hệ mở rộng (POP, Sorting, Kế hoạch):** Tự động điều hướng đúng Database Profile (`POP`, `Groupware`, `AndonDB`, `ERP`) qua tham số `-Profile`.

6. **RULE 10 - STANDARD TOOLING & ZERO JUNK FILES:**
   - Sử dụng thống nhất CLI Hub `.\mes.ps1` và dọn dẹp sạch sẽ sau khi hoàn thành.
