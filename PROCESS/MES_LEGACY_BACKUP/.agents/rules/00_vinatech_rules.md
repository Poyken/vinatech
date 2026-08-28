# 🛡️ VINATECH MES AGENT WORKSPACE RULE DEFINITIONS

## QUY TẮC BẮT BUỘC KHÔNG THỂ BỎ QUA:
1. **Rule 0 - Zero Select Without Prior KB:** Luôn tra cứu `find_kb.ps1` hoặc module KB trước khi chạy bất kỳ câu lệnh SQL SELECT nào.
2. **Rule 1 - Select-Only on Production:** Cấm thực thi DML/DDL trực tiếp. Mọi hotfix phải có `BEGIN TRAN...ROLLBACK`.
3. **Rule 4 - Surgical Retrieval:** Không đọc full file >50KB. Đọc đúng 20-40 dòng liên quan.
4. **Rule 6 - Golden Query 360° First:** Dùng `.\mes.ps1 trace` trong lần kiểm tra đầu tiên khi truy vết Lot/Barcode.
5. **Rule 10 - Standard Tooling:** Sử dụng CLI Hub `.\mes.ps1`.
